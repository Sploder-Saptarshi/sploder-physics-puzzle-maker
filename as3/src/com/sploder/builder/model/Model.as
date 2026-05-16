package com.sploder.builder.model 
{
	import com.sploder.builder.model.ModelObject;
	import com.sploder.game.effect.BackgroundEffect;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Model extends ModelObjectContainer
	{	
		public static var mainInstance:Model;
		
		private var _width:int = 640;
		private var _height:int = 480;

		private var _modifiers:ModifierContainer;
		private var _container:Sprite;
		private var _background:Shape;
		private var _backgroundEffect:BackgroundEffect;
		private var _touchArea:Sprite;
		private var _objectsContainer:Sprite;
		private var _modifiersContainer:Sprite;
		private var _newObjectContainer:Sprite;
		private var _selectionWindow:Sprite;
		private var _sprites:Vector.<ModelObjectSprite>;
		private var _viewMode:uint = ModelObjectSprite.VIEW_CONSTRUCT;
		
		public function get modifiers():ModifierContainer { return _modifiers; }
		
		public function get container():Sprite { return _container; }
		public function get touchArea():Sprite { return _touchArea; }
		public function get objectsContainer():Sprite { return _objectsContainer; }
		public function get modifiersContainer():Sprite { return _modifiersContainer; }
		public function get newObjectContainer():Sprite { return _newObjectContainer; }
		public function get selectionWindow():Sprite { return _selectionWindow; }
		
		public function get width():int { return _width; }
		
		public function get height():int { return _height; }
		
		private var _layerViewStates:Array;
		
		public function get background():Shape { return _background; }
		
		public function get backgroundEffect():BackgroundEffect { return _backgroundEffect; }
		
		protected var _populating:Boolean = false;
		public function get populating():Boolean { return _populating; }
		
		public function Model (container:Sprite, width:int, height:int) 
		{
			_container = container;
			_width = width;
			_height = height;
			
			_layerViewStates = [true, true, true, true, true];
			
			mainInstance = this;
			
			super();
			
			_id = 0;
			
			if (_container.stage) init();

		}
		
		override protected function init (e:Event = null):void
		{	
			super.init(e);
			
			_background = new Shape();
			_container.addChild(_background);
			
			_backgroundEffect = new BackgroundEffect(_width, _height);
			_backgroundEffect.animate = false;
			_container.addChild(_backgroundEffect);
			
			_touchArea = new Sprite();
			_container.addChild(_touchArea);
			
			var g:Graphics = _touchArea.graphics;
			g.beginFill(0, 0);
			g.drawRect(0, 0, _width, _height);
			
			_objectsContainer = new Sprite();
			_container.addChild(_objectsContainer);
			_objectsContainer.scrollRect = new Rectangle(0, 0, _width, _height);
			_modifiersContainer = new Sprite();
			_container.addChild(_modifiersContainer);
			_modifiersContainer.mouseEnabled = false;
			_modifiersContainer.mouseChildren = true;
			_modifiersContainer.scrollRect = new Rectangle(0, 0, _width, _height);
			_newObjectContainer = new Sprite();
			_container.addChild(_newObjectContainer);
			_newObjectContainer.scrollRect = new Rectangle(0, 0, _width, _height);
			_selectionWindow = new Sprite();
			_container.addChild(_selectionWindow);
			
			_sprites = new Vector.<ModelObjectSprite>();
			
			_modifiers = new ModifierContainer(this, _modifiersContainer);
			
		}
		
		public function resize (width:int, height:int):void {
			
			_width = Math.max(640, width);
			_height = Math.max(480, height);
			
			_objectsContainer.scrollRect = new Rectangle(0, 0, _width, _height);
			_modifiersContainer.scrollRect = new Rectangle(0, 0, _width, _height);
			_newObjectContainer.scrollRect = new Rectangle(0, 0, _width, _height);
			
			var g:Graphics = _touchArea.graphics;
			g.clear();
			g.beginFill(0, 0);
			g.drawRect(0, 0, _width, _height);
			
			dispatchEvent(new Event(Event.CHANGE));		
			
		}
		
		public function setViewMode (mode:uint):void {
			
			if (_viewMode != mode) {
				var i:int = _objects.length;
				while (i--) _objects[i].clip.mode = mode;
				_viewMode = mode;
				if (_viewMode == ModelObjectSprite.VIEW_DECORATE) {
					zSort();
				}
			}
			
		}
		
		public function getLayerView (layer:int):Boolean {
			
			return (_layerViewStates[layer] == true);
			
		}
		
		
		public function setLayerView (layer:int, value:Boolean):void {
			
			_layerViewStates[layer] = value;
			
			var i:int;
			
			i = _objects.length;
			while (i--)
			{
				var obj:ModelObject = _objects[i];
				obj.clip.visible = _layerViewStates[obj.props.zlayer - 1];
			}
			
			i = _modifiers.length;
			while (i--)
			{
				var mod:Modifier = _modifiers.objects[i];
				if (mod != null && mod.props != null && mod.props.parent != null)
				{
					mod.clip.visible = _layerViewStates[mod.props.parent.props.zlayer - 1];
				}
			}
			
			
		}
		
		override public function addObject (obj:ModelObject):Boolean
		{
			if (super.addObject(obj)) {
				_objectsContainer.addChild(obj.clip);
				if (obj && obj.clip && _sprites.indexOf(obj.clip) == -1) {
					_sprites.push(obj.clip);
					obj.clip.mode = _viewMode;
				}
				return true;
			}
			return false;
		}
		
		override public function removeObject (obj:ModelObject):Boolean
		{
			if (super.removeObject(obj)) {
				if (_modifiers) _modifiers.removeModifiersOnObject(obj);
				if (obj && obj.clip && _sprites.indexOf(obj.clip) != -1) _sprites.splice(_sprites.indexOf(obj.clip), 1);
				if (obj && obj.clip && obj.clip.parent == _objectsContainer) obj.clip.parent.removeChild(obj.clip);
				return true;
			}
			return false;			
		}
		
		protected function compare (x:ModelObjectSprite, y:ModelObjectSprite):Number {
			
			if (x.zlayer == y.zlayer) {
				
				if (x.id < y.id) return -1;
				if (x.id > y.id) return 1;
				
			} else {
				
				if (x.zlayer > y.zlayer) return -1;
				if (x.zlayer < y.zlayer) return 1;			
				
			}
			
			return 0;
			
		}
		
		public function zSort ():void {
			
			_sprites.sort(compare);
			
			var i:int = _sprites.length;
			
			while (i--) _objectsContainer.setChildIndex(_sprites[i], i);
			
		}
		
		public function objectAtPoint (globalPt:Point, ignoreObject:ModelObject = null):ModelObject {
			
			var i:int = _objects.length;
			var s:ModelObjectSprite;
			
			while (i--) {
				
				s = _objects[i].clip;
				if (s && s.visible && s.hitTestPoint(globalPt.x, globalPt.y, true)) {
					if (ignoreObject == null || ignoreObject != _objects[i]) return _objects[i];
				}
				
			}
			
			return null;
			
		}
		
		override public function clear():void 
		{
			super.clear();
			_modifiers.clear();
			_layerViewStates = [true, true, true, true, true];
		}
		
		override public function selectionToString(objects:Vector.<ModelObject>):String 
		{
			return super.selectionToString(objects) + "$" + _modifiers.selectionToString(objects);
		}
		
		override public function toString ():String {
			
			return super.toString() + "$" + _modifiers.toString();
			
		}
		
		override public function fromString (data:String):Array {
			
			if (data == null) return null;
			
			var newStuff:Array = [];
			
			_populating = true;
			
			var level:Array = data.split("$");
			newStuff.push(super.fromString(level[0]));
			
			if (level.length > 1) {
				newStuff.push(_modifiers.fromString(level[1]));
			}
			
			if (_viewMode == ModelObjectSprite.VIEW_DECORATE) {
				zSort();
			}
			
			_populating = false;
			
			return newStuff;
			
		}
		
		public function end ():void {
			
			if (_objects) {
				removeObjects(_objects);
			}
			
			if (_modifiers) {
				_modifiers.end();
				_modifiers = null;
			}
			
		}

	}

}