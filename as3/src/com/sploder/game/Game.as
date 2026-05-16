package com.sploder.game
{

	import com.sploder.builder.Textures;
	import com.sploder.data.*;
	import com.sploder.game.GameLevel;
	import com.sploder.game.library.EmbeddedLibrary;
	import com.sploder.game.widgets.GameConsole;
	import com.sploder.asui.Library;
	import com.sploder.util.Base64;
	import com.sploder.util.Key;
	import com.sploder.util.PlayTimeCounter;
	import com.sploder.util.SignString;
	import com.sploder.util.Stats;
	import flash.Boot;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.net.LocalConnection;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import Main;
	
	/**
	* ...
	* @author Geoff Gaudreault
	*/
	public class Game {
	
		public static var mainStage:Stage;
		
		public static const START:String = "game_start";
		public static const END:String = "game_end";
		public static const PAUSE:String = "game_pause";
		public static const RESTART:String = "game_restart";
		public static const RESULT_SUBMIT:String = "game_result_submit";
		public static const RESULT_SUBMIT_DONE:String = "game_result_submit_done";
		
		public static var do_submit_score:Boolean = true;
		
		[Embed(source = "../../../../lib/library.swf", mimeType="application/octet-stream")]
		public static var LibrarySWF:Class;
		
		public static var library:EmbeddedLibrary;
			
		protected var _main:Main;
		protected var _container:Sprite;
		protected var _levelContainer:Sprite;
		protected var _consoleContainer:Sprite;
		protected var _levelScreen:Sprite;
		
		protected var _width:int;
		protected var _height:int;
		
		protected var _currentLevel:GameLevel;
		protected var _currentLevelNum:uint = 0;
		protected var _firstLevel:Boolean = true;
		
		public static var gameInstance:Game;
			
		protected var _gameXML:XMLDocument;
		
		public static var s:String;
		
		public static var title:String = "Game Preview";
		public static var author:String = "You";
		public static var difficulty:int = 5;
		public static var rating:int = 3;
		
		public static var gamedata:URLVariables;
		
		public static var totalLevels:int = 1;
		public static var totalTime:int = 0;
		public static var totalScore:int = 0;
		
		public static var ended:Boolean = false;
		
		public static var wonGame:Boolean = false;
		public static var gameResultSubmitted:Boolean = false;
		
		private var _timer:Timer;
		public function get timer():Timer { return _timer; }
		
		public function get width():int { return _width; }
		
		public function get height():int { return _height; }
		
		public function get gameXML():XMLDocument { return _gameXML; }
		
		public function get currentLevel():GameLevel { return _currentLevel; }
		
		public function get uiLibrary():Library { return library; }
		
		public function get currentLevelNum():uint { return _currentLevelNum; }
		
		public function set currentLevelNum(value:uint):void { _currentLevelNum = value; }
		
		public static var console:GameConsole;
		
		public static var testing:Boolean = false;

		public var ctr:int = 0;
		
		public var gameResultLoader:URLLoader;
        public var gameResultVars:URLVariables;
		public var gameResultRequest:URLRequest;
		
		protected static var eventLC:LocalConnection;
		protected static var eventLCName:String = "_sploder_events";

		
		//
		//
		public function Game (main:Main, data:Object, container:Sprite = null) {

			init(main, data, container);
			
		}
		
		//
		//
		protected function init (main:Main, data:Object, container:Sprite = null):void {
			
			new Boot();
			
			_main = main;
			
			testing = Preloader.testing;
			
			_gameXML = new XMLDocument();
			_gameXML.ignoreWhite = true;
			_gameXML.parseXML(String(data));
			
			extractGraphicsFromXMLDocument();
			
			title = unescape(_gameXML.firstChild.attributes.title);
			author = unescape(_gameXML.firstChild.attributes.author);
			
			s = User.s;
			
			_container = container;
			_levelContainer = new Sprite();
			_container.addChild(_levelContainer);
			_consoleContainer = new Sprite();
			_container.addChild(_consoleContainer);
			
			if (Main.local) {
				var stats:Stats = new Stats();
				_container.addChild(stats);
			}
			
			gameInstance = this;
			ended = wonGame = false;
			
			EventHandler.totalLevels = totalLevels = _gameXML.firstChild.firstChild.childNodes.length;
			EventHandler.totalTime = totalTime = 0;
			EventHandler.totalScore = totalScore = 0;
			
			GameLevel.initialize();

			if (_container == null) _container = Sprite(Main.mainStage.addChild(new Sprite()));
			
			Main.mainStage.scaleMode = StageScaleMode.NO_SCALE;
			Main.mainStage.align = StageAlign.TOP_LEFT;
			
			_width = Math.max(Main.mainStage.stageWidth, 360);
			_height = Math.max(Main.mainStage.stageHeight, 240);
			
			Main.mainStage.addEventListener(Event.RESIZE, onResize, false, 0, true);
			
			Main.dataLoader.addEventListener(DataLoaderEvent.DATA_LOADED, onXML, false, 0, true);
			
			if (!testing) {
				eventLC = new LocalConnection();
				eventLC.addEventListener(StatusEvent.STATUS, onEventStatus, false, 0, true);
				eventLC.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onEventStatus, false, 0, true);
			}
			
			if (gamedata == null && !Main.localContent) {
				if (Preloader.url.indexOf("clearspring") != -1) {
					Main.dataLoader.loadMetadata("http://www.sploder.com/php/getgamedata.php?g=" + User.m, false, onGameDataLoaded);
				} else {
					Main.dataLoader.loadMetadata("/php/getgamedata.php?g=" + User.m, true, onGameDataLoaded);
				}
			}
			
			library = new EmbeddedLibrary(LibrarySWF);
			library.addEventListener(Event.INIT, onUILibraryLoaded, false, 0, true);
			
			new PlayTimeCounter().init();
			
		}
		
		//
		//
		public function onGameDataLoaded (e:Event):void {
			
			var loader:URLLoader = URLLoader(e.target);
			var urlVars:String = loader.data;
			trace(urlVars);
			if (urlVars.charAt(0) == "&") urlVars = urlVars.replace("&", "");
			
			gamedata = new URLVariables();
			try {
				
				gamedata.decode(urlVars);
			
				if (gamedata.username != null) author = gamedata.username;
				if (gamedata.difficulty != null && !isNaN(parseInt(gamedata.difficulty))) difficulty = parseInt(gamedata.difficulty);
				if (gamedata.rating != null && !isNaN(parseInt(gamedata.rating))) rating = parseInt(gamedata.rating);
				
			} catch (e:Error) {
				
				author = "Unknown";
				difficulty = 5;
				rating = 3;
				
			}
		}
		
		//
		//
		protected function onXML (e:DataLoaderEvent):void {
			
			_gameXML = new XMLDocument(Main.dataLoader.xml.toString());
			
			if (_gameXML != null) {
				
				initializeMediaManagers();
				
			}
			
		}
		

		protected function extractGraphicsFromXMLDocument ():void {
			
			if (_gameXML && 
				_gameXML.firstChild && 
				_gameXML.firstChild.firstChild && 
				_gameXML.firstChild.firstChild.nextSibling) {
				
				var graphicsNode:XMLNode = _gameXML.firstChild.firstChild.nextSibling;
				
				for (var i:int = 0; i < graphicsNode.childNodes.length; i++) {
					
					var name:String = XMLNode(graphicsNode.childNodes[i]).attributes.name;
					
					if (name && !Textures.isLoaded(name)) {
						
						var pngString:String = XMLNode(graphicsNode.childNodes[i]).firstChild.nodeValue;
						
						if (pngString) {
							
							var bytes:ByteArray = Base64.decodeToByteArray(pngString);
							
							if (bytes) {
								
								var loader:Loader = new Loader();
								loader.name = name;
								loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onGraphicExtracted);
								loader.loadBytes(bytes);
								
							}
							
							
						}
						
					}
					
				}
				
			}
			
		}
		
		protected function onGraphicExtracted (e:Event):void {
			
			if (e.target is LoaderInfo) {
				var loader:Loader = LoaderInfo(e.target).loader;
				if (loader.content is Bitmap) {
					Textures.addBitmapDataToCache(loader.name, Bitmap(loader.content).bitmapData);
				} else {
					trace("Error: loaded file is not bitmap", loader.name, loader.content);
				}
			}
			
		}
		
		protected function onResize (e:Event):void {
			
			if (_levelScreen) {
				
				if (mainStage.stageWidth > 0) {
					_levelScreen.x = Math.floor(mainStage.stageWidth * 0.5 - _levelScreen.width * 0.5);
					_levelScreen.y = Math.floor(mainStage.stageHeight * 0.5 - _levelScreen.height * 0.5);
				} else {
					_levelScreen.x = Math.floor(_width * 0.5 - _levelScreen.width * 0.5);
					_levelScreen.y = Math.floor(_height * 0.5 - _levelScreen.height * 0.5);
				}
				
			}
			
		}
		
		//
		//
		protected function initializeMediaManagers ():void {
			
			
		}
		
		//
		//
		protected function onUILibraryLoaded (e:Event):void {
			
			library.removeEventListener(Event.INIT, onUILibraryLoaded);
			
			Key.initialize(mainStage);
			Textures.library = library;
			ViewUI.library = library;
			View.stickToOrigin = false;
			
			startGame();
			
		}
		
		public function startGame ():void {
			
			nextLevel();
			
			Main.mainStage.addEventListener(Event.ENTER_FRAME, updateGame, false, 0, true);
			Main.mainStage.addEventListener(KeyboardEvent.KEY_UP, onKeyPress, false, 0, true);
			
		}
		
		//
		public function updateGame (e:Event):void {
			
			if (!ended && User["done"] == true) {

				endGame(false);
				
				if (_currentLevel != null) {
					_currentLevel.end();
					_currentLevel = null;
				}
				
				unloadAllReferences();
	
			}

		}
		
		public function nextLevel ():void {
			
			if (_currentLevel) {
				_currentLevel.end();
				_currentLevel = null;
			}
			
			_currentLevelNum = Math.min(totalLevels, _currentLevelNum + 1);
			
			Preloader.instance.hide();
			showLevelScreen(_currentLevelNum, 0);
			
			_timer = new Timer((_currentLevelNum == 1) ? 6000 : 3000, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, loadNextLevel, false, 0, true);
			_timer.start();
			
		}
		
		protected function loadNextLevel (e:TimerEvent):void {
			
			if (_currentLevel) {
				_currentLevel.end();
				_currentLevel = null;
			}
			
			if (_timer) {
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, loadNextLevel);
				_timer = null;
			}
			
			if (ended) return;
			
			_currentLevel = new GameLevel(this, _levelContainer, _currentLevelNum, _firstLevel);
			_currentLevel.buildGame();
			
			_firstLevel = false;
			
			onLevelLoaded();
			
		}
		
		public function onLevelLoaded ():void {
			
		}
		
		//
		//
		public function showLevelScreen (levelNum:uint = 1, gameType:int = 0):void {
			
			if (_levelScreen == null) _levelScreen = uiLibrary.getDisplayObject("leveldialogue") as Sprite;
			
			if (_levelScreen != null) {
				
				_levelScreen.mouseEnabled = true;
				_levelScreen.mouseChildren = true;
				
				if (mainStage.stageWidth > 0) {
					_levelScreen.x = Math.floor(mainStage.stageWidth * 0.5 - _levelScreen.width * 0.5);
					_levelScreen.y = Math.floor(mainStage.stageHeight * 0.5 - _levelScreen.height * 0.5);
				} else {
					_levelScreen.x = Math.floor(_width * 0.5 - _levelScreen.width * 0.5);
					_levelScreen.y = Math.floor(_height * 0.5 - _levelScreen.height * 0.5);
				}
				
				_container.addChild(_levelScreen);
				_levelScreen["anim"].gotoAndPlay(1);
				
				initLevelScreen(levelNum, gameType);
				
			}	
			
		}
		
		//
		//
		public function removeLevelScreen ():void {
			
			if (_levelScreen && _levelScreen.parent) _levelScreen.parent.removeChild(_levelScreen);
			
		}
		
		protected function initLevelScreen (levelNum:uint = 1, gameType:int = 0):void {
					
			// title tf
			
			var tf:TextField = _levelScreen["title"];
			
			if (tf) tf.text = "LEVEL " + levelNum;
			
			// level mcs
			
			for (var i:int = 1; i <= 9; i++) {
				
				var mc:MovieClip = _levelScreen["level" + i];
				mc.alpha = (i < levelNum) ? 0.5 : 1;
				if (i <= levelNum) mc.gotoAndStop(i + 2);
				else if (i <= Game.totalLevels) mc.gotoAndStop("locked");
				else mc.gotoAndStop(1);
				
			}
			
			_levelScreen["game_title"].text = Game.title;
			_levelScreen["game_author"].htmlText = '<font color="#999999">BY:</font> ' + Game.author.toUpperCase();
			_levelScreen["game_difficulty"].gotoAndStop(Game.difficulty + 2);
			_levelScreen["game_level"].text = "LEVEL " + _currentLevelNum + " LOADING";
			
		}
		
		public function updateConsole ():void {
			
			if (console == null) {
				console = new GameConsole(this, _consoleContainer, _width, _height);
			}
			
		}
		
		public static function restartLevel ():void {
			
			ended = wonGame = gameResultSubmitted = false;
			
			if (gameInstance) {
				gameInstance.currentLevelNum -= 1;
				gameInstance.nextLevel();
			}
			
		}
		
		//
		public static function restartGame ():void {
			
			ended = wonGame = gameResultSubmitted = false;
			
			if (gameInstance) gameInstance.end();

			if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.reset();
			Preloader.restart();

		}
		
		//
		public static function unloadAllReferences ():void {
			
			Main.global = null;
			GameLevel.gameEngine = null;
			console = null;
			Main.mainInstance = null;
			
		}
		
		//
		public function onPauseToggle (e:Event):void {
			
			if (_currentLevel) {
				if (_currentLevel.running) {
					if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.pause();
					_currentLevel.pause();
					console.showPauseScreen();
				} else {
					if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.resume();
					_currentLevel.resume();
					console.hidePauseScreen();
					console.hideTitleScreen();
					console.hideRetryScreen();
				}
			}
			
		}
		
		
		//
		//
		//
		public static function endGame (win:Boolean):void {
			
			ended = true;
			
			if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.pause();
			
			if (gameInstance) {
				if (gameInstance.currentLevel) gameInstance.currentLevel.stop();
				Main.mainStage.removeEventListener(Event.ENTER_FRAME, gameInstance.updateGame);
			}
			
			if (win) {
				wonGame = true;
				sendEvent(2);
			} else {
				wonGame = false;
				sendEvent(3);
			}
			
			if (!testing) {
				
				if (gameInstance) gameInstance.sendGameResult(win);
				
			}
			
		}
		
        //
        //
        //
        public function sendGameResult (win:Boolean):void {

            if (s == null && User.s == null) return;
            
			if (!do_submit_score) {
				gameResultSubmitted = true;
				return;
			}
			
			if (PlayTimeCounter.mainInstance != null) PlayTimeCounter.mainInstance.complete = true;
			
            var winParam:String = (win) ? "true" : "false";
            
            gameResultVars = new URLVariables();
			gameResultVars.w = winParam;
			
			if (PlayTimeCounter.mainInstance != null) {
				gameResultVars.gtm = PlayTimeCounter.mainInstance.secondsCounted;
			} else {
				gameResultVars.gtm = Math.floor(EventHandler.totalTime);
			}
			
			gameResultVars.score = EventHandler.totalScore;
			
            if (s != null) {
				gameResultVars.pubkey = s;
            } else if (User.s != null) {
                gameResultVars.pubkey = User.s;
            }
			
            gameResultRequest = new URLRequest(Main.dataLoader.baseURL + "/php/gameresults.php?ax=" + SignString.sign(s + gameResultVars.w + gameResultVars.gtm));
			gameResultRequest.method = "POST";
			gameResultRequest.data = gameResultVars;
			
			gameResultLoader = new URLLoader();
			gameResultLoader.addEventListener(Event.COMPLETE, onGameResultSent, false, 0, true);
			gameResultLoader.load(gameResultRequest);
			
			if (win && PlayTimeCounter.mainInstance != null)
			{
				if (PlayTimeCounter.timeLimit > 0 && PlayTimeCounter.mainInstance.secondsCounted <= PlayTimeCounter.timeLimit)
				{
					sendEvent(12);
				} 
				else if (PlayTimeCounter.scoreLimit > 0 && EventHandler.totalScore >= PlayTimeCounter.scoreLimit)
				{
					sendEvent(12);
				}
			}
			
            
        }
		
		//
		//
		public function onGameResultSent (e:Event):void {
			gameResultSubmitted = true;
		}
		
		//
		//
		public static function sendEvent (eventCode:Number):void {
			
			if (!testing) {
				trace("sending event " + eventCode + " " + title);
				eventLC.send(eventLCName, "onReceive", { e: eventCode, g: title, s: s } );
			}
			
		}
		
		//
		//
		public static function onEventStatus (e:Event):void {
			
			
		}
		
		//
		//
		protected function onKeyPress (e:KeyboardEvent):void {
			
			switch (e.charCode) {
				
				case String("p").charCodeAt(0):
					onPauseToggle(e);
					break;
					
				case String("y").charCodeAt(0):
					// nextLevel();
					break;
						
			}
			
		}
		
		//
		//
		public function end ():void {
			
			if (_timer && _timer.running) {
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, loadNextLevel);
				_timer.stop();
			}
			
			if (console) console.end();
			
			if (gameInstance) {
				if (gameInstance.currentLevel) gameInstance.currentLevel.end();
				gameInstance = null;
			}
			
			Main.mainStage.removeEventListener(Event.RESIZE, onResize);
			Main.mainStage.removeEventListener(Event.ENTER_FRAME, updateGame);
			Main.mainStage.removeEventListener(KeyboardEvent.KEY_UP, onKeyPress);
			
			unloadAllReferences();
			
		}
		
	}

}