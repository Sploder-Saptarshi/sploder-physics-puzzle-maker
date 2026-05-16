package com.sploder.builder.model 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class ModelObjectContainer extends EventDispatcher
	{
		protected static var _nextID:int = 1;
		protected var _id:int = 0;
		
		public static function resetNextID ():void {
			_nextID = 1;
		}
		
		protected var _objects:Vector.<ModelObject>;
		public function get objects():Vector.<ModelObject> { return _objects; }
		
		protected var _pasteIDs:Dictionary;
		
		public function get length ():uint
		{
			return _objects.length;
		}
		
		public function get id():int { return _id; }

		public function ModelObjectContainer () 
		{
			init();
		}
		
		protected function init (e:Event = null):void
		{	
			_id = _nextID;
			_nextID++;
			_objects = new Vector.<ModelObject>();	
			_pasteIDs = new Dictionary();
			
		}
		
		public function addObject (obj:ModelObject):Boolean
		{
			if (_objects.indexOf(obj) == -1) {
				_objects.push(obj);
				dispatchEvent(new Event(Event.CHANGE));
				obj.addEventListener(Event.CLEAR, onObjectDestroy);
				return true;
			}
			return false;
		}
		
		public function addObjects (objs:Vector.<ModelObject>):void
		{
			var i:int = objs.length;
			while (i--) addObject(objs[i]);
		}
		
		public function removeObject (obj:ModelObject):Boolean
		{
			if (_objects.indexOf(obj) != -1) {
				_objects.splice(_objects.indexOf(obj), 1);
				obj.removeEventListener(Event.CLEAR, onObjectDestroy);
				dispatchEvent(new Event(Event.CHANGE));
				return true;
			}
			return false;			
		}
		
		public function removeObjects (objs:Vector.<ModelObject>):void
		{
			var i:int = objs.length;
			while (i--) removeObject(objs[i]);
		}
		
		protected function onObjectDestroy (e:Event):void {
			
			removeObject(e.target as ModelObject);
			
		}
		
		public function destroyObjects ():void
		{
			var objs:Vector.<ModelObject> = _objects.concat();
			var i:int = objs.length;
			while (i--) {
				removeObject(objs[i]);
				objs[i].destroy();
			}
		}
		
		
		public function contains (obj:ModelObject):Boolean {
			
			return (_objects.indexOf(obj) != -1);
			
		}
		
		public function getObjectByPasteID (id:int):ModelObject {
			
			if (_pasteIDs && _pasteIDs[id]) return getObjectByID(_pasteIDs[id]);
			
			return null;
			
		}
		
		public function getObjectByID (id:int):ModelObject {
			
			var i:int = _objects.length;
			
			while (i--) if (_objects[i].id == id) return _objects[i];
			
			return null;
			
		}
		
		public function clear ():void
		{
			if (_objects.length == 0) return;
			var i:int = _objects.length;
			while (i--) removeObject(_objects[i]);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function selectionToString (objects:Vector.<ModelObject>):String {
			
			return objects.join("|");
			
		}
		
		override public function toString ():String {
			
			return _objects.join("|");
			
		}
		
		public function fromString (data:String):Array {

			var newObjects:Array = [];
			
			_pasteIDs = new Dictionary();
			
			var i:int;
			var m:ModelObject;
			var md:Modifier;
			var g:ModelObjectContainer;
			var pasteID:int;
			
			var level:Array = data.split("$");
			var level_objects:Array = String(level[0]).split("|");
			
			var groups:Dictionary = new Dictionary();
			
			for (i = 0; i < level_objects.length; i++) {
				
				if (level_objects[i] && String(level_objects[i]).length) {
					m = new ModelObject();
					pasteID = m.fromString(level_objects[i]);
					addObject(m);
					_pasteIDs[pasteID] = m.id;
					if (m.groupID > 0) {
						if (groups[m.groupID] == null) {
							groups[m.groupID] = new ModelObjectContainer();
						}
						g = groups[m.groupID];
						g.addObject(m);
						m.group = g;
					}
					newObjects.push(m);
				}
				
			}
			
			return newObjects;
			
		}
		
	}

}