package com.sploder.builder.ui 
{
	import com.sploder.builder.Creator;
	import com.sploder.asui.Cell;
	import com.sploder.asui.Clip;
	import com.sploder.asui.Component;
	import com.sploder.asui.HTMLField;
	import com.sploder.asui.Position;
	import com.sploder.asui.Style;
	import com.sploder.asui.Tween;
	import com.sploder.asui.TweenManager;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author ...
	 */
	public class Notice extends Sprite
	{
		public static var tweener:TweenManager;
		
		protected var _cell:Cell;
		protected var _message:HTMLField;
		
		public var style:Style;
		public var xoffset:int = 0;
		public var icon:String = "";
		
		public function Notice () 
		{
			super();
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		protected function init (e:Event = null):void {
			
			if (e) stage.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			if (tweener == null) tweener = new TweenManager(true);
			
			_cell = new Cell(this, stage.stageWidth * 0.6, 30, true, true, 10, 
				new Position( null, -1, Position.PLACEMENT_ABSOLUTE), 
				style);
				
			_cell.collapse = true;
			_cell.x = stage.stageWidth * 0.2 + xoffset;
			_cell.y = stage.stageHeight;
			_cell.mc.addEventListener(MouseEvent.CLICK, onClick);
			
			if (icon == "") {
				_message = new HTMLField(null, '<h1><p align="center">Are you sure you want to do this?</p></h1>', NaN, true, new Position( { margins: "10 30 0 30" } ), style);
				_cell.addChild(_message);
			} else {
				var fpos:Position = new Position( { margins: "9 0 0 20" }, -1, Position.PLACEMENT_FLOAT);
				var clip:Clip = new Clip(null, icon, Clip.EMBED_SMART, 40, 40, Clip.SCALEMODE_FILL, "", false, "", fpos, style);
				_cell.addChild(clip);
				_message = new HTMLField(null, '<h1><p align="left">Are you sure you want to do this?</p></h1>', _cell.width - 100, true, new Position( { margins: "10 30 0 10", placement: Position.PLACEMENT_FLOAT } ), style);
				_cell.addChild(_message);
			}
			
		}
		
		protected function onClick (e:MouseEvent):void {
			tweener.removeTweensOnObject(_cell);
			tweener.createTween(_cell, "y", _cell.y, stage.stageHeight, 0.25, 
				false, false, 0, 0, 
				Tween.EASE_IN, Tween.STYLE_EXPO);	
		}
		
		public function show (message:String):void {
			
			if (message.length) {
				if (icon == "") _message.value =  '<h1><p align="center">' + message + '</p></h1>';
				else _message.value =  '<h1><p align="left">' + message + '</p></h1>';
				_cell.update();
			}
			
			tweener.createTween(_cell, "y", _cell.y, stage.stageHeight - _cell.height - 40, 0.5, 
				false, false, 0, 0, 
				Tween.EASE_OUT, Tween.STYLE_CUBIC, 
				null, hide);
			
		}
		
		public function hide (tween:Tween = null):void {
			
			tweener.createTween(_cell, "y", _cell.y, stage.stageHeight, 0.5, 
				false, false, 0, 3000 + _message.value.length * 20, 
				Tween.EASE_IN, Tween.STYLE_CUBIC);			
			
		}
		
	}

}