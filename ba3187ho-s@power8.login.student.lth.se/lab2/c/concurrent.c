// LAB 2:

#include <assert.h>
#include <ctype.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h> // for using the boolean value.
#include <pthread.h> // import the lib for using thread in C
#include <unistd.h> // delay

#define PRINT 0 /* enable/disable prints. */


#if PRINT
#define pr(...)                       \
	do                                \
	{                                 \
		fprintf(stderr, __VA_ARGS__); \
	} while (0)
#else
#define pr(...) /* no effect at all */
#endif

#define MIN(a, b) (((a) <= (b)) ? (a) : (b))

/* introduce names for some structs. a struct is like a class, except
 * it cannot be extended and has no member methods, and everything is
 * public.
 *
 * using typedef like this means we can avoid writing 'struct' in
 * every declaration. no new type is introduded and only a shorter name.
 *
 */

typedef struct graph_t graph_t;
typedef struct node_t node_t;
typedef struct edge_t edge_t;
typedef struct list_t list_t;

struct list_t
{
	edge_t *edge;
	list_t *next;
};

struct node_t
{
	int h;		  /* height.			*/
	int e;		  /* excess flow.			*/
	list_t *edge; /* adjacency list.		*/
	node_t *next; /* with excess preflow.		*/
	pthread_mutex_t node_lock;
};

struct edge_t
{
	node_t *u; /* one of the two nodes.	*/
	node_t *v; /* the other. 			*/
	int f;	   /* flow > 0 if from u to v.	*/
	int c;	   /* capacity.			*/
	pthread_mutex_t edge_lock;
};

struct graph_t
{

	int n;			/* number of nodes.			*/
	int m;			/* number of edges			*/
	node_t *v;		/* pointer to array of n nodes.		*/
	edge_t *e;		/* pointer to array of m edges.		*/
	node_t *s;		/* pointer to the source.			*/
	node_t *t;		/* pointer to the sink.			*/
	node_t *excess; /* nodes with e > 0 except s,t.	*/
	int active_thread;
	pthread_mutex_t graph_lock;
	pthread_cond_t excess_cond;
};

/* a remark about C arrays. the phrase above 'array of n nodes' is using
 * the word 'array' in a general sense for any language. in C an array
 * (i.e., the technical term array in ISO C) is declared as: int x[10],
 * i.e., with [size] but for convenience most people refer to the data
 * in memory as an array here despite the graph_t's v and e members
 * are not strictly arrays. they are pointers. once we have allocated
 * memory for the data in the ''array'' for the pointer, the syntax of
 * using an array or pointer is the same so we can refer to a node with
 *
 * 			g->v[i]
 *
 * where the -> is identical to Java's . in this expression.
 *
 * in summary: just use the v and e as arrays.
 *
 * a difference between C and Java is that in Java you can really not
 * have an array of nodes as we do. instead you need to have an array
 * of node references. in C we can have both arrays and local variables
 * with structs that are not allocated as with Java's new but instead
 * as any basic type such as int.
 *
 */

static char *progname;

#if PRINT

static int id(graph_t *g, node_t *v)  // this function can be used when we want to get index of object.
{
	/* return the node index for v.
	 *
	 * the rest is only for the curious.
	 *
	 * we convert a node pointer to its index by subtracting
	 * v and the array (which is a pointer) with all nodes.
	 *
	 * if p and q are pointers to elements of the same array,
	 * then p - q is the number of elements between p and q.
	 *
	 * we can of course also use q - p which is -(p - q)
	 *
	 * subtracting like this is only valid for pointers to the
	 * same array.
	 *
	 * what happens is a subtract instruction followed by a
	 * divide by the size of the array element.
	 *
	 */

	return v - g->v;
}
#endif

