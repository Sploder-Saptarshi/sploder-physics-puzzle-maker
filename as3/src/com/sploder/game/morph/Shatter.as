package com.sploder.game.morph
{

	import com.sploder.game.ViewSprite;
	import com.sploder.util.delaunay.Delaunay;
	import com.sploder.util.delaunay.XYZ;
	import com.sploder.util.Geom2d;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	/**
	 * ...
	 * @author Geoff
	 */
	public class Shatter extends Morph {

		public static var gravPull:int = 2;
		
		public var fragments:Array;
		
		protected var force:Point;
		protected var contact:Point;
		
		protected var explosionScale:Number;

		protected var vectors:Dictionary;
		
		protected var hullOffset:int = 0;
		
		protected var gravPt:Point;
		
		protected var turbo:Boolean = false;
		
		public function Shatter (clip:ViewSprite, vertices:Vector.<Point>, tesselation:Number = 40, doExplode:Boolean = true, explosionFactor:Number = 1, shatterForce:Point = null, contactPoint:Point = null, color:uint = 0, turbo:Boolean = false) {

			super(clip, 990, false);
			
			vectors = new Dictionary();
			
			if (!doExplode) hullOffset = Math.max(clip.width, clip.height) / 10;
			
			if (shatterForce != null) force = shatterForce;
			else force = new Point(0, 0);
			
			gravPt = new Point(0, gravPull);
			
			this.turbo = turbo;
			
			doShatter(vertices, tesselation, color);
			if (clip.parent) clip.parent.removeChild(clip);
			
			if (doExplode) {
				explosionScale = 100 / Math.max(clip.width, clip.height);
				explosionScale *= explosionFactor;
			}
			
			if (doExplode) {
				if (stage) startMorph();
				else addEventListener(Event.ADDED_TO_STAGE, startMorph);
			}
			
		}
		
		override public function startMorph (e:Event = null):void 
		{
			
			var pt:Point = new Point();
			
			for each (var shape:Shape in fragments) {

				pt.x = (contact != null) ? 0 - contact.x * 0.5 + shape.x : shape.x;
				pt.y = (contact != null) ? 0 - contact.y * 0.5 + shape.y : shape.y;
				shape.alpha = 2;
				vectors[shape] = new Point((pt.x / 4 + force.x) * explosionScale * (Math.random() + 0.5), (pt.y / 4 + force.y) * explosionScale * (Math.random() + 0.5));
				
			}
			
			super.startMorph();
			
		}
		
		public function scaleFragments (scale:Number = 1):void {
			
			for each (var shape:Shape in fragments) {
				
				shape.scaleX = shape.scaleY = scale;

			}
			
		}
		
		override protected function doMorph(e:Event):void 
		{	
			
			if (_clip == null) return;
			if  (fragments == null) return;
			
			for each (var shape:Shape in fragments) {
				
				try {
					if (shape && vectors[shape]) {
						shape.x += vectors[shape].x;
						shape.y += vectors[shape].y;
						vectors[shape].x += gravPt.x;
						vectors[shape].y += gravPt.y;
						vectors[shape].x *= 0.95;
						vectors[shape].y *= 0.95;
						shape.scaleX *= 0.98;
						shape.scaleY *= 0.98;
						shape.rotation += (vectors[shape].x + vectors[shape].y);
						shape.alpha *= 0.95;
					}
				} catch (e:Error) {
					
				}
				
			}
			
			super.doMorph(e);
			
		}
		
		override protected function completeMorph():void 
		{
			super.completeMorph();
	
			vectors = null;

		}	
		
		protected function pointsClone (points:Vector.<Point>):Vector.<Point> {
			if (points) {
				var p:Vector.<Point> = new Vector.<Point>();
				var i:int = points.length;
				while (i--) p.unshift(points[i].clone());
				return p;
			}
			return null;
		}

		protected function doShatter (points:Vector.<Point>, tesselation:Number = 40, color:uint = 0xffffff):void {
			
			var time:int;
			var i:int;
			var j:int;
			var u:Number;
			var v:Number;
			var r:Number = _clip.rotation;
			_clip.rotation = 0;
			
			time = getTimer();
			points = pointsClone(points);
			
			while (Math.min(_clip.width, _clip.height) < tesselation * 2) tesselation /= 2;
			
			for (j = 0 - _clip.height / 2; j < _clip.height / 2; j += tesselation) {
				
				for (i = 0 - _clip.width / 2; i < _clip.width / 2; i += tesselation) {
					
					if (parent && hitTestPoint(x + parent.x + i, y + parent.y + j, true)) {
						
						u = i;
						v = j;
						
						if (i > 0 - _clip.width / 2 + 10 && i < _clip.width / 2 - 10) {
							u += Math.random() * tesselation / 2 - tesselation / 4;
						}
						
						if (j > 0 - _clip.height / 2 + 10 && j < _clip.height / 2 - 10) {
							v += Math.random() * tesselation / 2 - tesselation / 4;
						}
						
						if (Math.random() > 0.3) points.push(new Point(u, v));
						
					}
					
				}
				
			}
			
			if  (r != 0) {
				i = points.length;
				var rot:Number = r * Geom2d.dtr;
				while (i--) {
					Geom2d.rotate(points[i], rot);
				}
			}
			
			if (points.length > 2) {
				
				var XYZs:Array = [];
				
				for (i = 0; i < points.length; i++) {
					
					XYZs.push(new XYZ(points[i].x, points[i].y));
					
				}
				
				var triangles:Array = Delaunay.triangulate(XYZs);

				fragments = Delaunay.drawDelaunay(triangles, XYZs, this, color, 1, turbo);
				
			}

		}
		
	}

}