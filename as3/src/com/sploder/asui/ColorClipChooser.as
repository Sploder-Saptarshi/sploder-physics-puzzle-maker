package com.sploder.asui 
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Geoff Gaudreault
	 */
	public class ColorClipChooser extends ClipChooser 
	{
		private var selector:Shape;
		
		public function ColorClipChooser(container:Sprite, textLabel:String, choices:Array, alts:Array, selectionIndex:Number=0, promptText:String="", width:Number=NaN, height:Number=NaN, menuPosition:int=Position.POSITION_RIGHT, position:Position=null, style:Style=null) 
		{
			super(container, textLabel, choices, alts, selectionIndex, promptText, width, height, menuPosition, position, style);
			
		}
		
		override protected function createElements():void 
		{
			super.createElements();
			createChoices();
		}
		
		override protected function createChoices ():void {
			
			var i:int;
			
			if (_choicesCreated) return;
			_choicesCreated = true;
			
			var dt:Number = 0;
			var dl:Number = 0;
			var dw:Number = Math.min(_choices.length, rowLength) * (_height - choicesShrink);
			var dh:Number = Math.ceil(_choices.length / rowLength) * (_height - choicesShrink);
			
			switch (_dropdownPosition) {
				
				case Position.POSITION_ABOVE:
					dt = 0 - dh;
					dl = 0;
					break;
				
				case Position.POSITION_RIGHT:
					dt = 0;
					dl = _width;
					break;
				
				case Position.POSITION_BELOW:
					dt = _height;
					dl = 0;
					break;
				
				case Position.POSITION_LEFT:
					dt = 0;
					dl = 0 - dw;
					dw = Math.min(_choices.length, rowLength) * _height;
					break;
				
				
			}
			
			dl += choicesOffsetX;
			dt += choicesOffsetY;
            
            _dropdown = Cell(addChild(new Cell(null, dw, dh, true, true, (choicesPadding == 0) ? 0 : _style.round, new Position({ placement: Position.PLACEMENT_ABSOLUTE, top: dt, left: dl, ignoreContentPadding: true }))));
            _dropdown.maskContent = _dropdown.trapMouse = _dropdown.collapse = true;
            _dropdown.hide();
            
			var a:String = "";
			
			_buttons = [];
			
			for (i = 0; i < _choices.length; i++) {
                
				a = "";
				if (_alts && _alts[i]) a = _alts[i];
				
				if (typeof(_choices[i]) != "number")
				{
					var dobj:DisplayObject = library.getDisplayObject(_choices[i]);
					if (dobj != null) {
						dobj.width = dobj.height = 16;
						
						_dropdown.bkgd.addChild(dobj);
						dobj.x = 2 + 18 * (i % 18) - dobj.getBounds(dobj.parent).x;
						dobj.y = 2 + 18 * Math.floor(i / 18) - dobj.getBounds(dobj.parent).y;
						if (dobj is Sprite) Sprite(dobj).mouseEnabled = false;
					}
					
				}
                
            }
            
			var g:Graphics = _dropdown.bkgd.graphics;
			g.clear();
			
			g.beginFill(0);
			g.drawRect(0, 0, 18 * 18 + 2, 18 * 13 + 2);
			g.endFill();
			
            for (i = 0; i < _choices.length; i++) {
                
				if (typeof(_choices[i]) == "number")
				{
					g.beginFill(_choices[i]);
					g.drawRect(2 + 18 * (i % 18), 2 + 18 * Math.floor(i / 18), 16, 16);
					g.endFill();
				}
                
            }
			
			_dropdown.trapMouse = false;
			_dropdown.mouseEnabled = true;
			_dropdown.bkgd.buttonMode = true;
			_dropdown.bkgd.useHandCursor = true;
			_dropdown.bkgd.mouseEnabled = true;
			
			_dropdown.bkgd.addEventListener(MouseEvent.MOUSE_UP, onChoice);
			
			selector = new Shape();
			g = selector.graphics;
			g.lineStyle(1, 0xffffff);
			g.drawRect(0, 0, 15, 15);
			_dropdown.bkgd.addChild(selector);
			
			if (!isNaN(_selectionIndex))
			{
				selector.x = 2 + 18 * (_selectionIndex % 18);
				selector.y = 2 + 18 * Math.floor(_selectionIndex / 18);
			} else {
				selector.x = selector.y = 2;
			}
			
            addEventListener(EVENT_BLUR, _dropdown.hide);
		}
		
		override public function onChoice (e:Event):void {
            
			if (e is MouseEvent && e.target == _dropdown.bkgd) {
				
				var me:MouseEvent = e as MouseEvent;
				var idx:int = Math.floor((me.localY - 2) / 18) * 18 + Math.floor((me.localX - 2) / 18); 
				
				if (idx >= 0 && idx < _choices.length)
				{
					selector.x = 2 + 18 * (idx % 18);
					selector.y = 2 + 18 * Math.floor(idx / 18);
					
					var changed:Boolean = (_choiceButton.symbolName != (_choices[idx] + ""));
					if (changed) _choiceButton.setSymbol(_choices[idx] + "");
					
					dispatchEvent(new Event(EVENT_CLICK));
					dispatchEvent(new Event(EVENT_SELECT));
					if (changed) dispatchEvent(new Event(EVENT_CHANGE));
				}
				
				toggle();
			}
		}
		
		override public function set value(val:String):void 
		{
			if (val == value) return;
			if (_buttons == null) return;
			for (var i:int = 0; i < _choices.length; i++) {
				var symbol_name:String = _choices[i] + "";
				if (symbol_name == val) {
					selector.x = 2 + 18 * (i % 18);
					selector.y = 2 + 18 * Math.floor(i / 18);
					_choiceButton.setSymbol(symbol_name);
					dispatchEvent(new Event(EVENT_CHANGE))
					return;
				}
			}
		}
	}

}