package com.sploder.builder.ui 
{
	import com.sploder.builder.Creator;
	import com.sploder.builder.model.Environment;
	import com.sploder.builder.Styles;
	import com.sploder.game.effect.BackgroundEffect;
	import com.sploder.asui.Cell;
	import com.sploder.asui.ColorPicker;
	import com.sploder.asui.ComboBox;
	import com.sploder.asui.Component;
	import com.sploder.asui.HTMLField;
	import com.sploder.asui.Position;
	import com.sploder.asui.Style;
	import flash.events.Event;
	/**
	 * ...
	 * @author Geoff
	 */
	public class DialogueBackground extends Dialogue
	{
		private var bgColorTop:ColorPicker;
		private var bgColorBottom:ColorPicker;
		private var previewStyle:Style;
		private var preview:Cell;
		private var effect:BackgroundEffect;
		private var effectChooser:ComboBox;
		
		public function DialogueBackground(creator:Creator, width:int = 300, height:int = 300, title:String = "Title", buttons:Array = null) 
		{
			super(creator, width, height, title, buttons);	
		}
		
		override public function create():void 
		{
			_buttons = ["Cancel", "Reset", "Apply"];
			
			super.create();
			
			dbox.contentPadding = 35;
			_creator.ui.uiContainer.addChild(dbox);
			dbox.addButtonListener(Component.EVENT_CLICK, onClick);
			
			hide();
			
		}
		
		public function createContent ():void {
			
			if (_contentCreated) return;
			
			previewStyle = new Style();
			previewStyle.gradient = true;
			previewStyle.bgGradient = true;
			previewStyle.bgGradientColors = [0x0033cc, 0x0099ff];
			previewStyle.borderWidth = 2;
			
			preview = new Cell(null, 300, 230, true, true, 0, 
				Styles.floatPosition.clone( { margin_top: 15, margin_right: 40 } ),
				previewStyle);
				
			dbox.contentCell.addChild(preview);
			
			var pickers:Cell = new Cell(null, 160, 230, false, false, 0, Styles.floatPosition);
			dbox.contentCell.addChild(pickers);
			
			bgColorTop = new ColorPicker(null, 0x0033cc, 110, "Top Color", new Position( { margin_bottom: 20 } ), Styles.dialogueStyle);
			bgColorTop.showColorWheelOnly = true;
			bgColorTop.dimColorWheel = false;
			pickers.addChild(bgColorTop);
			bgColorTop.addEventListener(Component.EVENT_CHANGE, onChange);
			
			bgColorBottom = new ColorPicker(null, 0x00ccff, 110, "Bottom Color", null, Styles.dialogueStyle);
			bgColorBottom.showColorWheelOnly = true;
			bgColorBottom.dimColorWheel = false;
			pickers.addChild(bgColorBottom);
			bgColorBottom.addEventListener(Component.EVENT_CHANGE, onChange);
			
			effect = new BackgroundEffect(300, 230);
			preview.mc.addChild(effect);
			
			dbox.contentCell.addChild(new Cell(null, 300, 25));
			
			var elabel:HTMLField = new HTMLField(null, "<p align=\"right\">Background Effect:</p>", 176, false, Styles.floatPosition.clone( { margin_top: 3, margin_right: 10 } ), Styles.dialogueStyle);
			dbox.contentCell.addChild(elabel);
			
			effectChooser = new ComboBox(null, "",
				[Environment.EFFECT_NONE,
				 Environment.EFFECT_SNOW,
				 Environment.EFFECT_RAIN,
				 Environment.EFFECT_CLOUDS,
				 Environment.EFFECT_STARS,
				 Environment.EFFECT_SILK,
				 Environment.EFFECT_LEAFY,
				 Environment.EFFECT_SMOKE,
				 Environment.EFFECT_GRID], 0, "", 120, Styles.floatPosition, Styles.dialogueStyle);
				 
			effectChooser.dropDownPosition = Position.POSITION_ABOVE;
			dbox.contentCell.addChild(effectChooser);
			
			effectChooser.addEventListener(Component.EVENT_CHANGE, onChange);
			
			_contentCreated = true;
			
		}
		
		protected function onChange (e:Event):void {
			
			switch (e.target) {
			
				case (effectChooser):
					effect.type = effectChooser.value;
					break;
				
				case (bgColorTop):
				case (bgColorBottom):
					updatePreview();
					break;
					
			}
			
		}
		
		protected function updatePreview ():void {
			
			previewStyle.bgGradientColors[0] = bgColorTop.color;
			previewStyle.bgGradientColors[1] = bgColorBottom.color;
			preview.resizeCell(300, 230);
					
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
					getSettings();
					break;
					
				case dbox.buttons[2]:
					applyChanges();
					hide();
					break;
					
			}
			
		}
		
		override protected function getSettings():void 
		{
			bgColorTop.color = _creator.environment.bgColorTop;
			bgColorBottom.color = _creator.environment.bgColorBottom;
			effectChooser.select(effectChooser.choices.indexOf(_creator.environment.bgEffect));
			updatePreview();
			
		}
		
		override protected function applyChanges():void 
		{
			_creator.environment.bgColorTop = bgColorTop.color;
			_creator.environment.bgColorBottom = bgColorBottom.color;
			_creator.environment.bgEffect = effect.type;
		}
		
		override public function show():void 
		{
			if (!_contentCreated) createContent();
			super.show();
			preview.mc.addChild(effect);
		}
		
		override public function hide():void 
		{
			super.hide();
			if (effect && effect.parent) effect.parent.removeChild(effect);
		}
		
	}

}