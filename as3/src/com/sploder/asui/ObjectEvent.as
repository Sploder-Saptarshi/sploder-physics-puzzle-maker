package com.sploder.asui {
	
	import flash.events.Event;

	/**
	 * The ObjectEvent is dispatched with a reference to the object that triggered the event
	 * ...
	 * @author Geoff
	 */
	public dynamic class ObjectEvent extends Event {
		
		public var object:Object;

		//
		//
		public function ObjectEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, object:Object = null) {
			
			super(type, bubbles, cancelable);
			
			this.object = object
			
		}
		
		//
		//
		override public function clone():Event {
			return new ObjectEvent(type, bubbles, cancelable, object);	
		}
		
		//
		//
		override public function toString():String {
			return formatToString("ObjectEvent", "type", "bubbles", "cancelable", object);
		}	
		
	}
	
}