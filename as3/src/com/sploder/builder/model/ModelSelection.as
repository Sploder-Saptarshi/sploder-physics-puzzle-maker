package com.sploder.builder.model 
{
	import com.sploder.builder.model.ModelObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class ModelSelection extends ModelObjectContainer
	{
		
		protected var _model:Model;
		protected var _controller:ModelController;
		protected var _container:Sprite;
		protected var _allowMultiple:Boolean = true;
		protected var _rect:Rectangle;
		
		public function get allowMultiple():Boolean { return _allowMultiple; }
		public function set allowMultiple(value:Boolean):void 
		{
			_allowMultiple = value;
		}
		
		public function get rect():Rectangle { return _rect; }
		
		
		public function ModelSelection (model:Model, controller:ModelController, container:Sprite) 
		{
			_model = model;
			_controller = controller;
			_container = container;
			_rect = new Rectangle();
			
			super();
			_id = 0;
		}
		
		override public function addObject(obj:ModelObject):Boolean 
		{
			if (!_allowMultiple) clear();
			if (super.addObject(obj)) {
				obj.state = ModelObject.STATE_SELECTED;
				return true;
			}
			return false;
		}
		
		override public function removeObject(obj:ModelObject):Boolean 
		{
			if (super.removeObject(obj)) {
				obj.state = ModelObject.STATE_IDLE;
				return true;
			}
			return false;
		}
		
		public function startSelection ():void {
			
			_container.graphics.clear();
			_rect.x = _controller.mouseVector.x;
			_rect.y = _controller.mouseVector.y;
			
		}
		
		public function updateSelection ():void {
			
			clear();
			
			_rect.width = _controller.dragVector.x;
			_rect.height = _controller.dragVector.y;

			var g:Graphics = _container.graphics;
			
			g.clear();
			g.lineStyle(1, 0x00ffff);
			g.beginFill(0x00ffff, 0.25);
			g.drawRect(_rect.x, _rect.y, _rect.width, _rect.height);
			
			var sel:Vector.<ModelObject> = _model.objects.filter(objectIsWithinSelectionWindow);
			sel.forEach(selectObject);
			
		}
		
		public function endSelection ():void {
			
			_container.graphics.clear();
			
			dispatchEvent(new Event(Event.CHANGE));
			
		}
		
		public function sortSpatially ():void {
			
			var a:Array = [];
			var i:int = _objects.length;
			
			while (i--) a.unshift( { o: _objects[i], x: _objects[i].x, y: _objects[i].y } );
			
			a.sortOn(["y", "x"], [Array.NUMERIC, Array.NUMERIC]);
			
			i = _objects.length;
			while (i--) _objects.pop();
			i = a.length;
			while (i--) _objects.unshift(a[i].o);
			
		}
		
		public function duplicateObjects ():void {
			
			var objs:Vector.<ModelObject> = new Vector.<ModelObject>();
			var i:int = _objects.length;
			
			while (i--) {
				objs.unshift(_objects[i].clone());
			}
			
			clear();
			_model.addObjects(objs);
			addObjects(objs);
			
		}
		
		override public function destroyObjects():void 
		{
			_model.removeObjects(_objects);
			super.destroyObjects();
		}
		
		public function drag ():void {
			
			_objects.forEach(dragObject);
			
		}
		
		public function drop ():void {
			
			_objects.forEach(dropObject);
			
		}
		
		public function selectionContainsGroup ():Boolean {
			
			var i:int = _objects.length;
			
			while (i--) if (_objects[i].group) return true;
			
			return false;
			
		}
		
		public function selectionIsSingleGroup ():Boolean {
			
			return (_objects.length > 1 && _objects[0].group && _objects[0].group.length == _objects.length);
			
		}
		
		protected function objectIsWithinSelectionWindow (item:ModelObject, index:int, vector:Vector.<ModelObject>):Boolean {
			
			return (item && item.clip) ? (item.clip.visible && item.clip.hitTestObject(_container)) : false;
			
		}
		
		protected function selectObject (item:ModelObject, index:int, vector:Vector.<ModelObject>):void {
			
			if (item.group == null) addObject(item);
			else addObjects(item.group.objects);
			
		}
		
		protected function dragObject (item:ModelObject, index:int, vector:Vector.<ModelObject>):void {
			
			var pt:Point = _controller.dragVector;
			
			item.state = ModelObject.STATE_DRAGGING;
			
			item.offset.x = (_controller.snap) ? Math.round(pt.x / 10) * 10 : pt.x;
			item.offset.y = (_controller.snap) ? Math.round(pt.y / 10) * 10 : pt.y;
			item.update();
			
		}
		
		protected function dropObject (item:ModelObject, index:int, vector:Vector.<ModelObject>):void {
			
			var pt:Point = _controller.dragVector;
			
			item.offset.x = item.offset.y = 0;
			item.origin.x += (_controller.snap) ? Math.round(pt.x / 10) * 10 : pt.x;
			item.origin.y += (_controller.snap) ? Math.round(pt.y / 10) * 10 : pt.y;
			
			item.state = ModelObject.STATE_SELECTED;
			
		}
		
		public function moveSelection (x:int = 0, y:int = 0):void {
			
			var i:int = _objects.length;
			
			while (i--) {
				_objects[i].origin.x += x;
				_objects[i].origin.y += y;
				_objects[i].update();
			}
			
		}
		
	}

}