void error(const char *fmt, ...)
{
	/* print error message and exit.
	 *
	 * it can be used as printf with formatting commands such as:
	 *
	 *	error("height is negative %d", v->h);
	 *
	 * the rest is only for the really curious. the va_list
	 * represents a compiler-specific type to handle an unknown
	 * number of arguments for this error function so that they
	 * can be passed to the vsprintf function that prints the
	 * error message to buf which is then printed to stderr.
	 *
	 * the compiler needs to keep track of which parameters are
	 * passed in integer registers, floating point registers, and
	 * which are instead written to the stack.
	 *
	 * avoid ... in performance critical code since it makes
	 * life for optimizing compilers much more difficult. but in
	 * in error functions, they obviously are fine (unless we are
	 * sufficiently paranoid and don't want to risk an error
	 * condition escalate and crash a car or nuclear reactor
	 * instead of doing an even safer shutdown (corrupted memory
	 * can cause even more damage if we trust the stack is in good
	 * shape)).
	 *
	 */

	va_list ap;
	char buf[BUFSIZ];

	va_start(ap, fmt);
	vsprintf(buf, fmt, ap);

	if (progname != NULL)
		fprintf(stderr, "%s: ", progname);

	fprintf(stderr, "error: %s\n", buf);
	exit(1);
}

static int next_int()
{
	int x;
	int c;

	/* this is like Java's nextInt to get the next integer.
	 *
	 * we read the next integer one digit at a time which is
	 * simpler and faster than using the normal function
	 * fscanf that needs to do more work.
	 *
	 * we get the value of a digit character by subtracting '0'
	 * so the character '4' gives '4' - '0' == 4
	 *
	 * it works like this: say the next input is 124
	 * x is first 0, then 1, then 10 + 2, and then 120 + 4.
	 *
	 */

	x = 0;
	while (isdigit(c = getchar()))
		x = 10 * x + c - '0';

	return x;
}

static void *xmalloc(size_t s)
{
	void *p;

	/* allocate s bytes from the heap and check that there was
	 * memory for our request.
	 *
	 * memory from malloc contains garbage except at the beginning
	 * of the program execution when it contains zeroes for
	 * security reasons so that no program should read data written
	 * by a different program and user.
	 *
	 * size_t is an unsigned integer type (printed with %zu and
	 * not %d as for int).
	 *
	 */

	p = malloc(s);

	if (p == NULL)
		error("out of memory: malloc(%zu) failed", s);

	return p;
}

static void *xcalloc(size_t n, size_t s)
{
	void *p;

	p = xmalloc(n * s);

	/* memset sets everything (in this case) to 0. */
	memset(p, 0, n * s);

	/* for the curious: so memset is equivalent to a simple
	 * loop but a call to memset needs less memory, and also
	 * most computers have special instructions to zero cache
	 * blocks which usually are used by memset since it normally
	 * is written in assembler code. note that good compilers
	 * decide themselves whether to use memset or a for-loop
	 * so it often does not matter. for small amounts of memory
	 * such as a few bytes, good compilers will just use a
	 * sequence of store instructions and no call or loop at all.
	 *
	 */

	return p;
}

static void add_edge(node_t *u, edge_t *e)
{
	list_t *p;

	/* allocate memory for a list link and put it first
	 * in the adjacency list of u.
	 *
	 */

	p = xmalloc(sizeof(list_t)); // alocate memory for a new list_t element (p).
								 // the returned value is a pointer to newly allocated list_t struct.
	p->edge = e;				 // set the edge pointer of p to e.
	p->next = u->edge;			 // set the next pointer of p to the first edge of u.
	u->edge = p;				 //	make p is the new head of u's adjacency list.
}

static void connect(node_t *u, node_t *v, int c, edge_t *e)
{
	/* connect two nodes by putting a shared (same object)
	 * in their adjacency lists.
	 *
	 */

	e->u = u; // set 1 endpoint of the edge to u.
	e->v = v; // Set 1 endpoint of the edge to v.
	e->c = c; // set the new capacity connecting 2 nodes.

	add_edge(u, e); // add the edge to u's adjacency list.
	add_edge(v, e); // add the edge to v's adjacency list.
}

