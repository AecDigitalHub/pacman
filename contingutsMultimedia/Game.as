/*
Project: Pacman
Authors: Marc Pomar & Laura Cotrina.
Description:
	Main game class, manages game objects, score, sound FX, etc.
*/

package contingutsMultimedia {	
	import flash.display.MovieClip;
	import flash.geom.Point;
	import contingutsMultimedia.Pacman;
	import contingutsMultimedia.Ghost;
	import contingutsMultimedia.Mapa;
	import contingutsMultimedia.Constants;
	import contingutsMultimedia.Scoreboard;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import flash.media.Sound;
	import flash.net.URLRequest;

	import com.gskinner.motion.GTween;
	import com.gskinner.motion.easing.*;


	public class Game extends MovieClip{

		private var _mapa:Mapa;
		private var _offset:Point;
		public var pacman:Pacman;
		public var ghosts:Array;
		public var names:Array = [Constants.BLINKY, Constants.INKY, Constants.PINKY, Constants.CLYDE];
		public var paused:Boolean;

		// DEBUG: Path checker 
		private var pchecker:MovieClip = new MovieClip();

		// Start position pacman
		var startPositionPacman:Point;

		// Sound objects
		var soundFX:Sound;

		// Scoreboard
		public var scoreboard:Scoreboard;

		public function Game(gameMap:String){

			// DEBUG: Path checker
			this.addChild(pchecker);

			// Initialize ghosts
			ghosts = new Array();

			// Start map instance with map offset
			_offset = new Point(0,25);
			_mapa = new Mapa(gameMap, _offset);
			_mapa.addEventListener("eatPac", eventProcessor);
			_mapa.addEventListener("eatPowerUp", eventProcessor);
			_mapa.addEventListener("mapaLoaded", function(e:Event){
				// When map loaded reset game and spawn characters
				resetGame();
			});
			this.addChild(_mapa); // Add map clip and start listeners

			// Setup scoreboard (counts lives and scores)
			scoreboard = new Scoreboard();
			this.addChild(scoreboard);

			// Load chili sound
			soundFX = new Sound();
			soundFX.load(new URLRequest("audios/chili.mp3"));

			// Background sound
			var soundBG:Sound = new Sound();
			soundBG.load(new URLRequest("audios/bg_theme.mp3"));
			//soundBG.play();
		}

		public function resetGame(){

			trace("---- Reseting characters ----");

			// Unpause game
			paused = false;
			
			// Pacman start position
			startPositionPacman = new Point(13,23);

			// Setup new pacman character
			if(pacman){
				this.removeChild(pacman);
				pacman = null;
			}
			pacman = new Pacman("PacmanClip", _mapa, startPositionPacman);
			this.addChild(pacman);

			// Remove current ghosts & listeners
			var ghost:Ghost;
			while(ghost = ghosts.pop()){
				ghost.removeEventListener("eatGhost", eventProcessor);
				ghost.removeEventListener("killPacman", eventProcessor);
				this.removeChild(ghost);
			}

			// Create ghosts		
			for(var i:uint; i < names.length; i++){
				ghost = new Ghost(names[i], Constants.graficImplementation(names[i]), pacman, _mapa, pchecker);
				ghost.addEventListener("eatGhost", eventProcessor);
				ghost.addEventListener("killPacman", eventProcessor);
				ghosts.push(ghost);
				this.addChild(ghost);
			}

			// Update characters and objects
			this.addEventListener(Event.ENTER_FRAME, frameUpdate);
		}




		// Updates all objects of game
		public function frameUpdate(e:Event){
			if(!paused){
				// Update ghosts
				for(var i:uint; i < ghosts.length; i++){
					ghosts[i].actuate();
				}
				// Update pacman
				pacman.actuate();

				// Map bright animation
				_mapa.animateSlices();
			}
		}

		// Eat event
		public function eventProcessor(e:Event){
			if(e.type == "eatPac"){
				scoreboard.addScore(10);
			}else if (e.type == "eatPowerUp"){
				scoreboard.addScore(50);
				trace("PowerUp!");
				soundFX.play();
				for(var i:uint; i < ghosts.length; i++){
					ghosts[i].setFear();
				}
			}else if (e.type == "eatGhost"){
				trace("Eat ghost +200");
				scoreboard.addScore(200);
			}else if (e.type == "killPacman"){
				trace("Ohh, sorry pacman!");
				pacman.diePacman();
				for(var j:uint; j < ghosts.length; j++){
					ghosts[j].visible = false;
				}
				paused = true;
				if(scoreboard.removeLive()){
					pacman.addEventListener("pacmanDies", function(e:Event){
						resetGame();
					});
				}else{
					this.gameOver();
				}
			}
		}

		public function gameOver(){
			trace("GAME OVER");

			// Remove pacman
			if(pacman){
				this.removeChild(pacman);
				pacman = null;
			}

			// Remove current ghosts & listeners
			var ghost:Ghost;
			while(ghost = ghosts.pop()){
				ghost.removeEventListener("eatGhost", eventProcessor);
				ghost.removeEventListener("killPacman", eventProcessor);
				this.removeChild(ghost);
			}

			// Remove Mapa
			if(_mapa){
				this.removeChild(_mapa);
			}

			// Play gameover animation
			var gameOverGraphic:MovieClip = new gameOverClip();
			this.addChild(gameOverGraphic);
			// place in topcenter
			gameOverGraphic.x = stage.width/2 - gameOverGraphic.width/2;
			gameOverGraphic.y = -gameOverGraphic.height;

			var tween:GTween = new GTween(gameOverGraphic,20,null,{ease:Sine.easeInOut});
			tween.data = {y:(stage.height/2 - gameOverGraphic.height/2)};

		}

		// Detects key press
		public function detectKey(event:KeyboardEvent):void{
			switch (event.keyCode){
				case Keyboard.DOWN :
					pacman.updateMovement(Constants.DOWN);
					break;
				case Keyboard.UP :
					pacman.updateMovement(Constants.UP);
					break;
				case Keyboard.LEFT :
					pacman.updateMovement(Constants.LEFT);
					break;
				case Keyboard.RIGHT :
					pacman.updateMovement(Constants.RIGHT);
					break;
			}
		}
	}
}