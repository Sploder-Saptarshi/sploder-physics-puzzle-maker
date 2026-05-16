package com.sploder.builder.model 
{
	import com.sploder.builder.Textures;
	import com.sploder.game.ViewSprite;
	import com.sploder.asui.ObjectEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Geoff
	 */
	public class ModelGraphics 
	{
		protected var _base:String = "";
		
		protected var _graphics:Dictionary;
		protected var _requestedGraphics:Array;
		protected var _waitingObjects:Dictionary;
		protected var _loaders:Dictionary;
		
		public function ModelGraphics () 
		{
			init();
		}
		
		protected function init ():void {
			
			_graphics = new Dictionary();
			_requestedGraphics = [];
			_waitingObjects = new Dictionary(true);
			_loaders = new Dictionary();
			
			Textures.dispatcher.addEventListener(Textures.TEXTURE_REQUEST, onTextureRequest);
			
			if (CreatorMain.preloader.loaderInfo.url.indexOf("sploder") == -1 || CreatorMain.preloader.loaderInfo.url.indexOf("file") != -1) {
				_base = "http://sploder_dev.s3.amazonaws.com/gfx/png/";
			} else {
				_base = "http://sploder.s3.amazonaws.com/gfx/png/";
			}
			
		}
		
		public function clean ():void
		{
			Textures.cleanCache();
			Textures.dispatcher.removeEventListener(Textures.TEXTURE_REQUEST, onTextureRequest);
			init();
		}
		
		private function onTextureRequest (e:ObjectEvent):void {
			
			if (e.object is ModelObjectSprite && ModelObjectSprite(e.object).obj.props) {
				
				assignGraphicToObject(
					ModelObjectSprite(e.object).obj.props.graphic, 
					ModelObjectSprite(e.object).obj.props.graphic_version, 
					e.object
					);
					
			} else if (e.object is ViewSprite) {
				
				assignGraphicToObject(
					ViewSprite(e.object).modelObject.props.graphic,
					ViewSprite(e.object).modelObject.props.graphic_version,
					e.object
					);
					
				_waitingObjects[e.object] = getGraphicKey(
					ViewSprite(e.object).modelObject.props.graphic,
					ViewSprite(e.object).modelObject.props.graphic_version
					);
					
			}
			
		}
		
		protected function getGraphicKey (id:uint, version:uint):String {
			
			return id + "_" + version;
			
		}
		
		protected function loadGraphic (id:uint, version:uint):void {
			trace("LOADING GRAPHIC", id, "FROM SERVER");
			var loader:Loader = new Loader();
			_loaders[loader.contentLoaderInfo] = getGraphicKey(id, version);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onGraphicLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onGraphicError);
			loader.load(new URLRequest(_base + getGraphicKey(id, version) + ".png"));
			
		}
		
		protected function onGraphicLoaded (e:Event):void {
			
			var key:String = _loaders[e.target];
			var bitmapData:BitmapData = Bitmap(LoaderInfo(e.target).content).bitmapData;

			if (key && bitmapData) {
				var animate:Boolean = bitmapData.width > bitmapData.height;
				_graphics[key] = bitmapData;
				Textures.addBitmapDataToCache(key, bitmapData);
				handleWaitingObjects(animate);
			}
			
			_loaders[e.target] = null;
			delete _loaders[e.target];
			clearRequest(key);
			
		}
		
		protected function onGraphicError (e:Event):void {
			
			var key:String = _loaders[e.target];
			
			_loaders[e.target] = null;
			delete _loaders[e.target];
			clearRequest(key);
			
		}
		
		protected function clearRequest (key:String):void {
			
			if (_requestedGraphics.indexOf(key) != -1) {
				_requestedGraphics.splice(_requestedGraphics.indexOf(key), 1);
			}
			
		}
		
		protected function handleWaitingObjects (animate:Boolean = false):void {
			
			for (var obj:Object in _waitingObjects) {
				
				if (_waitingObjects[obj] is String && isLoaded(_waitingObjects[obj])) {
					
					if (obj is ModelObjectSprite) {
						ModelObjectSprite(obj).draw();
						if (animate && ModelObjectSprite(obj).obj.props.animation == 0) {
							ModelObjectSprite(obj).obj.props.animation = 1;
						}
					} else if (obj is ViewSprite) {
						ViewSprite(obj).draw();
						if (animate && ViewSprite(obj).modelObject.props.animation == 0) {
							ViewSprite(obj).modelObject.props.animation = 1;
						}
					}
					
					_waitingObjects[obj] = null;
					delete _waitingObjects[obj];
					
				}
				
			}
			
		}
		
		protected function isLoaded (key:String):Boolean {
			
			return (_graphics[key] is BitmapData);
			
		}
		
		public function assignGraphicToObject (graphicID:uint, graphicVersion:uint, obj:Object):void {
			
			var key:String = getGraphicKey(graphicID, graphicVersion);
			
			if (isLoaded(key)) {
				if (obj is ModelObjectSprite) {
					ModelObjectSprite(obj).draw();
				} else if (obj is ViewSprite) {
					ViewSprite(obj).draw();
				}
			} else {
				_waitingObjects[obj] = key;
				if (_requestedGraphics.indexOf(key) == -1) {
					loadGraphic(graphicID, graphicVersion);
					_requestedGraphics.push(key);
				}
				
			}
			
		}
		
		public function removeUnused ():void {
			
			
		}
		
		public function fromString (textures:String):void {
			
			
		}
		
		public function toString ():String {
			
			return "";
			
		}
		
		
	}

}