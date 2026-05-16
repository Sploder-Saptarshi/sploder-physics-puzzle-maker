package com.sploder.builder.model 
{
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.data.DataManifest;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.describeType;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class ModifierProperties extends EventDispatcher
	{

		protected var _type:String;
		protected var _parent:ModelObject;
		protected var _child:ModelObject;
		
		protected var _parentOffset:Point;
		protected var _childOffset:Point;
		
		protected var _amount:Number = 0;
		protected var _amount2:Number = 0;
		protected var _amount3:Number = 0;
		
		protected var _optionA:Boolean = false;
		protected var _optionB:Boolean = false;
		protected var _optionC:Boolean = false;
		
		public function ModifierProperties () 
		{
			_parentOffset = new Point();
			_childOffset = new Point();
		}
		
		protected function onModelChange (e:Event):void {
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get type():String { return _type; }
		public function set type(value:String):void 
		{
			_type = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get parent():ModelObject { return _parent; }
		public function set parent(value:ModelObject):void 
		{
			var i:int;
			if (_parent) {
				_parent.removeEventListener(Event.CHANGE, onModelChange);
				_parent.removeEventListener(Event.CLEAR, onModelChange);
				if (_type == CreatorUIStates.MODIFIER_FACTORY && _parent.group) {
					i = _parent.group.length;
					while (i--) {
						_parent.group.objects[i].removeEventListener(Event.CHANGE, onModelChange);
						_parent.group.objects[i].removeEventListener(Event.CLEAR, onModelChange);
					}
				}
			}
			_parent = value;
			if (_parent) {
				_parent.addEventListener(Event.CHANGE, onModelChange);
				_parent.addEventListener(Event.CLEAR, onModelChange);
			}
			if (_type == CreatorUIStates.MODIFIER_FACTORY && _parent && _parent.group) {
				i = _parent.group.length;
				while (i--) {
					_parent.group.objects[i].addEventListener(Event.CHANGE, onModelChange);
					_parent.group.objects[i].addEventListener(Event.CLEAR, onModelChange);
				}
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get child():ModelObject { return _child; }
		public function set child(value:ModelObject):void 
		{
			if (_child) {
				_child.removeEventListener(Event.CHANGE, onModelChange);
				_child.removeEventListener(Event.CLEAR, onModelChange);
			}
			_child = value;
			if (_child) {
				_child.addEventListener(Event.CHANGE, onModelChange);
				_child.addEventListener(Event.CLEAR, onModelChange);
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get parentOffset():Point { return _parentOffset; }
		public function setParentOffset(x:int, y:int):void 
		{
			_parentOffset.x = x;
			_parentOffset.y = y;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get childOffset():Point { return _childOffset; }
		
		public function get amount():Number { return _amount; }
		public function set amount(value:Number):void 
		{
			_amount = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get amount2():Number { return _amount2; }	
		public function set amount2(value:Number):void 
		{
			_amount2 = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get amount3():Number { return _amount3; }
		public function set amount3(value:Number):void 
		{
			_amount3 = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get optionA():Boolean 
		{
			return _optionA;
		}
		
		public function set optionA(value:Boolean):void 
		{
			_optionA = value;
			dispatchEvent(new Event(Event.CHANGE));
		}

		public function get optionB():Boolean 
		{
			return _optionB;
		}
		
		public function set optionB(value:Boolean):void 
		{
			_optionB = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get optionC():Boolean 
		{
			return _optionC;
		}
		
		public function set optionC(value:Boolean):void 
		{
			_optionC = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function setChildOffset(x:int, y:int):void 
		{
			_childOffset.x = x;
			_childOffset.y = y;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function clone ():ModifierProperties
		{
			var p:ModifierProperties = new ModifierProperties();
			var n:String;
			
			var params:XMLList = describeType(p)..accessor;
			for each (var param:XML in params) {
				n = param.@name;
				if (param.@access == "readwrite" && n != "size") {
					p[n] = this[n];
				}
			}
			
			p.setParentOffset(_parentOffset.x, _parentOffset.y);
			p.setChildOffset(_childOffset.x, _childOffset.y);
			
			return p;
		}
		

		override public function toString ():String {
			
			var v:Array = [
				DataManifest.stringMap.indexOf(_type),
				(_parent) ? _parent.id : 0,
				DataManifest.pointToString(_parentOffset),
				(_child) ? _child.id : 0,
				DataManifest.pointToString(_childOffset),
				_amount, _amount2, _amount3,
				(_optionA) ? "1" : "0",
				(_optionB) ? "1" : "0",
				(_optionC) ? "1" : "0",
				];
				
			return v.join(";");
			
		}
		
		public function fromString (data:String):void {
			
			var v:Array = data.split(";");
			
			_type = DataManifest.stringMap[parseInt(v[0])];
			if (v[1]) parent = Model.mainInstance.getObjectByPasteID(parseInt(v[1]));
			else parent = null;
			DataManifest.stringToPoint(v[2], _parentOffset);
			if (v[3]) child = Model.mainInstance.getObjectByPasteID(parseInt(v[3]));
			else child = null;
			DataManifest.stringToPoint(v[4], _childOffset);
			_amount = parseFloat(v[5]);
			_amount2 = parseFloat(v[6]);
			_amount3 = parseFloat(v[7]);
			_optionA = (v[8] == "1");
			_optionB = (v[9] == "1");
			_optionC = (v.length > 10 && v[10] == "1");

		}
		
	}

}