static graph_t *new_graph(FILE *in, int n, int m) // return an adress (pointer) to a graph_t object.
{
	graph_t *g; // pointer to a graph_t struct.
	node_t *u;	// pointer to a node_t struct.
	node_t *v;	// pointer to a node_v struct.
	int i;
	int a;
	int b;
	int c;

	g = xmalloc(sizeof(graph_t)); // alocate the memory for the graph structure

	g->n = n;
	g->m = m;
	g->active_thread = 0;			   // for termination
	g->v = xcalloc(n, sizeof(node_t)); // pointer to an array of node_t struct
	g->e = xcalloc(m, sizeof(edge_t)); // pointer to an array of edge_t struct

	for (int i = 0; i < n; i++)
	{
		pthread_mutex_init(&g->v[i].node_lock, NULL); // init the lock for nodes
	}

	for (int i = 0; i < m; i++)
	{ // init the lock for edges.
		pthread_mutex_init(&g->e[i].edge_lock, NULL);
	}

	g->s = &g->v[0];						  // g->s: is a pointer that point to the address of first v element
	g->t = &g->v[n - 1];					  // &g->v[0] the address of the first node
	g->excess = NULL;						  // &g->v[n-1] gets the address of the last element in array v
	pthread_mutex_init(&g->graph_lock, NULL); // init the lock for the whole graph.
	pthread_cond_init(&g->excess_cond, NULL);
	for (i = 0; i < m; i += 1)
	{ // loop through all edges
		a = next_int();
		b = next_int();
		c = next_int();
		u = &g->v[a];
		v = &g->v[b];
		connect(u, v, c, g->e + i); // g->e is a pointer to the first element
	} // g->e+i	is the pointer to the i-th edge
	  // the pointer references inside of edge struct will be added later.
	return g;
}

static void enter_excess(graph_t *g, node_t *v)
{
	/* put v at the front of the list of nodes
	 * that have excess preflow > 0.
	 *
	 * note that for the algorithm, this is just
	 * a set of nodes which has no order but putting it
	 * it first is simplest.
	 *
	 */

	if (v != g->t && v != g->s)
	{ // only the node which not are source or sink, can be added to the excess_list.
		v->next = g->excess;
		g->excess = v;
		pthread_cond_broadcast(&g->excess_cond);
	}
}

static node_t *leave_excess(graph_t *g)
{
	node_t *v;

	/* take any node from the set of nodes with excess preflow
	 * and for simplicity we always take the first.
	 *
	 */

	v = g->excess; // v points at the first elment in the array

	if (v != NULL)
		g->excess = v->next; // make the g->excess points at the next node in the list.

	return v;
}

static void push(graph_t *g, node_t *u, node_t *v, edge_t *e)
{
	int d; /* remaining capacity of the edge. */

	pr("push from %d to %d: ", id(g, u), id(g, v));
	pr("f = %d, c = %d, so ", e->f, e->c);

	if (u == e->u)
	{
		d = MIN(u->e, e->c - e->f); // forward push: limited by the node excess flow and remain capacity.
		e->f += d;
	}
	else
	{
		d = MIN(u->e, e->c + e->f); // backward push: limited by the node excess flow and backward capacity
		e->f -= d;
	}

	pr("pushing %d\n", d);

	u->e -= d;
	v->e += d;

	/* the following are always true. */

	assert(d >= 0);
	assert(u->e >= 0);
	assert(abs(e->f) <= e->c);
	if ((u->e > 0) || (v->e == d))
	{
		pthread_mutex_lock(&g->graph_lock); // lock the entrie graph before
		if (u->e > 0)
		{

			enter_excess(g, u);
		}

		if (v->e == d)
		{

			enter_excess(g, v);
		}
		pthread_mutex_unlock(&g->graph_lock); // lock the entire graph after.
	}
}

static void relabel(graph_t *g, node_t *u)
{
	u->h += 1;

	pr("relabel %d now h = %d\n", id(g, u), u->h);

	pthread_mutex_lock(&g->graph_lock); // lock before entering section for modify excess(task)
	enter_excess(g, u);
	pthread_mutex_unlock(&g->graph_lock); // unlock efter.
}

static node_t *other(node_t *u, edge_t *e)
{
	if (u == e->u)
		return e->v;
	else
		return e->u;
}

bool predicate(graph_t *g)
{
	if (g->excess != NULL)
	{
		return true;
	}
	return false;
}

