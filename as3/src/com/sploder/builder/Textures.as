package com.sploder.builder 
{
	import com.sploder.asui.ObjectEvent;
	import com.sploder.game.library.EmbeddedLibrary;
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Textures
	{
		public static const TEXTURE_REQUEST:String = "texture_request";
		public static var library:EmbeddedLibrary;
		protected static var _dispatcher:EventDispatcher;
		protected static var _textureCache:Object;
		protected static var _m:Matrix;
		
		public static function getCacheKey (name:String, scale:int = 2, frame:uint = 0):String {
			return name + "_" + scale + "_" + frame;
		}
		
		public static function getOriginal (name:String):BitmapData {
			
			if (_textureCache == null) _textureCache = { };
			return _textureCache[name];
			
		}
		
		public static function getScaledBitmapData (name:String, scale:int = 2, frame:uint = 0, obj:Object = null):BitmapData {
			
			var key:String = getCacheKey(name, scale, frame);
			
			if (_textureCache == null) _textureCache = { };
			else if (_textureCache[key] is BitmapData) return BitmapData(_textureCache[key]);
			
			if (library) {
				
				var orig_bd:BitmapData;
				
				if (isLoaded(name)) {
					orig_bd = _textureCache[name];
				} else if (!isNaN(parseInt(name.charAt(0)))) {
					if (obj != null) dispatcher.dispatchEvent(new ObjectEvent(TEXTURE_REQUEST, false, false, obj)); 
					return null;
				} else {
					orig_bd = library.getBitmapData(name);
				}
				
				try {
					if (orig_bd) {
						
						var scaled_bd:BitmapData = new BitmapData(orig_bd.height * scale, orig_bd.height * scale, true, 0);
					
						if (_m == null) _m = new Matrix();
						
						_m.createBox(scale, scale, 0, 0, 0);
						_m.tx = 0 - orig_bd.height * scale * frame;
						
						/*
						if (flipped) {
							_m.scale( -1, 1);
							_m.translate(orig_bd.height * scale, 0);
						}
						*/
						
						scaled_bd.draw(orig_bd, _m);
						
						_textureCache[key] = scaled_bd;
						return scaled_bd;
						
					}
				} catch (e:Error) {
					
				}
				
			}
			
			return null;
			
		}
		
		public static function isLoaded (name:String):Boolean {
			
			if (_textureCache == null) _textureCache = { };
			return (_textureCache[name] is BitmapData);
			
		}
		
		public static function addBitmapDataToCache (name:String, bd:BitmapData):void {
			
			if (_textureCache == null) _textureCache = { };
			_textureCache[name] = bd;
			
		}
		
		public static function cleanCache ():void {
			
			if (_textureCache) {
				
				for each (var bd:Object in _textureCache) {
					
					if (bd is BitmapData) BitmapData(bd).dispose();
					
				}
				
				_textureCache = { };
				
			}
			
		}
		
		static public function get dispatcher():EventDispatcher 
		{
			if (_dispatcher == null) _dispatcher = new EventDispatcher();
			return _dispatcher;
		}
		
	}

}