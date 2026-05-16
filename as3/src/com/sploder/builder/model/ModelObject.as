package com.sploder.builder.model 
{
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.data.DataManifest;
	import com.sploder.util.Closest;
	import com.sploder.util.Geom2d;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Geoff
	 */
	public class ModelObject extends EventDispatcher 
	{
		public static const STATE_NEW:int = 0;
		public static const STATE_IDLE:int = 1;
		public static const STATE_SELECTED:int = 2;
		public static const STATE_DRAGGING:int = 3;
		
		protected static var _nextID:int = 1;
		protected var _id:int = 0;
		
		public static function resetNextID ():void {
			_nextID = 1;
		}

		protected var _props:ModelObjectProperties;
		protected var _deleted:Boolean = false;
		protected var _group:ModelObjectContainer;
		protected var _groupID:int = 0;
		
		protected var _clip:ModelObjectSprite;
		protected var _origin:Point;
		protected var _pin:Point;
		protected var _offset:Point;
		protected var _rotation:int = 0;
		protected var _state:int = STATE_NEW;
		protected var _focused:Boolean = false;

		public function get props():ModelObjectProperties { return _props; }
		public function get deleted():Boolean { return _deleted; }
		
		public function get clip():ModelObjectSprite { return _clip; }
		
		public function get origin():Point { return _origin; }
		public function get pin():Point { return _pin; }
		public function get offset():Point { return _offset; }
		
		public function get x():Number {
			return _origin.x + _offset.x;
		}
		
		public function get y():Number {
			return _origin.y + _offset.y;
		}
		
		public function get rotation():int { return _rotation; }
		public function set rotation(value:int):void 
		{
			_rotation = value;
			update();
		}
		
		public function get state():int { return _state; }
		public function set state(value:int):void 
		{
			_state = value;
			update();
		}
		
		public function get group():ModelObjectContainer { return _group; }
		public function set group(value:ModelObjectContainer):void 
		{
			if (_group == null || value == null) _group = value;
			_groupID = (_group == null) ? 0 : _group.id;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get groupID():int { return _groupID; }
		
		public function get focused():Boolean { return _focused; }
		public function set focused(value:Boolean):void 
		{
			_focused = value;
			update();
		}
		
		public function get id():int { return _id; }
		
		
		
		public function ModelObject (sourceObject:ModelObject = null)
		{
			init(sourceObject);
		}
		
		protected function init (sourceObject:ModelObject = null):void
		{
			_id = _nextID;
			_nextID++;
			
			if (sourceObject) {
				_origin = sourceObject.origin.clone();
				_pin = sourceObject.pin.clone();
				_rotation = sourceObject.rotation;
				_props = sourceObject.props.clone();
			} else {
				_origin = new Point();
				_pin = new Point();
				_props = new ModelObjectProperties();
			}
			
			_offset = new Point();
			_clip = new ModelObjectSprite(this);

			_props.addEventListener(Event.CHANGE, onChangeProps);
			_clip.buttonMode = true;
		}
		
		public function update ():void {
			
			if (_clip) _clip.draw();
			dispatchEvent(new Event(Event.CHANGE));
			
		}
		
		public function updateFromVector (vec:Point, anchor:Point, anchor_location:String = CreatorUIStates.ORIGIN, snap:Boolean = false, angleSnap:Boolean = false):void {
			
			var t:Number;
			var l:Number;
			var w:Number;
			var h:Number;
			var v:Point = vec;
			var a:Point = anchor;
					
			switch (anchor_location) {
				
				case CreatorUIStates.TOP_LEFT:
				case CreatorUIStates.TOP_RIGHT:
				case CreatorUIStates.BOTTOM_LEFT:
				case CreatorUIStates.BOTTOM_RIGHT:
				
					if (_rotation != 0) {
						v = v.clone();
						Geom2d.rotate(v, 0 - _rotation * Geom2d.dtr);
						a = a.subtract(_origin);
						Geom2d.rotate(a, 0 - _rotation * Geom2d.dtr);
						a = a.add(_origin);
						snap = false;
					}
					
					t = a.y;
					l = a.x;
					
					if (_props.shape != CreatorUIStates.SHAPE_RAMP) {
						
						w = Math.abs(v.x);
						h = Math.abs(v.y);
						
					} else {
						
						w = v.x;
						h = v.y;
						
						switch (anchor_location) {
							
							case CreatorUIStates.TOP_RIGHT:
								h = 0 - h;
								t -= h;
								break;
								
							case CreatorUIStates.BOTTOM_LEFT:
								w = 0 - w;
								l -= w;
								break;
							
						}
						
					}
					
					if (snap) {
						t = Math.round(t / 10) * 10;
						l = Math.round(l / 10) * 10;
						w = Math.round(w / 10) * 10;
						h = Math.round(h / 10) * 10;
					}
					
					if (_props.shape != CreatorUIStates.SHAPE_RAMP) {
						
						switch (anchor_location) {
							
							case CreatorUIStates.TOP_LEFT:
								l -= (v.x < 0) ? w : 0 - w;
								t -= (v.y < 0) ? h : 0 - h;
								if (v.x > 0) l -= w;
								if (v.y > 0) t -= h;
								break;
								
							case CreatorUIStates.TOP_RIGHT:
								t -= (v.y < 0) ? h : 0 - h;
								if (v.x < 0) l -= w;
								if (v.y > 0) t -= h;
								break;
								
							case CreatorUIStates.BOTTOM_LEFT:
								l -= (v.x < 0) ? w : 0 - w;
								if (v.x > 0) l -= w;
								if (v.y < 0) t -= h;
								break;
							
							case CreatorUIStates.BOTTOM_RIGHT:
								if (v.x < 0) l -= w;
								if (v.y < 0) t -= h;
								break;
							
						}
					
					}
					
					if (_rotation == 0) {
						_origin.x = l;
						_origin.y = t;
						_origin.x += w / 2;
						_origin.y += h / 2;
					} else {
						_origin.x = anchor.x + (vec.x / 2);
						_origin.y = anchor.y + (vec.y / 2);
					}
					_props.width = w;
					_props.height = h;

					break;		
					
				case CreatorUIStates.ORIGIN:
				
					if (_props.shape != CreatorUIStates.SHAPE_BOX && 
						_props.shape != CreatorUIStates.SHAPE_POLY &&
						_props.shape != CreatorUIStates.SHAPE_RAMP) {
						_props.size = (snap) ? Math.round(v.length / 10) * 10 : v.length;
					}
					
					_rotation = Math.atan2(v.y, v.x) * 180 / Math.PI + 90;
					
					if (_state == STATE_NEW && 
						(_props.shape == CreatorUIStates.SHAPE_SQUARE || 
						 _props.shape == CreatorUIStates.SHAPE_CIRCLE)) _rotation = 0;
						 
					if (angleSnap) {
						_rotation = Math.round(_rotation / 45) * 45;
					} else if (snap) {
						_rotation = Math.round(_rotation / 10) * 10;
					}
					break;
				
			}
			
			dispatchEvent(new Event(Event.CHANGE));
			
		}
		
		protected function onChangeProps (e:Event):void {
			update();
		}
		
		public function setPinPosition (pos:Point):void {
		
			_pin.x = pos.x;
			_pin.y = pos.y;
			update();
		}
		
		public function localToGlobal (pt:Point):Point {
			
			pt = pt.clone();
			if (rotation != 0) Geom2d.rotate(pt, rotation * Geom2d.dtr);
			pt.x += _origin.x;
			pt.y += _origin.y;
			
			return pt;
			
		}
		
		public function centerVertices ():void {
			
			if (_rotation == 0 && _props && _props.vertices) {
				
				var xmin:Number = 10000;
				var xmax:Number = -10000;
				var ymin:Number = 10000;
				var ymax:Number = -10000;
				var w:Number = 0;
				var h:Number = 0;
				var xdiff:Number = 0;
				var ydiff:Number = 0;
				var i:int;
				
				i = _props.vertices.length;
			
				while (i--) {
					xmin = Math.min(xmin, _props.vertices[i].x);
					xmax = Math.max(xmax, _props.vertices[i].x);
					ymin = Math.min(ymin, _props.vertices[i].y);
					ymax = Math.max(ymax, _props.vertices[i].y);
				}
				
				w = xmax - xmin;
				h = ymax - ymin;
				xdiff = xmin + w / 2;
				ydiff = ymin + h / 2;
				
				xdiff += 0 - (xdiff + _origin.x) % 5;
				ydiff += 0 - (ydiff + _origin.y) % 5;
				
				i = _props.vertices.length;
			
				while (i--) {
					_props.vertices[i].x -= xdiff;
					_props.vertices[i].y -= ydiff; 
				}
				
				_origin.x += xdiff;
				_origin.y += ydiff;
				_props.width = Math.abs(w);
				_props.height = Math.abs(h);
				
				update();
			}
			
		}
		
		public function setVertexPosition (vertexIndex:int, pos:Point):void
		{
			if (_props && _props.vertices && _props.vertices.length > vertexIndex) {
				
				if (_rotation != 0) {
					pos = pos.clone();
					Geom2d.rotate(pos, 0 - _rotation * Geom2d.dtr);
				}
				
				_props.vertices[vertexIndex].x = Math.floor((pos.x - origin.x) / 10) * 10 + origin.x;
				_props.vertices[vertexIndex].y = Math.floor((pos.y - origin.y) / 10) * 10 + origin.y;
				update();
			}
		}
		
		public function deleteVertex (vertexIndex:int):void
		{
			if (_props && _props.vertices && _props.vertices.length > vertexIndex) {

				_props.vertices.splice(vertexIndex, 1);
				_clip.removeVertexHandle(vertexIndex);
				update();
			}
		}
		
		public function addVertex ():void
		{
			if (_props && _props.vertices && _props.vertices.length > 1) {

				var vertex:Point = new Point(_clip.mouseX, _clip.mouseY);
				
				var v:Array = [];
				
				for (var i:int = 0; i < _props.vertices.length; i++) {
					v.push( {
						index: i,
						dist: Closest.distanceFromLine(vertex, _props.vertices[i], 
							(i + 1 < _props.vertices.length) ? 
								_props.vertices[i + 1] : _props.vertices[0])
					});
				}
				
				v.sortOn("dist", Array.NUMERIC);
				
				if (v.length > 1) {
					
					var newIndex:int = v[0].index + 1;
					_props.vertices.splice(newIndex, 0, vertex);
					_clip.addVertexHandle();
					update();
					
				}
				
			}
		}
		
		public function isValid ():Boolean
		{
			if (_props && _props.shape == CreatorUIStates.SHAPE_POLY) {
				if (_props.vertices) return true;
			}
			return !_deleted && (_props.width != 0 && _props.height != 0);	
		}
		
		public function clone ():ModelObject {
			
			return new ModelObject(this);
			
		}
		
		override public function toString ():String
		{
			if (_deleted) return "";
			
			var v:Array = [
				_id,
				DataManifest.pointToString(_origin),
				DataManifest.pointToString(_pin),
				_rotation,
				_groupID,
				_props.toString()
				];
			
			return v.join("#");
				
		}
		
		public function fromString (data:String):int
		{
			var v:Array = data.split("#");
			
			_clip.suspend();
			var localID:int = parseInt(v[0]);

			DataManifest.stringToPoint(v[1], _origin);
			DataManifest.stringToPoint(v[2], _pin);
			_rotation = parseInt(v[3]);
			_groupID = parseInt(v[4]),
			_props.fromString(v[5]);
			_state = STATE_IDLE;
			_clip.release();
			
			update();
			
			return localID;
			
		}
		
		public function destroy ():void {
			if (!_deleted) {
				if (_group) _group.removeObject(this);
				
				_deleted = true;
				
				if (_props) _props.removeEventListener(Event.CHANGE, onChangeProps);
				if (_clip && _clip.parent) _clip.parent.removeChild(_clip);
				
				_props = null;
				_clip = null;
				dispatchEvent(new Event(Event.CLEAR));
			}
		}
		
	}

}