package com.sploder.builder.model 
{
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.game.States;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class ModifierContainer extends EventDispatcher
	{
		protected var _model:Model;
		protected var _container:Sprite;
		
		protected var _objects:Vector.<Modifier>;
		public function get objects():Vector.<Modifier> { return _objects; }
		
		protected var _focusObject:Modifier;
		
		public function get model():Model { return _model; }
		
		public function get length ():uint { return _objects.length; }
		
		public function get focusObject():Modifier { return _focusObject; }
		public function set focusObject(value:Modifier):void 
		{
			if (_focusObject) _focusObject.state = Modifier.STATE_IDLE;
			_focusObject = value;
			if (_focusObject) {
				_focusObject.state = Modifier.STATE_SELECTED;
				if (_focusObject.clip.parent == _container) {
					_container.setChildIndex(_focusObject.clip, _container.numChildren - 1);
				}
			}
			dispatchEvent(new Event(Event.SELECT));
			
		}
		
		
		public function ModifierContainer (model:Model, container:Sprite) 
		{
			_model = model;
			_container = container;
			init();
		}
		
		protected function init (e:Event = null):void
		{	
			_objects = new Vector.<Modifier>();	
		}
		
		public function addObject (obj:Modifier):Boolean
		{
			if (_objects.indexOf(obj) == -1) {
				_objects.push(obj);
				_container.addChild(obj.clip);
				obj.container = this;
				obj.addEventListener(Event.CLEAR, onObjectDestroy);
				dispatchEvent(new Event(Event.CHANGE));
				return true;
			}
			return false;
		}
		
		public function addObjects (objs:Vector.<Modifier>):void
		{
			var i:int = objs.length;
			while (i--) addObject(objs[i]);
		}
		
		public function removeObject (obj:Modifier):Boolean
		{
			if (_objects.indexOf(obj) != -1) {
				_objects.splice(_objects.indexOf(obj), 1);
				obj.removeEventListener(Event.CLEAR, onObjectDestroy);
				if (obj.clip && obj.clip.parent == _container) _container.removeChild(obj.clip);
				dispatchEvent(new Event(Event.CHANGE));
				return true;
			}
			return false;			
		}
		
		public function removeObjects (objs:Vector.<Modifier>):void
		{
			var i:int = objs.length;
			while (i--) removeObject(objs[i]);
		}
		
		public function removeModifiersOnObject (obj:ModelObject):void {
			
			var i:int = _objects.length;
			var mod:Modifier;
			
			while (i--) {
				mod = _objects[i];
				if (mod && mod.props) {
					if (mod.props.parent == obj || mod.props.child == obj) {
						removeObject(mod);
					}
				}
			}
			
		}
		
		protected function onObjectDestroy (e:Event):void {
			
			removeObject(e.target as Modifier);
			dispatchEvent(new Event(Event.CLEAR));
			
		}
		
		public function destroyObjects ():void
		{
			var objs:Vector.<Modifier> = _objects.concat();
			var i:int = objs.length;
			while (i--) {
				removeObject(objs[i]);
				objs[i].destroy();
			}
		}
		
		
		public function contains (obj:Modifier):Boolean {
			
			return (_objects.indexOf(obj) != -1);
			
		}
		
		public function getByType (type:String):Modifier {
			
			var i:int = _objects.length;
			while (i--) {
				if (_objects[i].props.type == type) return _objects[i];
			}
			return null;
			
		}
		
		public function getAllOfType (type:String):Vector.<Modifier> {
			
			var o:Vector.<Modifier> = new Vector.<Modifier>();
			
			var i:int = _objects.length;
			while (i--) {
				if (_objects[i].props.type == type) o.unshift(_objects[i]);
			}
			return o;
			
		}
		
		public function containsType (type:String):Boolean {
			
			var i:int = _objects.length;
			while (i--) {
				if (_objects[i].props.type == type) return true;
			}
			return false;
			
		}
		
		public function objContainsType (obj:ModelObject, type:String):Boolean {
			
			var i:int = _objects.length;
			while (i--) {
				if (_objects[i].props.type == type && _objects[i].props.parent == obj) return true;
			}
			return false;
			
		}
		
		public function clear ():void
		{
			if (_objects.length == 0) return;
			var i:int = _objects.length;
			while (i--) removeObject(_objects[i]);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function selectionToString (objects:Vector.<ModelObject>):String {
			
			var mods:Array = [];
			var md:Modifier;
			var i:int = _objects.length;
			
			while (i--) {
				md = _objects[i];
				if (md && md.props && md.props.parent && 
					objects.indexOf(md.props.parent) != -1) {
					
					mods.unshift(md.toString());
						
				}
			}
			
			return mods.join("|");
			
		}
		
		override public function toString ():String {
			
			return _objects.join("|");
			
		}
		
		public function fromString (data:String):Array {
			
			var newStuff:Array = [];
			
			var i:int;
			var md:Modifier;
			
			var level_modifiers:Array = data.split("|");
			
			for (i = 0; i < level_modifiers.length; i++) {
				
				if (level_modifiers[i] && String(level_modifiers[i]).length) {
					md = new Modifier();
					md.fromString(level_modifiers[i]);
					addObject(md);
					md.clip.draw();
					newStuff.push(md);
				}
				
			}
			
			return newStuff;
			
		}
		
		public function getControls ():Array {
			
			var a:Modifier;
			var controls:Array = [];
			
			if (containsType(CreatorUIStates.MODIFIER_SELECTOR)) {
				controls.push(States.CONTROLS_MOUSE);
			}
			
			if (containsType(CreatorUIStates.MODIFIER_MOVER)) {
				controls.push(States.CONTROLS_UPDOWN);
			}
			
			if (containsType(CreatorUIStates.MODIFIER_SLIDER)) {
				controls.push(States.CONTROLS_LEFTRIGHT);	
			}
			
			if (containsType(CreatorUIStates.MODIFIER_ARCADEMOVER)) {
				controls.push(States.CONTROLS_UPDOWN);
				controls.push(States.CONTROLS_LEFTRIGHT);	
			}
			
			if (containsType(CreatorUIStates.MODIFIER_ROTATOR)) {
				controls.push(States.CONTROLS_LEFTRIGHT);
			}
			
			if (containsType(CreatorUIStates.MODIFIER_JUMPER)) {
				controls.push(States.CONTROLS_UPDOWN);
			}
			
			if (containsType(CreatorUIStates.MODIFIER_AIMER)) {
				controls.push(States.CONTROLS_MOUSE);
			}
			
			if (containsType(CreatorUIStates.MODIFIER_ADDER)) {
				a = getByType(CreatorUIStates.MODIFIER_AIMER);
				if (a && a.props.optionA) {
					controls.push(States.CONTROLS_MOUSE);
				} else {
					controls.push(States.CONTROLS_SPACEBAR);
				}
			}
			
			if (containsType(CreatorUIStates.MODIFIER_FACTORY)) {
				a = getByType(CreatorUIStates.MODIFIER_FACTORY);
				if (a && a.props.optionA) {
					controls.push(States.CONTROLS_MOUSE);
				} else {
					controls.push(States.CONTROLS_SPACEBAR);
				}
			}
			
			if (containsType(CreatorUIStates.MODIFIER_LAUNCHER)) {
				controls.push(States.CONTROLS_MOUSE);
			}
			
			if (containsType(CreatorUIStates.MODIFIER_EMAGNET)) {
				controls.push(States.CONTROLS_SPACEBAR);
			}
			
			if (containsType(CreatorUIStates.MODIFIER_DRAGGER)) {
				controls.push(States.CONTROLS_MOUSE);
			}
			
			if (containsType(CreatorUIStates.MODIFIER_CLICKER)) {
				controls.push(States.CONTROLS_MOUSE);
			}

			return controls;
			
		}
		
		public function guessInstructions ():String {
			
			var a:Modifier;
			var tasks:Array = [];
			
			if (containsType(CreatorUIStates.MODIFIER_SELECTOR)) {
				tasks.push("First, select objects to control with the mouse.");
			}
			
			if (containsType(CreatorUIStates.MODIFIER_MOVER) && containsType(CreatorUIStates.MODIFIER_SLIDER)) {
				tasks.push("Move with the arrow keys or WASD.");
			} else if (containsType(CreatorUIStates.MODIFIER_MOVER)) {
				tasks.push("Move with the UP and DOWN arrow keys or W,S.");
			} else if (containsType(CreatorUIStates.MODIFIER_SLIDER)) {
				tasks.push("Move with the LEFT and RIGHT arrow keys or A,D.");
			}
			
			if (containsType(CreatorUIStates.MODIFIER_ROTATOR)) {
				tasks.push("Turn with the LEFT and RIGHT arrow keys or A,D.");
			}
			
			if (containsType(CreatorUIStates.MODIFIER_JUMPER)) {
				tasks.push("Jump with the UP arrow.");
			}
			
			if (containsType(CreatorUIStates.MODIFIER_THRUSTER)) {
				var objs:Vector.<Modifier> = getAllOfType(CreatorUIStates.MODIFIER_THRUSTER);
				var tn:int = objs.length;
				if (tn == 1) tasks.push("Thrust with the " + String.fromCharCode(objs[0].props.amount) + " key.");
				else {
					var keylist:Array = [];
					while (tn--) {
						keylist.push(String.fromCharCode(objs[tn].props.amount));
					}
					tasks.push("Thrust with the " + keylist.join(",") + " keys.");
				}
			}
			
			if (containsType(CreatorUIStates.MODIFIER_AIMER)) {
				tasks.push("Aim with the mouse.");
			}
			
			if (containsType(CreatorUIStates.MODIFIER_ADDER)) {
				a = getByType(CreatorUIStates.MODIFIER_AIMER);
				if (a && a.props.optionA) {
					tasks.push("Shoot with the mouse button.");
				} else {
					tasks.push("Shoot with the SPACEBAR.");
				}
			}
			
			if (containsType(CreatorUIStates.MODIFIER_FACTORY)) {
				a = getByType(CreatorUIStates.MODIFIER_FACTORY);
				if (a && a.props.optionA) {
					tasks.push("Add objects with the mouse button.");
				} else {
					tasks.push("Add objects with the SPACEBAR.");
				}
			}
			
			if (containsType(CreatorUIStates.MODIFIER_LAUNCHER)) {
				tasks.push("Launch objects from the launcher with the mouse button.");
			}
			
			if (containsType(CreatorUIStates.MODIFIER_EMAGNET)) {
				tasks.push("Turn the electromagnet on and off with the SPACEBAR.");
			}
			
			if (containsType(CreatorUIStates.MODIFIER_DRAGGER)) {
				tasks.push("Some objects can be dragged with the mouse.");
			}
			
			if (containsType(CreatorUIStates.MODIFIER_CLICKER)) {
				tasks.push("Some objects can be clicked with the mouse.");
			}
			
			if (tasks.length == 0) return "Your guess is as good as mine! :)";
			
			return tasks.join(" ");
			
		}
		
		public function end ():void {
			
			if (_objects) {
				removeObjects(_objects);
			}
			
			_container = null;
			
		}
		
	}

}