package com.sploder.builder
{
	import com.sploder.util.PM_PRNG;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Shapes
	{
		public static var origin:Point;
		
		public static function drawShape (g:Graphics, vertices:Vector.<Point>, offset:Point = null, fillColor:uint = 0, fillAlpha:Number = 1, lineThickness:Number = NaN, lineColor:uint = 0, lineAlpha:Number = 0, clear:Boolean = true, sharpCorners:Boolean = false):void {
			
			if (offset == null) {
				if (origin == null) origin = new Point();
				offset = origin;
			}
			
			var pt:Point;
			var i:int;
			
			if (g && vertices && vertices.length > 0) {
				
				if (clear) g.clear();
				g.beginFill(fillColor, fillAlpha);
				if (sharpCorners) {
					g.lineStyle(lineThickness, lineColor, lineAlpha, true, "normal", CapsStyle.SQUARE, JointStyle.MITER);
				} else {
					g.lineStyle(lineThickness, lineColor, lineAlpha);
				}
				
				i = 0;
				pt = vertices[i];
				
				g.moveTo(pt.x + offset.x, pt.y + offset.y);
				
				for (i = 1; i < vertices.length; i++) {
					
					pt = vertices[i];
					g.lineTo(pt.x + offset.x, pt.y + offset.y);
					
				}
				
				g.endFill();
				
			}
			
		}
		
		public static function drawTexture (g:Graphics, vertices:Vector.<Point>, bitmapData:BitmapData, m:Matrix, offset:Point = null, smoothing:Boolean = false):void {
			
			if (offset == null) {
				if (origin == null) origin = new Point();
				offset = origin;
			}
			
			var pt:Point;
			var i:int;
			
			if (g && vertices && vertices.length > 0) {
				
				g.beginBitmapFill(bitmapData, m, true, smoothing);
				
				i = 0;
				pt = vertices[i];
				
				g.moveTo(pt.x + offset.x, pt.y + offset.y);
				
				for (i = 1; i < vertices.length; i++) {
					
					pt = vertices[i];
					g.lineTo(pt.x + offset.x, pt.y + offset.y);
					
				}
				
				g.endFill();
				
			}
			
		}
		
		public static function drawCircle (g:Graphics, size:Number, offset:Point = null, fillColor:uint = 0, fillAlpha:Number = 1, lineThickness:Number = NaN, lineColor:uint = 0, lineAlpha:Number = 0, clear:Boolean = true):void {
			
			if (offset == null) {
				if (origin == null) origin = new Point();
				offset = origin;
			}
			
			if (clear) g.clear();
			
			g.beginFill(fillColor, fillAlpha);
			g.lineStyle(lineThickness, lineColor, lineAlpha);
			g.drawCircle(offset.x, offset.y, size);
			g.endFill();
			
		}
		
		public static function getVertices (shape:String, width:Number, height:Number, maxLineLength:Number = 0, scribbleAmount:Number = 0, seed:uint = 1):Vector.<Point> {
			
			var v:Vector.<Point> = new Vector.<Point>();
			
			var sides:int = 0;
			var a:Number = 0;	
			var r:Number = Math.max(width, height) / 2;			
			var s:Number = 0;
			var i:uint;
					
			switch (shape) {
				
				case CreatorUIStates.SHAPE_SQUARE:
				case CreatorUIStates.SHAPE_BOX:
				
					v.push(new Point(0 - width / 2, 0 - height / 2));
					v.push(new Point(width / 2, 0 - height / 2));
					v.push(new Point(width / 2, height / 2));
					v.push(new Point(0 - width / 2, height / 2));
					
					break;
					
				case CreatorUIStates.SHAPE_RAMP:
					
					v.push(new Point(width / 2, 0 - height / 2));
					v.push(new Point(width / 2, height / 2));
					v.push(new Point(0 - width / 2, height / 2));
					
					break;
					
				case CreatorUIStates.SHAPE_CIRCLE:
					if (r > 80) sides = 36;
					else if (r > 40) sides = 24;
					else if (r > 20) sides = 18;
					else sides = 12; 
				case CreatorUIStates.SHAPE_HEX:
					if (sides == 0) sides = 6;
				case CreatorUIStates.SHAPE_PENT:
					if (sides == 0) sides = 5;
					a = 0;						
					s = Math.PI * 2 / sides;
					for (i = 0; i <= sides; ++i) {
						v.push(new Point(r * Math.cos(a + s * i), r * Math.sin(a + s * i)));
					}
					break;
				
			}	
			
			if (maxLineLength > 0 || scribbleAmount > 0) {
				v = tesselate(v, maxLineLength, scribbleAmount, seed);
				if (shape == CreatorUIStates.SHAPE_CIRCLE) {
					v.pop();
				}
			}
			
			
			return v;
			
		}
		
		public static function tesselate (vertices:Vector.<Point>, maxLineLength:Number = 0, scribbleAmount:Number = 0, seed:uint = 1):Vector.<Point> {
			
			var v:Vector.<Point> = vertices.concat();
			var i:int;
			var nx:Number;
			var ny:Number;
			var dx:Number;
			var dy:Number;
			var lensq:Number;
			var maxlensq:Number = maxLineLength * maxLineLength;
			var newpt:Point;
			
			if (v.length > 2 && maxLineLength > 0) {
				
				i = v.length;
				nx = v[0].x;
				ny = v[0].y;
				
				while (i--) {
					
					dx = nx - v[i].x;
					dy = ny - v[i].y;
					lensq = dx * dx + dy * dy;
					
					while (lensq > maxlensq) {
						
						newpt = new Point(v[i].x + dx * 0.5, v[i].y + dy * 0.5);
						v.splice(i + 1, 0, newpt);
						i += 1;
						dx *= 0.5;
						dy *= 0.5;
						lensq = dx * dx + dy * dy;
						
					}
					nx = v[i].x;
					ny = v[i].y;
					
				}
				
			}
			
			if (scribbleAmount > 0) {
				
				i = v.length;
				
				var minx:Number = 10000;
				var maxx:Number = -10000;
				var miny:Number = 10000;
				var maxy:Number = -10000;				

				while (i--) {
					
					minx = Math.min(minx, v[i].x);					
					maxx = Math.max(maxx, v[i].x);					
					miny = Math.min(miny, v[i].y);
					maxy = Math.max(maxy, v[i].y);
					
				}
				
				var w:Number = maxx - minx;
				var h:Number = maxy - miny;
				var mind:Number = Math.min(w, h);
				
				if (mind < scribbleAmount * 20) {
					scribbleAmount /= mind / 20;
				}
				
				i = v.length;
				
				var p:PM_PRNG = new PM_PRNG();
				p.seed = seed;

				while (i--) {
					
					v[i].x += p.nextDouble() * scribbleAmount - scribbleAmount * 0.5;
					v[i].y += p.nextDouble() * scribbleAmount - scribbleAmount * 0.5;
					
				}
				
			}
			
			return v;
			
		}
		
	}

}