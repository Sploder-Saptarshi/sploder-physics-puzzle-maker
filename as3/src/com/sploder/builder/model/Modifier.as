package com.sploder.builder.model 
{
	import com.sploder.builder.CreatorUIStates;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Geoff
	 */
	public class Modifier extends EventDispatcher
	{
		public static const STATE_IDLE:int = 1;
		public static const STATE_SELECTED:int = 2;

		protected var _props:ModifierProperties;
		protected var _deleted:Boolean = false;
		protected var _state:int = STATE_IDLE;
		
		public var container:ModifierContainer;
		
		public function get props():ModifierProperties { return _props; }
		public function get deleted():Boolean { return _deleted; }
		
		public function get state():int { return _state; }
		public function set state(value:int):void 
		{
			_state = value;
			update();
		}
		
		protected var _clip:ModifierSprite;
		public function get clip():ModifierSprite { return _clip; }
		
		
		public function Modifier (sourceObject:Modifier = null, addClip:Boolean = true) 
		{
			init(sourceObject, addClip);
		}
		
		protected function init (sourceObject:Modifier = null, addClip:Boolean = true):void
		{
			if (sourceObject) {
				_props = sourceObject.props.clone();
			} else {
				_props = new ModifierProperties();
			}
			
			if (addClip) _clip = new ModifierSprite(this);
			_props.addEventListener(Event.CHANGE, onChangeProps);
			
		}
		
		protected function update ():void {
			
			if (_clip) _clip.draw();
			
			if (_props && 
			(_props.type == CreatorUIStates.MODIFIER_ADDER ||
			_props.type == CreatorUIStates.MODIFIER_SPAWNER) && 
			_props.parent && _props.parent.clip) {
				
				_props.parent.clip.alpha = 0.75;
				
			}
			
			dispatchEvent(new Event(Event.CHANGE));
			
		}
		
		protected function onChangeProps (e:Event):void {
			
			if (_deleted) return;
			
			if (_props.type == CreatorUIStates.MODIFIER_FACTORY &&
				_props.parent && _props.parent.group == null) {
				
				destroy();
				return;
				
			}
			
			if (_props.parent) {
				
				if (_props.parent.deleted) {
					destroy();
					return;
				}
				
				if (_props.child && _props.child.deleted) {
					_props.child = null;
				}
				
				if (_props.parent.state == STATE_SELECTED && 
					container && container.focusObject == this) {
					container.focusObject = null;
				}
				
				switch (_props.type) {
					
					case CreatorUIStates.MODIFIER_PUSHER:
					case CreatorUIStates.MODIFIER_LAUNCHER:	
						if (_props.parent.props.constraint == CreatorUIStates.MOVEMENT_STATIC) {
							_props.parent.props.constraint = CreatorUIStates.MOVEMENT_FREE;
						}
						if (!_props.parent.props.locked) { 
							_props.parent.props.locked = true;		
						}
						break;
						
					case CreatorUIStates.MODIFIER_MOTOR:
						if (_props.parent.props.constraint == CreatorUIStates.MOVEMENT_STATIC) {
							_props.parent.props.constraint = CreatorUIStates.MOVEMENT_PIN;
						}
						break;
					
				}
				
			}

			update();
		}
		
		override public function toString ():String
		{
			if (_deleted) return "";
			return _props.toString();
		}
		
		public function fromString (data:String):void {
			
			if (_clip) _clip.suspend();
			_props.fromString(data);
			if (_clip) _clip.release();
			update();
			
		}
		
		public function clone ():Modifier {
			
			return new Modifier(this);
			
		}
		
		public function destroy ():void
		{
			if (!_deleted) {
				_deleted = true;
				if (_props) {
					if (_props.parent && _props.parent.clip) _props.parent.clip.alpha = 1;
					_props.parent = null;
					_props.child = null;
					_props = null;
				}
				if (_clip && _clip.parent) _clip.parent.removeChild(_clip);
				_clip = null;
				dispatchEvent(new Event(Event.CLEAR));
			}
		}
		
		
	}

}