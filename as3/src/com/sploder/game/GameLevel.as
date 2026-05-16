package com.sploder.game
{
	import com.sploder.builder.model.Environment;
	import com.sploder.builder.model.Model;
	import com.sploder.game.library.EmbeddedLibrary;
	import com.sploder.game.Simulation;
	import com.sploder.util.PlayTimeCounter;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.xml.XMLNode;
	import nape.phys.Body;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class GameLevel
	{
		
		public static var gameEngine:Simulation;
		public static var forceTurbo:Boolean = false;
		public var turbo:Boolean = false;
		
		protected var _levelNum:uint = 1;
		public function get levelNum():uint { return _levelNum; }
		
		protected var _isFirstLevel:Boolean = false;
		
		protected var _game:Game;
		public function get game():Game { return _game; }

		protected var _container:Sprite;
		
		protected var _simulation:Simulation;
		public function get simulation():Simulation 
		{
			return _simulation;
		}
		
		public function get running():Boolean 
		{
			return _running;
		}
		
		public function get model():Model 
		{
			return _model;
		}
		
		public function get environment():Environment 
		{
			return _environment;
		}
		
		protected var _levelNode:XMLNode;
		protected var _envData:String;
		
		protected var _newLifeTimer:Timer;
		public static var lostLifeTime:int;
		
		protected var _started:Boolean = false;
		protected var _running:Boolean = false;
		protected var _exiting:Boolean = false;
		protected var _exitTimer:Timer;
		
		protected var _model:Model;
		protected var _environment:Environment;
		protected var _modelContainer:Sprite;
		
		public static function initialize ():void {
			
		}
		
		public function GameLevel (game:Game, container:Sprite, levelNum:uint = 1, isFirstLevel:Boolean = false) 
		{
			init(game, container, levelNum, isFirstLevel);
		}
		
		protected function init (game:Game, container:Sprite, levelNum:uint = 1, isFirstLevel:Boolean = false):void {
			
			_game = game;
			_container = container;
			_levelNum = levelNum;
			_isFirstLevel = isFirstLevel;
			
		}
		
		//
		//
		public function buildGame (e:Event = null):void {
			
			_levelNode = _game.gameXML.firstChild.firstChild.childNodes[_levelNum - 1];
			
			_envData = String(_levelNode.attributes.env);
			
			_modelContainer = new Sprite();
			_model = new Model(_modelContainer, 640, 480);
			_environment = new Environment();
			_environment.fromString(_envData);
			if (_environment.size != Environment.SIZE_NORMAL) {
				_model.resize(1280, 960);
			}
			_model.fromString(_levelNode.firstChild.nodeValue);

			var clip:MovieClip;

			Main.mainStage.scaleMode = StageScaleMode.NO_SCALE;
			
			Game.library.cleanTextureQueue();
			
			var turbo:Boolean = forceTurbo || (_game.gameXML && _game.gameXML.firstChild.attributes.turbo == "1");
			this.turbo = turbo;
			
			var menu:ContextMenu;
			if (!turbo) {
				menu = new ContextMenu();
				var cm:ContextMenuItem = new ContextMenuItem("Play in FAST DISPLAY mode...", true, true, true);
				cm.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onFastDisplaySelect, false, 0, true);
				menu.customItems.push(cm);
			} else {
				menu = new ContextMenu();
			}
			
			_container.contextMenu = menu;
			
			EventHandler.levelNum = _levelNum;
			
			_simulation = new Simulation(_container, _model, _environment, turbo);
			_simulation.build()
			_simulation.view.zSort();
			_simulation.events.addEventListener(States.ACTION_ENDGAME, onGameObjectiveComplete, false, 0, true);
			
			Main.preloader.hide();
			
			_game.removeLevelScreen();
			_game.updateConsole();
			
			if (_simulation.viewUI.helpButton) {
				_simulation.viewUI.helpButton.addEventListener(MouseEvent.CLICK, onHelpButtonClicked, false, 0, true);
			}
			
			if (_simulation.viewUI.retryButton) {
				_simulation.viewUI.retryButton.addEventListener(MouseEvent.CLICK, onRetryButtonClicked, false, 0, true);
			}
			
			var allowcopying:Boolean = (_game.gameXML && _game.gameXML.firstChild.attributes.allowcopying == "1");
			
			if (allowcopying) _simulation.viewUI.allowCopying();
			
			if (!_isFirstLevel) {
				if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.pause();
				Game.console.showTitleScreen();
			}
			
		}
		
		//
		//
		public function rebuildGame ():void {
			
			populateGame();
			
		}
		
		//
		//
		protected function populateGame ():void {
			
			_simulation.build();
			_game.onLevelLoaded();
			
		}
		
		//
		//
		protected function onGameObjectiveComplete (e:Event):void {
			
			if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.pause();
			exitIfComplete();
			
		}
		
		protected function onFastDisplaySelect (e:Event):void {
			
			forceTurbo = true;
			Game.restartGame();
			
		}
		
		//
		public function start ():void {
			
			_container.focusRect = false;
			Game.mainStage.focus = _container;
			
			if (_simulation) {
				_simulation.start();
				if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.resume();
				_started = true;
				_running = true;
			}
			
		}
		
		//
		public function stop ():void {
			
			if (_simulation) {
				if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.pause();
				_simulation.stop();
				_running = false;
			}
			Game.mainStage.quality = StageQuality.HIGH;
			
		}
		
		public function pause ():void {
			
			if (_started && !_exiting && _simulation) {
				if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.pause();
				_simulation.stop();
				_running = false;
			}
			
		}
		
		public function resume ():void {
			
			if (_started &&  !_exiting && _simulation) {
				if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.resume();
				_simulation.start();
				_running = true;
			}
			
		}
		
		protected function onHelpButtonClicked (e:MouseEvent):void {
			
			if (_started && !_exiting) {
				
				pause();
				Game.console.hidePauseScreen();
				Game.console.hideRetryScreen();
				Game.console.showTitleScreen();
				
			}
			
		}
		
		protected function onRetryButtonClicked (e:MouseEvent):void {
			
			if (_started && !_exiting) {
				
				pause();
				Game.console.hidePauseScreen();
				Game.console.hideTitleScreen();
				Game.console.showRetryScreen();
				
			}
			
		}
		
		//
		public function exitIfComplete ():void {
			
			if (!_exiting && _simulation && _simulation.events) {
				
				Game.totalTime = EventHandler.totalTime;
				Game.totalScore = EventHandler.totalScore;
				if (PlayTimeCounter.mainInstance) Game.totalTime = PlayTimeCounter.mainInstance.secondsCounted;
				
				if (!_simulation.events.won) {
					
					Game.console.finishGame(false);
					
				} else if (_levelNum == Game.totalLevels) {
					
					Game.console.finishGame(true);
					
				} else {
					
					_exiting = true;
					_exitTimer = new Timer(2000, 1);
					_exitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onExitTimerComplete, false, 0, true);
					_exitTimer.start();
				
				}
				
			}
			
		}
		
		protected function onExitTimerComplete (e:TimerEvent):void {
			
			_exitTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onExitTimerComplete);
			
			_game.nextLevel();
			
		}
		
		//
		//
		public function end ():void {
			
			Game.mainStage.quality = StageQuality.HIGH;
			
			if (_exitTimer) {
				_exitTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onExitTimerComplete);
				if (_exitTimer.running) _exitTimer.stop();
				_exitTimer = null;
			}
			
			if (_simulation) {
				
				if (_simulation.events) {
					_simulation.events.removeEventListener(States.ACTION_ENDGAME, onGameObjectiveComplete);
				}
				
				if (_simulation.viewUI) {
					if (_simulation.viewUI.helpButton) {
						_simulation.viewUI.helpButton.removeEventListener(MouseEvent.CLICK, onHelpButtonClicked);
					}
					if (_simulation.viewUI.retryButton) {
						_simulation.viewUI.retryButton.removeEventListener(MouseEvent.CLICK, onRetryButtonClicked);
					}
				}
				
				_simulation.end();
				_simulation = null;
				gameEngine = null;
				
			}
			
			_model.end();
			_model = null;
			_modelContainer = null;
			_container = null;
			_environment = null;
			
		}
		
	}

}