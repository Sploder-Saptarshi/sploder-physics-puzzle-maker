package com.sploder.builder.ui 
{
	import com.sploder.builder.Creator;
	import com.sploder.builder.Styles;
	import com.sploder.asui.Cell;
	import com.sploder.asui.CheckBox;
	import com.sploder.asui.Component;
	import flash.events.Event;
	/**
	 * ...
	 * @author Geoff
	 */
	public class DialoguePublish extends Dialogue
	{
		
		protected var _comments:CheckBox;
		protected var _isprivate:CheckBox;
		protected var _turbo:CheckBox;
		private var _allowcopying:CheckBox;
		
		public function DialoguePublish (creator:Creator, width:int = 300, height:int = 300, title:String = "Title", buttons:Array = null) 
		{
			super(creator, width, height, title, buttons);	
		}
		
		override public function create():void 
		{
			_buttons = ["Cancel", "Publish"];
			
			super.create();
			
			dbox.contentPadding = 100;
			_creator.ui.uiContainer.addChild(dbox);
			dbox.addButtonListener(Component.EVENT_CLICK, onClick);
			
			hide();
			
		}
		
		public function createContent ():void {
			
			if (_contentCreated) return;
			
			dbox.contentCell.addChild(new Cell(null, NaN, 10));
			
			_comments = new CheckBox(null, "Allow Comments", "comments", false, 140, 30, "", Styles.floatPosition, Styles.dialogueStyle);
			dbox.contentCell.addChild(_comments);
	
			_isprivate = new CheckBox(null, "Keep Private", "comments", false, 140, 30, "", Styles.floatPosition, Styles.dialogueStyle);
			dbox.contentCell.addChild(_isprivate);

			_turbo = new CheckBox(null, "Turn off smoothing (fast mode)", "true", false, 290, 30, "", Styles.floatPosition, Styles.dialogueStyle);
			dbox.contentCell.addChild(_turbo);
			
			_allowcopying = new CheckBox(null, "Allow copying <a class=\"litelink\" href=\"event:showtag\">(?)</a>", "true", false, 290, 30, "", Styles.floatPosition, Styles.dialogueStyle);
			_allowcopying.alt = "Check this box to allow others to copy your game levels to learn from and adapt to their own games";
			dbox.contentCell.addChild(_allowcopying);

			_contentCreated = true;
			
		}
		
		override protected function onClick(e:Event):void 
		{
			super.onClick(e);
			
			switch (e.target) {
				
				case dbox.buttons[0]:
					hide();
					break;
					
				case dbox.buttons[1]:
					applyChanges();
					_creator.project.publishProject();
					hide();
					break;	
				
			}
			
		}
		
		override protected function getSettings():void 
		{
			_comments.checked = _creator.project.comments;
			_isprivate.checked = _creator.project.isprivate;
			_turbo.checked = _creator.project.turbo;
			_allowcopying.checked = _creator.project.allowcopying;
		}
		
		override protected function applyChanges():void 
		{
			_creator.project.comments = _comments.checked;
			_creator.project.isprivate = _isprivate.checked;
			_creator.project.turbo = _turbo.checked;
			_creator.project.allowcopying = _allowcopying.checked;
		}
		
		override public function show():void 
		{
			if (!_contentCreated) createContent();
			super.show();
		}
		
	}

}