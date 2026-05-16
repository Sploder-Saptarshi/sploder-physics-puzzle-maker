package com.sploder.builder.model 
{
	import com.sploder.asui.Prompt;
	import com.sploder.asui.Tagtip;
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.builder.model.Modifier;
	import com.sploder.game.library.EmbeddedLibrary;
	import com.sploder.util.Geom2d;
	import com.sploder.util.Key;
	import flash.display.Graphics;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class ModifierSprite extends Sprite
	{
		public static var library:EmbeddedLibrary;
		public static var suppressDraw:Boolean = false;
		
		public static var mainStage:Stage;
		public static var focusObject:ModelObject;
		public static var focusClass:Class;
		
		protected var _modifier:Modifier;
		public function get obj ():Modifier { return _modifier; }
		
		protected var _indicatorBolt:Sprite;
		
		protected var _buttonActivate:SimpleButton;
		protected var _buttonActivate2:SimpleButton;
		protected var _handleParent:SimpleButton;
		protected var _handleChild:SimpleButton;
		protected var _handleAmount:SimpleButton;
		protected var _handleDelete:SimpleButton;
		
		protected var _clip:Sprite;
		protected var _clipContainer:Sprite;
		protected var _clipAdded:Boolean = false;
		protected var _handlesAdded:Boolean = false;
		
		protected var _clickTime:int = 0;

		protected var _suspended:Boolean = false;
		
		protected var _currentHandle:SimpleButton;
		
		protected var _dropPoint:Point;
		
		protected var _sx:Number = 0;
		protected var _sy:Number = 0;
		protected var _ex:Number = 0;
		protected var _ey:Number = 0;
		protected var _dx:Number = 0;
		protected var _dy:Number = 0;
		protected var _ch:Number = 0;
		
		
		public function ModifierSprite (modifier:Modifier) 
		{
			super();
			
			_modifier = modifier;
			_dropPoint = new Point();
			
		}
		
		protected function addClip ():void {
			
			if (_modifier.props && _modifier.props.type && _modifier.props.type != "") {
				
				_clipContainer = new Sprite();
				addChild(_clipContainer);
				_clip = library.getDisplayObject(_modifier.props.type) as Sprite;
				_clip.addEventListener(MouseEvent.CLICK, onClipClick);
				_clipContainer.mouseEnabled = false;
				_clipContainer.mouseChildren = true;
				_clipContainer.addChild(_clip);
				_clipAdded = true;
				
			}
			
		}
		
		protected function addHandles ():void {
			
			if (suppressDraw) return;
			
			_buttonActivate = library.getDisplayObject(CreatorUIStates.BUTTON_ACTIVATE_OVERLAY) as SimpleButton;
			_buttonActivate.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			_buttonActivate.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_buttonActivate.addEventListener(MouseEvent.MOUSE_DOWN, onClipClick);
			addChild(_buttonActivate);
			
			var addParent:Boolean = true;
			var addButton2:Boolean = true;
					
			switch (_modifier.props.type) {
				
				case CreatorUIStates.MODIFIER_MOTOR:
				
					_handleAmount = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_HANDLE_TWIST) as SimpleButton;
					Prompt.connectButton(_handleAmount, "Click and drag to adjust the speed of the motor.");
					_handleDelete = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_HANDLE_DELETE) as SimpleButton;
					
				case CreatorUIStates.MODIFIER_ROTATOR:
				
					if (!_handleAmount) {
						_handleAmount = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_CONTROL_TWIST) as SimpleButton;
						Prompt.connectButton(_handleAmount, "Click and drag to adjust the speed of rotation.");
					}
					_handleAmount.addEventListener(MouseEvent.MOUSE_DOWN, onHandlePress);
					_handleAmount.addEventListener(MouseEvent.MOUSE_UP, onHandleRelease);
					_handleAmount.visible = false;
					addChild(_handleAmount);
					
					if (!_handleDelete) _handleDelete = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_CONTROL_DELETE) as SimpleButton;
					_handleDelete.addEventListener(MouseEvent.CLICK, onDeleteClick);
					addChild(_handleDelete);
					break;
					
				case CreatorUIStates.MODIFIER_LAUNCHER:
				case CreatorUIStates.MODIFIER_SELECTOR:
				case CreatorUIStates.MODIFIER_AIMER:
				case CreatorUIStates.MODIFIER_DRAGGER:
				case CreatorUIStates.MODIFIER_CLICKER:
				case CreatorUIStates.MODIFIER_ARCADEMOVER:
				
					_handleDelete = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_CONTROL_DELETE) as SimpleButton;
					_handleDelete.addEventListener(MouseEvent.CLICK, onDeleteClick);
					addChild(_handleDelete);
					break;
					
				case CreatorUIStates.MODIFIER_CONNECTOR:
				
					_handleDelete = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_ACTUATOR_DELETE) as SimpleButton;
					_handleDelete.addEventListener(MouseEvent.CLICK, onDeleteClick);
					addChild(_handleDelete);
					break;
					
				case CreatorUIStates.MODIFIER_UNLOCKER:
				
					if (!_handleChild) {
						_handleChild = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_UNLOCK_MOVE) as SimpleButton;
						Prompt.connectButton(_handleChild, "Drag this end onto the object that should receive sensor events.");
					}
					
				case CreatorUIStates.MODIFIER_SPAWNER:
				
					if (!_handleChild) {
						_handleChild = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_ACTUATOR_MOVE) as SimpleButton;
						Prompt.connectButton(_handleChild, "Drag this end to adjust the direction and speed that objects go when they are spawned.");
					}
					if (!_handleDelete) _handleDelete = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_ACTUATOR_DELETE) as SimpleButton;
				
				case CreatorUIStates.MODIFIER_ADDER:
				case CreatorUIStates.MODIFIER_MOVER:
				case CreatorUIStates.MODIFIER_SLIDER:
				case CreatorUIStates.MODIFIER_JUMPER:
				
					if (!_handleChild) {
						_handleChild = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_CONTROL_MOVE) as SimpleButton;
						Prompt.connectButton(_handleChild, "Drag this end to adjust the direction. Make the arrow longer to increase the speed.");
					}
					if (!_handleDelete) _handleDelete = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_CONTROL_DELETE) as SimpleButton;
				
				case CreatorUIStates.MODIFIER_PUSHER:
					
					if (!_handleChild) {
						_handleChild = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_HANDLE_MOVE) as SimpleButton;
						Prompt.connectButton(_handleChild, "Drag this end to adjust the direction objects are pushed. Make the arrow longer to increase the speed.");
					}
					if (!_handleDelete) _handleDelete = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_HANDLE_DELETE) as SimpleButton;
					addParent = false;
					addButton2 = false;
					
				case CreatorUIStates.MODIFIER_ELEVATOR:
				
					if (!_handleChild) {
						_handleChild = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_ACTUATOR_MOVE) as SimpleButton;
						Prompt.connectButton(_handleChild, "Drag this end to adjust the location of the end point.");
					}
					if (!_handleParent) {
						_handleParent = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_ACTUATOR_MOVE) as SimpleButton;					
						Prompt.connectButton(_handleParent, "Drag this end to adjust the location of the start point.");
					}
					if (!_handleDelete) _handleDelete = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_ACTUATOR_DELETE) as SimpleButton;
				
				case CreatorUIStates.MODIFIER_GROOVEJOINT:
					
					if (!_handleChild) {
						_handleChild = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_JOINT_MOVE) as SimpleButton;
						Prompt.connectButton(_handleChild, "Drag this end to adjust the location of the end point.");
					}
					if (addButton2 && !_buttonActivate2) {
						_buttonActivate2 = library.getDisplayObject(CreatorUIStates.BUTTON_ACTIVATE_OVERLAY) as SimpleButton;
						_buttonActivate2.addEventListener(MouseEvent.MOUSE_DOWN, onClipClick);
						addChild(_buttonActivate2);
					}
					
				case CreatorUIStates.MODIFIER_GEARJOINT:
					if (!_handleChild) _handleChild = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_GEARJOINT_MOVE) as SimpleButton;
					
				case CreatorUIStates.MODIFIER_PINJOINT:
				case CreatorUIStates.MODIFIER_DAMPEDSPRING:
				case CreatorUIStates.MODIFIER_LOOSESPRING:
					
					if (!_handleChild) {
						_handleChild = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_JOINT_LINK) as SimpleButton;
						Prompt.connectButton(_handleChild, "Drag this end onto an object to link this object to it. Drag onto the background to link the object to a fixed spot.");
					}
					if (!_handleDelete) _handleDelete = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_JOINT_DELETE) as SimpleButton;
					
					_handleChild.addEventListener(MouseEvent.MOUSE_DOWN, onHandlePress);
					_handleChild.addEventListener(MouseEvent.MOUSE_UP, onHandleRelease);
					_handleChild.visible = false;
					addChild(_handleChild);
					
					if (addParent) {
						if (!_handleParent) {
							_handleParent = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_JOINT_MOVE) as SimpleButton;
							Prompt.connectButton(_handleParent, "Drag this end to adjust the location this joint attaches to the parent object.");
						}
						_handleParent.addEventListener(MouseEvent.MOUSE_DOWN, onHandlePress);
						_handleParent.addEventListener(MouseEvent.MOUSE_UP, onHandleRelease);
						_handleParent.visible = false;
						
						addChild(_handleParent);
					}
					
					_indicatorBolt = library.getDisplayObject(CreatorUIStates.MODIFIER_BOLT) as Sprite;
					_indicatorBolt.visible = false;
					addChild(_indicatorBolt);
					_indicatorBolt.parent.setChildIndex(_indicatorBolt, 0);
					_indicatorBolt.mouseEnabled = _indicatorBolt.mouseChildren = false;
					
					_handleDelete.addEventListener(MouseEvent.CLICK, onDeleteClick);
					addChild(_handleDelete);
					
					break;
					
				case CreatorUIStates.MODIFIER_FACTORY:
				case CreatorUIStates.MODIFIER_SWITCHER:
				case CreatorUIStates.MODIFIER_EMAGNET:
				case CreatorUIStates.MODIFIER_POINTER:
				
					_handleDelete = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_ACTUATOR_DELETE) as SimpleButton;
					_handleDelete.addEventListener(MouseEvent.CLICK, onDeleteClick);
					addChild(_handleDelete);
					break;
					
				case CreatorUIStates.MODIFIER_THRUSTER:
				
					_handleChild = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_CONTROL_MOVE) as SimpleButton;
					Prompt.connectButton(_handleChild, "Drag this end to adjust the direction of thrust. Make the arrow longer to increase the power.");
					_handleParent = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_CONTROL_MOVE) as SimpleButton;
					Prompt.connectButton(_handleParent, "Drag this end to adjust the point on the object in which to apply the thrust force.");
					
					_handleDelete = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_CONTROL_DELETE) as SimpleButton;
				
					_handleChild.addEventListener(MouseEvent.MOUSE_DOWN, onHandlePress);
					_handleChild.addEventListener(MouseEvent.MOUSE_UP, onHandleRelease);
					_handleChild.visible = false;
					addChild(_handleChild);
					
					_handleParent.addEventListener(MouseEvent.MOUSE_DOWN, onHandlePress);
					_handleParent.addEventListener(MouseEvent.MOUSE_UP, onHandleRelease);
					_handleParent.visible = false;
					addChild(_handleParent);

					_handleDelete.addEventListener(MouseEvent.CLICK, onDeleteClick);
					addChild(_handleDelete);
					break;
					
				case CreatorUIStates.MODIFIER_PROPELLER:
				
					_handleChild = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_ACTUATOR_MOVE) as SimpleButton;
					Prompt.connectButton(_handleChild, "Drag this end to adjust the direction of propulsion. Make the arrow longer to increase the power.");
					_handleParent = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_ACTUATOR_MOVE) as SimpleButton;
					Prompt.connectButton(_handleParent, "Drag this end to adjust the point on the object in which to apply the propulsion force.");
					
					_handleDelete = library.getDisplayObject(CreatorUIStates.BUTTON_MODIFIER_ACTUATOR_DELETE) as SimpleButton;
				
					_handleChild.addEventListener(MouseEvent.MOUSE_DOWN, onHandlePress);
					_handleChild.addEventListener(MouseEvent.MOUSE_UP, onHandleRelease);
					_handleChild.visible = false;
					addChild(_handleChild);
					
					_handleParent.addEventListener(MouseEvent.MOUSE_DOWN, onHandlePress);
					_handleParent.addEventListener(MouseEvent.MOUSE_UP, onHandleRelease);
					_handleParent.visible = false;
					addChild(_handleParent);

					_handleDelete.addEventListener(MouseEvent.CLICK, onDeleteClick);
					addChild(_handleDelete);
					break;

			}
			
			Prompt.connectButton(_handleDelete, "Click to delete this modifier.");
			
			_handlesAdded = true;
			
		}
		
		protected function setHandleVisibility (vis:Boolean = true):void {
			
			if (_buttonActivate) {
				_buttonActivate.x = _sx;
				_buttonActivate.y = _sy;
				_buttonActivate.visible = !vis;
			}
			
			if (_buttonActivate2) {
				_buttonActivate2.x = _ex;
				_buttonActivate2.y = _ey;
				_buttonActivate2.visible = !vis;
			}
			
			if (_handleAmount) {
				var pt:Point = Point.polar(30, _modifier.props.amount);
				_handleAmount.x = pt.x;
				_handleAmount.y = pt.y;
				_handleAmount.visible = vis;
				var a:Number = _modifier.props.amount * Geom2d.rtd;
				if (a < 0) a += 180;
				_handleAmount.rotation = a;
			}
			
			if (_handleChild) {
				_handleChild.x = _ex;
				_handleChild.y = _ey;
				_handleChild.visible = vis;
			}
			
			if (_handleDelete) {
				_handleDelete.x = _sx + _dx / 2;
				_handleDelete.y = _sy + _dy / 2;
				_handleDelete.rotation = 0 - rotation;
				_handleDelete.visible = vis;
			}
			
			if (_handleParent) {
				_handleParent.x = _sx;
				_handleParent.y = _sy;
				_handleParent.visible = vis;
			}
			
			if (_modifier.props.type == CreatorUIStates.MODIFIER_PINJOINT &&
				_indicatorBolt) {
					
				_indicatorBolt.x = _sx;
				_indicatorBolt.y = _sy;
				
				
				_indicatorBolt.visible = (Math.abs(_dx) <= 10 && Math.abs(_dy) <= 10);
				
				_clip.visible = !_indicatorBolt.visible;
				if (vis && _indicatorBolt.visible) {
					_handleParent.visible = _handleChild.visible = false;
					_handleDelete.visible = true;
				}
				
			}
			
		}
		
		protected function onMouseOver (e:MouseEvent):void {
			
			if (_indicatorBolt && _indicatorBolt.visible) Tagtip.showTag("These objects are bolted together! Drag them apart to edit this joint.", true);
			
		}
		
		protected function onMouseOut (e:MouseEvent):void {
			
			Tagtip.hideTag();
			
		}
		
		protected function onClipClick (e:MouseEvent):void {
			
			_modifier.container.focusObject = _modifier;
			
		}
		
		protected function onDeleteClick (e:MouseEvent):void {
			
			_modifier.destroy();
			
		}
		
		protected function onHandlePress (e:MouseEvent):void {
			
			switch (e.target) {
				
				case (_handleAmount):
				case (_handleChild):
				case (_handleParent):
					_currentHandle = e.target as SimpleButton;
					mainStage.addEventListener(MouseEvent.MOUSE_MOVE, onHandleMove);
					_currentHandle.addEventListener(MouseEvent.MOUSE_UP, onHandleRelease);
					mainStage.addEventListener(MouseEvent.MOUSE_UP, onHandleRelease);
					break;
	
			}
			
			
			
		}
		
		protected function onHandleMove (e:MouseEvent):void {
			
			switch (_currentHandle) {
				
				case (_handleAmount):
					
					var ang:Number = Math.atan2(mouseY, mouseX);
					if (Key.shiftKey) {
						ang *= Geom2d.rtd;
						ang = Math.round(ang / 15) * 15;
						ang *= Geom2d.dtr;
					}
					var pt:Point = Point.polar(40, ang);
					_handleAmount.x = pt.x;
					_handleAmount.y = pt.y;
					_modifier.props.amount = ang;
					break;
				
				case (_handleChild):
				
					_modifier.props.child = null;
					
					_handleChild.x = _modifier.props.childOffset.x = Math.round(mouseX / 5) * 5;
					_handleChild.y = _modifier.props.childOffset.y = Math.round(mouseY / 5) * 5;
					
					if (Key.shiftKey) {
						if (Math.abs(_handleChild.x) > Math.abs(_handleChild.y)) {
							_handleChild.y = _modifier.props.childOffset.y = 0;
						} else {
							_handleChild.x = _modifier.props.childOffset.x = 0;
						}
					}

					switch (_modifier.props.type) {
						
						case CreatorUIStates.MODIFIER_CONNECTOR:
						case CreatorUIStates.MODIFIER_PINJOINT:
						case CreatorUIStates.MODIFIER_DAMPEDSPRING:
						case CreatorUIStates.MODIFIER_LOOSESPRING:
						case CreatorUIStates.MODIFIER_UNLOCKER:
						case CreatorUIStates.MODIFIER_GEARJOINT:
							findObjectUnderMouse();	
							break;
						
					}
					
					draw();	
					if (_handleParent && _handleChild.x == _handleParent.x && _handleParent.y == _handleChild.y) {
						_handleChild.alpha = 0.1;
					} else {
						_handleChild.alpha = 1;
					}
					break;
					
				case (_handleParent):
				
					_handleParent.x = _modifier.props.parentOffset.x = Math.round(mouseX / 5) * 5;
					_handleParent.y = _modifier.props.parentOffset.y = Math.round(mouseY / 5) * 5;
					
					draw();
					break;
				
			}
			
		}
		
		protected function onHandleRelease (e:MouseEvent):void {
			
			var pt:Point;
			
			mainStage.removeEventListener(MouseEvent.MOUSE_MOVE, onHandleMove);
			if (_currentHandle) _currentHandle.removeEventListener(MouseEvent.MOUSE_UP, onHandleRelease);
			mainStage.removeEventListener(MouseEvent.MOUSE_UP, onHandleRelease);
			
			if (_modifier.deleted) return;
			
			switch (_currentHandle) {
				
				case (_handleChild):
						
					switch (_modifier.props.type) {
						
						case CreatorUIStates.MODIFIER_PINJOINT:
						case CreatorUIStates.MODIFIER_DAMPEDSPRING:
						case CreatorUIStates.MODIFIER_LOOSESPRING:
						case CreatorUIStates.MODIFIER_UNLOCKER:
						case CreatorUIStates.MODIFIER_GEARJOINT:
							if (focusObject == null) {
								findObjectUnderMouse();
							}
							if (focusObject && focusObject != _modifier.props.parent) {
								_modifier.props.child = focusObject;
								pt = _modifier.props.child.clip.globalToLocal(_dropPoint);
								if (_modifier.props.type == CreatorUIStates.MODIFIER_UNLOCKER || 
									_modifier.props.type == CreatorUIStates.MODIFIER_GEARJOINT) {
									_modifier.props.setChildOffset(0, 0);
								} else {
									pt.x = Math.round(pt.x / 5) * 5;
									pt.y = Math.round(pt.y / 5) * 5;
									_modifier.props.setChildOffset(pt.x, pt.y);
								}
							} else {
								_modifier.props.child = null;
								if (_modifier.props.type == CreatorUIStates.MODIFIER_UNLOCKER || 
									_modifier.props.type == CreatorUIStates.MODIFIER_GEARJOINT) {
									_modifier.props.setChildOffset(0, -100);
								}
							}
							break;
						
					}
					
					draw();
					break;
					
				case (_handleParent):
				
					findObjectUnderMouse();
					pt = _modifier.props.parent.clip.globalToLocal(_dropPoint);
					pt.x = Math.round(pt.x / 5) * 5;
					pt.y = Math.round(pt.y / 5) * 5;
					_modifier.props.setParentOffset(pt.x, pt.y);
					
					draw();
					break;
					
			}
			
			_currentHandle = null;
			_clickTime = getTimer();
			
		}
		
		protected function findObjectUnderMouse ():void {
			
			_dropPoint.x = mainStage.mouseX;
			_dropPoint.y = mainStage.mouseY;
			if (focusClass) focusClass.mainInstance.focusObject = _modifier.container.model.objectAtPoint(_dropPoint, _modifier.props.parent);				
				
		}
		
		public function draw ():void
		{
			if (_suspended || _modifier.deleted) return;
			if (suppressDraw) return;
			if (library == null) return;
			if (_modifier == null || _modifier.props == null || _modifier.props.type == null) return;
			if (!_clipAdded) addClip();
			if (!_handlesAdded) addHandles();
			
			mouseEnabled = mouseChildren = true;
			
			if (getTimer() - _clickTime < 250) {
				if (_currentHandle == _handleParent) _modifier.props.parentOffset.x = _modifier.props.parentOffset.y = 0;
				if (_currentHandle == _handleChild) _modifier.props.childOffset.x = _modifier.props.childOffset.y = 0;
			}
				
			if (_modifier.props && _modifier.props.parent) {
				
				x = _sx = _modifier.props.parent.x;
				y = _sy = _modifier.props.parent.y;
				rotation = _modifier.props.parent.rotation;
				
				var pt:Point = new Point();
				
				if (_modifier.props.parentOffset.x != 0 || _modifier.props.parentOffset.y != 0) {
					
					pt = _modifier.props.parent.clip.localToGlobal(_modifier.props.parentOffset);
					pt = globalToLocal(pt);
					
				}
				
				_sx = pt.x;
				_sy = pt.y;
					
				if (_modifier.props.child) {
					
					pt = _modifier.props.child.clip.localToGlobal(_modifier.props.childOffset);
		
				} else {
					
					pt = _modifier.props.parent.clip.localToGlobal(_modifier.props.childOffset);
					
				}
				
				pt = globalToLocal(pt);
				_ex = pt.x;
				_ey = pt.y;
				
				_dx = _ex - _sx;
				_dy = _ey - _sy;
				
				if (Math.abs(_dx) <= 5 && Math.abs(_dy) <= 5) _dx = _dy = 0;
				
				if (_clipAdded) {
					_clip.mouseEnabled = _clip.mouseChildren = mouseEnabled = 
						_modifier.props.parent &&
						(_modifier.props.parent.state == ModelObject.STATE_IDLE) && 
						(_modifier.props.child == null || _modifier.props.child.state == ModelObject.STATE_IDLE);
				}
				
				alpha = (_modifier.state == Modifier.STATE_SELECTED) ? 1 : 0.5;
				
				if (_buttonActivate) _buttonActivate.rotation = 0 - rotation;

				switch (_modifier.props.type) {
					
					case CreatorUIStates.MODIFIER_MOTOR:
					case CreatorUIStates.MODIFIER_ROTATOR:
					
						x += _modifier.props.parent.pin.x;
						y += _modifier.props.parent.pin.y;
						
						_sx = _sy = _ex = _ey = _dx = _dy = 0;
						rotation = 0;
						var a:Number = _modifier.props.amount * Geom2d.rtd;
						
						if (_clip) {
							
							var m_neg:Sprite = _clip["mask_neg"];
							var m_pos:Sprite = _clip["mask_pos"];
							
							if (m_neg && m_pos) {
								
								m_neg.rotation = m_pos.rotation = 0;
								if (a > 0) m_pos.rotation = a;
								if (a < 0) m_neg.rotation = a;
								
							}
							
						}
						
						_handleAmount.visible = true;
						_handleAmount.enabled = (_modifier.state == Modifier.STATE_SELECTED);
						break;
						
					case CreatorUIStates.MODIFIER_CONNECTOR:
					case CreatorUIStates.MODIFIER_PUSHER:
					case CreatorUIStates.MODIFIER_PINJOINT:
					case CreatorUIStates.MODIFIER_DAMPEDSPRING:
					case CreatorUIStates.MODIFIER_LOOSESPRING:
					case CreatorUIStates.MODIFIER_GROOVEJOINT:
					case CreatorUIStates.MODIFIER_ELEVATOR:
					case CreatorUIStates.MODIFIER_JUMPER:
					case CreatorUIStates.MODIFIER_ADDER:
					case CreatorUIStates.MODIFIER_SPAWNER:
					case CreatorUIStates.MODIFIER_UNLOCKER:
					case CreatorUIStates.MODIFIER_GEARJOINT:
					case CreatorUIStates.MODIFIER_THRUSTER:
					case CreatorUIStates.MODIFIER_PROPELLER:
					
						_ch = Math.max(30, Math.sqrt(_dx * _dx + _dy * _dy)) + 31;
						
						_clip.height = _ch;
						_clip.y = 0 - _ch / 2 + 15;
						
						_clipContainer.rotation = Math.atan2(_dy, _dx) * Geom2d.rtd + 90;
						_clipContainer.x = _sx;
						_clipContainer.y = _sy;
						
						if (_handleChild) _handleChild.rotation = _clipContainer.rotation;
						
						break;
						
					case CreatorUIStates.MODIFIER_MOVER:
					case CreatorUIStates.MODIFIER_SLIDER:
					
						_ch = Math.max(30, Math.sqrt(_dx * _dx + _dy * _dy)) + 21;
						
						_clip.height = _ch * 2;
						_clip.x = _clip.y = 0;
						
						_clipContainer.rotation = Math.atan2(_dy, _dx) * Geom2d.rtd + 90;
						_clipContainer.x = 0;
						_clipContainer.y = 0;
						
						if (_handleChild) _handleChild.rotation = _clipContainer.rotation;
						
						break;
					
				}
				
				if (_modifier.props.type == CreatorUIStates.MODIFIER_FACTORY ||
					_modifier.props.type == CreatorUIStates.MODIFIER_SWITCHER ||
					_modifier.props.type == CreatorUIStates.MODIFIER_EMAGNET) {
					rotation = 0;
				}
				
				setHandleVisibility(_modifier.state == Modifier.STATE_SELECTED);
				
				if (_handleDelete && _ch < 80 && 
					_modifier.props.type != CreatorUIStates.MODIFIER_MOTOR && 
					_modifier.props.type != CreatorUIStates.MODIFIER_ROTATOR && 
					_modifier.props.type != CreatorUIStates.MODIFIER_MOVER &&
					_modifier.props.type != CreatorUIStates.MODIFIER_SLIDER &&
					_modifier.props.type != CreatorUIStates.MODIFIER_LAUNCHER &&
					_modifier.props.type != CreatorUIStates.MODIFIER_SELECTOR && 
					_modifier.props.type != CreatorUIStates.MODIFIER_FACTORY && 
					_modifier.props.type != CreatorUIStates.MODIFIER_SWITCHER &&
					_modifier.props.type != CreatorUIStates.MODIFIER_EMAGNET &&
					_modifier.props.type != CreatorUIStates.MODIFIER_AIMER && 
					_modifier.props.type != CreatorUIStates.MODIFIER_DRAGGER && 
					_modifier.props.type != CreatorUIStates.MODIFIER_CLICKER && 
					_modifier.props.type != CreatorUIStates.MODIFIER_ARCADEMOVER && 
					_modifier.props.type != CreatorUIStates.MODIFIER_POINTER && 
					!(_modifier.props.type == CreatorUIStates.MODIFIER_PINJOINT && _dx == 0 && _dy == 0)) {
							
					_handleDelete.visible = false;
					
				}
				
				
				if (_modifier.props.type == CreatorUIStates.MODIFIER_MOVER ||
					_modifier.props.type == CreatorUIStates.MODIFIER_SLIDER) {
					_handleDelete.x = _handleDelete.y = 0;
					if (_ch < 40) _handleDelete.visible = false;
				}
				
				if (_modifier.props.type == CreatorUIStates.MODIFIER_MOTOR ||
					_modifier.props.type == CreatorUIStates.MODIFIER_ROTATOR) {
				
					_handleAmount.visible = true;
					_handleAmount.mouseEnabled = (_modifier.state == Modifier.STATE_SELECTED);
					
				}
				
				if (_modifier.props.type == CreatorUIStates.MODIFIER_UNLOCKER || 
					_modifier.props.type == CreatorUIStates.MODIFIER_GEARJOINT) {
					_handleChild.rotation = 0 - rotation;
					_handleChild.visible = true;
				}
				
				if (_modifier.props.type == CreatorUIStates.MODIFIER_FACTORY) {
					
					if (_modifier.props.parent.group == null) {
						return;
					}
					
					var minX:Number = 10000;
					var maxX:Number = -10000;
					var minY:Number = 10000;
					var maxY:Number = -10000;
					
					var n:int = _modifier.props.parent.group .length;
					var gm:ModelObject;
					
					while (n--) {
						
						gm = _modifier.props.parent.group.objects[n];
						
						if (gm.clip && gm.clip.parent) {
							
							var r:Rectangle = gm.clip.getBounds(gm.clip.parent);
							
							minX = Math.min(minX, r.x);
							maxX = Math.max(maxX, r.x + r.width);
							minY = Math.min(minY, r.y);
							maxY = Math.max(maxY, r.y + r.height);
							
						}
						
					}
					
					minX -= x;
					maxX -= x;
					minY -= y;
					maxY -= y;
					
					var g:Graphics = _clipContainer.graphics;
					
					g.clear();
					if (_modifier.state == Modifier.STATE_SELECTED) {
						g.lineStyle(4, 0xffffff, 2);
					} else {
						g.lineStyle(2, 0xff6600, 2);
					}
					g.drawRect(minX, minY, maxX - minX, maxY - minY);
					
					_buttonActivate.x = _handleDelete.x = _clip.x = (maxX + minX) / 2;
					_buttonActivate.y = _handleDelete.y = _clip.y = (maxY + minY) / 2;
					
					alpha = 1;
			
				}

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
			return _modifier.toString();
		}
		
	}

}