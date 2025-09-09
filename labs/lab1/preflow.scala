import scala.util._
import java.util.Scanner
import java.io._
import akka.actor._
import akka.pattern.ask
import akka.util.Timeout
import scala.concurrent.{Await,ExecutionContext,Future,Promise}
import scala.concurrent.duration._
import scala.language.postfixOps
import scala.io._
import math.min
import math.abs

case class Flow(f: Int) // case class for data with parameters
case class Debug(debug: Boolean)
case class Control(control:ActorRef)
case class Source(n: Int)


case object Print // case object for singletons for parameterless messages. 
case object Start
case object Excess
case object Maxflow
case object Sink
case object Hello
case object GetHeight


class Edge(var u: ActorRef, var v: ActorRef, var c: Int) {
	var	f = 0
}

class Node(val index: Int) extends Actor {
	var	e = 0;				/* excess preflow. 						*/
	var	h = 0;				/* height. 							*/
	var	control:ActorRef = null		/* controller to report to when e is zero. 			*/
	var	source:Boolean	= false		/* true if we are the source.					*/
	var	sink:Boolean	= false		/* true if we are the sink.					*/
	var	edge: List[Edge] = Nil		/* adjacency list with edge objects shared with other nodes.	*/
	var	debug = false			/* to enable printing.						*/
	/* 
		index, e , h is attributes (member variables or instance variables), which hold the state of 
		each node object. 
	 */
	def min(a:Int, b:Int) : Int = { if (a < b) a else b }

	def id: String = "@" + index;

	def other(a:Edge, u:ActorRef) : ActorRef = { if (u == a.u) a.v else a.u }

	def status: Unit = { if (debug) println(id + " e = " + e + ", h = " + h) }

	def custom_print (str: String): Unit = 
		{if (debug) println(str +s" mess from ${id}")}
	
	def start_push : Unit = {
		var start_flow = 0;
		for (ed <- edge){
			custom_print("start push to " + ed.v)
			// find repecipent 
			if (ed.u == self){
				ed.f = ed.c
				start_flow += ed.c
				ed.v ! Flow(ed.c)
			}
		}
		//println(s"flow from source from beginning ${start_flow} excess preflow from source ${e} ")
	}

	def enter(func: String): Unit = { if (debug) { println(id + " enters " + func); status } } // helper fuunction for debug
	def exit(func: String): Unit = { if (debug) { println(id + " exits " + func); status } } // helper fuunction for debug

	def relabel : Unit = {

		enter("relabel")

		h += 1

		exit("relabel")
	}

	def receive = {

	case Debug(debug: Boolean)	=> this.debug = debug /* used to set the debug flag to true */

	case Print => status

	case Excess => { sender ! Flow(e) /* send our current excess preflow to actor that asked for it. */ }

	case edge:Edge => { this.edge = edge :: this.edge /* put this edge first in the adjacency-list. */ }

	case Control(control:ActorRef)	=> this.control = control

	case Sink	=> 
		{ 
			sink = true
			custom_print("set to sink ") 
		} 
	// when receiving the message from the controller, indicating the node is a sink
	// the sink attribute sets to true. 

	case Source(n:Int)	=> 
		{ 
			custom_print("set to source")
			h = n; 
			source = true 
		}
	/* while receving this the source flag would be set to true */ 

	case Start => {
		custom_print("start command from controller to " + index)
		if(source){ start_push }
	}

	case Flow(f:Int) =>{
		e += f
		custom_print("update the flow to: " + e)
		//for (e <- edge){
		//	if(e.v == sender || e.u == sender){
		//		e.f += f
				//println(s"flow from edge ${e.u} to ${e.v} to ${e.f}") 	
		//	}
		//}
		if(!source && !sink){ self ! Hello }
		else{
			if (source){
				control ! Source(e)  
			}
		}

	}

	case GetHeight =>{
		sender ! h // send back the current height. 
	}

	case Hello =>{
		if (e > 0 && !sink){
			var pushSuccessful = false
			for (ed <- edge if!pushSuccessful ){
				if (ed.u == self && ed.c > ed.f){
					implicit val timeout = Timeout(10.seconds)
					var heightFuture = ed.v ? GetHeight
					var height = Await.result(heightFuture, timeout.duration).asInstanceOf[Int]
					if (h > height){
						var flowToPush = min(e, ed.c - ed.f)
						e -= flowToPush
						ed.f += flowToPush
						//println(s"push from ${index} with flow ${flowToPush}")   
						ed.v ! Flow(flowToPush)
						self ! Hello
						pushSuccessful = true
					}
				}
				else if (ed.v == self && ed.f > 0){
					implicit val timeout = Timeout(10.seconds)
					var heightFuture = ed.u ? GetHeight
					var height = Await.result(heightFuture, timeout.duration).asInstanceOf[Int]
					if (h > height){
						var flowToBack = min(e, ed.f)
						e -= flowToBack
						//println(s"before update ${ed.f}")
						ed.f = ed.f - flowToBack
						//println(s"push back from ${index} with flow ${ed.f}")   
						ed.u ! Flow(-ed.f)
						self ! Hello
						pushSuccessful = true
					}
				}

			}
			if(pushSuccessful){
				if (e > 0){
					self ! Hello
				}
			}else{
				relabel
				self ! Hello
			}
		}
	} 
	
	case _		=> {
		println("" + index + " received an unknown message" + _) }

		assert(false)
	}

}


