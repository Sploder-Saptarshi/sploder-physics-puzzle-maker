package com.sploder.builder.ui 
{
	import com.sploder.asui.Position;
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
	public class DialogueClipboard extends Dialogue
	{
		private var warningText:HTMLField;
		protected var _clipboard:String = "";
		protected var _clipboardField:FormField;
		
		public function DialogueClipboard (creator:Creator, width:int = 300, height:int = 300, title:String = "Title", buttons:Array = null) 
		{
			super(creator, width, height, title, buttons);	
		}
		
		override public function create():void 
		{
			_buttons = ["Cancel", "Clear", "Copy to Clipboard", "Paste with Layers", "Paste into Layer"];
			super.create();
			
			dbox.contentPadding = 20;
			_creator.ui.uiContainer.addChild(dbox);
			dbox.addButtonListener(Component.EVENT_CLICK, onClick);
			
			hide();
			
		}
		
		public function createContent ():void {
			
			if (_contentCreated) return;
			
			var h:HTMLField = new HTMLField(null, "Clipboard Contents (Copy: CTRL-C, Paste: CTRL-V) <a class=\"litelink\" href=\"event:showtag\">(?)</a>:", NaN, false, null, Styles.dialogueStyle);
			h.alt = "You can copy the contents of your clipboard and share it with others! Select objects in your game and press CTRL-C to copy them. To put objects into your game, click the text area below and press CTRL-V!";
			dbox.contentCell.addChild(h);
			
			var tfStyle:Style = Styles.dialogueStyle.clone();
			tfStyle.font = "_sans";
			tfStyle.fontSize = 11;
			tfStyle.textColor = 0x00ffff;
			tfStyle.embedFonts = false;
			
			_clipboardField = new FormField(null, "", 520, 100, true, null, tfStyle);
			_clipboardField.addEventListener(Component.EVENT_CLICK, onClick);
			dbox.contentCell.addChild(_clipboardField);
			_clipboardField.editable = true;
			_clipboardField.restrict = "0123456789.,#?%$|:;\\-";
			_clipboardField.selectable = true;
			
			warningText = new HTMLField(null, "<font color=\"#ffcc00\">Select objects in your game if you wish to copy them, otherwise paste in your data.</font>", NaN, false, null, Styles.dialogueStyle);
			dbox.contentCell.addChild(warningText);

			_contentCreated = true;
			
		}
		
		override protected function onClick(e:Event):void 
		{
			super.onClick(e);
			
			switch (e.target) {
				
				case (_clipboardField):
					
					_clipboardField.focus();
					break;
					
				case dbox.buttons[0]:
					hide();
					break;
					
				case dbox.buttons[1]:
					_clipboardField.value = "";
					break;
					
				case dbox.buttons[2]:
					System.setClipboard(_clipboard);
					hide();
					break;	
				
				case dbox.buttons[3]:
					paste(true);
					hide();
					break;	

				case dbox.buttons[4]:
					paste(false);
					hide();
					break;	
			}
			
		}
		
		override protected function getSettings():void 
		{
			_clipboard = _creator.modelController.clipboard;
			_clipboardField.value = _clipboard;
		}
		
		protected function paste(retainLayers:Boolean = false):void 
		{
			_clipboard = _clipboardField.value;
			_creator.modelController.clipboard = _clipboard;
			_creator.uiController.paste(false, "", retainLayers);
		}
		
		override public function show():void 
		{
			if (!_contentCreated) createContent();
			_clipboardField.focus();
			
			super.show();
			
			if (warningText) {
				if (_clipboardField.text.length) {
					warningText.hide();
				} else {
					warningText.show();
				}
			}
		}
		
	}

}