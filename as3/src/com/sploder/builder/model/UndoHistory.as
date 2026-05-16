package com.sploder.builder.model 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author ...
	 */
	public class UndoHistory extends EventDispatcher
	{
		protected var _model:Model;
		protected var _modelController:ModelController;
		
		protected var _history:Vector.<String>;
		protected var _marker:int = -1;
		
		public function get length ():int {
			return _history.length;
		}
		
		public function get hasRedo ():Boolean {
			return _marker < _history.length - 1;
		}
		
		public function get hasUndo ():Boolean {
			return (_history.length > 0 && _marker > 0);
		}
		
		public function UndoHistory (model:Model, controller:ModelController) {
			
			init(model, controller);
			
		}
		
		protected function init (model:Model, controller:ModelController):void {
			
			_model = model;
			_modelController = controller;
			
			clear();
			
		}
		
		protected function setModel ():void {
			
			if (_marker >= 0 && _history.length > _marker && _history[_marker] != null) {
				_model.clear();
				_model.fromString(_history[_marker]);
			}
			
		}
		
		public function record ():void {
			
			if (_marker <= _history.length - 1) {
				while (_history.length - 1 > _marker) _history.pop();
				dispatchEvent(new Event(Event.CHANGE));
			}
			
			var m:String = _model.toString();
			
			if (m.length > 0 && 
				(_history.length == 0 || m != _history[_history.length - 1])
				) {
								
				_history.push(m);
				_marker = _history.length - 1;
				
				if (_history.length > 25) {
					_history.shift();
					_marker--;
				}
				
				dispatchEvent(new Event(Event.CHANGE));
				
			}
			
		}
		
		public function stepBack ():void {
			
			if (_marker > 0 || (_marker == 0 && _marker == _history.length - 1)) {
				
				_modelController.selection.clear();
				
				if (_marker == _history.length - 1) {
					record();
				}
				
				_marker--;
				setModel();
				
				dispatchEvent(new Event(Event.CHANGE));
				
			}
			
		}
		
		public function stepForward ():void {
			
			if (_marker < _history.length - 1) {
				
				_modelController.selection.clear();
				
				_marker++;
				setModel();
				
				dispatchEvent(new Event(Event.CHANGE));
				
			}
			
		}
		
		public function clear ():void {
			
			_history = new Vector.<String>();
			_marker = -1;
			
			dispatchEvent(new Event(Event.CHANGE));
			
		}
		
	}

}