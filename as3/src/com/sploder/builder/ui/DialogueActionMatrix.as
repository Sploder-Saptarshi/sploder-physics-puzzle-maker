package com.sploder.builder.ui 
{
	import com.sploder.builder.Creator;
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.builder.model.Environment;
	import com.sploder.builder.Styles;
	import com.sploder.game.States;
	import com.sploder.asui.Cell;
	import com.sploder.asui.CheckBox;
	import com.sploder.asui.Component;
	import com.sploder.asui.HTMLField;
	import com.sploder.asui.Position;
	import com.sploder.asui.Style;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Geoff
	 */
	public class DialogueActionMatrix extends Dialogue
	{
		
		protected var _checkboxes:Object;
		protected var _actionTitles:Object;
		protected var _eventTitles:Object;
		
		public function DialogueActionMatrix (creator:Creator, width:int = 300, height:int = 300, title:String = "Title", buttons:Array = null) 
		{
			super(creator, width, height, title, buttons);	
		}
		
		override public function create():void 
		{
			_buttons = ["Cancel", "Clear All", "Reset", "Apply"];
			
			super.create();
			
			dbox.contentPadding = 20;
			_creator.ui.uiContainer.addChild(dbox);
			dbox.addButtonListener(Component.EVENT_CLICK, onClick);
			
			hide();
			
		}
		
		public function createContent ():void {
			
			if (_contentCreated) return;
			
			_checkboxes = { };
			_actionTitles = { };
			_eventTitles = { };
			
			var i:int;
			var j:int;
			var n:String;
			var alt:String;
			var c:CheckBox;
			var p:Position = Styles.floatPosition.clone( { margins: 5 } );
			var table:Cell = new Cell(null, 540, 200);
			var h:HTMLField;
			var hPos:Position = Styles.floatPosition.clone( { margin_right: 10 } );
			var hStyle:Style = Styles.dialogueStyle.clone();
			hStyle.fontSize = 12;
			hStyle.textColor = 0xffffff;
			hStyle.font = "Myriad Web Bold";
			
			dbox.contentCell.addChild(new Cell(null, NaN, 20));
			dbox.contentCell.addChild(table);
			
			var actions:Array = [
				"Score",
				"Penalty",
				"Lose Life",
				"Add Life",
				"Unlock",
				"Remove",
				"Explode",
				"End Game"
				];
				
			var actionsAlts:Array = [
				"Add a point to the score",
				"Add a penalty to the penalty score",
				"Lose a life in the game",
				"Add a life to the game",
				"Unlock this object",
				"Quietly remove this object from the game",
				"Make this object explode and push surrounding objects",
				"End the game with a losing result"
				];
				
			h = new HTMLField(null, ' ', 116, true, hPos, hStyle);
			table.addChild(h);
				
			for (i = 0; i < actions.length; i++) {
				
				h = new HTMLField(null, '<p align="left"><a class=\"litelink\" href=\"event:showtag\">(?)</a> ' + actions[i] + '</p>', 160, true, hPos, hStyle);
				h.alt = actionsAlts[i];
				table.addChild(h);
				h.boundsWidth = 40;
				h.boundsHeight = 20;
				h.rotation = -45;
				h.innerY = 35;
				h.mc.alpha = 0.5;
				_actionTitles[i] = h;
				
			}
			
			var events:Array = [
				"On Sensor",
				"On Crush",
				"On Adder, Factory, Spawner Empty",
				"On Out of<br>Bounds"
				];
				
			var eventsAlts:Array = [
				"When this object (or parent sensor link) touches an object on the same sensor layer",
				"When this object is crushed by crushing collision forces",
				"When this object (or parent sensor link) finishes spawning and the last object expires",
				"When this object falls out of the game bounds"
				];
			
			for (j = 0; j < States.EVENTS.length; j++) {
				
				h = new HTMLField(null, '<p align="right">' + events[j] + ' <a class=\"litelink\" href=\"event:showtag\">(?)</a></p>', 110, true, hPos, hStyle);
				h.alt = eventsAlts[j];
				table.addChild(h);
				h.outerHeight = 50;
				h.mc.alpha = 0.5;
				
				_eventTitles[j] = h;
				
				for (i = 0; i < States.ACTIONS.length; i++) {
					
					n = j + "_" + i; 
					alt = eventsAlts[j] + ", " + actionsAlts[i].toLowerCase() + ".";
					c = new CheckBox(null, "", n, false, 40, 40, alt, p, Styles.dialogueStyle);
					table.addChild(c);
					c.name = n;
					c.mc.scaleX = c.mc.scaleY = 2;
					_checkboxes[n] = c;
					c.addEventListener(Component.EVENT_HOVER_START, onHover);
					c.addEventListener(Component.EVENT_HOVER_END, onHoverEnd);
					
				}
				
			}
			
			/*
			_checkboxes["1_5"].disable();
			_checkboxes["2_5"].disable();
			_checkboxes["3_5"].disable();
			_checkboxes["3_6"].disable();
			*/
			
			var hxStyle:Style = hStyle.clone( { textColor: 0x999999 } );

			dbox.contentCell.addChild(new Cell(null, NaN, 60));
			
			var xp:String = "To create game behaviors, match the actions in each column to the event you wish to link. Keep in mind that sensor events between two of the same objects only occur once in the game.";

			h = new HTMLField(null, '<p>' + xp + '</p>', NaN, true, new Position( { margin_right: 20, margin_left: 120 } ), hxStyle);
			dbox.contentCell.addChild(h);
			
			_contentCreated = true;
			
		}
		
		protected function onHover (e:Event):void {
			
			var t:Array = String(e.target.name).split("_");
			
			_actionTitles[t[1]].mc.alpha = 1;
			_eventTitles[t[0]].mc.alpha = 1;
			
			
		}
		
		protected function onHoverEnd (e:Event):void {
			
			var t:Array = String(e.target.name).split("_");
			
			_actionTitles[t[1]].mc.alpha = 0.5;
			_eventTitles[t[0]].mc.alpha = 0.5;
			
		}
		
		override protected function onClick(e:Event):void 
		{
			super.onClick(e);
			
			switch (e.target) {
				
				case dbox.buttons[0]:
					getSettings();
					hide();
					break;
					
				case dbox.buttons[1]:
					clear();
					break;	
					
				case dbox.buttons[2]:
					getSettings();
					break;
					
				case dbox.buttons[3]:
					applyChanges();
					hide();
					break;	
				
			}
			
		}
		
		protected function clear ():void {
			
			for (var i:int = 0; i < 8; i++) {
				for (var j:int = 0; j < 4; j++) {
					CheckBox(_checkboxes[j + "_" + i]).checked = false;
				}
			}
			
		}
		
		override protected function getSettings():void 
		{
			var astate:uint = _creator.modelController.getActionsState();
			
			var actions:String = astate.toString(16);
			while (actions.length < 8) actions = "0" + actions;
			
			var events:String = "";
			
			for (var i:int = 0; i < 8; i++) {
				events = parseInt(actions.charAt(i), 16).toString(2);
				while (events.length < 4) events = "0" + events;
				for (var j:int = 0; j < 4; j++) {
					if (CheckBox(_checkboxes[j + "_" + i]).enabled) {
						CheckBox(_checkboxes[j + "_" + i]).checked = (events.charAt(j) == "1");
					}
				}
			}
			
		}
		
		override protected function applyChanges():void 
		{
			var actions:String = "";
			var events:String = "";
			
			var hasSensorAction:Boolean = false;
			var hasCrushAction:Boolean = false;
			var hasEmptyAction:Boolean = false;
			var hasBoundsAction:Boolean = false;
			
			for (var i:int = 0; i < 8; i++) {
				
				events = "";
				
				for (var j:int = 0; j < 4; j++) {
					
					events += (CheckBox(_checkboxes[j + "_" + i]).checked) ? "1" : "0";
					
					if (!hasSensorAction && j == 0 && (CheckBox(_checkboxes[j + "_" + i]).checked)) hasSensorAction = true;
					if (!hasCrushAction && j == 1 && (CheckBox(_checkboxes[j + "_" + i]).checked)) hasCrushAction = true;
					if (!hasEmptyAction && j == 2 && (CheckBox(_checkboxes[j + "_" + i]).checked)) hasEmptyAction = true;
					if (!hasBoundsAction && j == 3 && (CheckBox(_checkboxes[j + "_" + i]).checked)) hasBoundsAction = true;
				
				}
				
				actions += parseInt(events, 2).toString(16);
				
			}
			
			_creator.modelController.setActions(parseInt(actions, 16));
			
			if (_creator.modelController.selection.length > 0) {
				
				if (hasSensorAction && _creator.modelController.selection.objects[0].props.sensor_group == 0) {
	

					if (_creator.modelController.selection.length > 1) {
						_creator.uiController.notice("Your objects have actions applied to their Sensor events. Make sure you put them on at least one sensor layer in the panel above!");
					} else {
						_creator.uiController.notice("Your object has actions applied to its Sensor event. Make sure you put it on at least one sensor layer in the panel above!");
					}
					
					_creator.ui.layersMenu.show();
					_creator.uiController.tweener.createTween(_creator.ui.sensorLayersTitle.mc, "alpha", 1, 0.5, 0.5, true, true, 12);

				} else if (hasCrushAction && _creator.modelController.selection.objects[0].props.strength == CreatorUIStates.STRENGTH_PERM) {
					
					if (_creator.modelController.selection.length > 1) {
						_creator.uiController.notice("Your objects have actions applied to their Crush events. Make sure you choose a crushable strength from the menu above!");
					} else {
						_creator.uiController.notice("Your object has actions applied to its Crush event. Make sure you choose a crushable strength from the menu above!");
					}
					
					_creator.ui.strengths.toggle();		
					
				} else if (hasEmptyAction && 
					!(_creator.model.modifiers.containsType(CreatorUIStates.MODIFIER_ADDER) ||
					  _creator.model.modifiers.containsType(CreatorUIStates.MODIFIER_SPAWNER) ||
					  _creator.model.modifiers.containsType(CreatorUIStates.MODIFIER_FACTORY))) {
						  
					_creator.uiController.notice("You have actions applied to the Empty event. Make sure you place an Adder, Spawner or Factory modifer, or sensor link this to one!");
					
				} else if (hasBoundsAction && _creator.environment.extents == Environment.EXTENTS_ENCLOSED) {
					
					_creator.uiController.notice("You have actions applied to the Out of Bounds event, but your Playfield Boundaries are enclosed. Click 'Playfield' above and choose another option!");
					_creator.modelController.selection.clear();
					_creator.uiController.tweener.createTween(_creator.ui.world.mc, "alpha", 1, 0.5, 0.5, true, true, 12);
					
				}
			}
			
		}
		
		override public function show():void 
		{
			if (!_contentCreated) createContent();
			super.show();
		}
		
	}

}