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
import scala.concurrent.ExecutionContext.Implicits.global

case class Flow(f: Int) // case class for data with parameters
case class Debug(debug: Boolean)
case class Control(control:ActorRef)
case class Source(n: Int) // send to the source node, and inform the height the source would have. 
case class IncomingFlow(n: Int) // flow was sent by source
case class OutgoingFlow(n: Int) // flow was received by sink  
case class PushRequest(node: Int, edge : Edge, flow: Int, height: Int)
case class Reject(flow: Int, edge: Edge)
case class Done(status: Boolean)

case object Print // case object for singletons for parameterless messages. 
case object Start
case object Excess
case object Maxflow
case object Sink
case object Hello
case object Accept
case object GetHeight
case object IsDone


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
	var	debug = false			/* to enable printing. */
	var pushRequest = 0
	var listIndex = 0 						
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
			 
			if (ed.u == self){ // forward-push from start
			custom_print("start to push to " + ed.v)
				ed.f = ed.c
				e -= ed.c
				ed.v ! PushRequest(index, ed, ed.c, h)
				pushRequest += 1
			}
			else{
				ed.f = ed.c 
				e -= ed.c
				ed.u ! PushRequest(index, ed, ed.c, h)
				pushRequest +=1
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
	
	def pushToNeighbours() : Unit ={
		if(pushRequest > 0) return // wait until the excess flow updated correctly (the last accept or reject)			 
		if (!sink && !source && e > 0){
			if (listIndex == edge.length ) {
				listIndex = 0
				relabel
			}
			//var second_loop = listIndex
			for(i <- listIndex until edge.length){
				if (e == 0){
					return
				}
				var currentEdge = edge(i);
				if (currentEdge.u == self && currentEdge.f < currentEdge.c ){ // forward-push 
					var flowToPush = min(e, currentEdge.c - currentEdge.f)
					e -= flowToPush
					currentEdge.f += flowToPush
					currentEdge.v ! PushRequest(index, currentEdge, flowToPush, h)
					pushRequest += 1
					 
				} 
				else if(currentEdge.v == self ){ // backward-push 
					var flowToPushBack = min(e, currentEdge.f + currentEdge.c)
					e -= flowToPushBack	
					currentEdge.f -= flowToPushBack
					currentEdge.u ! PushRequest(index, currentEdge, flowToPushBack, h)
					pushRequest += 1
					
				}
				listIndex +=1	 
			}
			 
		}
		if (!sink && ! source && e > 0 ) pushToNeighbours // after the loop, if the are still excess preflow left
		
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
			start_push
		}
	/* while receving this the source flag would be set to true */ 

	case PushRequest(node: Int, edge : Edge, flow: Int, height: Int) => {
		custom_print("get push request from "  +id )
		var sender = other(edge, self)
		if (height > h){
			e += flow
			sender ! Accept
			if (sink) control ! OutgoingFlow(e)
			if (source) control ! IncomingFlow(e)
		}
		else{
			sender ! Reject(flow,edge)
		}
		
		if(!sink && ! source) pushToNeighbours

	} 

	case Accept => {
		custom_print("push acepted " + id)
		pushRequest -= 1
		pushToNeighbours
		
		if(source){
			control ! IncomingFlow(e)
		}
	}

	case Reject(flow: Int, edge: Edge) => {
		custom_print("push rejected " + id)
		pushRequest -= 1
		e += flow
		if (edge.u == sender){
				edge.f += flow // forward-push request
			}
		else{
			edge.f -= flow // backward-push request
		}
		
		pushToNeighbours
	}

	case IsDone =>{
		custom_print("get finish request from controller, current flow: " +e)
		if (e == 0){
			control ! Done(true)
		}else if(e > 0){
			control ! Done(false)
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
	var incommingFlow = 0;
	var outgoingFlow = 0;
	var counter = 0 

	def sendFinishRequestToNodes{
		for (i <- 1 until node.length -1 ){ // the Finnish request sends to all the nodes, except sink and source 
			node(i) ! IsDone
		}
	}

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

		node(t) ! Sink
		node(s) ! Source(n) // note: use node(index) for array access.
		//node(s) ! Start
		
	}
	/* 
		Receives the array of node actors, stores it n,s,t, tells each node who thee controller is.
	 */

	case edge:Array[Edge] => this.edge = edge
	/* 
		receive the array of edges and stores it
	 */

	
	/* 
		recive the flow value (from the sink node), and sends it to actor stored in ret

	 */

	case Maxflow => {
		ret = sender
		//node(t) ! Excess	/* ask sink for its excess preflow (which certainly still is zero). */
	}
	
	case IncomingFlow(flow: Int) => {
		//println("get flow from source " + flow)
		incommingFlow = abs(flow)
		if (incommingFlow == outgoingFlow){
			sendFinishRequestToNodes
		}
	}

	case OutgoingFlow(flow: Int) => {
		//println("get flow from sink " + flow)
		outgoingFlow = flow
		if(outgoingFlow == incommingFlow){
			sendFinishRequestToNodes
		}
	}
	
	case Done(status : Boolean) =>{
		//println("Controller get feedback from IsDone request: " + status)
		if (status){
			counter += 1 
			if (counter == (node.length - 2)){ // all nodes (exclusive source and sink ) have no excess flow left.
				ret ! outgoingFlow
			}
		}else{
			counter = 0 // wait for next update from sink or source
		}
	}
		
	

	}
}

object main extends App {
	implicit val t = Timeout(160.seconds);

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

	//println(s"node ${n} nbr edges ${m} ")
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
		
		//println(s"edge from ${u} to ${v} capacity ${c}")
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
