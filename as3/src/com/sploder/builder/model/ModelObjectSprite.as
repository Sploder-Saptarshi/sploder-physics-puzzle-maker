package com.sploder.builder.model 
{
	
	import com.sploder.asui.Prompt;
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.builder.model.ModelObject;
	import com.sploder.builder.Shapes;
	import com.sploder.builder.Textures;
	import com.sploder.game.library.EmbeddedLibrary;
	import com.sploder.util.Geom2d;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class ModelObjectSprite extends Sprite
	{
		public static var library:EmbeddedLibrary;
		public static var suppressDraw:Boolean = false;
		
		public static const VIEW_CONSTRUCT:uint = 0;
		public static const VIEW_DECORATE:uint = 1;
		
		protected var _modelObject:ModelObject;
		public function get obj ():ModelObject { return _modelObject; }
		
		public function get id ():int {
			if (_modelObject) return _modelObject.id;
			return 0;
		}
		
		public function get zlayer ():int {
			if (_modelObject && _modelObject.props) return _modelObject.props.zlayer;
			return 3;
		}
		
		protected var _mode:uint = 0;
		public function get mode():uint { return _mode; }
		public function set mode(value:uint):void 
		{
			if (_mode != value) {
				_mode = value;
				if (_mode == VIEW_DECORATE) setHandleVisibility(false);
				draw();
			}
		}
		
		protected var _indicatorLocked:Sprite;
		protected var _indicatorSlide:Sprite;
		protected var _indicatorStatic:Sprite;
		
		protected var _handleRotate:SimpleButton;
		protected var _handlePin:SimpleButton;
		
		protected var _handleTL:SimpleButton;
		protected var _handleTR:SimpleButton;
		protected var _handleBL:SimpleButton;
		protected var _handleBR:SimpleButton;
		
		protected var _handlesV:Vector.<SimpleButton>;
		
		protected var _handlesAdded:Boolean = false;
		
		protected var _m:Matrix;
		
		protected var _suspended:Boolean = false;
		
		public function ModelObjectSprite (modelObject:ModelObject) 
		{
			super();
			
			_modelObject = modelObject;
			_m = new Matrix();
				
		}
		
		protected function addHandles ():void {
			
			if (suppressDraw) return;
			
			_indicatorSlide = library.getDisplayObject(CreatorUIStates.INDICATOR_SLIDE) as Sprite;
			_indicatorSlide.visible = false;
			_indicatorSlide.mouseEnabled = false;
			addChild(_indicatorSlide);
			
			_indicatorLocked = library.getDisplayObject(CreatorUIStates.INDICATOR_LOCKED) as Sprite;
			_indicatorLocked.visible = false;
			_indicatorLocked.mouseEnabled = false;
			addChild(_indicatorLocked);
			
			_indicatorStatic = library.getDisplayObject(CreatorUIStates.INDICATOR_STATIC) as Sprite;
			_indicatorStatic.visible = false;
			_indicatorStatic.mouseEnabled = false;
			addChild(_indicatorStatic);
			
			if (_modelObject.props.shape != CreatorUIStates.SHAPE_RAMP) {
				_handleRotate = library.getDisplayObject(CreatorUIStates.BUTTON_HANDLE_ROTATE) as SimpleButton;
				_handleRotate.name = CreatorUIStates.ROTATE;
				_handleRotate.visible = false;
				addChild(_handleRotate);
				Prompt.connectButton(_handleRotate, "Drag this to rotate the object. Double-click to reset rotation.");
			}
			
			_handlePin = library.getDisplayObject(CreatorUIStates.BUTTON_HANDLE_PIN) as SimpleButton;
			_handlePin.name = CreatorUIStates.PIN;
			_handlePin.visible = false;
			addChild(_handlePin);
			Prompt.connectButton(_handlePin, "Drag this to change the center of rotation for this object.");
			
			if (_modelObject.props.shape == CreatorUIStates.SHAPE_BOX ||
				_modelObject.props.shape == CreatorUIStates.SHAPE_RAMP) {
				
				if (_modelObject.props.shape == CreatorUIStates.SHAPE_BOX) {
					_handleTL = library.getDisplayObject(CreatorUIStates.BUTTON_HANDLE_CORNER) as SimpleButton;
					_handleTL.name = CreatorUIStates.TOP_LEFT;
					_handleTL.visible = false;
					addChild(_handleTL);
					Prompt.connectButton(_handleTL, "Drag this to change the shape of this object.");
				}
				
				_handleTR = library.getDisplayObject(CreatorUIStates.BUTTON_HANDLE_CORNER) as SimpleButton;
				_handleTR.name = CreatorUIStates.TOP_RIGHT;
				_handleTR.visible = false;
				addChild(_handleTR);
				Prompt.connectButton(_handleTR, "Drag this to change the shape of this object.");
				
				_handleBL = library.getDisplayObject(CreatorUIStates.BUTTON_HANDLE_CORNER) as SimpleButton;
				_handleBL.name = CreatorUIStates.BOTTOM_LEFT;
				_handleBL.visible = false;
				addChild(_handleBL);
				Prompt.connectButton(_handleBL, "Drag this to change the shape of this object.");
				
				_handleBR = library.getDisplayObject(CreatorUIStates.BUTTON_HANDLE_CORNER) as SimpleButton;
				_handleBR.name = CreatorUIStates.BOTTOM_RIGHT;
				_handleBR.visible = false;
				addChild(_handleBR);
				Prompt.connectButton(_handleBR, "Drag this to change the shape of this object.");
				
			} else if (_modelObject.props.shape == CreatorUIStates.SHAPE_POLY) {
				
				if (_handlesV != null) {
					while (_handlesV.length) removeChild(_handlesV.pop());
				}
				
				_handlesV = new Vector.<SimpleButton>();
				
				if (_modelObject.props.vertices) {
					var h:SimpleButton;
					var v:Vector.<Point> = _modelObject.props.vertices;
					for (var i:int = 0; i < v.length; i++) {
						h = library.getDisplayObject(CreatorUIStates.BUTTON_HANDLE_VERTEX) as SimpleButton;
						h.name = CreatorUIStates.VERTEX;
						h.visible = false;
						_handlesV.push(h);
						h.x = v[i].x;
						h.y = v[i].y;
						addChild(h);
						Prompt.connectButton(h, "Drag this to change the shape of this object, double-click to remove.");
					}
				} else {
					return;
				}
				
				
			}
			
			_handlesAdded = true;
			
		}
		
		protected function setHandleVisibility (vis:Boolean = true):void {
			
			var w:int = _modelObject.props.width;
			var h:int = _modelObject.props.height;
			
			if (_handleRotate) {
				_handleRotate.visible = vis;
				_handleRotate.x = 0;
				_handleRotate.y = (_modelObject.props.shape == CreatorUIStates.SHAPE_POLY) ? 
					Math.min( -40, 0 - h / 4) : 
					0 - h / 2;
			}
			if (_handleTL) {
				_handleTL.visible = vis;
				_handleTL.x = 0 - w / 2;
				_handleTL.y = 0 - h / 2;
			}
			if (_handleTR) {
				_handleTR.visible = vis;
				_handleTR.x = w / 2;
				_handleTR.y = 0 - h / 2;
			}
			if (_handleBL) {
				_handleBL.visible = vis;
				_handleBL.x = 0 - w / 2;
				_handleBL.y = h / 2;
			}
			if (_handleBR) {
				_handleBR.visible = vis;
				_handleBR.x = w / 2;
				_handleBR.y = h / 2;
			}
			if (_handlesV) {
				var i:int = _handlesV.length;
				while (i--) {
					_handlesV[i].visible = vis;
					_handlesV[i].x = _modelObject.props.vertices[i].x;
					_handlesV[i].y = _modelObject.props.vertices[i].y;
					_handlesV[i].rotation = 0 - _modelObject.rotation;
				}
			}
			
			if (_indicatorSlide) {
				_indicatorSlide.visible = (vis && _modelObject.props.constraint == CreatorUIStates.MOVEMENT_SLIDE);
				_indicatorSlide.rotation = 0 - _modelObject.rotation;
			}
			
			if (_indicatorLocked) {
				_indicatorLocked.visible = (vis && _modelObject.props.locked);
				_indicatorLocked.rotation = 0 - _modelObject.rotation;
			}
			
			if (_modelObject.props.constraint == CreatorUIStates.MOVEMENT_PIN) {
				
				_handlePin.visible = vis;
				
				var pos:Point = _modelObject.pin;
				
				if (vis && _modelObject.rotation != 0) {
					pos = pos.clone();
					Geom2d.rotate(pos, 0 - _modelObject.rotation * Geom2d.dtr);
				}
				
				_handlePin.x = pos.x;
				_handlePin.y = pos.y;
				_handlePin.rotation = 0 - _modelObject.rotation;

			} else {
				
				if (_handlePin) _handlePin.visible = false;
				
			}

			if (_modelObject.props.constraint == CreatorUIStates.MOVEMENT_STATIC) {
				
				if (_indicatorStatic) {
					_indicatorStatic.visible = vis;
					_indicatorStatic.rotation = 0 - _modelObject.rotation;
				}
				if (_indicatorLocked) {
					_indicatorLocked.visible = false;
				}
				
			} else {
				
				if (_indicatorStatic) {
					_indicatorStatic.visible = false;
				}
				
			}
			
		}
		
		public function getHandleIndex (handle:SimpleButton):int {
			
			return _handlesV.indexOf(handle);
			
		}
		
		public function addVertexHandle ():SimpleButton {
			
			var h:SimpleButton = library.getDisplayObject(CreatorUIStates.BUTTON_HANDLE_VERTEX) as SimpleButton;
			h.name = CreatorUIStates.VERTEX;
			h.visible = false;
			_handlesV.push(h);
			addChild(h);
			Prompt.connectButton(h, "Drag this to change the shape of this object, double-click to remove.");
			
			return h;
			
		}
		
		public function removeVertexHandle (index:int):void {
			
			if (_handlesV && _handlesV.length > index) {
				
				var h:Vector.<SimpleButton> = _handlesV.splice(index, 1);
				if (h.length > 0 && h[0].parent) h[0].parent.removeChild(h[0]);
				
			}
			
		}
		
		public function draw ():void
		{
			if (_suspended || _modelObject.deleted) return;
			if (suppressDraw) return;
			if (library == null) return;
			if (_modelObject == null || _modelObject.props == null || _modelObject.props.shape == CreatorUIStates.SHAPE_NONE) return;
			if (!_handlesAdded) addHandles();
			
			x = _modelObject.origin.x;
			y = _modelObject.origin.y;
			rotation = _modelObject.rotation;
			
			if (_modelObject.state == ModelObject.STATE_DRAGGING) {
				x += _modelObject.offset.x;
				y += _modelObject.offset.y;
			} else if (_mode != VIEW_DECORATE && _modelObject.state == ModelObject.STATE_SELECTED) {
				if (parent) parent.setChildIndex(this, parent.numChildren - 1);
			}
			
			var g:Graphics = graphics;
			g.clear();
			
			
			
			if (_mode == VIEW_DECORATE) {
				
				var m:ModelObject = _modelObject;
				
				var bd:BitmapData;
				if (m.props.attribs != null)
				{
					bd = library.getTextureBitmapData(m.props.attribs, 64);
				} 
				else if (m.props.texture > 0 || m.props.graphic > 0) 
				{
					bd = Textures.getScaledBitmapData(m.props.textureName, 8, 0, this);
				}
				
				var highlight:Boolean = (m.state == ModelObject.STATE_SELECTED || m.state == ModelObject.STATE_DRAGGING);
						
				var glow:Boolean = (m.props.color >= 0 && m.props.line == -2);
				
				if (m.props.shape == CreatorUIStates.SHAPE_CIRCLE && m.props.scribble == 0) {
					
					if (glow) {
						Shapes.drawCircle(g, m.props.size, null, 0, 0, 8, m.props.color, 0.65, false);
						Shapes.drawCircle(g, m.props.size, null, 0, 0, 16, m.props.color, 0.4, false);
					}
					
					if (highlight) {
						Shapes.drawCircle(g, m.props.size, null, 0, 0, 8, 0xffffff, 0.35, false);
						Shapes.drawCircle(g, m.props.size, null, 0, 0, 16, 0xffffff, 0.15, false);
					}
					
					if (m.props.color >= 0 || m.props.line >= 0) {
						Shapes.drawCircle(g, m.props.size, null, 
							m.props.color >= 0 ? m.props.color : 0, 
							m.props.color >= 0 ? ((m.props.opaque == 1) ? 1 : 0.5) : 0.01, 
							m.props.line >= 0 ? 4 : NaN, 
							m.props.line >= 0 ? m.props.line : 0,
							1, false);
					} else if (m.props.texture == 0 && m.props.graphic == 0 && m.props.attribs == null) {	
						Shapes.drawCircle(g, m.props.size, null, 0, 0, 2, 0x00ffff, 0.5, !highlight);
					} else if (m.props.graphic > 0) {
						Shapes.drawCircle(g, m.props.size, null, 0, 0, 2, 0xff0066, 0.25, !highlight);
					}
					
					if (m.props.texture > 0 || m.props.graphic > 0 || m.props.attribs != null) {
						
						if (bd) {
							_m.createBox(m.props.size / (bd.width * 0.5), m.props.size / (bd.height * 0.5), 0, m.props.size, m.props.size);
							g.beginBitmapFill(bd, _m, true, true);
							g.drawCircle(0, 0, m.props.size);
							g.endFill();
						}
						
					}
					
				} else {
				
					var bsv:Vector.<Point> = (m.props.vertices) ? m.props.vertices : Shapes.getVertices(m.props.shape, m.props.width, m.props.height, 30, m.props.scribble * 2, _modelObject.id);
					if (m.props.vertices && m.props.scribble == 1) bsv = Shapes.tesselate(m.props.verticesClone(), 30, 2, _modelObject.id);
					
					if (glow) {
						Shapes.drawShape(g, bsv, null, 0, 0, 8, m.props.color, 0.65, false);
						Shapes.drawShape(g, bsv, null, 0, 0, 16, m.props.color, 0.4, false);
					}
					
					if (highlight) {
						Shapes.drawShape(g, bsv, null, 0, 0, 8, 0xffffff, 0.35, false);
						Shapes.drawShape(g, bsv, null, 0, 0, 16, 0xffffff, 0.15, false);
					}
					
					if (m.props.color >= 0 || m.props.line >= 0) {
						Shapes.drawShape(g, bsv, null, 
							m.props.color >= 0 ? m.props.color : 0, 
							m.props.color >= 0 ? ((m.props.opaque == 1) ? 1 : 0.5) : 0.01, 
							m.props.line >= 0 ? 4 : NaN, 
							m.props.line >= 0 ? m.props.line : 0,
							1, false);
					} else if (m.props.texture == 0 && m.props.graphic == 0 && m.props.attribs == null) {	
						Shapes.drawShape(g, bsv, null, 0, 0, 2, 0x00ffff, 0.5, false);
					} else if (m.props.graphic > 0) {	
						Shapes.drawShape(g, bsv, null, 0, 0, 2, 0xff0066, 0.25, false);
					}
					
					if (m.props.texture > 0 || m.props.graphic > 0 || m.props.attribs != null) {
										
						if (bd) {
							
							switch (m.props.shape) {
								case CreatorUIStates.SHAPE_CIRCLE:
								case CreatorUIStates.SHAPE_SQUARE:
								case CreatorUIStates.SHAPE_PENT:
								case CreatorUIStates.SHAPE_HEX:
									_m.createBox(m.props.size / (bd.width * 0.5), m.props.size / (bd.height * 0.5), 0, m.props.size, m.props.size);
									break;
								case CreatorUIStates.SHAPE_BOX:
									if (m.props.graphic > 0 || m.props.attribs != null) {
										_m.createBox(m.props.size / (bd.width * 0.5), m.props.size / (bd.height * 0.5), 0, m.props.size, m.props.size);
										break;
									}
									// if texture, continue
								default:
									_m.createBox(0.25, 0.25, 0, bd.width * 0.125, bd.height * 0.125);
									break;
							}
							Shapes.drawTexture(g, bsv, bd, _m, null, true);
							
						}
						
					}
				
				}
				
				if (_modelObject.state == ModelObject.STATE_SELECTED || 
					_modelObject.state == ModelObject.STATE_DRAGGING) {
					setHandleVisibility();
				} else {
					setHandleVisibility(false);
				}
					
				return;
				
			}
			
			g.clear();
			g.beginFill(getFillColor(_modelObject), getFillAlpha(_modelObject));
			
			if (_modelObject.state == ModelObject.STATE_SELECTED || 
				_modelObject.state == ModelObject.STATE_DRAGGING) {
				g.lineStyle(4, 0xffffff);
				setHandleVisibility();
			} else {
				g.lineStyle(getLineThickness(_modelObject), getLineColor(_modelObject));
				setHandleVisibility(false);
			}
			
			if (_modelObject.props.width == 0 && _modelObject.props.height == 0) {
				g.beginFill(0xffffff, 1);
				g.lineStyle(4, 0xffffff, 0.5);
				g.drawCircle(0, 0, 4);
				return;
			}
			
			
			drawBody(g);
			
			if (_modelObject.props.constraint == CreatorUIStates.MOVEMENT_STATIC) {
				g.lineStyle(2, 0x000000, 0.5);
			}
			
			if (getFillHatch(_modelObject) != "") {
				_m.createBox(1, 1, 0 - _modelObject.rotation * Geom2d.dtr);
				g.beginBitmapFill(library.getBitmapData(getFillHatch(_modelObject)), _m);
				drawBody(g);
			} else if (_modelObject.props.constraint == CreatorUIStates.MOVEMENT_STATIC) {
				g.beginFill(0, 0);
				drawBody(g);
			}
			
			if (_modelObject.state == ModelObject.STATE_SELECTED &&
				_modelObject.props.constraint == CreatorUIStates.MOVEMENT_PIN) {
				
				var r:Number = _modelObject.pin.length;
				if (r > 0) {
					g.lineStyle(2, 0xffec00, 0.5);
					g.beginFill(0, 0);
					var pos:Point = _modelObject.pin;
					if (_modelObject.rotation != 0) {
						pos = pos.clone();
						Geom2d.rotate(pos, 0 - _modelObject.rotation * Geom2d.dtr);
					}
					g.drawCircle(pos.x, pos.y, r);
				}
				
			}

			g.lineStyle(NaN, NaN);
			g.beginFill(0, 0.25);
			g.drawCircle(0, 0, 4);
			g.beginFill(0xffec00, 1);
			g.drawCircle(0, 0, 2);
			

		}
		
		protected function drawBody (g:Graphics):void {
			
			var sides:int = 0;
			var a:Number = 0;	
			var r:Number = _modelObject.props.size;			
			var s:Number = 0;
			var i:uint;
			
			switch (_modelObject.props.shape) {
				
				case CreatorUIStates.SHAPE_BOX:
					g.moveTo(0, 0);
					g.lineTo(0, 0 - _modelObject.props.height / 2);
					g.drawRect(0 - _modelObject.props.width / 2, 0 - _modelObject.props.height / 2, _modelObject.props.width, _modelObject.props.height);
					break;
					
				case CreatorUIStates.SHAPE_RAMP:
					g.moveTo(_modelObject.props.width / 2, 0 - _modelObject.props.height / 2);
					g.lineTo(_modelObject.props.width / 2, _modelObject.props.height / 2);
					g.lineTo(0 - _modelObject.props.width / 2, _modelObject.props.height / 2);
					g.lineTo(_modelObject.props.width / 2, 0 - _modelObject.props.height / 2);
					break;
				
				case CreatorUIStates.SHAPE_CIRCLE:
					g.moveTo(0, 0);
					g.lineTo(0, 0 - r);
					g.drawCircle(0, 0, r);
					break;
					
				case CreatorUIStates.SHAPE_SQUARE:
					g.moveTo(0, 0);
					g.lineTo(0, 0 - r);
					g.drawRect(0 - r, 0 - r, r * 2, r * 2);
					break;
					
				case CreatorUIStates.SHAPE_PENT:
					sides = 5;
					
				case CreatorUIStates.SHAPE_HEX:
					if (sides == 0) sides = 6;
					a = 0;							
					s = Math.PI * 2 / sides;
					g.moveTo(0, 0);
					for (i = 0; i <= sides; ++i) {
						graphics.lineTo(r * Math.cos(a + s * i), r * Math.sin(a + s * i));
					}
					break;
				
				case CreatorUIStates.SHAPE_POLY:
					
					if (_modelObject.props.vertices && _modelObject.props.vertices.length > 2) {
						var v:Vector.<Point> = _modelObject.props.vertices;
						g.moveTo(v[0].x, v[0].y);
						for (i = 1; i < v.length; i++) {
							g.lineTo(v[i].x, v[i].y);
						}
						g.lineTo(v[0].x, v[0].y);
						if (_modelObject.state == ModelObject.STATE_SELECTED) {
							g.moveTo(0, 0);
							g.lineStyle(2, getLineColor(_modelObject), 0.5);
							g.lineTo(_handleRotate.x, _handleRotate.y);
						}
					}
					break;
			}			
			
		}
		
		public function suspend ():void
		{
			_suspended = true;
		}
		
		public function release ():void
		{
			_suspended = false;
			draw();
		}
		
		override public function toString():String 
		{
			return _modelObject.toString();
		}
		
		public static function getFillColor (obj:ModelObject):uint {
			
			
			var mat:String = obj.props.material;
			
			switch (mat) {
				
				case CreatorUIStates.MATERIAL_GLASS:
					return 0x0099ff;
				case CreatorUIStates.MATERIAL_ICE:
					return 0x66cccc;
				case CreatorUIStates.MATERIAL_RUBBER:
					return 0x660099;
				case CreatorUIStates.MATERIAL_STEEL:
					return 0x999999;
				case CreatorUIStates.MATERIAL_TIRE:
					return 0x000000;
				case CreatorUIStates.MATERIAL_WOOD:
					return 0x993300;
				case CreatorUIStates.MATERIAL_AIR_BALLOON:
					return 0x0096e4;
				case CreatorUIStates.MATERIAL_HELIUM_BALLOON:
					return 0x0096e4;
				case CreatorUIStates.MATERIAL_MAGNET:
					return 0x666666;
				case CreatorUIStates.MATERIAL_SUPERBALL:
					return 0xff00ff;
				
			}
			
			return 0xffffff;
			
		}
		
		public static function getFillAlpha (obj:ModelObject):Number {
			
			if (obj.state == ModelObject.STATE_NEW || obj.state == ModelObject.STATE_DRAGGING) return 0.5;
			
			var mat:String = obj.props.material;
			
			switch (mat) {
				
				case CreatorUIStates.MATERIAL_GLASS:
					return 0.5;
				case CreatorUIStates.MATERIAL_ICE:
				case CreatorUIStates.MATERIAL_RUBBER:
				case CreatorUIStates.MATERIAL_STEEL:
				case CreatorUIStates.MATERIAL_TIRE:
				case CreatorUIStates.MATERIAL_WOOD:
				case CreatorUIStates.MATERIAL_AIR_BALLOON:
				case CreatorUIStates.MATERIAL_HELIUM_BALLOON:
				case CreatorUIStates.MATERIAL_MAGNET:
				case CreatorUIStates.MATERIAL_SUPERBALL:
					return 1;
				
			}
			
			return 1;
			
		}
		
		public static function getLineColor (obj:ModelObject):uint {
			
			if (obj.focused) return 0xffffff;
			if (obj.props.constraint == CreatorUIStates.MOVEMENT_STATIC) return 0xcccccc;
			
			var mat:String = obj.props.material;
			
			switch (mat) {
				
				case CreatorUIStates.MATERIAL_GLASS:
					return 0x0099ff;
				case CreatorUIStates.MATERIAL_ICE:
					return 0x66ffff;
				case CreatorUIStates.MATERIAL_RUBBER:
					return 0xcc00ff;
				case CreatorUIStates.MATERIAL_STEEL:
					return 0xcccccc;
				case CreatorUIStates.MATERIAL_TIRE:
					return 0x666666;
				case CreatorUIStates.MATERIAL_WOOD:
					return 0xcc6600;
				case CreatorUIStates.MATERIAL_AIR_BALLOON:
					return 0x0075d4;
				case CreatorUIStates.MATERIAL_HELIUM_BALLOON:
					return 0x0075d4;
				case CreatorUIStates.MATERIAL_MAGNET:
					return 0xcccccc;
				case CreatorUIStates.MATERIAL_SUPERBALL:
					return 0xff66ff;
				
			}
			
			return 0xffffff;
			
		}
		
		public static function getLineThickness (obj:ModelObject):int {
			
			if (obj.props.constraint == CreatorUIStates.MOVEMENT_STATIC) return 4;
			
			return 2;
			
		}
		
		public static function getFillHatch (obj:ModelObject):String {
			
			switch (obj.props.strength) {
				
				case CreatorUIStates.STRENGTH_STRONG:
					return CreatorUIStates.HATCH_STRONG;
				case CreatorUIStates.STRENGTH_STRONG:
					return CreatorUIStates.HATCH_STRONG;
				case CreatorUIStates.STRENGTH_MEDIUM:
					return CreatorUIStates.HATCH_MEDIUM;
				case CreatorUIStates.STRENGTH_WEAK:
					return CreatorUIStates.HATCH_WEAK;
				
			}
			
			return "";
			
		}
		
	}

}