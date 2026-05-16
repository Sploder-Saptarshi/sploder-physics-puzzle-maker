package com.sploder.builder.model 
{
	import com.sploder.builder.Creator;
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.asui.Component;
	import com.sploder.util.Geom2d;
	import com.sploder.util.Key;
	import flash.display.Graphics;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import nape.*;
	import nape.geom.GeomPoly;
	import nape.geom.GeomVert;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.shape.Polygon;
	import nape.util.Tools;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class ModelController
	{
		public static const STATE_IDLE:int = 0;
		public static const STATE_CREATING:int = 1;
		public static const STATE_EDITING:int = 2;
		public static const STATE_COPYING:int = 3;
		public static const STATE_SELECTING:int = 4;
		public static const STATE_ROTATING:int = 5;
		public static const STATE_SIZING:int = 6;
		
		public static var mainInstance:ModelController;
		
		private var _state:int = STATE_IDLE;
		private var _subState:String = "";

		private var _creator:Creator;
		private var _model:Model;
		
		private var _newObject:ModelObject;
		private var _selection:ModelSelection;
		private var _history:UndoHistory;
		private var _prevSelection:ModelObjectContainer;
		private var _mouseVector:Point;
		private var _dragVector:Point;
		
		public var paintFillColor:int = 0x993300;
		public var paintLineColor:int = 0xcc6600;
		public var paintTexture:int = 0;
		public var paintLayer:int = 3;
		public var paintOpaque:int = 1;
		public var paintScribble:int = 0;
		
		private var _vertexIndex:int = 0;
		private var _vertices:Array;
        private var px:Number; 
		private var py:Number;
		private var _mouseIsDown:Boolean;
		private var _mouseDownTime:int = 0;
		private var _mouseDownTimeLast:int = 0;
		
		public var snap:Boolean = true;
		
		private var _clipboard:String = "";
		public function get clipboard():String { return _clipboard; }
		public function set clipboard(value:String):void { _clipboard = value; }
		
		public function get newObject():ModelObject { return _newObject; }
		public function get selection():ModelSelection { return _selection; }
		public function get history():UndoHistory { return _history; }
		
		public function get mouseVector():Point { return _mouseVector; }
		public function get dragVector():Point { return _dragVector; }
		
		protected var _focusObject:ModelObject;
		public function get focusObject():ModelObject { return _focusObject; }
		public function set focusObject(value:ModelObject):void 
		{
			if (_focusObject) _focusObject.focused = false;
			_focusObject = value;
			ModifierSprite.focusObject = value;
			if (_focusObject) _focusObject.focused = true;
		}
		
		
		public function ModelController(main:Creator) 
		{
			super();
			init(main);
			
		}
		
		protected function init (main:Creator):void {
			
			_creator = main;
			_model = _creator.model;
			
			mainInstance = this;
			
			ModifierSprite.focusClass = ModelController;
			
			_mouseVector = new Point();
			_dragVector = new Point();
			
			_vertices = [];
			
			_model.newObjectContainer.mouseEnabled = _model.newObjectContainer.mouseChildren = false;
			_model.newObjectContainer.transform.colorTransform = new ColorTransform(1, 0.8, 0, 1, 255, 230, 0);
			_model.selectionWindow.mouseEnabled = _model.selectionWindow.mouseChildren = false;
			_model.modifiers.addEventListener(Event.SELECT, onModifierSelect);

			_selection = new ModelSelection(_model, this, _model.selectionWindow);
			_history = new UndoHistory(_model, this);
			_prevSelection = new ModelObjectContainer();
			
		}
		
		public function connect ():void {
			
			_creator.ui.tools.addEventListener(Component.EVENT_CHANGE, onToolChange);
			_creator.stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			_creator.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			
		}
		
		public function createNewObject ():void {
			
			var pt:Point = _mouseVector;

			_newObject = new ModelObject();
			_newObject.clip.suspend();
			_newObject.origin.x = (snap) ? Math.round(pt.x / 10) * 10 : pt.x;
			_newObject.origin.y = (snap) ? Math.round(pt.y / 10) * 10 : pt.y;
			_newObject.props.shape = _creator.ui.shapes.value;
			_newObject.props.zlayer = paintLayer;
			updateObjectFromUI(_newObject);
			_model.newObjectContainer.addChild(_newObject.clip);
			_newObject.clip.release();			
			
		}
		
		public function createNewModifier (type:String, parent:ModelObject, child:ModelObject = null):void {
			
			var mod:Modifier = new Modifier();
			mod.clip.suspend();
			mod.props.type = type;
			mod.props.parent = parent;
			
			switch (type) {
				
				case CreatorUIStates.MODIFIER_SWITCHER:
				case CreatorUIStates.MODIFIER_EMAGNET:
					child = null;
					break;
					
				case CreatorUIStates.MODIFIER_MOTOR:
					child = null;
					mod.props.amount = 1;
					if (mod.props.parent.props.constraint == CreatorUIStates.MOVEMENT_STATIC) {
						mod.props.parent.props.constraint = CreatorUIStates.MOVEMENT_PIN;
					}
					break;
					
				case CreatorUIStates.MODIFIER_ROTATOR:
				case CreatorUIStates.MODIFIER_LAUNCHER:
				case CreatorUIStates.MODIFIER_SELECTOR:
				case CreatorUIStates.MODIFIER_AIMER:
				case CreatorUIStates.MODIFIER_DRAGGER:
				case CreatorUIStates.MODIFIER_CLICKER:
				case CreatorUIStates.MODIFIER_POINTER:
					child = null;
					mod.props.amount = 1;
					break;
					
				case CreatorUIStates.MODIFIER_ARCADEMOVER:
					child = null;
					mod.props.amount = 10;
					break;
				
				case CreatorUIStates.MODIFIER_ADDER:
				case CreatorUIStates.MODIFIER_SPAWNER:
				case CreatorUIStates.MODIFIER_FACTORY:
					mod.props.amount = 1000;
					mod.props.amount2 = 0;
					mod.props.amount3 = 10;
				case CreatorUIStates.MODIFIER_PUSHER:
				case CreatorUIStates.MODIFIER_MOVER:
				case CreatorUIStates.MODIFIER_JUMPER:
					child = null;
					mod.props.childOffset.y = -50;
					break;
				
				case CreatorUIStates.MODIFIER_THRUSTER:
				case CreatorUIStates.MODIFIER_PROPELLER:
					child = null;
					mod.props.childOffset.y = -50;
					mod.props.amount = 90;
					break;
					
				case CreatorUIStates.MODIFIER_SLIDER:
					child = null;
					mod.props.childOffset.x = -50;
					break;
					
				case CreatorUIStates.MODIFIER_UNLOCKER:
				case CreatorUIStates.MODIFIER_GEARJOINT:
				case CreatorUIStates.MODIFIER_PINJOINT:
				case CreatorUIStates.MODIFIER_DAMPEDSPRING:
				case CreatorUIStates.MODIFIER_LOOSESPRING:
					mod.props.childOffset.y = -100;
					break;
					
				case CreatorUIStates.MODIFIER_GROOVEJOINT:
					mod.props.parentOffset.x = -100;
					mod.props.childOffset.x = 100;
					break;
					
				case CreatorUIStates.MODIFIER_ELEVATOR:
					mod.props.parentOffset.y = -100;
					mod.props.childOffset.y = 100;
					break;
			}
			
			if (_selection.length == 2 &&
				(type == CreatorUIStates.MODIFIER_DAMPEDSPRING ||
				type == CreatorUIStates.MODIFIER_LOOSESPRING ||
				type == CreatorUIStates.MODIFIER_PINJOINT)
				) {
					
				child = (_selection.objects[0] == parent) ? _selection.objects[1] : _selection.objects[0];
				
			}
			
			if (_selection.length == 2 && type == CreatorUIStates.MODIFIER_UNLOCKER) {
				child = (_focusObject == _selection.objects[0]) ? _selection.objects[1] : _selection.objects[0];
				mod.props.childOffset.x = mod.props.childOffset.y = 0;
			}
			
			if (child) {
				mod.props.child = child;
				mod.props.setChildOffset(0, 0);
			}
			
			_model.modifiers.addObject(mod);
			
			mod.clip.release();
			
		}
		
		public function addModifiersParentOnly (objName:String):void {
			for (var i:int = 0; i < _selection.length; i++) {
				createNewModifier(objName, _selection.objects[i]);
			}	
		}
		
		public function addModifiersParentChildStep (objName:String):void {
			if (_creator.ui.tools.value == CreatorUIStates.TOOL_WINDOW) {
				_selection.sortSpatially();
			}
			for (var i:int = 0; i < _selection.length - 1; i++) {
				createNewModifier(objName, _selection.objects[i], _selection.objects[i + 1]);
			}
		}
		
		public function addModifiersParentChildSpoke (objName:String):void {
			for (var i:int = 0; i < _selection.length; i++) {
				if (_selection.objects[i] != _focusObject) {
					createNewModifier(objName, _focusObject, _selection.objects[i]);
				}
			}
		}
		
		public function updateObjectFromUI (obj:ModelObject):void {
			
			obj.props.constraint = _creator.ui.constraints.value;
			obj.props.material = _creator.ui.materials.value;
			obj.props.strength = _creator.ui.strengths.value;
			obj.props.locked = _creator.ui.moveLock.toggled;	
			obj.props.color = ModelObjectSprite.getFillColor(obj);
			obj.props.line = ModelObjectSprite.getLineColor(obj);
			obj.props.opaque = (obj.props.material == CreatorUIStates.MATERIAL_GLASS) ? 0 : 1;
			
		}
		
		public function updateSelection (attrib:String):void {
			
			_history.record();
			
			var obj:ModelObject;
			var i:int = _selection.length;
			
			while (i--) {
				
				obj = _selection.objects[i];
				
				switch (attrib) {
					case CreatorUIStates.MOVEMENT:
						obj.props.constraint = _creator.ui.constraints.value;
						break;
						
					case CreatorUIStates.MATERIAL:
						obj.props.material = _creator.ui.materials.value;
						break;
						
					case CreatorUIStates.STRENGTH:
						obj.props.strength = _creator.ui.strengths.value;
						break;
						
					case CreatorUIStates.LOCK:
						obj.props.locked = _creator.ui.moveLock.toggled;	
						break;
						
					case CreatorUIStates.DECORATE_FILL:
						if (_creator.ui.fills.value == CreatorUIStates.NONE) {
							obj.props.color = -1;
						} else {
							obj.props.color = parseInt(_creator.ui.fills.value);
						}
						break;
						
					case CreatorUIStates.DECORATE_LINE:
						if (_creator.ui.lines.value == CreatorUIStates.NONE) {
							obj.props.line = -1;
						} else if (_creator.ui.lines.value == CreatorUIStates.GLOW) {
							obj.props.line = -2;
						} else {
							obj.props.line = parseInt(_creator.ui.lines.value);
						}
						break;
					
					case CreatorUIStates.TEXTURE:
						obj.props.texture = paintTexture;
						obj.props.graphic = 0;
						obj.props.graphic_version = 0;
						obj.props.graphic_flip = 0;
						obj.props.animation = 0;
						break;
						
					case CreatorUIStates.DECORATE_ZLAYER:
						obj.props.zlayer = paintLayer;
						_model.zSort();
						break;
						
					case CreatorUIStates.OPAQUE:
						obj.props.opaque = paintOpaque;
						break;
						
					case CreatorUIStates.SCRIBBLE:
						obj.props.scribble = paintScribble;
						break;
						
				}
				
			}
			
		}
		
		protected function onToolChange (e:Event):void {
			
			_model.touchArea.buttonMode = _model.touchArea.useHandCursor = false;
			_model.objectsContainer.buttonMode = _model.objectsContainer.useHandCursor = false;
			_model.objectsContainer.mouseEnabled = _model.objectsContainer.mouseChildren = false;
			_model.modifiersContainer.mouseEnabled = _model.modifiersContainer.mouseChildren = false;
			_model.modifiersContainer.alpha = 0.5;
			_model.touchArea.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_model.touchArea.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_model.objectsContainer.removeEventListener(MouseEvent.MOUSE_DOWN, onObjectPress);
			_model.objectsContainer.removeEventListener(MouseEvent.MOUSE_UP, onObjectRelease);
			_model.objectsContainer.removeEventListener(MouseEvent.MOUSE_DOWN, onObjectPaintPress);
			_model.objectsContainer.removeEventListener(MouseEvent.MOUSE_UP, onObjectPaintRelease);
			_model.objectsContainer.removeEventListener(MouseEvent.MOUSE_DOWN, onObjectPaintPick);
			_model.touchArea.removeEventListener(MouseEvent.MOUSE_UP, onObjectPaintDeselect);
			
			snap = true;
			
			switch (_creator.ui.tools.value) {
				
				case CreatorUIStates.TOOL_SELECT:
				
					_model.objectsContainer.buttonMode = _model.objectsContainer.useHandCursor = true;
					_model.objectsContainer.mouseEnabled = _model.objectsContainer.mouseChildren = true;
					_model.modifiersContainer.mouseChildren = true;
					_model.modifiersContainer.alpha = 1;
					_model.touchArea.buttonMode = true;
					_model.touchArea.useHandCursor = false;
					_model.objectsContainer.addEventListener(MouseEvent.MOUSE_DOWN, onObjectPress);
					_model.objectsContainer.addEventListener(MouseEvent.MOUSE_UP, onObjectRelease);
					_model.touchArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					_model.touchArea.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					break;
					
				case CreatorUIStates.TOOL_WINDOW:
				
					_model.objectsContainer.buttonMode = _model.objectsContainer.useHandCursor = true;
					_model.objectsContainer.mouseEnabled = _model.objectsContainer.mouseChildren = true;
					_model.objectsContainer.addEventListener(MouseEvent.MOUSE_DOWN, onObjectPress);
					_model.objectsContainer.addEventListener(MouseEvent.MOUSE_UP, onObjectRelease);
					_model.touchArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					_model.touchArea.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					_model.modifiers.focusObject = null;
					break;
					
				case CreatorUIStates.TOOL_DRAW:
				
					_model.touchArea.buttonMode = _model.touchArea.useHandCursor = true;
					_model.touchArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					_model.touchArea.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					_selection.clear();
					_model.modifiers.focusObject = null;
					break;
					
				case CreatorUIStates.TOOL_PAINT:
				
					_model.objectsContainer.buttonMode = _model.objectsContainer.useHandCursor = true;
					_model.objectsContainer.mouseEnabled = _model.objectsContainer.mouseChildren = true;
					_model.objectsContainer.addEventListener(MouseEvent.MOUSE_DOWN, onObjectPaintPress);
					_model.objectsContainer.addEventListener(MouseEvent.MOUSE_UP, onObjectPaintRelease);
					_model.touchArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					_model.touchArea.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					_model.modifiers.focusObject = null;
					break;
					
				case CreatorUIStates.TOOL_PICK:
				
					_model.objectsContainer.buttonMode = _model.objectsContainer.useHandCursor = true;
					_model.objectsContainer.mouseEnabled = _model.objectsContainer.mouseChildren = true;
					_model.objectsContainer.addEventListener(MouseEvent.MOUSE_DOWN, onObjectPaintPick);
					break;
										
				
			}
			
		}
		
		protected function onModifierSelect (e:Event):void {
			
			if (_model.modifiers.focusObject) _selection.clear();
			focusObject = null;
			
		}

		protected function setMouseAnchorPoint (snap:Boolean = false):void
		{
			_mouseVector.x = _model.touchArea.mouseX;
			_mouseVector.y = _model.touchArea.mouseY;
			
			if (snap) {
				_mouseVector.x = Math.round(_mouseVector.x / 10) * 10;
				_mouseVector.y = Math.round(_mouseVector.y / 10) * 10;
			}
			
		}
		
		protected function setMouseDragPoint (snap:Boolean = false):void
		{
			_dragVector.x = _model.touchArea.mouseX - _mouseVector.x;
			_dragVector.y = _model.touchArea.mouseY - _mouseVector.y;
		
			if (snap || _subState == CreatorUIStates.PIN) {
				_dragVector.x = Math.round(_dragVector.x / 10) * 10;
				_dragVector.y = Math.round(_dragVector.y / 10) * 10;
			}
			
			if (Key.shiftKey && _state != STATE_COPYING && _subState != CreatorUIStates.VERTEX) {
				if (_state == STATE_SIZING) {
					var s:int = Math.abs(Math.max(_dragVector.x, _dragVector.y));
					var ix:int = (_dragVector.x >= 0) ? 1 : -1;
					var iy:int = (_dragVector.y >= 0) ? 1 : -1;
					_dragVector.x = _dragVector.y = s;
					_dragVector.x *= ix;
					_dragVector.y *= iy;
				} else if (_state != STATE_ROTATING) {
					if (Math.abs(_dragVector.x) > Math.abs(_dragVector.y)) {
						_dragVector.y = 0;
					} else {
						_dragVector.x = 0;
					}
				}
			}
			
		}
		
		protected function clearMouseDragPoint ():void
		{
			_dragVector.x = _dragVector.y = 0;
		}

		protected function onMouseDown (e:MouseEvent):void
		{
			if (_creator.testing) return;
			
			if (_state == STATE_IDLE) {
				
				_selection.clear();
				if (_newObject) onMouseUp(e);
				
				_subState = "";
				focusObject = null;
				_mouseIsDown = true;

				switch (_creator.ui.tools.value) {
					
					case CreatorUIStates.TOOL_SELECT:
						setMouseAnchorPoint();
						break;
						
					case CreatorUIStates.TOOL_WINDOW:
					case CreatorUIStates.TOOL_PAINT:
					
						_state = STATE_SELECTING;
						setMouseAnchorPoint();
						_selection.startSelection();
						_model.objectsContainer.mouseEnabled = _model.objectsContainer.mouseChildren = false;
						_model.modifiersContainer.mouseChildren = false;
						break;
						
					case CreatorUIStates.TOOL_DRAW:
									
						_state = STATE_CREATING;
						
						if (_model.getLayerView(2) == false) _model.setLayerView(2, true);
						
						setMouseAnchorPoint();
						
						_history.record();
						
						createNewObject();
						
						if (_newObject.props.shape == CreatorUIStates.SHAPE_POLY) {
							
							var x:Number = _model.newObjectContainer.mouseX;
							var y:Number = _model.newObjectContainer.mouseY;
							var g:Graphics = _model.newObjectContainer.graphics;

							g.lineStyle(2, 0, 1);
							_vertices.push(new Vec2(x, y));
							g.moveTo(x, y);
							px = x; py = y;
									
						}
						
						break;
				}
				
				_model.touchArea.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

			}
			
			//_mouseDownTime = getTimer();
			
		}

		protected function onMouseMove (e:MouseEvent = null):void
		{
			if (_creator.testing) return;
			
			switch (_creator.ui.tools.value) {
					
				case CreatorUIStates.TOOL_SELECT:
					if (_mouseIsDown && _model.container.scaleX == 1) {
						_creator.ui.playfieldContainer.contentX -= _dragVector.x;
						_creator.ui.playfieldContainer.contentY -= _dragVector.y;
						setMouseDragPoint();
						_creator.ui.playfieldContainer.contentX += _dragVector.x;
						_creator.ui.playfieldContainer.contentY += _dragVector.y;
						_creator.ui.playfieldContainer.contentX = Math.min(0, Math.max(_creator.ui.playfieldContainer.contentX, 0 - _model.width + 640 - 24));
						_creator.ui.playfieldContainer.contentY = Math.min(0, Math.max(_creator.ui.playfieldContainer.contentY, 0 - _model.height + 480 - 24));
						_creator.ui.hScroll.alignToTarget();
						_creator.ui.vScroll.alignToTarget();
					}
					break;
					
			}
			
			switch (_state) {
				
				case STATE_SELECTING:
				
					setMouseDragPoint();
					_selection.updateSelection();
					break;
				
				case STATE_CREATING:
				
					if (_newObject) {
						
						setMouseDragPoint();
						
						if (_newObject.props.shape == CreatorUIStates.SHAPE_POLY) {
							
							if (_mouseIsDown) {
								
								// Trace the object on the stage so the user can see what he has done
								var x:Number = _model.newObjectContainer.mouseX;
								var y:Number = _model.newObjectContainer.mouseY;
								var g:Graphics = _model.newObjectContainer.graphics;
								
								var dx:Number = x - px; 
								var dy:Number = y - py;
								
								if (dx * dx + dy * dy > 100) {
									if (e.shiftKey) {
										x = Math.round(x / 10) * 10;
										y = Math.round(y / 10) * 10;
									}
									_vertices.push(new Vec2(x, y));
									px = x; py = y;
									g.lineTo(x, y);
								}
								
							}
							
						} else {
						
							_newObject.clip.suspend();
							_newObject.updateFromVector(_dragVector, _mouseVector,
								(_newObject.props.shape == CreatorUIStates.SHAPE_BOX || _newObject.props.shape == CreatorUIStates.SHAPE_RAMP) ? CreatorUIStates.BOTTOM_RIGHT : CreatorUIStates.ORIGIN,
								snap, 
								e.shiftKey);
							_newObject.clip.release();
							
						}
						
					}
					break;
		
			}	
			
		}
		
		protected function onMouseUp (e:MouseEvent):void
		{
			if (_creator.testing) return;
			
			_mouseIsDown = false;
			
			switch (_creator.ui.tools.value) {
					
				case CreatorUIStates.TOOL_SELECT:
					_model.touchArea.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
					break;
					
			}
			
			switch (_state) {
				
				case STATE_SELECTING:
				
					_selection.endSelection();
					_model.objectsContainer.mouseEnabled = _model.objectsContainer.mouseChildren = true;
					if (_creator.ui.tools.value == CreatorUIStates.TOOL_SELECT) {
						_model.modifiersContainer.mouseChildren = true;
					}
					if (getTimer() - _mouseDownTime <= 250) {
						_creator.ui.tools.activateTab(null, _creator.ui.tools.tabs[CreatorUIStates.TOOL_SELECT]);
					}
					_state = STATE_IDLE;
					break;
				
				case STATE_CREATING:
				
					_model.touchArea.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);

					onMouseMove(e);
					
					if (_newObject) {
							
						if (_newObject.props.shape == CreatorUIStates.SHAPE_POLY) {
							
							var g:Graphics = _model.newObjectContainer.graphics;
								
							// Check and see if the user has drawn anything we can use.
							
							if (_vertices.length >= 3) {
								
								var poly:GeomPoly = new GeomPoly(_vertices);
								
								if (e.shiftKey) {
									poly.simplify(1000, 100);
								} else {
									poly.simplify(4000, 120);
								}
								
								if (!poly.selfIntersecting()) {
									
									if (!poly.cw()) poly.points.reverse();
									
									var v:Vector.<Point> = new Vector.<Point>();
									var p:GeomVert;
									
									p = poly.points;
									do {
										if (p.p) {
											v.push(new Point(
												p.p.px - _newObject.origin.x, 
												p.p.py - _newObject.origin.y
												));
										}
									} while (p = p.next);
									
									_newObject.props.vertices = v;
									_newObject.centerVertices();
									
								}
							}
							// Erase the sprite and clear the data
							g.clear();
							_vertices = new Array();
							px = -100;
						
						}
						
						if (_newObject.isValid()) {
							_model.addObject(_newObject);
							_newObject.state = ModelObject.STATE_IDLE;
						} else {
							_newObject.destroy();
							if (getTimer() - _mouseDownTime <= 250) {
								_creator.ui.tools.activateTab(null, _creator.ui.tools.tabs[CreatorUIStates.TOOL_SELECT]);
							}
						}
						_newObject = null;
						
					}
					
					_state = STATE_IDLE;
					break;
					
				case STATE_EDITING:
				case STATE_SIZING:
				
					onObjectRelease(e);
					break;
					
				case STATE_COPYING:
					break;
					
				default:
					_selection.clear();
					_model.modifiers.focusObject = null;
					if (getTimer() - _mouseDownTime <= 250) {
						if (_creator.ui.tools.activeTab.value == CreatorUIStates.TOOL_SELECT) {
							_creator.ui.tools.activateTab(null, _creator.ui.tools.tabs[CreatorUIStates.TOOL_WINDOW]);
						}
					}
					break;
			
			}
			
			if (_state != STATE_COPYING) clearMouseDragPoint();
			//e.stopImmediatePropagation();
		}
		
		protected function onObjectPaintPress (e:MouseEvent):void {
			
			if (_creator.testing) return;
			
			onObjectPress(e, true);
			
			var o:ModelObject = ModelObject(e.target.obj);
			
			if (o && o.props) {
							
				if (_selection.contains(o)) {
					if (!e.shiftKey && !e.ctrlKey) {
						if (o.props.graphic == 0 && getTimer() - _mouseDownTime < 250) {
							o.props.color = paintFillColor;
							o.props.line = paintLineColor;
							o.props.texture = paintTexture;
							o.props.zlayer = paintLayer;
							o.props.opaque = paintOpaque;
							o.props.scribble = paintScribble;
						}		
					}
				}

			}
			
			_mouseDownTime = getTimer();
			
		}
		
		protected function onObjectPaintRelease (e:MouseEvent):void {
			
			if (_creator.testing) return;
			onObjectRelease(e);
			
		}
		
		protected function onObjectPaintDeselect (e:MouseEvent):void {
			if (_creator.testing) return;
			_selection.clear();
		}
		
		protected function onObjectPaintPick (e:MouseEvent):void {
			
			if (_creator.testing) return;
			
			var o:ModelObject = ModelObject(e.target.obj);
			
			if (o && o.props) {
				
				paintFillColor = o.props.color;
				paintLineColor = o.props.line;
				paintLayer = o.props.zlayer;
				
				_creator.uiController.getPaintState();
				
			}			
			
		}
		
		protected function onObjectPress (e:MouseEvent, suppressMouseDownTime:Boolean = false):void
		{
			if (_creator.testing) return;
			
			_history.record();
			_subState = "";
			focusObject = null;
			
			if (!(e.target is ModelObjectSprite)) {
				
				_state == STATE_IDLE;
				
				if (e.target is SimpleButton && SimpleButton(e.target).parent is ModelObjectSprite) {
					
					var obj:ModelObject = ModelObjectSprite(e.target.parent).obj;
					_selection.clear();
					_selection.addObject(obj);
					_mouseVector.x = obj.origin.x;
					_mouseVector.y = obj.origin.y;

					switch (e.target.name) {
						
						case CreatorUIStates.ROTATE:
							if (getTimer() - _mouseDownTime < 250) {
								obj.rotation = 0;
							}
							_state = STATE_ROTATING;
							break;
							
						case CreatorUIStates.VERTEX:
						
							_state = STATE_SIZING;
							_subState = e.target.name;
							_mouseVector.x = obj.origin.x;
							_mouseVector.y = obj.origin.y;
							_vertexIndex = obj.clip.getHandleIndex(e.target as SimpleButton);
							if (_vertexIndex == -1) _state = STATE_EDITING;
							else if (getTimer() - _mouseDownTime < 250 &&
								obj.props.vertices.length > 3) {
								obj.deleteVertex(_vertexIndex);
								_state = STATE_EDITING;
								_subState = "";
							}
							break;
							
						case CreatorUIStates.PIN:
						
							_state = STATE_SIZING;
							_subState = e.target.name;
							_mouseVector.x = obj.origin.x;
							_mouseVector.y = obj.origin.y;
							if (getTimer() - _mouseDownTime < 250) {
								obj.setPinPosition(new Point(0, 0));
								_state = STATE_EDITING;
								_subState = "";
							}
							break;
							
						default:
							_state = STATE_SIZING;
							_subState = e.target.name;
							
							switch (_subState) {
								case CreatorUIStates.TOP_LEFT:
									_mouseVector.x = obj.props.width / 2;
									_mouseVector.y = obj.props.height / 2;
									break;
								case CreatorUIStates.TOP_RIGHT:
									_mouseVector.x = 0 - obj.props.width / 2;
									_mouseVector.y = obj.props.height / 2;
									break;
								case CreatorUIStates.BOTTOM_LEFT:
									_mouseVector.x = obj.props.width / 2;
									_mouseVector.y = 0 - obj.props.height / 2;
									break;
								case CreatorUIStates.BOTTOM_RIGHT:
									_mouseVector.x = 0 - obj.props.width / 2;
									_mouseVector.y = 0 - obj.props.height / 2;
									break;
							}
							
							Geom2d.rotate(_mouseVector, obj.rotation * Geom2d.dtr);
							_mouseVector.x += obj.origin.x;
							_mouseVector.y += obj.origin.y;
							
							break;
					}
					
					_model.container.addEventListener(MouseEvent.MOUSE_MOVE, onObjectDrag);
					
				}

			}
			
			var o:ModelObject = ModelObject(e.target.obj);
			
			if (o != null && _state == STATE_IDLE) {
				
				switch (_creator.ui.tools.value) {
					
					case CreatorUIStates.TOOL_SELECT:
					case CreatorUIStates.TOOL_WINDOW:
					case CreatorUIStates.TOOL_PAINT:
					
						setMouseAnchorPoint();
						_state = STATE_EDITING;
						
						if (!_selection.contains(o)) {
							if (!e.shiftKey && !e.ctrlKey) _selection.clear();
							if (o.group) {
								_selection.addObjects(o.group.objects);
							} else {
								_selection.addObject(o);
							}
						} else {
							if (e.ctrlKey) {
								if (o.group) {
									_selection.removeObjects(o.group.objects);
								} else {
									_selection.removeObject(o);
								}
							} else if (e.shiftKey) {
								_prevSelection.clear();
								_prevSelection.addObjects(_selection.objects);
								_selection.duplicateObjects();
								for (var i:int = 0; i < _selection.length; i++) {
									_selection.objects[i].state = ModelObject.STATE_NEW;
									_selection.objects[i].clip.draw();
									_model.newObjectContainer.addChild(_selection.objects[i].clip);
								}
								_state = STATE_COPYING;
							} else if (getTimer() - _mouseDownTime < 250 && o.props.shape == CreatorUIStates.SHAPE_POLY) {
								o.addVertex();
							}
						}
						
						_model.container.addEventListener(MouseEvent.MOUSE_MOVE, onObjectDrag);
						
						break;
						
					
				}
				
			}
			
			_mouseIsDown = true;
			if (!suppressMouseDownTime) _mouseDownTime = getTimer();
			
		}
		
		protected function onObjectDrag (e:MouseEvent):void
		{
			if (_creator.testing) return;
			
			if (!_mouseIsDown) {
				onObjectRelease(e);
				return;
			}
			
			var obj:ModelObject;
			
			switch (_state) {
				
				case STATE_EDITING:
				case STATE_COPYING:
					
					setMouseDragPoint();
					_selection.drag();
					break;
					
				case STATE_ROTATING:
					
					if (_selection.length == 1) {
						setMouseDragPoint();
						obj = _selection.objects[0];
						obj.clip.suspend();
						obj.updateFromVector(_dragVector, _mouseVector, CreatorUIStates.ORIGIN, snap, e.shiftKey);
						obj.clip.release();
					}
					break;
					
				case STATE_SIZING:
					
					if (_selection.length == 1) {
						
						setMouseDragPoint();
						obj = _selection.objects[0];
						obj.clip.suspend();
						
						if (_subState == CreatorUIStates.PIN) {
						
							obj.setPinPosition(_dragVector);
							
						} else if (_subState == CreatorUIStates.VERTEX) {
							
							obj.setVertexPosition(_vertexIndex, _dragVector);
							
						} else {
							
							obj.updateFromVector(_dragVector, _mouseVector, _subState, snap, e.shiftKey);
							
						}
						
						obj.clip.release();
						
					}
					break;
					
			}
			
			
		
		}
		
		protected function onObjectRelease (e:MouseEvent):void
		{
			if (_creator.testing) return;
			
			_model.container.removeEventListener(MouseEvent.MOUSE_MOVE, onObjectDrag);
			
			if (_state == STATE_EDITING || _state == STATE_COPYING) {
					
				setMouseAnchorPoint();
				
				if (_state == STATE_COPYING && Math.abs(_dragVector.x) < 10 && Math.abs(_dragVector.y) < 10) {
					
					_selection.destroyObjects();
					
				} else {
				
					var ps:Vector.<ModelObject> = _prevSelection.objects;
					var ns:Vector.<ModelObject> = _selection.objects.concat();
					
					_selection.drop();
					
					if (_state == STATE_COPYING && ps && ns && ps.length > 0) {
						
						var i:int;
						
						// GROUPS;
						
						var groups:Dictionary = new Dictionary();
						var pm:ModelObject;
						var m:ModelObject;
						var g:ModelObjectContainer;
				
						for (i = 0; i < ns.length; i++) {
							
							pm = ps[i];
							m = ns[i];
							m.state = ModelObject.STATE_SELECTED;
							_model.objectsContainer.addChild(m.clip);
							if (pm.groupID > 0) {
								if (groups[pm.groupID] == null) {
									groups[pm.groupID] = new ModelObjectContainer();
								}
								g = groups[pm.groupID];
								g.addObject(m);
								m.group = g;
							}
		
						}
						
						try  {
						//
						// ASSOCIATED MODIFIERS
						
						var md:Modifier;
						
						for (i = 0; i < _model.modifiers.objects.length; i++) {
							
							md = _model.modifiers.objects[i];
							
							if (md && md.props && 
								md.props.parent && 
								ps.indexOf(md.props.parent) != -1 && 
								ps.indexOf(md.props.parent) < ps.length) {
									
								md = md.clone();
								if (ps.length > ps.indexOf(md.props.parent)) md.props.parent = ns[ps.indexOf(md.props.parent)];
								if (md.props && md.props.child && ps.indexOf(md.props.child) != -1 && ps.indexOf(md.props.child) < ps.length) md.props.child = ns[ps.indexOf(md.props.child)];
								_model.modifiers.addObject(md);
								md.clip.draw();
								
							}
							
						}
						
						} catch (e:Error) {
							
							trace("Unable to copy modifiers");
							
						}
						
					}
					
				}
				
			}
			
			if (_state == STATE_SIZING && _subState == CreatorUIStates.VERTEX) {
				
				if (_selection.length == 1) {
					_selection.objects[0].centerVertices();
				}
				
			}
			
			_state = STATE_IDLE;
			_subState = "";
			clearMouseDragPoint();
			
			_mouseIsDown = false;
			
			//e.stopImmediatePropagation();
		}
		
		private function onStageMouseDown (e:MouseEvent):void {
			
			if (_creator.testing) return;
			_mouseDownTimeLast = getTimer();
			
		}
		
		protected function onStageMouseUp (e:MouseEvent):void
		{
			if (_creator.testing) return;
			
			switch (_state) {

				case STATE_IDLE:
					_mouseIsDown = false;
					break;
					
				case STATE_CREATING:
					onMouseUp(e);
					break;
					
				case STATE_EDITING:
				case STATE_COPYING:
				case STATE_SELECTING:
				case STATE_SIZING:
					onObjectRelease(e);
					break;
			
			}
			
			_mouseDownTime = _mouseDownTimeLast;

		}
		
		public function lockSelectedObjects ():void {
			
			_history.record();
			var i:int = _selection.length;
			while (i--) _selection.objects[i].props.locked = true;
			
		}
		
		public function unlockSelectedObjects ():void {
			
			_history.record();
			var i:int = _selection.length;
			while (i--) _selection.objects[i].props.locked = false;
			
		}
		
		public function groupSelectedObjects ():void {
			
			_history.record();
			ungroupSelectedObjects();
			
			var i:int;
			var o:ModelObject;
			var g:ModelObjectContainer = new ModelObjectContainer();
			
			i = _selection.length;
			while (i--) {
				o = _selection.objects[i];
				g.addObject(o);
				o.group = g;
				o.clip.draw();
			}
			
			_selection.dispatchEvent(new Event(Event.CHANGE));
			
		}
		
		public function ungroupSelectedObjects ():void {
			
			_history.record();
			
			var i:int;
			var o:ModelObject;

			i = _selection.length;
			while (i--) {
				o = _selection.objects[i];
				if (o.group) {
					o.group.removeObject(o);
					o.group = null;
					o.clip.draw();
				}
			}
			
			_selection.dispatchEvent(new Event(Event.CHANGE));
			
		}
		
		public function getLayerState (m:ModelObject, layerNum:int, layerGroup:int = 0):Boolean {
			
			var state:String;
			
			switch (layerGroup) {
				case ModelObjectProperties.LAYER_COLLISION:
					state = m.props.collision_group.toString(2);
					break;
				case ModelObjectProperties.LAYER_PASSTHRU:
					return (layerNum == m.props.passthru_group);
				case ModelObjectProperties.LAYER_SENSOR:
					state = m.props.sensor_group.toString(2);
					break;
			}
			
			while (state.length < 5) state = "0" + state;
			
			return (state.charAt(layerNum) == "1");
			
		}
		
		public function setLayerState (m:ModelObject, layerNum:int, value:Boolean, layerGroup:int = 0):void {
			
			var state:String;
			
			switch (layerGroup) {
				case ModelObjectProperties.LAYER_COLLISION:
					state = m.props.collision_group.toString(2);
					break;
				case ModelObjectProperties.LAYER_PASSTHRU:
					m.props.passthru_group = (value) ? layerNum : -1;
					return;
				case ModelObjectProperties.LAYER_SENSOR:
					state = m.props.sensor_group.toString(2);
					break;
			}
			
			while (state.length < 5) state = "0" + state;
			
			var new_state:String = "";
			
			for (var i:int = 0; i < 5; i++) {
				
				if (i == layerNum) {
					new_state += (value) ? "1" : "0"; 
				} else {
					new_state += state.charAt(i);
				}
				
			}
			
			switch (layerGroup) {
				case ModelObjectProperties.LAYER_COLLISION:
					m.props.collision_group = parseInt(new_state, 2);
					break;
				case ModelObjectProperties.LAYER_SENSOR:
					m.props.sensor_group = parseInt(new_state, 2);
					break;
			}
			
		}
		
		public function setLayers (m:ModelObject, value:String, layerGroup:int = 0):void {
			
			var new_state:int = parseInt(value, 2);
			
			switch (layerGroup) {
				case ModelObjectProperties.LAYER_COLLISION:
					m.props.collision_group = new_state;
					break;
				case ModelObjectProperties.LAYER_PASSTHRU:
					m.props.passthru_group = parseInt(value, 10);
					break;
				case ModelObjectProperties.LAYER_SENSOR:
					m.props.sensor_group = new_state;
					break;
			}
			
			
		}
		
		public function updateLayersForSelection ():void {
			
			_history.record();
			
			var a:Array = _creator.uiController.getLayersState();
			
			var i:int = _selection.length;
			
			while (i--) {
				
				setLayers(_selection.objects[i], a[0], ModelObjectProperties.LAYER_COLLISION);
				setLayers(_selection.objects[i], a[1], ModelObjectProperties.LAYER_PASSTHRU);
				setLayers(_selection.objects[i], a[2], ModelObjectProperties.LAYER_SENSOR);
				
			}
			
		}
		
		public function getActionsState ():uint {
			
			if (_creator.modelController.selection.length > 0) {
				return _selection.objects[0].props.actions;
			} else {
				return 0x00000000;
			}
			
		}
		
		public function setActions (value:uint):void {
			
			_history.record();
			var i:int = _selection.length;
			
			while (i--) {
				_selection.objects[i].props.actions = value;
			}
			
		}
		
	}

}