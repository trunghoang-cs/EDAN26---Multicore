
import java.io.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.locks.*;



class Node {
    int index;
    int h;              // height
    int e;              // excess flow
    List<Edge> edge;      // adjacency list
    ReentrantLock nodeLock;
    
    Node(int index) {
        this.index = index;
        this.h = 0;
        this.e = 0;
        this.edge = new ArrayList<>();
        this.nodeLock = new ReentrantLock();
    }
}

class Edge {
    Node u;             // one of the two nodes
    Node v;             // the other
    int f;              // flow > 0 if from u to v
    int c;              // capacity
    ReentrantLock edgeLock;
    
    Edge() {
        this.f = 0;
        this.edgeLock = new ReentrantLock();
    }
}

class Graph {
    int n;                      // number of nodes
    int m;                      // number of edges
    Node[] v;                   // array of n nodes
    Edge[] e;                   // array of m edges
    Node s;                     // pointer to the source
    Node t;                     // pointer to the sink
    LinkedList<Node> excess;                // nodes with e > 0 except s,t
    int activeThread;
    ReentrantLock graphLock;
    Condition excessCond;
    
    Graph(int n, int m) {
        this.n = n;
        this.m = m;
        this.activeThread = 0;
        this.v = new Node[n];
        this.e = new Edge[m];
        
        // Initialize nodes
        for (int i = 0; i < n; i++) {
            this.v[i] = new Node(i);
        }
        
        // Initialize edges
        for (int i = 0; i < m; i++) {
            this.e[i] = new Edge();
        }
        
        this.s = this.v[0];         // source is first node
        this.t = this.v[n - 1];     // sink is last node
        this.excess = new LinkedList<>();
        this.graphLock = new ReentrantLock();
        this.excessCond = this.graphLock.newCondition();
    }
}

class WorkerThread implements Runnable {
    private Graph g;
    
    WorkerThread(Graph g) {
        this.g = g;
    }
    
    @Override
    public void run() {
        boolean active_before = false;
        while (true){
            g.graphLock.lock();
            while(predicate(g)){
                if(active_before){
                    g.activeThread --;
                    active_before = false;
                }
                if(g.activeThread == 0){
                    g.excessCond.signal();
                    g.graphLock.unlock();
                    return;
                }
                try{
                    g.excessCond.await();                       // try to make the thread sleep.
                } catch (InterruptedException e){
                    Thread.currentThread().interrupt();        // catch error.
                    return;
                }
            }
            if (!active_before){
                g.activeThread ++;                              // update counter.
                active_before = true;                           
            }
            Node u = leaveExcess(g);                            // get new Node.
            g.graphLock.unlock();

            List<Edge> edges = u.edge;                          // get the list of edges for the current node.
            
            Node v = null;                                      // Variable Node v, connected through edge ed
            Edge e = null;
            int b;
            
            for(Edge ed : edges){
                e = ed;
                if (u.index == ed.u.index){
                    v = ed.v;
                    b = 1;
                }else{
                    v = ed.u;
                    b = -1;
                }
                if (u.index < v.index){
                    u.nodeLock.lock();
                    v.nodeLock.lock();
                }
                else{
                    v.nodeLock.lock();
                    u.nodeLock.lock();
                }
                if((u.h > v.h) && (b * ed.f < ed.c)){
                    break;
                }
                else{
                    v.nodeLock.unlock();
                    u.nodeLock.unlock();
                    v = null;
                }
            }
            if (v != null){
                push(g, u, v, e);
                u.nodeLock.unlock();
                v.nodeLock.unlock();
            }else{
                u.nodeLock.lock();
                relabel(g, u);
                u.nodeLock.unlock();
            }
        }
    }
    
    private boolean predicate(Graph g) {
        return g.excess.isEmpty();       
    }
    
    private Node leaveExcess(Graph g) {
        if (g.excess.isEmpty()) return null;
        return g.excess.removeFirst();                     //return first element
    }
    
