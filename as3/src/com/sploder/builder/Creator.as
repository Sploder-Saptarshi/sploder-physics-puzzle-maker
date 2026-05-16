package com.sploder.builder
{
	import com.sploder.builder.CreatorUI;
	import com.sploder.builder.CreatorUIController;
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.builder.model.Environment;
	import com.sploder.builder.model.Model;
	import com.sploder.builder.model.ModelController;
	import com.sploder.builder.model.ModelGraphics;
	import com.sploder.data.*;
	import com.sploder.game.Simulation;
	import com.sploder.game.sound.SoundManager;
	import com.sploder.game.ViewUI;
	import com.sploder.asui.Clip;
	import com.sploder.asui.Component;
	import com.sploder.asui.Library;
	import com.sploder.asui.Prompt;
	import com.sploder.util.Key;
	import com.sploder.util.Settings;
	import com.sploder.util.StringUtils;
	import flash.Boot;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.*;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.xml.*;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class Creator extends EventDispatcher
	{
		public static const INITIALIZED:String = "creator_initialized";
		public static const GAME_VERSION:String = "5";
		
		protected var _main:CreatorMain;
		protected var _container:Sprite;
		public function get stage ():Stage { return _container.stage; }
		
		protected static var _mainInstance:Creator;
		public static function get mainInstance():Creator { return _mainInstance; }
		
		[Embed(source = "../../../../lib/library.swf", mimeType="application/octet-stream")]
		public static var LibrarySWF:Class;
		
		public static var gameLibrary:Library;
		
		protected var _solBucketName:String = "creator" + GAME_VERSION;
		
        public var resultXML:XML;
		
		public static var projectToLoad:String;
		
		public var gameMode:Number;
        
        public var todaysdate:Date;
        public var activedate:Date;
        public var today:String;
        public var todaycgi:String;
        public var activeday:String;
        public var activedaycgi:String;
		
        public var sessionExpired:Boolean = false;
        public var keepTimer:Timer;
        public var keepLoader:URLLoader;
		
		public var ui:CreatorUI;
		public var uiController:CreatorUIController;
		public var menuController:CreatorMenu;
		public var levels:CreatorLevels;
		public var model:Model;
		public var modelController:ModelController;
		public var environment:Environment;
		public var graphics:ModelGraphics;
		
		protected var _project:CreatorProject;
		public function get project():CreatorProject { return _project; }
		
        private var debugmode:Boolean = false;
		public var betaMode:Boolean = false;
		public var demo:Boolean = false;
		public var local:Boolean = false;
		
		protected var _testSimulation:Simulation;
		protected var _testing:Boolean = false;
		public function get testing():Boolean { return _testing; }
		
		
		public function Creator (main:CreatorMain, container:Sprite = null) {

			init(main, container);
			
		}
		
		//
		//
		protected function init (main:CreatorMain, container:Sprite = null):void {
			
			_main = main;
			
			_container = container;
			
			_mainInstance = this;
			
			Component.mainStage = stage;
			Key.initialize(stage);
			
			gameLibrary = new Library(LibrarySWF);
			
			if (CreatorMain.dataLoader.baseURL.indexOf("http://sploder.home") == 0) betaMode = false;
			
			_project = new CreatorProject(this, "/php/saveproject" + GAME_VERSION + ".php", "version=" + GAME_VERSION, "/php/savegamedata" + GAME_VERSION + ".php");
				
            gameMode = 5;

			if (CreatorMain.dataLoader.embedParameters.userid == undefined || 
				CreatorMain.dataLoader.embedParameters.userid == "demo") demo = true;
			
			if (demo) {
				 User.u = 1;
				 if (CreatorMain.dataLoader.embedParameters.creationdate != undefined) {
					 User.c = String(CreatorMain.dataLoader.embedParameters.creationdate);
				 } else {
					 User.c = "20061226154248";
				 }
			} else {
				User.u = parseInt(CreatorMain.dataLoader.embedParameters.userid);
				User.name = String(CreatorMain.dataLoader.embedParameters.username);
				_project.author = User.name;
				User.c = String(CreatorMain.dataLoader.embedParameters.creationdate);
			}
			     
            // 
            // 
            todaysdate = new Date();
            activedate = new Date();
            today = StringUtils.prettydatestring(todaysdate);
            todaycgi = StringUtils.cgidatestring(todaysdate);
            activeday = StringUtils.prettydatestring(todaysdate);
            activedaycgi = StringUtils.cgidatestring(todaysdate);
			   
            if (!demo) {
                keepTimer = new Timer(20000, 0);
				keepTimer.addEventListener(TimerEvent.TIMER, keepAlive);
				keepTimer.start();
            }

			CreatorMain.dataLoader.addEventListener(DataLoaderEvent.DATA_ERROR, onServerError);
			CreatorMain.dataLoader.addEventListener(DataLoaderEvent.METADATA_ERROR, onServerError);
				
			build();
			
			dispatchEvent(new Event(INITIALIZED));
			
		}
		
		protected function build ():void {
			
			new Boot();
			
			ui = new CreatorUI(this);
			_container.addChild(ui);
			ui.addEventListener(Event.INIT, onUIInit);
			ui.start();
			
		}
		
		protected function onUIInit (e:Event):void {
			
			levels = new CreatorLevels(this);
			model = new Model(ui.playfield.mc, 640, 480);
			environment = new Environment();
			graphics = new ModelGraphics();
			
			uiController = new CreatorUIController(this);
			modelController = new ModelController(this);
			menuController = new CreatorMenu(this);
			
			uiController.connect();
			modelController.connect();
			
			menuController.saveEnabled = menuController.saveAsEnabled = menuController.publishEnabled = (!demo);
			menuController.publishEnabled = (!betaMode);
			
			ui.ddManager.listURL = "/php/getprojects.php"
			ui.ddManager.listParamString = "version=" + GAME_VERSION;
			
			ui.ddMusic.listURL = "/music/modules/index.m3u";
			ui.ddMusic.listParamString = "";
			
			ui.tools.activateTab(null, ui.tools.tabs[CreatorUIStates.TOOL_DRAW]);
			
			ui.ddWelcome.show();
			
			SoundManager.generateSounds();
			
		}
		
		public function showTour ():void {
			
			var tour:Clip = new Clip(_container, CreatorUIStates.SCREEN_TOUR, Clip.EMBED_LOCAL, 720, 590);
			
			tour.loadedClip.getChildAt(0)["done_btn"].addEventListener(MouseEvent.CLICK, 
				function (e:Event):void {
					tour.destroy();
					onWelcomeClosed();
				}
			);
			tour.underClipMouseEnabled = true;
			
		}
		
		public function onWelcomeClosed ():void {
			
			start();
			
		}
		
		protected function start ():void {
			
			CreatorMain.preloader.done();
			
			Settings.bucketName = String(_solBucketName + "_" + User.u);
			trace(Settings.bucketName, project.sharedObjectName);
			var demoXML:String;
			
			if (CreatorMain.dataLoader.embedParameters.copyaction == "true") {
			
				ui.ddClipboard.show();
			
			} else if (demo) {
				
				if (project.hasLocalProject) {
					
					demoXML = Settings.loadSetting(project.sharedObjectName) as String;
					
					if (demoXML && demoXML.indexOf("geoff") == -1) {
						project.confirmLoadLocalProject();
					} else {
						project.newProject();
						if (!local) ui.ddAlert.alert(CreatorUIStates.MESSAGE_GAME_DEMO);
					}
					
				} else {	
					
					project.newProject();
					if (!local) ui.ddAlert.alert(CreatorUIStates.MESSAGE_GAME_DEMO);
					
				}
				
			} else {
				
				if (!project.hasLocalProject) {
					
					Settings.bucketName = String(_solBucketName + "_1");

					if (project.hasLocalProject) {
						
						demoXML = Settings.loadSetting(project.sharedObjectName) as String;
						
						Settings.saveSetting(project.sharedObjectName, "");
						Settings.bucketName = String(_solBucketName + "_" + User.u);
						
						if (demoXML.indexOf("geoff") == -1) {
							Settings.saveSetting(project.sharedObjectName, demoXML);
						}

					} else {
						
						Settings.bucketName = String(_solBucketName + "_" + User.u);
						
					}
				
				}
				
				if (project.hasLocalProject) {
					project.confirmLoadLocalProject();
				} else {
					project.newProject();
				}

			}	
			
		}
		
		public function test ():void {
			
			if (_testSimulation) _testSimulation.end();
			
			ViewUI.library = gameLibrary;
			
			_testSimulation = new Simulation(_container, model, environment);
			_testSimulation.build();
			
			var p:Sprite = _testSimulation.view.container;
			p.x = 180;
			p.y = 90;
			
			if (_testSimulation.viewUI) {
				if (_testSimulation.viewUI.helpButton) {
					_testSimulation.viewUI.helpButton.visible = false;
				}
				if (_testSimulation.viewUI.retryButton) {
					_testSimulation.viewUI.retryButton.visible = false;
				}
			}
			
			_testSimulation.start();
			_testing = true;
			
			ui.modifierPropertiesEditor.hide();
			ui.testMask.visible = true;
			ui.testEndButtonContainer.show();
			uiController.keyboardEnabled = false;
			
			Prompt.permaMessage = (SoundManager.soundsGenerated) ? 
				"Your game level is now being tested. It may play a little slower in the creator." : 
				"Your game level is now being tested. Sounds are still being generated while you test.";
			
		}
		
		public function testEnd ():void {
			
			if (_testSimulation) {
				
				_testSimulation.end();
				_testSimulation = null;
				_testing = false;
				
				ui.testEndButtonContainer.hide();
				ui.testMask.visible = false;
				uiController.keyboardEnabled = true;
				
			}
			
			Prompt.permaMessage = "";
			Prompt.prompt("Done testing your game level.");
				
		}	
		
		//
		//
		protected function onServerError (e:DataLoaderEvent):void {
			ui.ddAlert.alert("There was an error communicating with the server.");		
		}
		
        // 
        // 
        // RESETACTIVEDATE sets the active date to today
        public function resetactivedate():void {
            
            activedate = new Date();
            activeday = today;
            activedaycgi = todaycgi;
            
        }	
		
       /*    ----------------------------------------------------------
        *   Creator Functions
        *    ---------------------------------------------------------- */
            
        //
        //
        // SETGAMEMODE changes the game mode
        public function setGameMode (mode:Number):void {

            gameMode = (!isNaN(mode)) ? mode : gameMode;
            if (gameMode != 2) gameMode = 2;
    
        }
		
		
        //
        //
        // KEEPALIVE pings the server to keept he session alive
        public function keepAlive (e:TimerEvent):void {
             
			keepLoader = new URLLoader();
			keepLoader.addEventListener(Event.COMPLETE, checkAlive);
			keepLoader.load(new URLRequest("php/keepalive.php" + CreatorMain.dataLoader.getCacheString()));
			
        }
    
        
        //
        //
        // CHECKALIVE checks to see if the session is still alive
        public function checkAlive (e:Event):void {

			// trace(e.target.data);
			
			if (e.target.data != "keepalive=1") {
				
				ui.ddAlert.alert(CreatorUIStates.MESSAGE_SESSION_EXPIRE);
				project.saveLocalProject();
				sessionExpired = true;
				
			} else {
				
				if (sessionExpired == true) {
					sessionExpired = false;
				}
				
			}
            
        }

	}
	
}