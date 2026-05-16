package com.sploder.builder.ui 
{
	import com.sploder.builder.Creator;
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.builder.Styles;
	import com.sploder.asui.Cell;
	import com.sploder.asui.Clip;
	import com.sploder.asui.Component;
	import com.sploder.asui.HTMLField;
	import flash.events.Event;
	/**
	 * ...
	 * @author Geoff
	 */
	public class DialogueWelcome extends Dialogue
	{

		protected var _logo:Clip;
		
		public function DialogueWelcome (creator:Creator, width:int = 300, height:int = 150, title:String = "Welcome to Sploder's", buttons:Array = null) 
		{
			super(creator, width, height, title, buttons);	
		}
		
		override public function create():void 
		{
			
			_buttons = ["Take a Tour", "Skip Tour"];
			
			super.create();
			
			dbox.contentPadding = 60;
			_creator.ui.uiContainer.addChild(dbox);
			dbox.addButtonListener(Component.EVENT_CLICK, onClick);
			
			dbox.contentCell.addChild(new Cell(null, NaN, 20));
			
			_logo = new Clip(null, CreatorUIStates.ICON_CREATOR_LOGO);
			dbox.contentCell.addChild(_logo);
			
			hide();
			
		}
		
		override protected function onClick(e:Event):void 
		{
			super.onClick(e);
			
			switch (e.target) {
				
				case dbox.buttons[0]:
					_creator.showTour();
					hide();
					break;
				
				case dbox.buttons[1]:
					hide();
					_creator.onWelcomeClosed();
					break;
				
			}
			
		}

	}

}