class Preflow extends Actor
{
	var	s	= 0;			/* index of source node.					*/
	var	t	= 0;			/* index of sink node.					*/
	var	n	= 0;            /* number of vertices in the graph.				*/
	var	edge:Array[Edge]	= null	/* edges in the graph.						*/
	var	node:Array[ActorRef]	= null	/* vertices in the graph.					*/
	var	ret:ActorRef 		= null	/* Actor to send result to.					*/

	def receive = {

	case node:Array[ActorRef]	=> {
		this.node = node
		n = node.size
		s = 0
		t = n-1
		for (u <- node){
			u ! Control(self)
			//u ! Debug(true)
		}	
			
		// impl for setting the source, sink

		node(s) ! Source(n) // note: use node(index) for array access.
		node(t) ! Sink

		for (u <- node){
			u ! Start
		}
		
	}
	/* 
		Receives the array of node actors, stores it n,s,t, tells each node who thee controller is.
	 */

	case edge:Array[Edge] => this.edge = edge
	/* 
		receive the array of edges and stores it
	 */

	case Flow(f:Int) => {
		ret ! f			/* somebody (hopefully the sink) told us its current excess preflow. */
	
	}
	/* 
		recive the flow value (from the sink node), and sends it to actor stored in ret

	 */

	case Maxflow => {
		ret = sender

		
		//node(t) ! Excess	/* ask sink for its excess preflow (which certainly still is zero). */
	}
	
	case Source(n:Int) =>{
		var fromSource = abs(n);
		implicit val timeout = Timeout(2.seconds)
		val sinkFuture = node(t) ? Excess
		val sinkResult = Await.result(sinkFuture, timeout.duration)
    	val sinkExess = sinkResult match {
      		case Flow(f) => f
      		case i: Int => i
      		case _ => throw new Exception("Unexpected message type for sink excess")
    	}

		if (fromSource == sinkExess && ret != null){
			ret ! sinkExess
		} 
		
	}
		
	

	}
}

object main extends App {
	implicit val t = Timeout(30	.seconds);

	val	begin = System.currentTimeMillis()
	val system = ActorSystem("Main")
	val control = system.actorOf(Props[Preflow], name = "control")

	var	n = 0;
	var	m = 0;
	var	edge: Array[Edge] = null
	var	node: Array[ActorRef] = null

	val	s = new Scanner(System.in);

	n = s.nextInt
	m = s.nextInt

	/* next ignore c and p from 6railwayplanning */
	s.nextInt
	s.nextInt

	node = new Array[ActorRef](n)

	for (i <- 0 to n-1)
		node(i) = system.actorOf(Props(new Node(i)), name = "v" + i)
	// create node
	edge = new Array[Edge](m)
	// create edges
	for (i <- 0 to m-1) {

		val u = s.nextInt
		val v = s.nextInt
		val c = s.nextInt

		edge(i) = new Edge(node(u), node(v), c)

		node(u) ! edge(i)
		node(v) ! edge(i)
	}

	control ! node // "fire-and-forget" message, sends the array of node actors to Preflow actor
	control ! edge // the message is delivered and processed whenever the receiver is ready.

	val flow = control ? Maxflow 
	/*
		Asynchronous "ask" pattern (request-response)
		Sends Maxflow message to the Preflow actor and expects a reply.  
	*/
	val f = Await.result(flow, t.duration)

	println(f)

	system.stop(control);
	system.terminate()

	val	end = System.currentTimeMillis()

	//println("t = " + (end - begin) / 1000.0 + " s")
}
