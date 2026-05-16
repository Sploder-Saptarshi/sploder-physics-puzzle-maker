package com.sploder.builder.ui 
{
	import com.sploder.builder.Creator;
	import com.sploder.builder.model.Environment;
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.builder.Styles;
	import com.sploder.asui.Cell;
	import com.sploder.asui.CheckBox;
	import com.sploder.asui.Clip;
	import com.sploder.asui.Component;
	import com.sploder.asui.HRule;
	import com.sploder.asui.HTMLField;
	import com.sploder.asui.Position;
	import com.sploder.asui.RadioButton;
	import flash.events.Event;
	/**
	 * ...
	 * @author Geoff
	 */
	public class DialogueEnvironment extends Dialogue
	{
		private var sizeNormal:RadioButton;
		private var sizeDouble:RadioButton;
		private var sizeFollow:RadioButton;
		private var gravity:CheckBox;
		private var resistance:CheckBox;
		private var p_enclose:RadioButton;
		private var p_ground:RadioButton;
		private var p_open:RadioButton;
		private var sizeNormalc:Clip;
		private var sizeDoublec:Clip;
		private var sizeFollowc:Clip;
		
		public function DialogueEnvironment(creator:Creator, width:int = 300, height:int = 300, title:String = "Title", buttons:Array = null) 
		{
			super(creator, width, height, title, buttons);	
		}
		
		override public function create():void 
		{
			_buttons = ["Cancel", "Reset", "Apply"];
			
			super.create();
			
			dbox.contentPadding = 55;
			_creator.ui.uiContainer.addChild(dbox);
			dbox.addButtonListener(Component.EVENT_CLICK, onClick);
			
			hide();
			
		}
		
		public function createContent ():void {
			
			if (_contentCreated) return;
			
			var altA:String = "Game area is the same size as it appears in the creator, and the game is not scaled";
			var altB:String = "Game area is double size as the creator window, and the game is scaled to half-size in order to show the whole area";
			var altC:String = "Game area is double size as the creator window, and the game is not scaled, but follows your controlled object like a camera";
			
			dbox.contentCell.addChild(new Cell(null, NaN, 10));
			dbox.contentCell.addChild(new HTMLField(null, "Playfield Size and View:", NaN, false, null, Styles.dialogueStyle));
			dbox.contentCell.addChild(new Cell(null, NaN, 10));
			
			sizeNormalc = new Clip(null, CreatorUIStates.PLAYFIELD_SIZE_NORMAL, Clip.EMBED_LOCAL, 
				120, 60, Clip.SCALEMODE_NOSCALE, "", false, 
				altA, Styles.floatPosition.clone( { margin_left: 5 } ) );
			sizeNormalc.showAltImmediate = true;
			dbox.contentCell.addChild(sizeNormalc);
			sizeNormalc.addEventListener(Component.EVENT_CLICK, onClick);
			
			sizeDoublec = new Clip(null, CreatorUIStates.PLAYFIELD_SIZE_DOUBLE, Clip.EMBED_LOCAL, 
				120, 60, Clip.SCALEMODE_NOSCALE, "", false, 
				altB, Styles.floatPosition);
			sizeDoublec.showAltImmediate = true;
			dbox.contentCell.addChild(sizeDoublec);
			sizeDoublec.addEventListener(Component.EVENT_CLICK, onClick);
			
			sizeFollowc = new Clip(null, CreatorUIStates.PLAYFIELD_SIZE_FOLLOW, Clip.EMBED_LOCAL, 
				80, 60, Clip.SCALEMODE_NOSCALE, "", false, 
				altC, Styles.floatPosition.clone( { clear: Position.CLEAR_RIGHT } ));
			sizeFollowc.showAltImmediate = true;
			dbox.contentCell.addChild(sizeFollowc);
			sizeFollowc.addEventListener(Component.EVENT_CLICK, onClick);
			
			dbox.contentCell.addChild(new Cell(null, NaN, 10));
			
			sizeNormal = new RadioButton(null, 
				"Normal Size", Environment.SIZE_NORMAL + "", "psize", 
				true, 120, 30, altA,
				Styles.floatPosition, Styles.dialogueStyle); 	
			dbox.contentCell.addChild(sizeNormal);
				
			sizeDouble = new RadioButton(null, 
				"Double Size", Environment.SIZE_DOUBLE + "", "psize", 
				false, 120, 30, altB,
				Styles.floatPosition, Styles.dialogueStyle); 
			dbox.contentCell.addChild(sizeDouble);
			
			sizeFollow = new RadioButton(null, 
				"Zoomed", Environment.SIZE_FOLLOW + "", "psize", 
				false, 120, 30, altC,
				Styles.floatPosition, Styles.dialogueStyle); 
			dbox.contentCell.addChild(sizeFollow);
			
			dbox.contentCell.addChild(new HRule(null, 320, null, Styles.dialogueStyle.clone( { border: true, borderWidth: 4, borderColor: 0xffffff, borderAlpha: 1 }) ));
			dbox.contentCell.addChild(new Cell(null, NaN, 10));
			dbox.contentCell.addChild(new HTMLField(null, "Playfield Physics:", NaN, false, null, Styles.dialogueStyle));
			dbox.contentCell.addChild(new Cell(null, NaN, 10));
			
			gravity = new CheckBox(null, "Gravity", "true", 
				true, 120, 30, "Check to simulate gravity by pulling objects down toward the bottom of the screen",
				Styles.floatPosition, Styles.dialogueStyle);
			dbox.contentCell.addChild(gravity);
			
			resistance = new CheckBox(null, "Motion Resistance", "true", 
				false, 240, 30, "Check to slow down objects as they move and turn. Good for top-down games.",
				Styles.floatPosition, Styles.dialogueStyle);
			dbox.contentCell.addChild(resistance);
			
			dbox.contentCell.addChild(new HRule(null, 320, null, Styles.dialogueStyle.clone( { border: true, borderWidth: 4, borderColor: 0xffffff, borderAlpha: 1 }) ));
			dbox.contentCell.addChild(new Cell(null, NaN, 10));
			dbox.contentCell.addChild(new HTMLField(null, "Playfield Boundaries:", NaN, false, null, Styles.dialogueStyle));
			dbox.contentCell.addChild(new Cell(null, NaN, 10));
			
			p_enclose = new RadioButton(null, 
				"Enclosed", Environment.EXTENTS_ENCLOSED + "", "pextents", 
				true, 118, 30, "Completely enclose the playfield and do not allow objects to escape",
				Styles.floatPosition, Styles.dialogueStyle); 
				
			p_enclose.radioSymbolName = CreatorUIStates.PLAYFIELD_EXTENTS_ENCLOSED;
			dbox.contentCell.addChild(p_enclose);
			
			p_ground = new RadioButton(null, 
				"Ground Only", Environment.EXTENTS_GROUND + "", "pextents", 
				false, 118, 30, "Allow objects to escape the playfield, but not go below the bottom",
				Styles.floatPosition, Styles.dialogueStyle); 
				
			p_ground.radioSymbolName = CreatorUIStates.PLAYFIELD_EXTENTS_GROUND;
			dbox.contentCell.addChild(p_ground);
			
			p_open = new RadioButton(null, 
				"Open", Environment.EXTENTS_OPEN + "", "pextents", 
				false, 120, 30, "Allow objects to escape the playfield, and do not stop any of them",
				Styles.floatPosition, Styles.dialogueStyle); 
				
			p_open.radioSymbolName = CreatorUIStates.PLAYFIELD_EXTENTS_OPEN;
			dbox.contentCell.addChild(p_open);
			
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
					applyChanges();
					hide();
					break;
				
				case sizeNormalc:
					sizeNormal.checked = true;
					break;
					
				case sizeDoublec:
					sizeDouble.checked = true;
					break;
					
				case sizeFollowc:
					sizeFollow.checked = true;
					break;		
				
			}
			
		}
		
		override protected function getSettings():void 
		{
			RadioButton(RadioButton.groups["psize"].buttons[_creator.environment.size]).checked = true;
			gravity.checked = (_creator.environment.gravity == 1);
			resistance.checked = (_creator.environment.resistance == 1);
			RadioButton(RadioButton.groups["pextents"].buttons[_creator.environment.extents]).checked = true;
		}
		
		override protected function applyChanges():void 
		{
			_creator.environment.size = parseInt(RadioButton.groups["psize"].value);
			_creator.environment.gravity = (gravity.checked) ? 1 : 0;
			_creator.environment.resistance = (resistance.checked) ? 1 : 0;
			_creator.environment.extents = parseInt(RadioButton.groups["pextents"].value);
			
		}
		
		override public function show():void 
		{
			if (!_contentCreated) createContent();
			super.show();
		}
		
	}

}