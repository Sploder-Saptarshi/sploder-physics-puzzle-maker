package com.sploder.builder.model 
{
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.data.DataManifest;
	import com.sploder.texturegen_internal.TextureAttributes;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.describeType;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class ModelObjectProperties extends EventDispatcher
	{
		public static const LAYER_COLLISION:int = 0;
		public static const LAYER_SENSOR:int = 1;
		public static const LAYER_PASSTHRU:int = 2;
		
		protected var _width:int = 0;
		protected var _height:int = 0;

		protected var _shape:String = CreatorUIStates.SHAPE_NONE;
		protected var _constraint:String = CreatorUIStates.MOVEMENT_FREE;
		protected var _material:String = CreatorUIStates.MATERIAL_WOOD;
		protected var _strength:String = CreatorUIStates.STRENGTH_PERM;
		
		protected var _locked:Boolean = false;
		
		protected var _vertices:Vector.<Point>;
		
		protected var _collision_group:int = 31;
		protected var _passthru_group:int = -1;
		protected var _sensor_group:int = 0;
		
		protected var _color:int = 0;
		protected var _line:int = -1;
		protected var _zlayer:int = 3;
		protected var _clip:uint = 0;
		protected var _opaque:uint = 1;
		protected var _scribble:uint = 0;
		protected var _texture:uint = 0;
		
		protected var _actions:uint = 0x00000000;
		
		protected var _graphic:uint = 0
		protected var _graphic_version:uint = 0;
		protected var _graphic_flip:uint = 0;
		protected var _animation:uint = 0;
		protected var _custom_texture:String = "";
		protected var _attribs:TextureAttributes;
		
		public function ModelObjectProperties () 
		{
			
		}
		
		public function get width():int { return _width; }
		public function set width(value:int):void 
		{
			_width = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get height():int { return _height; }
		public function set height(value:int):void 
		{
			_height = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get shape():String { return _shape; }
		public function set shape(value:String):void 
		{
			_shape = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get constraint():String { return _constraint; }
		public function set constraint(value:String):void 
		{
			_constraint = value;
			if (_constraint == CreatorUIStates.MOVEMENT_STATIC) _locked = false;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get material():String { return _material; }
		public function set material(value:String):void 
		{
			_material = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get strength():String { return _strength; }
		public function set strength(value:String):void 
		{
			_strength = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get size():int { return Math.max(_width, _height) / 2; }
		public function set size(value:int):void 
		{
			_width = _height = value * 2;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get locked():Boolean { return _locked; }
		public function set locked(value:Boolean):void 
		{
			_locked = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get vertices():Vector.<Point> { return _vertices; }
		public function set vertices(value:Vector.<Point>):void 
		{
			_vertices = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get collision_group():int { return _collision_group; }
		public function set collision_group(value:int):void 
		{
			_collision_group = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get passthru_group():int { return _passthru_group; }
		public function set passthru_group(value:int):void 
		{
			_passthru_group = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get sensor_group():int { return _sensor_group; }
		public function set sensor_group(value:int):void 
		{
			_sensor_group = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get color():int { return _color; }
		public function set color(value:int):void 
		{
			_color = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get line():int { return _line; }
		public function set line(value:int):void 
		{
			_line = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get zlayer():int { return _zlayer; }	
		public function set zlayer(value:int):void 
		{
			_zlayer = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get clip():uint { return _clip; }
		public function set clip(value:uint):void 
		{
			_clip = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get opaque():uint { return _opaque; }
		public function set opaque(value:uint):void 
		{
			_opaque = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get scribble():uint { return _scribble; }
		public function set scribble(value:uint):void 
		{
			_scribble = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get texture():uint { return _texture; }
		public function set texture(value:uint):void 
		{
			_texture = value;
			if (_texture > 0)
			{
				_attribs = null;
				_custom_texture = "";
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get actions():uint 
		{
			return _actions;
		}
		
		public function set actions(value:uint):void 
		{
			_actions = value;
		}
		
		public function get graphic():uint 
		{
			return _graphic;
		}
		
		public function set graphic(value:uint):void 
		{
			_graphic = value;
			if (_graphic > 0)
			{
				_attribs = null;
				_custom_texture = "";
			}
		}
		
		public function get graphic_version():uint 
		{
			return _graphic_version;
		}
		
		public function set graphic_version(value:uint):void 
		{
			_graphic_version = value;
		}
		
		public function get graphic_flip():uint 
		{
			return _graphic_flip;
		}
		
		public function set graphic_flip(value:uint):void 
		{
			_graphic_flip = value;
		}
		
		public function get animation():uint 
		{
			return _animation;
		}
		
		public function set animation(value:uint):void 
		{
			_animation = value;
		}
		
		public function get textureName ():String {
			
			if (_graphic > 0 && _graphic_version > 0) {
				return _graphic + "_" + _graphic_version;
			} else if (_texture > 0) {
				return CreatorUIStates.textures[_texture];
			}
			
			return "";
			
		}
		
		public function get custom_texture():String 
		{
			return _custom_texture;
		}
		
		public function set custom_texture(value:String):void 
		{
			_custom_texture = value;
			if (_custom_texture != null && _custom_texture.length > 0)
			{
				if (_attribs == null) _attribs = new TextureAttributes().initWithData(_custom_texture);
				else _attribs.unserialize(_custom_texture);
				_graphic = _graphic_version = _graphic_flip = _animation = _texture = 0;
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get attribs():TextureAttributes 
		{
			return _attribs;
		}
		
		public function set attribs(value:TextureAttributes):void 
		{
			_attribs = value;
		}

		public function verticesClone ():Vector.<Point> {
			if (_vertices) {
				var v:Vector.<Point> = new Vector.<Point>();
				var i:int = _vertices.length;
				while (i--) v.unshift(_vertices[i].clone());
				return v;
			}
			return null;
		}
		
		public function clone ():ModelObjectProperties
		{
			var p:ModelObjectProperties = new ModelObjectProperties();
			var n:String;
			
			var params:XMLList = describeType(p)..accessor;
			for each (var param:XML in params) {
				n = param.@name;
				if (param.@access == "readwrite" && n != "size") {
					p[n] = this[n];
				}
			}
			
			p.vertices = verticesClone();
			
			return p;
		}
		

		override public function toString ():String {
			
			var m:Array = DataManifest.modelObjectPropertiesProps;
			var p:Array = [];
			var v:Array;
			
			for (var i:int = 0; i < m.length; i++) {
				
				if (m[i] == "vertices") {
					if (_vertices) {
						v = [];
						for (var j:int = 0; j < _vertices.length; j++) {
							v.push(DataManifest.pointToString(_vertices[j]));
						}
						p.push(v.join(","));
					} else {
						p.push("");
					}
				} else if (m[i] == "custom_texture") {
					p.push((_custom_texture != null) ? _custom_texture : "");
				} else {
					if (this[m[i]] is String && DataManifest.stringMap.indexOf(this[m[i]]) != -1) {
						p.push(DataManifest.stringMap.indexOf(this[m[i]]));
					} else if (this[m[i]] is Boolean) {
						p.push(this[m[i]] ? 1 : 0);
					} else {
						p.push(this[m[i]]);
					}
				}
				
			}
			
			return p.join(";");
			
		}
		
		public function fromString (data:String):void {
			
			if (data == null || data == "") return;
			
			var m:Array = DataManifest.modelObjectPropertiesProps;
			var p:Array = data.split(";");
			var v:Array;
			var pt:Array;
			
			for (var i:int = 0; i < p.length; i++) {
				
				if (m[i] == "vertices") {
					
					if (String(p[i]).length) {
						
						v = String(p[i]).split(",");
						if (_vertices == null) _vertices = new Vector.<Point>();
						
						var j:int = v.length;
						
						while (j--) {
							_vertices.unshift(DataManifest.stringToPoint(v[j]))
						}
						
					}
					
				} else if (m[i] == "custom_texture") {
					
					_custom_texture = "";
					if (p[i] != null && p[i] is String && String(p[i]).length > 0) 
					{
						_custom_texture = String(p[i]);
						_attribs = new TextureAttributes().initWithData(_custom_texture);
					}
					
				} else {
					
					if (this[m[i]] is String && DataManifest.stringMap.length > parseInt(p[i])) {
						this[m[i]] = DataManifest.stringMap[parseInt(p[i])];
					} else if (this[m[i]] is Boolean) {
						this[m[i]] = (parseInt(p[i]) == 1);
					} else {
						this[m[i]] = p[i];
					}
					
				}
				
			}
			
			dispatchEvent(new Event(Event.CHANGE));

		}

	}

}