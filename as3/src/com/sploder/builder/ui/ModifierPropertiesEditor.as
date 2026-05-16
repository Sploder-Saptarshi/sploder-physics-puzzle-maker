package com.sploder.builder.ui 
{
	import com.sploder.builder.CreatorUI;
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.builder.Styles;
	import com.sploder.builder.model.Modifier;
	import com.sploder.asui.ASUIObject;
	import com.sploder.asui.Cell;
	import com.sploder.asui.CheckBox;
	import com.sploder.asui.Component;
	import com.sploder.asui.FormField;
	import com.sploder.asui.HTMLField;
	import com.sploder.asui.Position;
	import com.sploder.asui.Style;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Geoff
	 */
	public class ModifierPropertiesEditor
	{
		protected var _ui:CreatorUI;
		protected var _modifier:Modifier;
		protected var _cell:Cell;
		protected var _container:Sprite;
		
		protected var _showing:Boolean = false;
		
		protected var box:Cell;
		protected var amt1:FormField;
		protected var amt2:FormField;
		protected var amt3:FormField;
		protected var optA:CheckBox;
		protected var optB:CheckBox;
		protected var optC:CheckBox;
		
		public function get showing():Boolean { return _showing; }
		
		public function get modifier():Modifier { return _modifier; }
		
		public function ModifierPropertiesEditor (ui:CreatorUI) 
		{
			init(ui);
		}
		
		protected function init (ui:CreatorUI):void {
			
			_ui = ui;
			_container = new Sprite();
			_container.x = 80;
			_container.y = 90;
			
			CreatorUI.stage.addChild(_container);
			_cell = new Cell(_container, 640, 480, false, false);

		}
		
		protected function onChange (e:Event):void {
			
			if (amt1) {
				switch (_modifier.props.type) {
					case CreatorUIStates.MODIFIER_THRUSTER:
						amt1.maxChars = 1;
						if (amt1.value.length > 0) {
							var ac1:Number = amt1.value.charCodeAt(0);
							if (!isNaN(ac1) && ac1 >= 65 && ac1 <= 122) {
								if (ac1 > 90) ac1 -= 32;
								_modifier.props.amount = ac1;
							}
						}
						break;
					
					case CreatorUIStates.MODIFIER_ARCADEMOVER:
						if (amt1.value.length > 0) {
							var vel:int = Math.floor(Math.max(0, Math.min(20, parseInt(amt1.value))));
							if (!isNaN(vel)) _modifier.props.amount = vel;
						}
						break;
						
					default:
						var a1:Number = parseFloat(amt1.value);
						if (!isNaN(a1)) _modifier.props.amount = a1 * 1000;
						break;
				}
			}
			
			if (amt2) {
				var a2:Number = parseInt(amt2.value, 10);
				if (!isNaN(a2)) _modifier.props.amount2 = a2;
			}
			
			if (amt3) {
				var a3:Number = parseInt(amt3.value, 10);
				if (!isNaN(a3)) _modifier.props.amount3 = a3;
			}
			
			if (optA) {
				
				_modifier.props.optionA = optA.checked;
				
				if (e.target == optA && optA.checked && optB && optB.checked && 
					(_modifier.props.type == CreatorUIStates.MODIFIER_SLIDER ||
					_modifier.props.type == CreatorUIStates.MODIFIER_MOVER ||
					_modifier.props.type == CreatorUIStates.MODIFIER_ARCADEMOVER ||
					_modifier.props.type == CreatorUIStates.MODIFIER_JUMPER)) {
						
					_modifier.props.optionB = optB.checked = false;
						
				}
				
			}
			
			if (optB) {
				
				_modifier.props.optionB = optB.checked;
				
				if (e.target == optB && optB.checked && optA && optA.checked && 
					(_modifier.props.type == CreatorUIStates.MODIFIER_SLIDER ||
					_modifier.props.type == CreatorUIStates.MODIFIER_MOVER ||
					_modifier.props.type == CreatorUIStates.MODIFIER_ARCADEMOVER ||
					_modifier.props.type == CreatorUIStates.MODIFIER_JUMPER)) {
						
					_modifier.props.optionA = optA.checked = false;
						
				}				
				
			}
			
			if (optC) {
				
				_modifier.props.optionC = optC.checked;			
				
			}
			
		}
		
		protected function build ():void {
			
			var addAmt1:Boolean = false;
			var addAmt2:Boolean = false;
			var addAmt3:Boolean = false;
			var addoptA:Boolean = false;
			var addoptB:Boolean = false;
			var addoptC:Boolean = false;
			var amt1Title:String = "";
			var amt2Title:String = "";
			var amt3Title:String = "";
			var optATitle:String = "";
			var optBTitle:String = "";
			var optCTitle:String = "";
			var amt1Alt:String = "";
			var amt2Alt:String = "";
			var amt3Alt:String = "";
			var optAAlt:String = "";
			var optBAlt:String = "";
			var optCAlt:String = "";
			var boxHeight:Number = 0;
			var restrict:String = "0123456789.";
			var checkboxIndent:int = 75;
			
			switch (_modifier.props.type) {
				
				case CreatorUIStates.MODIFIER_ADDER:
					amt1Title = "<p align=\"right\">Key down speed <a class=\"litelink\" href=\"event:showtag\">(?)</a> (secs)</p>";
					amt1Alt = "Speed at which objects are added while the spacebar is pushed down";
					amt2Title = "<p align=\"right\">Total Adds <a class=\"litelink\" href=\"event:showtag\">(?)</a> (0 for infinity)</p>";
					amt3Title = "<p align=\"right\">Added Lifespan <a class=\"litelink\" href=\"event:showtag\">(?)</a> (secs)</p>"
					addoptA = true;
					optATitle = "use mouse click";
					optAAlt = "Check this if you want to use a mouse click instead of the spacebar";
					
				case CreatorUIStates.MODIFIER_SPAWNER:
				case CreatorUIStates.MODIFIER_FACTORY:
					addAmt1 = true;
					if (amt1Title == "") amt1Title = "<p align=\"right\">Spawn Interval <a class=\"litelink\" href=\"event:showtag\">(?)</a> (secs)</p>";
					if (amt1Alt == "") amt1Alt = "Speed (in seconds) at which new objects are added to the game";
					addAmt2 = true;
					if (amt2Title == "") amt2Title = "<p align=\"right\">Total Spawns <a class=\"litelink\" href=\"event:showtag\">(?)</a> (0 for infinity)</p>";
					if (amt2Alt == "") amt2Alt = "Total number of objects this widget will add to the game";
					addAmt3 = true;
					if (amt3Title == "") amt3Title = "<p align=\"right\">Spawned Lifespan <a class=\"litelink\" href=\"event:showtag\">(?)</a> (secs)</p>"
					if (amt3Alt == "") amt3Alt = "How long each spawned object will live in the game. Enter 0 for forever.";
					if (!addoptA) boxHeight = 130;
					else boxHeight = 160;
					addoptB = true;
					optBTitle = "explode on expire";
					optBAlt = "Check this if you want spawned objects to explode at end of lifespan";
					break;
					
				case CreatorUIStates.MODIFIER_THRUSTER:
					addAmt1 = true;
					if (amt1Title == "") amt1Title = "<p align=\"right\">Keyboard letter to press <a class=\"litelink\" href=\"event:showtag\">(?)</a></p>";
					if (amt1Alt == "") amt1Alt = "Enter a letter for which key to press to activate this thruster";
					addoptA = true;
					optATitle = "don't rotate with object";
					optAAlt = "Check this if you want the thruster to always point in the same direction regardless of object orientation";
					boxHeight = 75;
					restrict = "a-zA-Z";
					checkboxIndent = 33;
					break;
				
				case CreatorUIStates.MODIFIER_SLIDER:
					addoptA = true;
					optATitle = "only use LEFT and RIGHT arrows";
					optAAlt = "Check this if you want to only use the LEFT and RIGHT arrows and not the A and D keys";
					addoptB = true;
					optBTitle = "only use A and D keys";
					optBAlt = "Check this if you want to only use the A and D keys and not the LEFT and RIGHT arrow keys";
					checkboxIndent = 33;
					boxHeight = 75;
					break;
					
				case CreatorUIStates.MODIFIER_MOVER:
					addoptA = true;
					optATitle = "only use UP and DOWN arrows";
					optAAlt = "Check this if you want to only use the UP and DOWN arrows and not the W and S keys";
					addoptB = true;
					optBTitle = "only use W and S keys";
					optBAlt = "Check this if you want to only use the W and S keys and not the UP and DOWN arrow keys";
					checkboxIndent = 33;
					boxHeight = 75;
					break;
					
				case CreatorUIStates.MODIFIER_ARCADEMOVER:
					addAmt1 = true;
					if (amt1Title == "") amt1Title = "<p align=\"right\">Movement <a class=\"litelink\" href=\"event:showtag\">(?)</a> (pixels)</p>";
					if (amt1Alt == "") amt1Alt = "Speed (in pixels per frame) at which the object moves when a direction arrow is pressed";
					addoptA = true;
					optATitle = "only use arrow keys";
					optAAlt = "Check this if you want to only use the arrow keys and not the WASD keys";
					addoptB = true;
					optBTitle = "only use WASD keys";
					optBAlt = "Check this if you want to only use the WASD keys and not the arrow keys";
					checkboxIndent = 33;
					boxHeight = 110;
					break;
					
				case CreatorUIStates.MODIFIER_JUMPER:
					addoptA = true;
					optATitle = "only use UP arrow";
					optAAlt = "Check this if you want to only use the UP arrow and not the W key";
					addoptB = true;
					optBTitle = "only use W key";
					optBAlt = "Check this if you want to only use the W key and not the arrow key";
					addoptC = true;
					optCTitle = "Allow air-jumping";
					optCAlt = "Check this if you want to be able to jump repeatedly in mid air";
					
					
					checkboxIndent = 33;
					boxHeight = 100;
					break;
					
			}
			
			var o:Point = new Point(0, 0);
			var offset:Point = new Point();
	
			if (_modifier.props.type == CreatorUIStates.MODIFIER_FACTORY && _modifier.clip && _modifier.clip.parent) {
				
				var r:Rectangle = _modifier.clip.getBounds(_container);
				o.x = r.x + r.width * 0.5;
				o.y = r.y + r.height * 0.5;
				offset.x = r.width * 0.5;
				offset.y = 0 - r.height * 0.5;
				
			} else {
				
				o = _modifier.props.parent.clip.localToGlobal(o);
				o = _container.globalToLocal(o);
				offset.x = _modifier.props.parent.props.width * 0.5;
				offset.y = 0 - boxHeight * 0.5;				
				
			}
			
			box = new Cell(null, 250, boxHeight, true, true, 10);
			_cell.addChild(box);
			box.x = o.x + offset.x + 20;
			box.y = o.y + offset.y;
			
			if (box.x > 640 - 250) {
				box.x = o.x - offset.x - 20 - 250;
			}
			
			if (box.y > 480 - 150) {
				box.y = 480 - 150;
			}
			
			box.x = Math.floor(box.x);
			box.y = Math.floor(box.y);
			
			box.addChild(new Cell(null, 250, 10));
			box.allowCellDrag();
			
			var amtt:HTMLField;
			
			var s:Style = Styles.dialogueStyle.clone();
			s.fontSize = 11;
			s.textColor = 0xcccccc;
			
			var s2:Style = s.clone();
			s2.embedFonts = false;
			s2.font = "_sans";
			
			var p:Position = Styles.floatPosition.clone( { margins: "5 10 5 10" } );
			
			if (addAmt1) {
				amtt = new HTMLField(null, amt1Title, 150, false, p, s);
				amtt.alt = amt1Alt;
				box.addChild(amtt);
				amt1 = new FormField(null, "000", 60, 25, true, Styles.floatPosition, s2);
				box.addChild(amt1);
				amt1.restrict = restrict;
				if (_modifier.props.type == CreatorUIStates.MODIFIER_THRUSTER) {
					amt1.text = String.fromCharCode(_modifier.props.amount);
				} else if (_modifier.props.type == CreatorUIStates.MODIFIER_ARCADEMOVER) {
					amt1.text = _modifier.props.amount + "";
				} else {
					amt1.text = (_modifier.props.amount / 1000) + "";
				}
				amt1.addEventListener(Component.EVENT_CHANGE, onChange);
				
			}

			if (addAmt2) {
				amtt = new HTMLField(null, amt2Title, 150, false, p, s);
				amtt.alt = amt2Alt;
				box.addChild(amtt);
				amt2 = new FormField(null, "000", 60, 25, true, Styles.floatPosition, s2);
				box.addChild(amt2);
				amt2.restrict = "0123456789";
				amt2.text = _modifier.props.amount2.toString();
				amt2.addEventListener(Component.EVENT_CHANGE, onChange);
			}

			if (addAmt3) {
				amtt = new HTMLField(null, amt3Title, 150, false, p, s);
				amtt.alt = amt3Alt;
				box.addChild(amtt);
				amt3 = new FormField(null, "000", 60, 25, true, Styles.floatPosition, s2);
				box.addChild(amt3);
				amt3.restrict = "0123456789";
				amt3.text = _modifier.props.amount3.toString();
				amt3.addEventListener(Component.EVENT_CHANGE, onChange);
			}
			
			if (addoptA) {
				optA = new CheckBox(null, optATitle, "mouse", _modifier.props.optionA, 200, 20, optAAlt, p.clone( { margin_left: checkboxIndent} ), s);
				box.addChild(optA);
				optA.addEventListener(Component.EVENT_CHANGE, onChange);
			}
			
			if (addoptB) {
				optB = new CheckBox(null, optBTitle, "splode", _modifier.props.optionB, 200, 25, optBAlt, p.clone( { margin_left: checkboxIndent, margin_top: 0 } ), s);
				box.addChild(optB);
				optB.addEventListener(Component.EVENT_CHANGE, onChange);
			}
			
			if (addoptC) {
				optC = new CheckBox(null, optCTitle, "flapp", _modifier.props.optionC, 200, 20, optCAlt, p.clone( { margin_left: checkboxIndent, margin_top: 0 } ), s);
				box.addChild(optC);
				optC.addEventListener(Component.EVENT_CHANGE, onChange);
			}
			
		}
		
		protected function unbuild ():void {
			
			if (amt1) amt1.removeEventListener(Component.EVENT_CHANGE, onChange);
			if (amt2) amt2.removeEventListener(Component.EVENT_CHANGE, onChange);
			if (amt3) amt3.removeEventListener(Component.EVENT_CHANGE, onChange);
			if (optA) optA.removeEventListener(Component.EVENT_CHANGE, onChange);
			if (optB) optB.removeEventListener(Component.EVENT_CHANGE, onChange);
			
			amt1 = amt2 = amt3 = null;
			optA = null;
			optB = null;
			
			_cell.clear();
			
		}
		
		public function show (modifier:Modifier):void {
			
			if (_modifier != modifier) {
				hide();
			}
			
			if (!_showing) {
				_modifier = modifier;
				_showing = true;
				build();
			}
			
		}
		
		public function hide ():void {
			
			if (_showing) {
				unbuild();
				_showing = false;
			}
			
		}
		
	}

}