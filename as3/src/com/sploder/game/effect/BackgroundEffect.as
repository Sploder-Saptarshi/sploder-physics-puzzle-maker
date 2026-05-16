package com.sploder.game.effect 
{
	import com.sploder.builder.model.Environment;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class BackgroundEffect extends Shape
	{
		public static var skip:int = 1;
		
		protected var _width:uint = 0;
		protected var _height:uint = 0;
		protected var _built:Boolean = false;
		
		protected var bd:BitmapData;
		protected var bd2:BitmapData;
		protected var r:Rectangle;
		private var m:Matrix;
		private var m2:Matrix;
		
		protected var bdSize:uint = 200;
		protected var bdScale:Number = 2;
		protected var bdScale2:Number = 2;
		protected var bdSmooth:Boolean = true;
		
		protected var tx1:Number = 0;
		protected var ty1:Number = 0;
		protected var tx2:Number = 0;
		protected var ty2:Number = 0;
		
		protected var _cameraPX:int = 0;
		protected var _cameraPY:int = 0;
		public var cameraX:int = 0;
		public var cameraY:int = 0;
		
		public var animate:Boolean = true;
		protected var _isStatic:Boolean = false;
		
		protected var _fm:int = 0;
		
		protected var _type:String = Environment.EFFECT_NONE;
		
		public function BackgroundEffect (width:uint, height:uint) 
		{
			init(width, height);
		}
		
		protected function init (width:uint, height:uint):void
		{
			_width = width;
			_height = height;
			
			if (stage) {
				build();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, build);
			}
			
		}
		
		protected function build (e:Event = null):void {
			
			if (e) removeEventListener(Event.ADDED_TO_STAGE, build);
			
			if (_built) return;
			
			r = new Rectangle(0, 0, bdSize, bdSize);
			
			bd = new BitmapData(bdSize, bdSize, true, 0);
			draw(bd);
			bd2 = new BitmapData(bdSize, bdSize, true, 0);
			draw(bd2);
			
			m = new Matrix();
			m.createBox(bdScale, bdScale, 0, 0, 0);

			m2 = new Matrix();
			m2.createBox(bdScale2, bdScale2, 0, 0, 0);

			if (!animate) {
				update();
				_isStatic = true;
			} else if (tx1 == 0 && tx2 == 0 && ty1 == 0 && ty2 == 0) {
				update();
				_isStatic = true;
			} else {
				if (stage && animate) stage.addEventListener(Event.ENTER_FRAME, update);
				_isStatic = false;
			}
			
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			
			_built = true;
			
		}
		
		public function setSize (width:uint, height:uint):void {
			
			if (_width != width || _height != height) {
				_width = width;
				_height = height;			
				rebuild();
			}
			
		}
		
		public function rebuild ():void {
			
			onRemove();
			build();
			
		}
		
		protected function draw (bd:BitmapData):void {
			
			var x:int;
			var y:int;
			
			switch (_type) {
				
				case Environment.EFFECT_NONE:
					tx1 = 0;
					ty1 = 0;
					tx2 = 0;
					ty2 = 0;
					alpha = 1;
					break;
					
				case Environment.EFFECT_SNOW:
					bdScale = 2;
					bdScale2 = 1.5;

					tx1 = 0.0625;
					ty1 = 0.5;
					tx2 = 0.125;
					ty2 = 0.5;
					
					for (y = 0; y < bdSize; y++) {
						for (x = 0; x < bdSize; x++) {
							if (Math.random() > 0.995) bd.setPixel32(x, y, 0xffffffff);
						}
					}
					
					bd.applyFilter(bd, r, new Point(0, 0), new BlurFilter(1, 1, 3));
					bd.applyFilter(bd, r, new Point(0, 0), new GlowFilter(0xffffff, 1, 2, 2, 3, 3));
					bd.applyFilter(bd, r, new Point(0, 0), new BlurFilter(1, 1, 3));
					alpha = 1;
					bdSmooth = true;
					break;
				
				case Environment.EFFECT_RAIN:
					bdScale = 1;
					bdScale2 = 1;
					bdSmooth = false;
					
					tx1 = 0.125;
					ty1 = 1;
					tx2 = 1;
					ty2 = 2;
					
					var n:Boolean = true;
					for (x = -100; x < bdSize; x++) {
						for (y = -30; y < bdSize; y++) {
							if (y % 5 == 0 && Math.random() > 0.5) n = !n
							if (Math.floor(x) % 5 == 0 && n) {
								bd.setPixel32(x + y * 0.5, y, 0x15ffffff);
							}
						}
					}
					alpha = 1;
					break;
				
				case Environment.EFFECT_CLOUDS:
					bdScale = 2;
					bdSmooth = false;
					
					tx1 = 1;
					ty1 = 0;
					tx2 = 0.5;
					ty2 = 0;
					
					bd.perlinNoise(200, 20, 2, 3049 + Math.random() * 1000, true, true, BitmapDataChannel.ALPHA, true);
					alpha = 0.25;
					break;
				
				case Environment.EFFECT_STARS:
					bdScale = 1;
					tx1 = 0;
					ty1 = 0;
					tx2 = 0;
					ty2 = 0;
					bdSmooth = false;
					
					bd.perlinNoise(200, 200, 5, 3049 + Math.random() * 1000, true, true, 8, true);
					bd.merge(new BitmapData(bdSize, bdSize, true, 0), r, new Point(0, 0), 0, 0, 0, 200);
					var sc:uint = 0xffffffff;
					for (y = 0; y < bdSize; y++) {
						for (x = 0; x < bdSize; x++) {
							if (Math.random() > 0.5) sc = 0xffffccff;
							if (Math.random() > 0.5) sc = 0xffffcccc;
							if (Math.random() > 0.5) sc = 0xffffff99;
							if (Math.random() > 0.95) sc = 0xffccccff;
							if (Math.random() > 0.9995) {
								bd.setPixel32(x, y, sc);
								if (Math.random() > 0.85) {
									sc -= 0x66000000;
									bd.setPixel32(x - 1, y, sc);
									bd.setPixel32(x + 1, y, sc);
									bd.setPixel32(x, y - 1, sc);
									bd.setPixel32(x, y + 1, sc);
									sc -= 0x33000000;
									bd.setPixel32(x - 2, y, sc);
									bd.setPixel32(x + 2, y, sc);
									bd.setPixel32(x, y - 2, sc);
									bd.setPixel32(x, y + 2, sc);
								}
							}
						}
					}
					alpha = 1;
					break;
					
				case Environment.EFFECT_SILK:
					tx1 = 0;
					ty1 = 0;
					tx2 = 0;
					ty2 = 0;
					bdScale = 2;
					bdScale2 = 2;
					bdSmooth = false;
					bd.perlinNoise(60, 60, 1, 3049 + Math.random() * 1000, true, false, BitmapDataChannel.ALPHA, true);
					alpha = 0.5;
					bdSmooth = false;
					break;
				
				case Environment.EFFECT_LEAFY:
					tx1 = 0;
					ty1 = 0;
					tx2 = 0;
					ty2 = 0;
					bdScale = 1;
					bdScale2 = 1;
					bdSmooth = false;
					bd.perlinNoise(60, 60, 1, 3049 + Math.random() * 1000, true, false, BitmapDataChannel.ALPHA, true);
					ReduceColors.toEGA(bd);
					alpha = 0.25;
					break;
					
				case Environment.EFFECT_SMOKE:
					tx1 = 0.5;
					ty1 = 0;
					tx2 = 0.25;
					ty2 = 0;
					bdScale = 2;
					bdScale2 = 1;
					bdSmooth = false;
					bd.perlinNoise(200, 100, 2, 3049 + Math.random() * 1000, true, false, BitmapDataChannel.ALPHA, true);
					var wbd:BitmapData = new BitmapData(bdSize, bdSize, true, 0xffffffff);
					bd.copyChannel(wbd, r, new Point(0, 0), 1, 1);
					bd.copyChannel(wbd, r, new Point(0, 0), 2, 2);
					bd.copyChannel(wbd, r, new Point(0, 0), 4, 4);
					
					ReduceColors.toVGA(bd, false, true);
					alpha = 0.5;
					break;
					
				case Environment.EFFECT_GRID:
					tx1 = 0;
					ty1 = 0;
					tx2 = 0;
					ty2 = 0;
					bdScale = 1;
					bdScale2 = 1;
					bdSmooth = false;
					for (x = 0; x < bdSize; x++) {
						for (y = 0; y < bdSize; y++) {
							if ((x + 10) % 20 == 0 && (y + 10) % 20 == 0) bd.setPixel32(x, y, 0x33ffffff);
						}
					}
					alpha = 1;
					break;
				
			}
			
			tx1 *= skip;
			ty1 *= skip;
			
		}
		
		public function update (e:Event = null):void {

			if (skip > 1) {
				_fm++;
				if (_fm % skip != 0) return;
				_fm = 0;
			}
			
			
			var g:Graphics = graphics;
			g.clear();
			
			m.tx += tx1;
			m.ty += ty1;
			m.ty %= bdSize * bdScale;
			m.tx %= bdSize * bdScale;
			m.tx -= cameraX - _cameraPX;
			m.ty -= cameraY - _cameraPY;
			g.beginBitmapFill(bd, m, true, bdSmooth);
			g.drawRect(0, 0, _width, _height);
			g.endFill();		

			m2.tx += tx2;
			m2.ty += ty2;
			m2.ty %= bdSize * bdScale2;
			m2.tx %= bdSize * bdScale2;
			m2.tx -= cameraX - _cameraPX;
			m2.ty -= cameraY - _cameraPY;
			g.beginBitmapFill(bd2, m2, true, bdSmooth);
			g.drawRect(0, 0, _width, _height);
			g.endFill();
			
			_cameraPX = cameraX;
			_cameraPY = cameraY;
			
		}
		
		protected function onRemove (e:Event = null):void {
			
			if (!_built) return;
			
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			stage.removeEventListener(Event.ENTER_FRAME, update);
			if (bd) bd.dispose();
			if (bd2) bd2.dispose();
			graphics.clear();
			_built = false;
			
			if (e) addEventListener(Event.ADDED_TO_STAGE, build);
			
		}
		
		public function get type():String { return _type; }
		
		public function set type(value:String):void 
		{
			if (value != _type) {
				_type = value;
				rebuild();
			}
		}
		
		public function get isStatic():Boolean { return _isStatic; }
		
		public function end ():void {
			
			if (stage) stage.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			if (stage) stage.removeEventListener(Event.ENTER_FRAME, update);
			
			if (parent) parent.removeChild(this);
			
			if (bd) bd.dispose();
			if (bd2) bd2.dispose();
			
			graphics.clear();
			
			_built = false;
			
		}
		
		
	}

}