package contingutsMultimedia {

	/*
	Author: MarcP
	Implementation of A* (a-star) algorithm on AS3 for Continguts Multimedia (Pacman project)
	See more at http://en.wikipedia.org/wiki/A*_search_algorithm
	*/
	
	import flash.geom.Point;
	import contingutsMultimedia.Mapa;
	import contingutsMultimedia.Node;

	public class AStar{

		private var _map:Mapa;
		private var _nodes:Array;

		// Not fully searched nodes
		private var _openNodes:Array;
		
		// Fully searched nodes
		private var _closedNodes:Array;

		public function AStar(map:Mapa){
			_map = map;

			// Initialize nodes
			var mSize:Point = map.getMapSize();
			var h:uint = 0;
			var w:uint = 0;
			_nodes = new Array();
			trace(mSize);
			for(w = 0; w < mSize.x; w++){
				_nodes[w] = new Array();
				for(h = 0; h < mSize.y; h++){
					_nodes[w][h] = new Node(w,h);
					
				}
			}
		}

		public function findPath(start:Point, target:Point):Array{

			// Clear searched list and add first node
			_openNodes = new Array();
			_closedNodes = new Array();
			_openNodes.push(_nodes[start.x][start.y]);

			// Set parent node 
			_nodes[target.x][target.y].parent = null;

			// Initialize nodes
			var currentNode:Node = _nodes[start.x][start.y];
			var targetNode:Node = _nodes[target.x][target.y];		

			// Initialize start node
			currentNode.setTravelCost(0);
			currentNode.setHeuristicCost(this.getCost(currentNode, targetNode));
			currentNode.setDepth(0);

			while(currentNode != targetNode && _openNodes.length != 0){

				var  neighbours:Array = this.getNeighbours(currentNode);
				var currentMix =  (currentNode.getTravelCost() + 1) + this.getCost(currentNode, targetNode);
				
				// Check all neighbours from nodes
				for(var i:uint = 0; i < neighbours.length; i++){
					//trace("Neighbour <"+ i +"/"+(neighbours.length-1)+">  "+ neighbours[i].getX()+"  "+ neighbours[i].getY())
					
					// Current node is not a Wall or something we cant pass thru
					if( _map.checkTransversable(neighbours[i].getX(),neighbours[i].getY()) ){
						continue;
					}

					// Calculate current neighbour cost
					var trCost = currentNode.getTravelCost() + 1;
					var heCost = this.getCost(neighbours[i], targetNode);
					var mixCost = trCost + heCost;
	
					if( this.isOpen(neighbours[i]) || this.isClosed(neighbours[i]) ){
							var currN = neighbours[i].getTravelCost() + neighbours[i].getHeuristicCost();
						
						if( currN > currentMix){
							neighbours[i].setTravelCost( trCost );
							neighbours[i].setHeuristicCost( heCost );
							neighbours[i].setParent(currentNode);
						}

					}else{
						//trace("Adding to open list");
						neighbours[i].setTravelCost( trCost );
						neighbours[i].setHeuristicCost( heCost );
						neighbours[i].setParent(currentNode);
						_openNodes.push(neighbours[i]);					
					}
				}

				// This node is now scanned, close it
				_closedNodes.push(currentNode);
				// Sort open nodes by cost and get new current node
				_openNodes.sortOn('_costHeuristic', Array.NUMERIC);
				currentNode = _openNodes.shift() as Node;
			}

			return this.buildPath(_nodes[start.x][start.y],targetNode);

		}

		// Build final path
		public function buildPath(start:Node, target:Node):Array {			
			var path:Array = [];
			var node:Node = target;
			path.push(node);
			var i = 0;
			while (node != start) {
				node = node.parent;
				path.unshift( node );
				i++;
			}
			return path;			
		}


		// Get 4 Nearest neighbours
		public function getNeighbours(n:Node){
			var connectedNodes:Array = [];
			var neighboursIndex:Array = [[0,-1],[-1, 0],[1, 0],[0, 1]];
			var _x = n.getX();
			var _y = n.getY();
			var _sizeM:Point = _map.getMapSize();

			for (var i:int = 0; i < neighboursIndex.length; i++){

				var _currX = _x + neighboursIndex[i][0];
				var _currY = _y + neighboursIndex[i][1];
				//trace("X-> "+_currX+"  Y-> "+_currY);
				if(  _currX < 0 || _currY < 0 || _currX > _sizeM.x || _currY > _sizeM.y){
					continue;
				}else{
					connectedNodes.push( _nodes[_currX][_currY] );
				}
			}
			return connectedNodes;
		}


		private function isOpen(node:Node):Boolean {
			
			var l:int = _openNodes.length;
			for (var i:int = 0; i < l; ++i) {
				if ( _openNodes[i] == node ) return true;
			}
			return false;			
		}
		
		private function isClosed(node:Node):Boolean {
			
			var l:int = _closedNodes.length;
			for (var i:int = 0; i < l; ++i) {
				if (_closedNodes[i] == node ) return true;
			}
			return false;
		}

		// Heuristic cost function for A-star search algorithm
		public function getCost(current:Node, target:Node) {		
			var dx:Number = target.getX() - current.getX();
			var dy:Number = target.getY() - current.getY();
			return Math.sqrt( (dx * dx) + (dy * dy) );
		}
	}
}