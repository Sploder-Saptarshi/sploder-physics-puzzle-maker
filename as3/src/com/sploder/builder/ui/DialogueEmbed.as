package com.sploder.builder.ui 
{
	import com.sploder.builder.Creator;
	import com.sploder.builder.Styles;
	import com.sploder.asui.Component;
	import com.sploder.asui.FormField;
	import com.sploder.asui.HTMLField;
	import com.sploder.asui.Style;
	import flash.events.Event;
	import flash.system.System;
	/**
	 * ...
	 * @author Geoff
	 */
	public class DialogueEmbed extends Dialogue
	{
		protected var _embed:String = "";
		protected var _embedField:FormField;
		
		public function DialogueEmbed (creator:Creator, width:int = 300, height:int = 300, title:String = "Title", buttons:Array = null) 
		{
			super(creator, width, height, title, buttons);	
		}
		
		override public function create():void 
		{
			
			super.create();
			
			dbox.contentPadding = 20;
			_creator.ui.uiContainer.addChild(dbox);
			dbox.addButtonListener(Component.EVENT_CLICK, onClick);
			
			hide();
			
		}
		
		public function createContent ():void {
			
			if (_contentCreated) return;
			
			dbox.contentCell.addChild(new HTMLField(null, "Embed Code:", NaN, false, null, Styles.dialogueStyle));
			
			var tfStyle:Style = Styles.dialogueStyle.clone();
			tfStyle.font = "_sans";
			tfStyle.fontSize = 11;
			tfStyle.textColor = 0x00ffff;
			tfStyle.embedFonts = false;
			
			_embedField = new FormField(null, "", NaN, 100, true, null, tfStyle);;
			_embedField.addEventListener(Component.EVENT_CLICK, onClick);
			dbox.contentCell.addChild(_embedField);

			_contentCreated = true;
			
		}
		
		override protected function onClick(e:Event):void 
		{
			super.onClick(e);
			
			switch (e.target) {
				
				case (_embedField):
					
					_embedField.focus();
					break;
					
				case dbox.buttons[0]:
					_creator.project.saveProject();
					hide();
					break;
					
				case dbox.buttons[1]:
					_creator.project.saveProject();
					applyChanges();
					hide();
					break;	
				
			}
			
		}
		
		override protected function getSettings():void 
		{
			_embed = '<div align="center">' + 
				'<embed type="application/x-shockwave-flash" src="http://www.sploder.com/player3.php?s=' + 
				_creator.project.pubkey + '" id="splodergame" base="http://www.sploder.com" width="640" height="480" salign="tl" scale="noscale" >' +
				'</embed><br />' + 
				'<a href="http://www.sploder.com">Make Your Own Game for Free!</a>' + 
				'</div>';	
				
			_embedField.value = _embed;
		}
		
		override protected function applyChanges():void 
		{
			System.setClipboard(_embed);
		}
		
		override public function show():void 
		{
			if (!_contentCreated) createContent();
			_embedField.focus();
			super.show();
		}
		
	}

}