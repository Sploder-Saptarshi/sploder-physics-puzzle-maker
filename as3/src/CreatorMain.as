package 
{
	import com.sploder.builder.Creator;
	import com.sploder.data.*;
	import com.sploder.game.sound.SoundManager;
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.events.*;
	import flash.system.Security;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ...
	 * @author Geoff
	 */
	[Frame(factoryClass="CreatorPreloader")]
	public class CreatorMain extends Sprite 
	{
		public static var mainStage:Stage;
		public static var global:Object;
		public static var preloader:CreatorPreloader;
		
		public static var dataLoader:DataLoader;
		
		public static var debugmode:Boolean = true;
		
		protected static var _creator:Creator;
		public static function get creator():Creator { return _creator; }
		
		protected static var _gameLoader:Loader;
		protected static var _testButton:SimpleButton;
		protected static var _previewing:Boolean = false;
		
		public static var mainInstance:CreatorMain;
		
		protected static var firstTest:Boolean = true;
		
		//
		//
		public function CreatorMain(stage:Stage, preloader:CreatorPreloader):void {
			
			init(stage, preloader);
			
		}
		
		
		//
		//
		protected function init (stage:Stage, preloader:CreatorPreloader):void {
			
			global = { };
			mainStage = stage;
			mainInstance = this;
			CreatorMain.preloader = preloader;
			
			Security.loadPolicyFile("http://www.sploder.com/crossdomain.xml");
			Security.loadPolicyFile("http://sploder.s3.amazonaws.com/crossdomain.xml");
			
			dataLoader = new DataLoader(stage.root);
			
			CreatorMain.preloader.status = "Initializing Creator…";
			
			if (this.stage) {
				initializeData();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, onAdded);
			}

		}
		
		protected function onAdded (e:Event):void {
			
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			initializeData();
			
		}
		
		
		//
		//
		public static function debug (reporter:Object, msg:String, errorType:String = "NOTICE"):void {
			
			if (debugmode) trace("(!) " + errorType + " from " + getQualifiedClassName(reporter) + ": " + msg);
			
		}
		
		//
		//
		protected function initializeData ():void {
			
			var local:Boolean = false;
			var allow:Boolean = false;
			
			if (CreatorPreloader.url.length > 0) {
				
				if (CreatorPreloader.url.indexOf("http://www.sploder.com/") === 0 || 
					CreatorPreloader.url.indexOf("http://sploder.com/") === 0) {
					
					allow = true;
					
				} else if (CreatorPreloader.url.indexOf("file:///") === 0) {
				
					debug(this, "testing locally");
					//User.s = "mgh2uzkh";
					local = true;
					dataLoader.baseURL = SoundManager.baseURL = "http://192.168.2.51/";
					allow = true;

				} else if (CreatorPreloader.url.indexOf("http://sploder.home") === 0 || CreatorPreloader.url.indexOf("http://192.168.") === 0) {
				
					dataLoader.baseURL = SoundManager.baseURL = "";
					allow = true;
					
				}
				
			}
			
			trace("BASE URL:", dataLoader.baseURL);
			
			if (dataLoader.embedParameters.userid == null || dataLoader.embedParameters.userid == "demo") {
				
				User.u = 0;
				User.c = "0000000000";
				User.m = "temp";
				
			} else {
				
				User.u = parseInt(dataLoader.embedParameters.userid);
				User.c = String(dataLoader.embedParameters.creationdate);
				
			}
			
			preloader.status = "Initializing...";
			allow = true;
			if (allow) {
				
				_creator = new Creator(this, this);
				_creator.local = local;
				_creator.addEventListener(Creator.INITIALIZED, onCreatorInit);
				
			} else {
				
				preloader.status = "Something is funky!";
				
			}
			
		}
		
		//
		//
		public static function onCreatorInit (e:Event):void {
			
			preloader.done();
			mainStage.quality = StageQuality.HIGH;
	
		}
		
	}

}