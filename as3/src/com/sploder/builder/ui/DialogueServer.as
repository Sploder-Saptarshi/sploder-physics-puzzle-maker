package com.sploder.builder.ui 
{
	import com.sploder.builder.Creator;
	import com.sploder.builder.Styles;
	import com.sploder.asui.Component;
	import com.sploder.asui.HTMLField;
	import com.sploder.asui.Position;
	import com.sploder.asui.ProgressBar;
	import flash.events.Event;
	/**
	 * ...
	 * @author Geoff
	 */
	public class DialogueServer extends Dialogue
	{

		protected var _message:HTMLField;
		protected var _progress:ProgressBar;
		
		public function DialogueServer (creator:Creator, width:int = 300, height:int = 150, title:String = "Title", buttons:Array = null) 
		{
			super(creator, width, height, title, buttons);	
		}
		
		override public function create():void 
		{
			
			_buttons = ["OK"];
			
			super.create();
			
			dbox.contentPadding = 35;
			_creator.ui.uiContainer.addChild(dbox);
			dbox.addButtonListener(Component.EVENT_CLICK, onClick);
			
			_progress = new ProgressBar(null, 200, 25, new Position({ margins: "20 0 10 85"}), Styles.dialogueStyle.clone( { borderColor: 0xffffff } ));
			dbox.contentCell.addChild(_progress);
			
			_message = new HTMLField(null, '<h1><p align="center">Your game is now saving to the server...</p></h1>', dbox.width - 70, true, null, Styles.dialogueStyle.clone( { titleColor: 0x999999 } ));
			dbox.contentCell.addChild(_message);
			
			
			
			hide();
			
		}
		
		override protected function onClick(e:Event):void 
		{
			super.onClick(e);
			
			switch (e.target) {
				
				case dbox.buttons[0]:
					hide();
					break;
				
			}
			
		}
		
		public function alert (message:String = ""):void {
			
			if (message.length) _message.value =  '<h1><p align="center">' + message + '</p></h1>';
			
			show();
			
		}
		
		public function set progress (percent:Number):void {
			_progress.percent = percent;
		}
		
	}

}