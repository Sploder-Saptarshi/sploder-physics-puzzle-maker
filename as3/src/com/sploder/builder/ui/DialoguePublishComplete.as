package com.sploder.builder.ui 
{
	import com.sploder.builder.Creator;
	import com.sploder.builder.Styles;
	import com.sploder.asui.Cell;
	import com.sploder.asui.CheckBox;
	import com.sploder.asui.Component;
	import com.sploder.asui.HTMLField;
	import flash.events.Event;
	/**
	 * ...
	 * @author Geoff
	 */
	public class DialoguePublishComplete extends Dialogue
	{
		
		protected var _message:HTMLField;
		
		public function DialoguePublishComplete (creator:Creator, width:int = 300, height:int = 300, title:String = "Title", buttons:Array = null) 
		{
			super(creator, width, height, title, buttons);	
		}
		
		override public function create():void 
		{
			_buttons = ["Get Embed Code", "Play Again", "Done"];
			
			super.create();
			
			dbox.contentPadding = 35;
			_creator.ui.uiContainer.addChild(dbox);
			dbox.addButtonListener(Component.EVENT_CLICK, onClick);
			
			hide();
			
		}
		
		public function createContent ():void {
			
			if (_contentCreated) return;
			
			dbox.contentCell.addChild(new Cell(null, NaN, 10));
			
			_message = new HTMLField(null, '<h1><p align="center">Your game is now saving to the server...</p></h1>', dbox.width - 70, true, null, Styles.dialogueStyle.clone( { titleColor: 0x999999 } ));
			dbox.contentCell.addChild(_message);

			_contentCreated = true;
			
		}
		
		override protected function onClick(e:Event):void 
		{
			super.onClick(e);
			
			switch (e.target) {
				
				case dbox.buttons[0]:
					_creator.ui.ddEmbed.show();
					hide();
					break;
					
				case dbox.buttons[1]:
					_creator.project.playPubMovie();
					break;	
					
				case dbox.buttons[2]:
					_creator.project.saveProject();
					hide();
					break;	
				
			}
			
		}
		
		override protected function getSettings():void 
		{

		}
		
		override protected function applyChanges():void 
		{

		}
		
		public function alert (message:String = ""):void {
			
			if (!_contentCreated) createContent();
			
			if (message.length) _message.value =  '<h1><p align="center">' + message + '</p></h1>';
			
			show();
			
		}
		
		override public function show():void 
		{
			if (!_contentCreated) createContent();
			super.show();
		}
		
	}

}