package com.sploder.game {

	import flash.geom.Point;
	import flash.utils.getTimer;
	import nape.phys.Body;
	
	public class Camera {
		
		protected var _target:Point;
		public function get target ():Point { return _target; }
		
		protected var _pixelSnap:Boolean = false;
		public function get pixelSnap():Boolean { return _pixelSnap; }
		public function set pixelSnap(value:Boolean):void {	_pixelSnap = value; }
		
		protected var _watching:Boolean = false;
		public function get watching ():Boolean { return _watching; }
		
		protected var _chasing:Boolean = false;
		public function get chasing ():Boolean { return _chasing; }
		
		protected var _alignToTarget:Boolean = false;
		public function get alignToTarget():Boolean { return _alignToTarget; }
		public function set alignToTarget(value:Boolean):void { _alignToTarget = value; }
		
		protected var _x:Number = 0;
		protected var _y:Number = 0;

		protected var _lastTime:Number = 0;
		protected var _duration:Number;
		protected var _delta:Number = 1;
		
		private var _watchObject:Body;
		public function get watchObject():Body { return _watchObject; }
		
		private var _watchOffsetPoint:Point;
		private var _watchElasticity:Number;
	
		private var _shakeTime:Number = -3000;
		
		public function get x():Number { return _x; }

		public function get y():Number 
		{
			if (getTimer() -_shakeTime < 500) {
				return _y + Math.sin((getTimer() - _shakeTime - 100) / 15) * 20 * (500 -(getTimer() - _shakeTime)) / 500;
			} else {
				return _y;
			}
		}
		
		
	
		//
		//
		public function Camera (x:Number = 0, y:Number = 0, target:Point = null) {
			
			if (target != null) {
				_target = new Point(target.x, target.y);
			} else {
				_target = new Point(0, 0);
			}

		}
		
		//
		//
		public function update ():void {

			doActions();
			
		}
		
		//
		//
		private function doActions ():void {
			
			_duration = getTimer() - _lastTime;
			_delta = Math.min(1, _duration / 33);

			_lastTime = getTimer();
			
			if (_watching) {
				watch();
			}
				
		}
		
		//
		public function startWatching (body:Body, elasticity:Number = 1, offsetPoint:Point = null, alignToTarget:Boolean = false):void {
			
			_watchObject = body;
			_watchElasticity = Math.max(1, elasticity);
			
			_alignToTarget = alignToTarget;
			
			if (offsetPoint == null) {
				_watchOffsetPoint = new Point(0, 0);
			} else {
				_watchOffsetPoint = offsetPoint.clone();
			}

			_watching = true;
	
		}
		
		//
		public function stopWatching (newFocus:Point = null):void {
			
			_watching = false;

			if (newFocus != null) _target = newFocus.clone();
			
		}
		
		//
		private function watch ():void {

			if (target == null) { stopWatching(); return; }
			if (watchObject && !watchObject.added_to_space) { stopWatching(); return; }
			
			var ease:Number = _watchElasticity / _delta;

			var deltaX:Number = (_watchObject.px - _target.x) / ease;
			var deltaY:Number = (_watchObject.py - _target.y) / ease;


			if (_pixelSnap) {
				
				deltaX = Math.round(deltaX)
				deltaY = Math.round(deltaY);
		
			}
			
			_target.x += deltaX;
			_target.y += deltaY;
			
			_x = _target.x;
			_y = _target.y;	

		}
		
		//
		public function alignTo(b:Body, position:Boolean = true):void 
		{

			_x = _target.x = b.px;
			_y = _target.y = b.py;
			
		}
		
		public function shake ():void {
			
			_shakeTime = getTimer();
			
		}
				
	}
	
}