void *worker_function(void *g)
{
	// TODO: the work function to passed into the thread_create
	list_t *edges;
	node_t *v;
	node_t *u;
	edge_t *e;
	int b;
	bool active_before = false;
	graph_t *graph = (graph_t *)g;
	//printf("from thread \n");
	while (true)
	{

		pthread_mutex_lock(&graph->graph_lock);
		while (!predicate(graph))
		{
			if (active_before){
				graph -> active_thread--;
				active_before = false;
			}
			if (graph->active_thread ==  0){
				pthread_cond_signal(&graph->excess_cond);
				pthread_mutex_unlock(&graph->graph_lock);
				return NULL;
			}
			pthread_cond_wait(&graph->excess_cond, &graph->graph_lock); // based on the value of the predicate
		}
		if(!active_before){
			graph->active_thread++;
			active_before = true;
		}
		
		// to processs															   // the thread would release the lock and wait, or else
		u = leave_excess(graph);
		pthread_mutex_unlock(&graph->graph_lock);

		edges = u->edge;

		while (edges != NULL)
		{					 // loop through all the edges
			e = edges->edge; // get the first edge.
			edges = edges->next;

			if (u == e->u)
			{
				v = e->v; // Forward direction
				b = 1;
			}
			else
			{
				v = e->u; // Backward direction
				b = -1;
			}
			if (u < v)
			{
				pthread_mutex_lock(&u->node_lock);
				pthread_mutex_lock(&v->node_lock);
			}
			else
			{
				pthread_mutex_lock(&v->node_lock);
				pthread_mutex_lock(&u->node_lock);
			}
			if (u->h > v->h && b * e->f < e->c)
			{
				break;
			}
			else
			{
				pthread_mutex_unlock(&v->node_lock);
				pthread_mutex_unlock(&u->node_lock);
				v = NULL;
			}
		}

		if (v != NULL)
		{

			push(g, u, v, e);

			pthread_mutex_unlock(&v->node_lock);
			pthread_mutex_unlock(&u->node_lock);
		}
		else
		{
			pthread_mutex_lock(&u->node_lock);
			relabel(g, u);
			pthread_mutex_unlock(&u->node_lock);
		}
	}

	return NULL;
}

int preflow(graph_t *g)
{
	node_t *s;
	node_t *u;
	node_t *v;
	edge_t *e;
	list_t *p;
	int b;
	int t;
	t = 9; // nbr of thread
	pthread_t thread[t];

	s = g->s;
	s->h = g->n;

	p = s->edge;

	/* start by pushing as much as possible (limited by
	 * the edge capacity) from the source to its neighbors.
	 *
	 */

	while (p != NULL)
	{
		e = p->edge;
		p = p->next;

		s->e += e->c;
		push(g, s, other(s, e), e);
	}

	/* then loop until only s and/or t have excess preflow. */
	for (int i = 0; i < t; i++)
	{
		if (pthread_create(&thread[i], NULL, worker_function, (void *)g) != 0)
		{
			error("pthread_create failed");
		}
	}
	// 	MAIN THREAD MONITORING LOOP
	

	for (int i = 0; i < t; i++)
	{
		if (pthread_join(thread[i], NULL) != 0)
		{
			error("pthread_join failed");
		}
	}


	return g->t->e;
}

static void free_graph(graph_t *g) // this function releases all the memory allocated for the graph
{								   // (using malloc & calloc, etc)
	int i;						   // but never free it using free function, this applied for dynamically
	list_t *p;					   // allocated memory.
	list_t *q;

	for (i = 0; i < g->m; i += 1)
	{
		pthread_mutex_destroy(&g->e[i].edge_lock);
	}

	for (i = 0; i < g->n; i += 1)
	{ // ADD the logic for destroying lock and condtion here.
		p = g->v[i].edge;
		while (p != NULL)
		{
			q = p->next;
			free(p);
			p = q;
		}
		pthread_mutex_destroy(&g->v[i].node_lock);
	}
	pthread_mutex_destroy(&g->graph_lock);
	pthread_cond_destroy(&g->excess_cond);
	free(g->v);
	free(g->e);
	free(g);
}

int main(int argc, char *argv[])
{
	FILE *in;	/* input file set to stdin	*/
	graph_t *g; /* undirected graph. 		*/
	int f;		/* output from preflow.		*/
	int n;		/* number of nodes.		*/
	int m;		/* number of edges.		*/

	progname = argv[0]; /* name is a string in argv[0]. */

	in = stdin; /* same as System.in in Java.	*/

	n = next_int();
	m = next_int();

	/* skip C and P from the 6railwayplanning lab in EDAF05 */
	next_int();
	next_int();

	g = new_graph(in, n, m);

	fclose(in);

	f = preflow(g);

	printf("f = %d\n", f);

	free_graph(g);

	return 0;
}