    private void push(Graph g, Node u, Node v, Edge e) {
        int d; // remaining capacity of the edge
        
        if (u == e.u) {
            d = Math.min(u.e, e.c - e.f);  // forward push
            e.f += d;
        } else {
            d = Math.min(u.e, e.c + e.f);  // backward push
            e.f -= d;
        }
        
        u.e -= d;
        v.e += d;
        
        // Add nodes with excess to the excess list
        if (u.e > 0 || v.e == d) {
            g.graphLock.lock();
            try {
                if (u.e > 0) {
                    enterExcess(g, u);
                }
                if (v.e == d) {
                    enterExcess(g, v);
                }
            } finally {
                g.graphLock.unlock();
            }
        }
    }
    
    private void relabel(Graph g, Node u) {
        u.h += 1;
        
        g.graphLock.lock();
        try {
            enterExcess(g, u);
        } finally {
            g.graphLock.unlock();
        }
    }
    
    private void enterExcess(Graph g, Node v) {
        if (v.index != g.t.index && v.index != g.s.index) {
            g.excess.addLast(v);
            g.excessCond.signalAll();
        }
    }
}

public class MaxFlowPushRelabel {
    
    private static void addEdge(Node u, Edge e) {
        u.edge.add(e);
    }
    
    private static void connect(Node u, Node v, int c, Edge e) {
        e.u = u;
        e.v = v;
        e.c = c;
        
        addEdge(u, e);
        addEdge(v, e);
    }
    
    private static Graph newGraph(Scanner in, int n, int m) {
        Graph g = new Graph(n, m);
        
        for (int i = 0; i < m; i++) {
            int a = in.nextInt();
            int b = in.nextInt();
            int c = in.nextInt();
            
            Node u = g.v[a];
            Node v = g.v[b];
            connect(u, v, c, g.e[i]);
        }
        
        return g;
    }
    
    private static Node other(Node u, Edge e) {
        if (u == e.u) {
            return e.v;
        } else {
            return e.u;
        }
    }
    
    private static void enterExcess(Graph g, Node v) {
        if (v != g.t && v != g.s) {
            g.excess.addLast(v);
            g.excessCond.signalAll();
        }
    }
    
    private static void push(Graph g, Node u, Node v, Edge e) {
        int d; // remaining capacity of the edge
        
        if (u == e.u) {
            d = Math.min(u.e, e.c - e.f);  // forward push
            e.f += d;
        } else {
            d = Math.min(u.e, e.c + e.f);  // backward push
            e.f -= d;
        }
        
        u.e -= d;
        v.e += d;
        
        // Add nodes with excess to the excess list
        if (u.e > 0 || v.e == d) {
            g.graphLock.lock();
            try {
                if (u.e > 0) {
                    enterExcess(g, u);
                }
                if (v.e == d) {
                    enterExcess(g, v);
                }
            } finally {
                g.graphLock.unlock();
            }
        }
    }
    
    private static int preflow(Graph g) throws InterruptedException {
        Node s = g.s;
        s.h = g.n;
        
        List<Edge> edges = g.s.edge;
        
        // Initial push from source. 
        for(Edge e : edges) {                 // loop through all edges conected to source, perform a push.
            s.e += e.c;
            push(g, s, other(s, e), e);      // perform push
        }
        
        // Create and start worker threads
        int t = 9; // number of threads
        Thread[] threads = new Thread[t];
        
        for (int i = 0; i < t; i++) {
            threads[i] = new Thread(new WorkerThread(g));
            threads[i].start();
        }
        
        // Wait for all threads to complete
        for (int i = 0; i < t; i++) {
            threads[i].join();
        }
        
        return g.t.e;
    }
    
    public static void main(String[] args) throws InterruptedException {
        Scanner scanner = new Scanner(System.in);
        
        int n = scanner.nextInt();
        int m = scanner.nextInt();
        
        // Skip C and P (as in original code)
        scanner.nextInt();
        scanner.nextInt();
        
        Graph g = newGraph(scanner, n, m);
        
        int f = preflow(g);
        
        System.out.println("f = " + f);
        
        scanner.close();
    }
}
