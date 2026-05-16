package com.sploder.builder.ui 
{
	import com.sploder.builder.Creator;
	import com.sploder.builder.Styles;
	import com.sploder.asui.Cell;
	import com.sploder.asui.CheckBox;
	import com.sploder.asui.Component;
	import com.sploder.asui.FormField;
	import com.sploder.asui.HTMLField;
	import com.sploder.asui.Position;
	import com.sploder.asui.Style;
	import com.sploder.util.Cleanser;
	import flash.events.Event;
	/**
	 * ...
	 * @author Geoff
	 */
	public class DialogueGoals extends Dialogue
	{
		protected var _instructionsField:FormField;
		
		protected var _totalLives:FormField;
		protected var _totalPenalties:FormField;
		protected var _totalScore:FormField;
		protected var _totalTime:FormField;
		
		public function DialogueGoals (creator:Creator, width:int = 300, height:int = 300, title:String = "Title", buttons:Array = null) 
		{
			super(creator, width, height, title, buttons);	
		}
		
		override public function create():void 
		{
			_buttons = ["Cancel", "Reset", "Guess How to Play", "Apply"];
			
			super.create();
			
			dbox.contentPadding = 40;
			_creator.ui.uiContainer.addChild(dbox);
			dbox.addButtonListener(Component.EVENT_CLICK, onClick);
			
			hide();
			
		}
		
		public function createContent ():void {
			
			if (_contentCreated) return;
			
			var th:HTMLField = new HTMLField(null, "How to Play  <a class=\"litelink\" href=\"event:showtag\">(?)</a>:", NaN, false, null, Styles.dialogueStyle);
			th.alt = "It's a good idea to type some instructions so players know to complete your game level!";
			dbox.contentCell.addChild(th);
			
			var tfStyle:Style = Styles.dialogueStyle.clone();
			tfStyle.font = "_sans";
			tfStyle.fontSize = 11;
			tfStyle.textColor = 0x00ffff;
			tfStyle.embedFonts = false;
			
			_instructionsField = new FormField(null, "", 420, 100, true, null, tfStyle);;
			_instructionsField.selectable = _instructionsField.editable = true;
			dbox.contentCell.addChild(_instructionsField);
			_instructionsField.restrict = "A-Za-z0-9 .,!()";
			_instructionsField.maxChars = 200;
			
			var s:Style = Styles.dialogueStyle.clone();
			s.fontSize = 13;
			s.textColor = 0xcccccc;
			
			var s2:Style = s.clone();
			s2.embedFonts = false;
			s2.font = "_sans";
			
			var p:Position = Styles.floatPosition.clone( { margins: "-4 10 5 10" } );
			
			var h:HTMLField;
			var ht:String = "";
			var hta:String = "";
			var f:FormField;
			
			dbox.contentCell.addChild(new Cell(null, NaN, 20));
			
			ht = "<p align=\"right\">Number of lives at start of level <a class=\"litelink\" href=\"event:showtag\">(?)</a></p>";
			hta = "This is the starting count for 'Lose Life' and 'Add Life' actions. Once you reach 0 lives in the game, you will lose the game.";
			
			h = new HTMLField(null, ht, 120, true, p, s);
			h.alt = hta;
			dbox.contentCell.addChild(h);
			
			f = new FormField(null, "000", 60, 30, true, Styles.floatPosition, s2);
			dbox.contentCell.addChild(f);
			f.restrict = "0123456789";
			_totalLives = f;
			
			ht = "<p align=\"right\">Number of penalties to allow <a class=\"litelink\" href=\"event:showtag\">(?)</a></p>";
			hta = "A life is lost when the number of penalties are reached. Leave at 0 for no penalty counting.";
			
			h = new HTMLField(null, ht, 120, true, p, s);
			h.alt = hta;
			dbox.contentCell.addChild(h);
			
			f = new FormField(null, "000", 60, 30, true, Styles.floatPosition, s2);
			dbox.contentCell.addChild(f);
			f.restrict = "0123456789";
			_totalPenalties = f;
			
			dbox.contentCell.addChild(new Cell(null, NaN, 10));
			
			ht = "<p align=\"right\">Top score to win level <a class=\"litelink\" href=\"event:showtag\">(?)</a></p>";
			hta = "The level completes if you reach this score. Leave at 0 for no score counting.";
			
			h = new HTMLField(null, ht, 120, true, p, s);
			h.alt = hta;
			dbox.contentCell.addChild(h);
			
			f = new FormField(null, "000", 60, 30, true, Styles.floatPosition, s2);
			dbox.contentCell.addChild(f);
			f.restrict = "0123456789";
			_totalScore = f;
			
			ht = "<p align=\"right\">Time limit for level in secs <a class=\"litelink\" href=\"event:showtag\">(?)</a></p>";
			hta = "The game ends if the timer reaches the time limit (in seconds) before the other goals are reached. Leave at 0 for no time limit.";
			
			h = new HTMLField(null, ht, 120, true, p, s);
			h.alt = hta;
			dbox.contentCell.addChild(h);
			
			f = new FormField(null, "000", 60, 30, true, Styles.floatPosition, s2);
			dbox.contentCell.addChild(f);
			f.restrict = "0123456789";
			_totalTime = f;

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
					getSettings();
					break;
					
				case dbox.buttons[2]:
					var txt:String = _instructionsField.value;
					_instructionsField.value = txt + " " + _creator.model.modifiers.guessInstructions();
					_instructionsField.focus();
					break;
					
				case dbox.buttons[3]:
					applyChanges();
					hide();
					break;	
				
			}
			
		}
		
		override protected function getSettings():void 
		{
			_totalLives.value = _creator.environment.total_lives.toString();
			_totalPenalties.value = _creator.environment.total_penalties.toString();
			_totalScore.value = _creator.environment.total_score.toString();
			_totalTime.value = _creator.environment.total_time.toString();
			_instructionsField.value = _creator.environment.vInstructions;
			
		}
		
		override protected function applyChanges():void 
		{
			if (!isNaN(parseInt(_totalLives.value))) _creator.environment.total_lives = parseInt(_totalLives.value);
			if (!isNaN(parseInt(_totalPenalties.value))) _creator.environment.total_penalties = parseInt(_totalPenalties.value);
			if (!isNaN(parseInt(_totalScore.value))) _creator.environment.total_score = parseInt(_totalScore.value);
			if (!isNaN(parseInt(_totalTime.value))) _creator.environment.total_time = parseInt(_totalTime.value);
			_creator.environment.vInstructions = Cleanser.cleanse(_instructionsField.value.substring(0, 200));
			
		}
		
		override public function show():void 
		{
			if (!_contentCreated) createContent();
			_instructionsField.focus();
			super.show();
		}
		
	}

}