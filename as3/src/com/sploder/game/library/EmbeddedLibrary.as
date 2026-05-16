package com.sploder.game.library {
	
	import com.sploder.asui.Library;
	import com.sploder.texturegen_internal.TextureAttributes;
	import com.sploder.texturegen_internal.TextureRenderingCache;
	import com.sploder.texturegen_internal.TextureRenderingJob;
	import com.sploder.texturegen_internal.TextureRenderingQueue;
	import com.sploder.util.Geom2d;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	
	//
	//
	public class EmbeddedLibrary extends Library {
		
		public static const INITIALIZED:String = "embeddedlibrary_initialized";

		public static var textureQueue:TextureRenderingQueue;
		
		//
		//
		public function EmbeddedLibrary (embeddedSWF:Class, debug:Boolean = false) {
			
			super(embeddedSWF, debug);
			
		}
		
		/**
		 * must be initialized at least one frame before any resources are available;
		 * be sure to call init() well in advance of any attempt to access library resources.
		 */
		override protected function init ():void {
			
			super.init();
			
			if (TextureRenderingQueue.mainInstance != null) textureQueue = TextureRenderingQueue.mainInstance;
			else {
				textureQueue = new TextureRenderingQueue().init();
				textureQueue.pauseInterval = 1;
				textureQueue.tasksPerFrame = 1;
			}
			
		}
		
		//
		//
		public function getMovieClipAsBitmap (symbolName:String, frameLabel:String = "", filters:Array = null):Bitmap {
			
			return new Bitmap(getDisplayObjectBitmapData(symbolName, frameLabel, filters), PixelSnapping.ALWAYS, smoothing);
			
		}
		
		//
		//
		public function getMovieClipBitmapData (symbolName:String, frameLabel:String = "", filters:Array = null, rotation:Number = 0):BitmapData {
			
			return getDisplayObjectBitmapData(symbolName, frameLabel, filters, rotation);
			
		}
		
		//
		//
		public function getDisplayObjectBitmapData (symbolName:String, frameLabel:String = "", filters:Array = null, rotation:Number = 0, constrainBounds:Boolean = false):BitmapData {
			
			var frameID:String = (frameLabel != "") ? "__" + frameLabel : "";
			
			var deg:int = (rotation == 0) ? 0 : Math.floor(Geom2d.dtr * rotation);
			
			if (bitmapDataCache[symbolName + frameID + "_" + deg] != null && bitmapDataCache[symbolName + frameID + "_" + deg] is BitmapData) return BitmapData(bitmapDataCache[symbolName + frameID + "_" + deg]);
			
			var clip:DisplayObject = getDisplayObject(symbolName);
			
			if (frameLabel != "" && clip is MovieClip) MovieClip(clip).gotoAndStop(frameLabel);
			
			if (clip != null) {
				
				//clip.scaleX = clip.scaleY = scale;
				
				var bw:int = clip.width;
				var bh:int = clip.height;
				
				var bd:BitmapData = new BitmapData(Math.floor(bw * scale), Math.floor(bh * scale), true, 0x00000000);
				
				var m:Matrix = new Matrix();	
				m.createBox(scale, scale, rotation, Math.floor(bw * 0.5 * scale), Math.floor(bh * 0.5 * scale));
				
				bd.draw(clip, m);
				
				if (filters != null) {
					
					for (var i:int = 0; i < filters.length; i++) {
						
						bd.applyFilter(bd, new Rectangle(0, 0, bd.width, bd.height), new Point(0, 0), filters[i]);
						
					}
					
				}
				
				bitmapDataCache[symbolName] = bd;
				
				return bd;
				
			}
			
			return null;
			
		}
		
			
		
		//
		//
		public function getTextureAsBitmap (attribs:TextureAttributes, size:int = 120, borderType:int = 0):Bitmap {
			
			return new Bitmap(getTextureBitmapData(attribs, size, borderType), PixelSnapping.ALWAYS, false);
	
		}
		
		//
		//
		public function getTextureBitmapData (attribs:TextureAttributes, size:int = 120, borderType:int = 0):BitmapData {
			
			var bd:BitmapData;
			
			if (!TextureRenderingCache.hasTexture(attribs, size, borderType))
			{
				bd = new BitmapData(size * 4, size * 4, true, 0);
				bd.fillRect(bd.rect, 0xff000000 + attribs.diffuseColor);
				
				var job:TextureRenderingJob = new TextureRenderingJob().initWithProperties(attribs, bd, bd.rect, borderType, true, true, true);
				//textureQueue.renderImmediately(job);
				textureQueue.queueObject(job);
				TextureRenderingCache.setTexture(bd, attribs, size, borderType);
			} else {
				
				// texture may not be rendered yet, but using the same BitmapData will allow for it to update automatically.
				bd = TextureRenderingCache.getTexture(attribs, size, borderType);
			}
			
			return bd;
			
		}
		
		public function cleanTextureQueue ():void
		{
			TextureRenderingCache.queue = textureQueue;
			TextureRenderingCache.clearCache();
		}
		
		//
		//
		public function updateTexture (b:Bitmap, attribs:TextureAttributes, size:int = 120, borderType:int = 0):void {
			
			var bd:BitmapData = b.bitmapData;
			
			bd = getTextureBitmapData(attribs, size, borderType);
			if (bd != null) b.bitmapData = bd;
		}
		
	}
	
}