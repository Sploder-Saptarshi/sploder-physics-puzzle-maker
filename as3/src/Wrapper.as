package
{

	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Wrapper extends Sprite {
		
		protected var _loader:Loader;
		protected var _urlRequest:URLRequest;
		protected var _loadTimer:Timer;
		protected var _checkInterval:int = 7000;
		
		protected var _gameSWF:String = "fullgame5_b26s.swf";
		
		protected var _servers:Array = ["http://sploder.s3.amazonaws.com/"];
		protected var _currentServer:int = 0;
		
		private static const ENABLE_ADS:Boolean = true;
		private static var ads_allowed:Boolean = false;
		private var _adLoader:Loader;
		
		protected var _firstLoadStarted:Boolean = false;
		protected var _loadStarted:Boolean = false;
		protected var _progress:Number = 0;
		
		public function get loadStarted ():Boolean { return _loadStarted; }
		
		public function set loadStarted (value:Boolean):void {
			
			_loadStarted = value;
			
			if (!_loadStarted) removeLoaderListeners();
			
			if (_loadTimer != null && _loadTimer.running) _loadTimer.stop();
			
			if (!_loadStarted) {
				
				if (_loader != null && _loader.contentLoaderInfo != null) {
					
					_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
					_loader.addEventListener(Event.COMPLETE, onComplete);
					_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
					_loader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR, onError);
						
				}
				
				if (_loadTimer != null) {
				
					_loadTimer.reset();
					_loadTimer.start();
					
				}
					
			}
			
		}

		public function Wrapper () {
			
			super();
			
			init();
			
		}
		
		protected function init ():void {
			
			Security.allowDomain("www.sploder.com");
			Security.allowDomain("sploder.com");
			Security.allowDomain("sploder.s3.amazonaws.com");
			Security.allowDomain("sploder.home");
			
			_loadTimer = new Timer(_checkInterval, 0);
			_loadTimer.addEventListener(TimerEvent.TIMER, checkLoadStarted);
			
			_loadTimer.start();
			
			_loader = new Loader();
			
			if (root != null && root.loaderInfo != null && root.loaderInfo.url != null && root.loaderInfo.parameters.localswf != undefined) _servers[0] = "";
			else if (root == null || root.loaderInfo == null) _servers[0] = "http://www.sploder.com/";
			
			ads_allowed = ((root.loaderInfo.parameters.nu == "1" || root.loaderInfo.parameters.fads == "1") && root.loaderInfo.parameters.onsplodercom == "true");
				
			if (ENABLE_ADS && ads_allowed && root.loaderInfo.parameters.s != null)
			{
				_adLoader = new Loader();
				addChild(_adLoader);
				_adLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onAdLoaderComplete);
				_adLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onAdLoaderError);
				_adLoader.contentLoaderInfo.addEventListener(IOErrorEvent.NETWORK_ERROR, onAdLoaderError);
				
				var prerollad_url:String = "prerollad4.swf?s=" + root.loaderInfo.parameters.s;
				if (loaderInfo.parameters["adtest"] != undefined) prerollad_url += "&adtest=1";
				_adLoader.load(new URLRequest(prerollad_url), new LoaderContext(false, ApplicationDomain.currentDomain, SecurityDomain.currentDomain));
				
			} else {
				addChild(_loader);
			}

			load();
			
		}
		
		private function checkBase ():void {
			
			
			if (loaderInfo.url.indexOf("sploder.home") != -1 || loaderInfo.url.indexOf("192.168.") != -1) {
				
				_servers[0] = "";

			}
			
			if (root.loaderInfo.parameters.beta_version != undefined && root.loaderInfo.parameters.beta_version.length > 0) {
			
				_servers[0] = "";
				_gameSWF = "fullgame5_b" + root.loaderInfo.parameters.beta_version + "s.swf";
				
			}
			
		}
		
		//
		//
		protected function load ():void {
			
			if (_firstLoadStarted && _loader) _loader.unloadAndStop();
			else _firstLoadStarted = true;
			
			loadStarted = false;
			
			checkBase();
			
			if (loaderInfo.url.indexOf("sploder.home") != -1 || loaderInfo.url.indexOf("192.168.") != -1) {
				_servers[0] = "";
			}
			if (root.loaderInfo.parameters.cs == "1" || root.loaderInfo.parameters.clearspring_widget == "true") {
				_servers[1] = "http://www.sploder.com/";
				_urlRequest = new URLRequest(_servers[_currentServer] + _gameSWF + "?s=" + root.loaderInfo.parameters.s + "&clearspring_widget=true");
			} else {
				var challenge:String = root.loaderInfo.parameters.challenge;
				
				if (challenge) {
					var chtime:String = root.loaderInfo.parameters.chtime;
					var chscore:String = root.loaderInfo.parameters.chscore;
					if (chscore) {
						_urlRequest = new URLRequest(_servers[_currentServer] + _gameSWF + "?challenge=" + challenge + "&chscore=" + chscore);
					} else {
						_urlRequest = new URLRequest(_servers[_currentServer] + _gameSWF + "?challenge=" + challenge + "&chtime=" + chtime);
					}
				} else {
					_urlRequest = new URLRequest(_servers[_currentServer] + _gameSWF);
				}
			}	
			
			_loader.load(_urlRequest, new LoaderContext(false, ApplicationDomain.currentDomain, SecurityDomain.currentDomain));				
			
		}
		
		//
		//
		protected function checkLoadStarted (e:TimerEvent = null):void {
			
			_loadTimer.stop();
			
			if (!_loadStarted && _currentServer < _servers.length - 1) {
				
				_currentServer++;
				
				load();
				
				trace("failing over to " + _servers[_currentServer]);
				
			} else {
				
				_loadTimer.stop();
				
				trace("load success");
				
			}
			
		}
		
		//
		//
		private function onProgress (e:ProgressEvent):void {
			
			_progress = (e.bytesLoaded / e.bytesTotal);
			if (_adLoader != null && _adLoader.content != null) Object(_adLoader.content).progress = _progress;
			
			if (!_loadStarted && !isNaN(e.bytesTotal) && e.bytesTotal > 0) {
				
				loadStarted = true;
				
				trace("load success");
				
			}
			
		}
		
		protected function removeLoaderListeners ():void
		{
			if (_loader != null && _loader.contentLoaderInfo != null) {
					
				if (_loader.contentLoaderInfo.hasEventListener(ProgressEvent.PROGRESS)) _loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				if (_loader.hasEventListener(Event.COMPLETE)) _loader.removeEventListener(Event.COMPLETE, onComplete);
				if (_loader.contentLoaderInfo.hasEventListener(ProgressEvent.PROGRESS)) _loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				if (_loader.contentLoaderInfo.hasEventListener(IOErrorEvent.IO_ERROR)) _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);	
				if (_loader.contentLoaderInfo.hasEventListener(IOErrorEvent.NETWORK_ERROR)) _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.NETWORK_ERROR, onError);	
					
			}
		}
		
		//
		//
		private function onComplete (e:ProgressEvent):void {
			
			_progress = 1;
			
			removeLoaderListeners();
			
			if (_adLoader != null && _adLoader.content != null) Object(_adLoader.content).progress = 1;
			trace("GAME LOAD COMPLETE");
		}
		
		//
		//
		private function onError (e:IOErrorEvent):void {
			
			if (_loader) {
				removeLoaderListeners();
				_loader.unloadAndStop();
			}
			loadStarted = false;
			
		}
		
		protected function removeAdLoaderListeners ():void
		{
			if (_adLoader != null && _adLoader.contentLoaderInfo != null) {
					
				if (_adLoader.contentLoaderInfo.hasEventListener(ProgressEvent.PROGRESS)) _adLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				if (_adLoader.hasEventListener(Event.COMPLETE)) _adLoader.removeEventListener(Event.COMPLETE, onComplete);
				if (_adLoader.contentLoaderInfo.hasEventListener(ProgressEvent.PROGRESS)) _adLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				if (_adLoader.contentLoaderInfo.hasEventListener(IOErrorEvent.IO_ERROR)) _adLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onError);	
				if (_adLoader.contentLoaderInfo.hasEventListener(IOErrorEvent.NETWORK_ERROR)) _adLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.NETWORK_ERROR, onError);	
					
			}
		}
		
		//
		private function onAdLoaderComplete (e:Event):void
		{
			removeAdLoaderListeners();
			
			_adLoader.content.addEventListener(Event.COMPLETE, onAdComplete);
			trace("ADDING AD LISTENER...");
			
			if (_adLoader != null && _adLoader.content != null) Object(_adLoader.content).progress = _progress;
		}
		
		//
		//
		private function onAdLoaderError (e:IOErrorEvent):void {
			
			if (_adLoader)
			{
				removeAdLoaderListeners();
				_adLoader.unloadAndStop();
			}
			
			onAdComplete()
			
		}
		
		private function onAdComplete (e:Event = null):void
		{
			trace("AD COMPLETE!");
			
			if (_adLoader != null && _adLoader.parent != null) _adLoader.parent.removeChild(_adLoader);
			addChild(_loader);
			if (_loader.content != null) MovieClip(_loader.content).gotoAndPlay(1);
		}
		
		
	}
	
}