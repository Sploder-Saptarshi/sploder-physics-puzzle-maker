package {
	
	import com.sploder.data.*;
	import com.sploder.game.Game;
	import com.sploder.game.GameLevel;
	import com.sploder.game.sound.SoundManager;
	import com.sploder.texturegen_internal.TextureRendering;
	import com.sploder.texturegen_internal.util.ThreadedQueue;
	import com.sploder.util.PlayTimeCounter;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.getQualifiedClassName;
	
	
	public class Main extends MovieClip {
		
		private var last_modified:String;
		
		public static var mainStage:Stage;
		public static var mainInstance:Main;
		public static var global:Object;
		public static var preloader:Preloader;
		
		public static var dataLoader:DataLoader;
		
		public static var debugmode:Boolean = true;
		public static var local:Boolean = false;
		
		protected var _game:Game;
		public function get game():Game { return _game; }
		public function set game(value:Game):void { _game = value; }
		
		public static var localContent:Boolean = false;
		
		protected var _originalBaseURL:String = "";
		
		//
		//
		public function Main(preloader:Preloader):void {
			
			Main.preloader = preloader;
			
			scaleX = scaleY = 1;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		
		//
		//
		protected function init (e:Event = null):void {
			
			global = { };
			mainStage = Game.mainStage = ThreadedQueue.mainStage = TextureRendering.mainStage = preloader.stage;
			mainInstance = this;
			
			dataLoader = new DataLoader(stage.root);
			
			last_modified = "" + Math.floor(Math.random() * 100000);
			if (stage && stage.loaderInfo.parameters["modified"] != undefined) last_modified = stage.loaderInfo.parameters["modified"];
			
			SoundManager.generateSounds();
			
			Main.preloader.status = "Building game…";
			if (Preloader.testing) Main.preloader.status = "Testing game…";
			
			initializeData();
			
			// MOCHIBOT
			// MochiBot.com -- Version 8
			// Tested with Flash 9-10, ActionScript 3
			//MochiBot.track(preloader, "a29334ce");
			
		}
		
		
		//
		//
		public static function debug (reporter:Object, msg:String, errorType:String = "NOTICE"):void {
			
			if (debugmode) trace("(!) " + errorType + " from " + getQualifiedClassName(reporter) + ": " + msg);
			
		}
		
		//
		//
		protected function initializeData ():void {
			
			dataLoader.addEventListener(DataLoaderEvent.METADATA_ERROR, onDataError);
			
			if (Preloader.url.length > 0) {

				if (Preloader.url.indexOf("file://") != -1) {
				
					debug(this, "testing locally");
					
					// TEMP
					if (!Preloader.testing) User.s = "d0018txl"; // first test
					
					Security.allowDomain("*");

					//dataLoader.baseURL = SoundManager.baseURL = "http://192.168.2.51/";
					dataLoader.baseURL = SoundManager.baseURL = "http://sploder.home/";
					
					//User.s = "d0018txl"; // Physics Game Original Test
					//User.s = "d001pcba"; // Graphics test 1
					//User.s = "d001pcbb"; // Graphics test 2
					//User.s = "d0018txy"; // LOCAL TEST SPAWNER
					//User.s = "d001w8my"; // cat burglar
					User.s = "d001vwi7"; // planet protector
					//User.s = "d001vxbb"; // space invaders
					//User.s = "d001w0df"; // hexagon 3;
					//User.s = "d001vyj1"; // rotate and roll
					//User.s = "d001vsu1"; // static fire
					//User.s = "d001vuwd"; // the kid who no one cares about
					//User.s = "d001vq8f"; // space invaders (littlemittle)
					//User.s = "d001wpt3"; // bunker busting episode I
					//User.s = "d001wjug"; // notebook escape
					//User.s = "d001x9o2"; // ninja ninja
					//User.s = "d0020631"; // knockout master
					//User.s = "d003q05y"; // textures test
					//GameLevel.forceTurbo = true;
					
					local = true;
					
				} else if (Preloader.url.indexOf("http://sploder.home") != -1 || Preloader.url.indexOf("http://192.168.") != -1) {
				
					dataLoader.baseURL = SoundManager.baseURL = "http://" + Preloader.url.split("/")[2] + "/";
					
				}
				
				if (Preloader.url.indexOf("clearspring_widget") != -1) {
					
					dataLoader.baseURL = "http://www.sploder.com/";
					SoundManager.baseURL = "http://sploder.s3.amazonaws.com/";
					
				}
				
				_originalBaseURL = dataLoader.baseURL;
				
			}
			
			var embed:Object = dataLoader.embedParameters;

			if (User.u > 0) {
				
				dataLoader.metadata.u = User.u;
				dataLoader.metadata.c = User.c;
				dataLoader.metadata.m = User.m;

				onMetadataLoaded();

			} else if (Preloader.url.indexOf("clearspring") != -1) {

				User.s = Preloader.url.split("?s=")[1].split("&clear")[0];

				dataLoader.addEventListener(DataLoaderEvent.METADATA_LOADED, onMetadataLoaded);
				dataLoader.loadMetadata("http://www.sploder.com/php/getgameprops.php?pubkey=" + User.s + "&modified=" + last_modified, false);

			} else if (embed.s != null || User.s != null) {

				if (embed.s != undefined) User.s = embed.s;

				dataLoader.addEventListener(DataLoaderEvent.METADATA_LOADED, onMetadataLoaded);
				dataLoader.loadMetadata("/php/getgameprops.php?pubkey=" + User.s + "&modified=" + last_modified);
				
			} else {

				if (!Preloader.testing) {
					
					Preloader.instance.status = "Game not found.";
					
					var loader:Loader = new Loader();
					addChild(loader);
					loader.load(new URLRequest("gamelinks.swf"));
					
				}
				
			}
			
			if (embed.challenge != undefined && parseInt(embed.challenge) > 0) {
				PlayTimeCounter.showTime = true;
				if (embed.chtime != undefined && parseInt(embed.chtime) > 0) {
					PlayTimeCounter.timeLimit = parseInt(embed.chtime);
				} else if (embed.chscore != undefined && parseInt(embed.chscore) > 0) {
					PlayTimeCounter.scoreLimit = parseInt(embed.chscore);
				}
			}
			
		}
		
		
		//
		//
		protected function onMetadataLoaded (e:DataLoaderEvent = null):void {
			
			dataLoader.removeEventListener(DataLoaderEvent.METADATA_LOADED, onMetadataLoaded);
			
			if (e != null) User.parseUserData(e.dataObject);
			
			dataLoader.addEventListener(DataLoaderEvent.DATA_LOADED, onDataLoaded);
			
			if (User.a == "1") {
				
				dataLoader.baseURL = "http://sploder.s3.amazonaws.com/";
				
				dataLoader.loadXMLData(User.projectpath + "game.xml?modified=" + last_modified);
				dataLoader.addEventListener(DataLoaderEvent.DATA_ERROR, onDataArchiveError);
				
			} else {
		
				dataLoader.loadXMLData(User.projectpath + "game.xml?modified=" + last_modified);
				dataLoader.addEventListener(DataLoaderEvent.DATA_ERROR, onDataError);
				
			}
			
		}
		
		//
		//
		protected function onDataLoaded (e:DataLoaderEvent = null):void {
			
			dataLoader.baseURL = _originalBaseURL;
			
			dataLoader.removeEventListener(DataLoaderEvent.DATA_LOADED, onDataLoaded);
			
			scaleX = scaleY = 1;
			
			_game = new Game(this, e.dataObject, this);

		}
		
		//
		//
		protected function onDataArchiveError (e:DataLoaderEvent):void {

			dataLoader.removeEventListener(DataLoaderEvent.DATA_ERROR, onDataArchiveError);
			
			dataLoader.baseURL = _originalBaseURL;
			dataLoader.loadXMLData(User.projectpath + "game.xml");
			dataLoader.addEventListener(DataLoaderEvent.DATA_ERROR, onDataError);
			
		}
		
		//
		//
		protected function onDataError (e:DataLoaderEvent):void {

			dataLoader.removeEventListener(DataLoaderEvent.DATA_ERROR, onDataError);

			Main.preloader.status = "Error Loading Game";
			
		}

	}
	
}