package com.sploder.game 
{
	import com.adobe.protocols.dict.DictionaryServer;
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.builder.model.Environment;
	import com.sploder.builder.model.Model;
	import com.sploder.builder.model.ModelObject;
	import com.sploder.builder.model.ModelObjectContainer;
	import com.sploder.builder.model.Modifier;
	import com.sploder.builder.Shapes;
	import com.sploder.game.morph.Shatter;
	import com.sploder.game.sound.SoundManager;
	import com.sploder.game.sound.Sounds;
	import com.sploder.asui.ObjectEvent;
	import com.sploder.util.Closest;
	import com.sploder.util.Geom2d;
	import com.sploder.util.Key;
	import cx.CxFastAllocList_Callback;
	import cx.CxFastList_PhysObj;
	import cx.CxFastNode_Constraint;
	import cx.CxFastNode_PhysObj;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import nape.*;
	import nape.callbacks.*;
	import nape.constraint.*;
	import nape.dynamics.Collide;
	import nape.dynamics.RayCast;
	import nape.geom.*;
	import nape.phys.*;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.space.*;
	import nape.util.*;
	
	
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class Simulation
	{
		protected var _container:Sprite;
		
		protected var _model:Model;
		protected var _environment:Environment;
		protected var _space:UniformSpace;
		protected var _frame:int = 0;
		
		public static var _nextID:int = 0;
		protected var _id:int = 0;
		
		protected var _built:Boolean = false;
		protected var _running:Boolean = false;
		
		protected var _bodies:Dictionary;
		protected var _bodiesLockStates:Dictionary;
		protected var _constraints:Vector.<Constraint>;
		protected var _constraintsAddedStates:Dictionary;
		protected var _constraintsBodies:Dictionary;
		protected var _elevators:Dictionary;
		protected var _motors:Dictionary;
		protected var _switchTimes:Dictionary;
		protected var _elevatorStates:Dictionary;
		protected var _lastSpawns:Dictionary;
		protected var _spawners:Dictionary;
		protected var _spawnedBodyModifiers:Dictionary;
		protected var _spawnedBodyTimes:Dictionary;
		protected var _spawnedBodyExplodes:Dictionary;
		protected var _spawnedBodyLifespans:Dictionary;
		protected var _spawnedBodyLastBodies:Vector.<PhysObj>
		protected var _spawnLimits:Dictionary;
		protected var _spawnTotals:Dictionary;
		protected var _spawnIntervals:Dictionary;
		protected var _jumpedStates:Dictionary;
		protected var _jumpedTimes:Dictionary;
		protected var _emagnetStates:Dictionary;
		protected var _emagnetPressed:Dictionary;
		protected var _groups:Vector.<Group>;
		protected var _pinnedBodies:Dictionary;
		protected var _jointedBodies:Dictionary;
		
		protected var _pivotJoints:Vector.<PivotJoint>;
		protected var _pivotJointGroups:Vector.<Group>;
		protected var _pivotJointGroupMap:Dictionary;
		
		protected var _gearJoints:Dictionary;
		
		protected var _force:Point;
		protected var _origin:Point;
		protected var _origin2:Point;
		protected var _sense_id:int;
		protected var _lastAdd:int = -1000;
		
		protected var _firstControlledObject:ModelObject;
		protected var _focusObject:ModelObject;
		protected var _focusBody:PhysObj;
		protected var _focusObjectStates:Dictionary;
		protected var _focusObjectMap:Dictionary;
		
		protected var _removedObjs:Vector.<PhysObj>;
		
		protected var _dragObject:ModelObject;
		protected var _dragConstraint:PivotJoint;
		
		public var gravity:int = 250;
		public var linDamp:Number = 0.995;
		public var angDamp:Number = 0.995;
		
		protected var _width:int = 640;
		protected var _height:int = 480;
		
		protected var _view:View;
		public function get view():View { return _view; }
		
		protected var _viewUI:ViewUI;
		public function get viewUI():ViewUI { return _viewUI; }
		
		protected var _turbo:Boolean = false;
		
		protected static var _sounds:SoundManager;
		public static function get sounds():SoundManager { return _sounds; }
		
		protected var _events:EventHandler;
		
		public function get running():Boolean { return _running; }
		
		public function get space():UniformSpace { return _space; }
		
		public function get bodies():Dictionary 
		{
			return _bodies;
		}
		
		public function get focusBody():PhysObj 
		{
			return _focusBody;
		}
		
		public function get environment():Environment 
		{
			return _environment;
		}
		
		public function get events():EventHandler 
		{
			return _events;
		}
		
		public function get model():Model 
		{
			return _model;
		}
		
		public function get frame():int 
		{
			return _frame;
		}
		
		protected var _mouseDown:Boolean = false;
		private var frictionAmount:Number = 0;
		private var _focusObjectOnFloor:Boolean;
		
		public function Simulation (container:Sprite, model:Model, environment:Environment, turbo:Boolean = false)
		{
			_container = container;
			_model = model;
			_environment = environment;
			_turbo = turbo;
			
			_nextID++;
			_id = _nextID;
			
			if (_container.stage) init();
			else _container.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init (e:Event = null):void 
		{
			_container.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			if (_environment.size != Environment.SIZE_NORMAL) {
				_width = 1280;
				_height = 960;
			}
			
			if (!_environment.gravity) {
				gravity = 0;
				Shatter.gravPull = 0;
			} else {
				Shatter.gravPull = 2;
			}
			
			if (_environment.resistance) {
				linDamp = 0.25;
				angDamp = 0.15;
			} else {
				linDamp = 0.995;
				angDamp = 0.995;
			}
			
			Material.Steel.density = 3;
			
			// TEMP
			if (Capabilities.cpuArchitecture == "ARM" ||
				Capabilities.screenResolutionX <= 480 || 
				Capabilities.screenResolutionY <= 480) {
					
				_turbo = true;
				
			}
			
			_view = new View(_container, _model, _environment, _turbo);
			
			_events = new EventHandler(this, _model, _environment);
			
			if (_sounds == null) _sounds = new SoundManager();
			_sounds.simulation = this;
			_sounds.initialize(_container.stage);
			
			_viewUI = new ViewUI(this);
			
			if (_container.stage) {
				_container.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
				_container.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			}
			
			if (_environment.vMusic != "" && SoundManager.hasSound) {
				_sounds.loadSong(_environment.vMusic);
			}

		}
		
		public function build ():void {
			
			if (_built) return;
			
			_bodiesLockStates = new Dictionary(true);
			
			_constraints = new Vector.<Constraint>();
			_constraintsAddedStates = new Dictionary(true);
			_constraintsBodies = new Dictionary(true);
			
			_elevatorStates = new Dictionary(true);
			_spawners = new Dictionary(true);
			_lastSpawns = new Dictionary(true);
			_spawnedBodyModifiers = new Dictionary(true);
			_spawnedBodyTimes = new Dictionary(true);
			_spawnedBodyExplodes = new Dictionary(true);
			_spawnedBodyLifespans = new Dictionary(true);
			_spawnedBodyLastBodies = new Vector.<PhysObj>();
			_spawnLimits = new Dictionary(true);
			_spawnTotals = new Dictionary(true);
			_spawnIntervals = new Dictionary(true);
			_focusObjectStates = new Dictionary(true);
			_focusObjectMap = new Dictionary(true);
			_elevators = new Dictionary(true);
			_motors = new Dictionary(true);
			_switchTimes = new Dictionary(true);
			_jumpedStates = new Dictionary(true);
			_jumpedTimes = new Dictionary(true);
			_emagnetStates = new Dictionary(true);
			_emagnetPressed = new Dictionary(true);
			_pinnedBodies = new Dictionary(true);
			_jointedBodies = new Dictionary(true);
			
			_pivotJoints = new Vector.<PivotJoint>();
			_pivotJointGroups = new Vector.<Group>();
			_pivotJointGroupMap = new Dictionary(true);
			
			_gearJoints = new Dictionary(true);
			
			_removedObjs = new Vector.<PhysObj>();

			_force = new Point();
			_origin = new Point();
			_origin2 = new Point();
			
			var ng:int;
			
			var s:UniformSpace = _space = new UniformSpace(new AABB(-320, -320, _width + 640, _height + 640), 15, new Vec2(0, gravity));
			
			var b:Body;
			
			switch (_environment.extents) {
				
				case Environment.EXTENTS_ENCLOSED:
					b = Tools.createBox(_width * 0.5, -50, _width + 200, 100, 0, 0, 0, true, Material.Wood);
					s.addObject(b);
					b = Tools.createBox( -50, _height * 0.5, 100, _height, 0, 0, 0, true, Material.Wood);
					s.addObject(b);
					b = Tools.createBox( _width + 50, _height * 0.5, 100, _height, 0, 0, 0, true, Material.Wood);
					s.addObject(b);
					
				case Environment.EXTENTS_GROUND:
					b = Tools.createBox(_width * 0.5, _height + 50, _width + 600, 100, 0, 0, 0, true, Material.Wood);
					s.addObject(b);
					
			}
			
			_groups = new Vector.<Group>();
			for (ng = 0; ng < 5; ng++) {
				_groups.push(new Group());
				_groups[ng].ignore = true;
			}
			
			_sense_id = CbType.get();
			s.addCbSenseBegin(_sense_id, _sense_id);
			s.addCbSenseEnd(_sense_id, _sense_id);
			
			_bodies =  new Dictionary(true);
			
			var i:int;
			var m:ModelObject;

			//
			// MODEL OBJECTS
			
			for (i = 0; i < _model.objects.length; i++) {
				
				m = _model.objects[i];
				if (!m.deleted) b = addObject(m);
					
			}
			
			for (ng = 0; ng < 5; ng++) {
				s.addGroup(_groups[ng]);
			}
			
			buildModifiers();
			addPivotGroups();
			
			_built = true;	
			
		}
		
		protected function buildModifiers ():void {
			
			var i:int;
			var md:Modifier;
			var factoryGroups:Dictionary = new Dictionary();
			
			for (i = 0; i < _model.modifiers.objects.length; i++) {
				
				md = _model.modifiers.objects[i];
				
				if (!md.deleted && 
					md.props.type == CreatorUIStates.MODIFIER_FACTORY &&
					md.props.parent &&
					md.props.parent.group) {
						
					factoryGroups[md.props.parent.group] = true;
					
				}
				
			}
			
			for (i = 0; i < _model.modifiers.objects.length; i++) {
				
				md = _model.modifiers.objects[i];
				
				if (!md.deleted &&
					!(md.props.parent && md.props.parent.group && factoryGroups[md.props.parent.group] &&
					  (md.props.type == CreatorUIStates.MODIFIER_ADDER || md.props.type == CreatorUIStates.MODIFIER_SPAWNER)
					 )) {
						
					addModifier(_model.modifiers.objects[i]);
					
				}
				
			}
			
		}
		
		protected function addModifier (md:Modifier):void {
			
			var b:Body;
			var b2:Body;
			
			//
			// MODIFIERS
			
			var ap:Point;
			var ap2:Point;
			var ap3:Point;
			var a1:Vec2;
			var a2:Vec2;
			var a3:Vec2;
			var d:Number;
			var c:Constraint;
			var bs:Shape;
			
			if (md && !md.deleted && md.props && md.props.parent) {
				
				b = _bodies[md.props.parent];
				b2 = _bodies[md.props.child];
				
				if (_spawners[b] != null && (
					md.props.type == CreatorUIStates.MODIFIER_PROPELLER ||
					md.props.type == CreatorUIStates.MODIFIER_MAGNET)
					) {
					return;
				}
				
				if (b && b.added_to_space) {
					
					switch (md.props.type) {
						
						case CreatorUIStates.MODIFIER_MOTOR:
							if (b) {
								d = md.props.amount;
								c = new SimpleMotor(_space.STATIC, b, d, 1);
								_constraints.push(c);
								_space.addConstraint(c);
								_motors[md.props.parent] = c;
							}
							break;
							
						case CreatorUIStates.MODIFIER_GEARJOINT:
							if (b && b2) {
								d = md.props.amount;
								c = new SimpleMotor(b2, b, 0, -1);
								_constraints.push(c);
								_space.addConstraint(c);
							}
							break;
							
						case CreatorUIStates.MODIFIER_PUSHER:
							if (b) {
								b.stopAll();
								b.setVel(md.props.childOffset.x * 2, md.props.childOffset.y * 2);
							}
							break;
						
						case CreatorUIStates.MODIFIER_PINJOINT:
							if (b && b2) {
								ap = localToGlobal(md.props.parentOffset, b);
								a1 = new Vec2(ap.x, ap.y);
								ap2 = localToGlobal(md.props.childOffset, b2);
								a2 = new Vec2(ap2.x, ap2.y);
								
								if (Math.abs(a2.px - a1.px) <= 10 && Math.abs(a2.py - a1.py) <= 10) {
									c = new PivotJoint(b, b2, a1);
									_pivotJoints.push(PivotJoint(c));
								} else {
									c = new PinJoint(b, b2, a1, a2);
								}
								_jointedBodies[b] = _jointedBodies[b2] = c;			
								
							} else {
								ap = md.props.parent.localToGlobal(md.props.parentOffset);
								a1 = new Vec2(ap.x, ap.y);
								ap2 = md.props.parent.localToGlobal(md.props.childOffset);
								a2 = new Vec2(ap2.x, ap2.y);
								
								if (Math.abs(a2.px - a1.px) <= 10 && Math.abs(a2.py - a1.py) <= 10) {
									c = new PivotJoint(b, _space.STATIC, a1);
								} else {
									c = new PinJoint(b, _space.STATIC, a1, a2);	
								}
								_jointedBodies[b] = c;
							}
							_constraints.push(c);
							_space.addConstraint(c);
							break;
							
						case CreatorUIStates.MODIFIER_CONNECTOR:
							if (b && b2) {
								c = new GearJoint(b, b2, b2.a, 1);
								_space.addConstraint(c);
								_gearJoints[b2] = c;
							}
							if (b && b2) {
								c = new PivotJoint(_space.STATIC, b2, new Vec2(b2.px, b2.py));
								_space.addConstraint(c);
								_constraints.push(c);
								b2.shapes.front().group = 0;
								if (b2.shapes.front().next) {
									b2.shapes.front().next.group = 0;								
								}
								_pivotJoints.push(PivotJoint(c));
								if (b2.data is ModelObject &&
									ModelObject(b2.data).props.graphic > 0 &&
									ModelObject(b2.data).props.animation == 0 &&
									b2.graphic is ViewSprite) {
									_view.animations.register(ViewSprite(b2.graphic), b2);
								}
							}
							
							break;
							
						case CreatorUIStates.MODIFIER_DAMPEDSPRING:
							if (b && b2) {
								ap = localToGlobal(md.props.parentOffset, b);
								a1 = new Vec2(ap.x, ap.y);
								ap2 = localToGlobal(md.props.childOffset, b2);
								a2 = new Vec2(ap2.x, ap2.y);
								d = ap2.subtract(ap).length;
								if (d <= 21) d += 5; 
								c = new DampedSpring(b, b2, a1, a2, d, 3e+5, 1000);
								DampedSpring(c).restLength *= 0.5;
								_jointedBodies[b] = _jointedBodies[b2] = c;
							} else {
								ap = md.props.parent.localToGlobal(md.props.parentOffset);
								a1 = new Vec2(ap.x, ap.y);
								ap2 = md.props.parent.localToGlobal(md.props.childOffset);
								a2 = new Vec2(ap2.x, ap2.y);
								c = new DampedSpring(b, _space.STATIC, a1, a2, ap2.subtract(ap).length, 3e+5, 1000);
								DampedSpring(c).restLength = Math.max(md.props.parent.props.width, md.props.parent.props.height);
								_jointedBodies[b] = c;
							}
							
							_constraints.push(c);
							_space.addConstraint(c);
							break;
							
						case CreatorUIStates.MODIFIER_LOOSESPRING:
							if (b && b2) {
								ap = localToGlobal(md.props.parentOffset, b);
								a1 = new Vec2(ap.x, ap.y);
								ap2 = localToGlobal(md.props.childOffset, b2);
								a2 = new Vec2(ap2.x, ap2.y);
								c = new DampedSpring(b, b2, a1, a2, ap2.subtract(ap).length, 3e+4, 1000);
								DampedSpring(c).restLength *= 0.25;
								_jointedBodies[b] = _jointedBodies[b2] = c;
							} else {
								ap = md.props.parent.localToGlobal(md.props.parentOffset);
								a1 = new Vec2(ap.x, ap.y);
								ap2 = md.props.parent.localToGlobal(md.props.childOffset);
								a2 = new Vec2(ap2.x, ap2.y);
								c = new DampedSpring(b, _space.STATIC, a1, a2, ap2.subtract(ap).length, 3e+4, 1000);
								DampedSpring(c).restLength *= 0.5;
								_jointedBodies[b] = c;
							}
							_constraints.push(c);
							_space.addConstraint(c);
							break;
							
						
						case CreatorUIStates.MODIFIER_ELEVATOR:
						
							if (b) {
								_elevatorStates[md.props.parent] = true;
								b.gmass = 0;
							}
						
						case CreatorUIStates.MODIFIER_GROOVEJOINT:
							
							if (b) {
								ap = md.props.parent.localToGlobal(md.props.parentOffset);
								a1 = new Vec2(ap.x, ap.y);
								ap2 = md.props.parent.localToGlobal(md.props.childOffset);
								a2 = new Vec2(ap2.x, ap2.y);
								ap3 = Closest.pointClosestTo(md.props.parent.origin, ap, ap2);
								a3 = new Vec2(ap3.x, ap3.y);
								c = new GrooveJoint(_space.STATIC, b, a1, a2, a3);
								_constraints.push(c);
								_space.addConstraint(c);
								if (md.props.type == CreatorUIStates.MODIFIER_ELEVATOR) {
									_elevators[md.props.parent] = c;
								}
								_jointedBodies[b] = c;
							}
							break;
						
						case CreatorUIStates.MODIFIER_POINTER:
							if (b) {
								d = md.props.amount;
								c = new SimpleMotor(_space.STATIC, b, 0, 1);
								_constraints.push(c);
								_space.addConstraint(c);
							}
							break;
							
						case CreatorUIStates.MODIFIER_AIMER:
						case CreatorUIStates.MODIFIER_ROTATOR:
							if (b) {
								d = md.props.amount;
								c = new SimpleMotor(_space.STATIC, b, 0, 1);
								_constraints.push(c);
								_space.addConstraint(c);
								if (_firstControlledObject == null) _firstControlledObject = md.props.parent;
							}
							break;
						
						case CreatorUIStates.MODIFIER_EMAGNET:
							_emagnetStates[b] = true;
						case CreatorUIStates.MODIFIER_LAUNCHER:
							if (b) _bodiesLockStates[b] = false;
						case CreatorUIStates.MODIFIER_MOVER:
						case CreatorUIStates.MODIFIER_ARCADEMOVER:
						case CreatorUIStates.MODIFIER_SLIDER:
						case CreatorUIStates.MODIFIER_JUMPER:
						case CreatorUIStates.MODIFIER_THRUSTER:
						
							if (b) {
								c = new Constraint();
								_constraints.push(c);
								_space.addConstraint(c);
								if (_firstControlledObject == null) {
									_firstControlledObject = md.props.parent;
								}
							}
							break;
							
						case CreatorUIStates.MODIFIER_SWITCHER:
							_switchTimes[b] = 33;
						case CreatorUIStates.MODIFIER_PROPELLER:
						
							if (b) {
								c = new Constraint();
								_constraints.push(c);
								_space.addConstraint(c);
							}
							break;
							
						case CreatorUIStates.MODIFIER_UNLOCKER:
							if (b) {
								c = new Constraint();
								_constraints.push(c);
								_space.addConstraint(c);
								_events.addSensorLink(b, md);
								if (md.props.child && _events.hasActionForEvent(md.props.child, 3)) {
									b.cbOutOfBounds = true;
								}
							}
							break;
						
						case CreatorUIStates.MODIFIER_DRAGGER:
							if (b) {
								c = new Constraint();
								_constraints.push(c);
								_space.addConstraint(c);
								if (b.hasGraphic && b.graphic) {
									_focusObjectMap[b.graphic] = b;
									b.graphic.addEventListener(MouseEvent.MOUSE_DOWN, onObjectPress, false, 0, true);
									if (b.graphic is Sprite) {
										Sprite(b.graphic).buttonMode = true;
										Sprite(b.graphic).mouseEnabled = true;
									}
								}
								if (_firstControlledObject == null) _firstControlledObject = md.props.parent;
							}
							break;
							
						case CreatorUIStates.MODIFIER_CLICKER:
							if (b) {
								if (b.hasGraphic && b.graphic) {
									_focusObjectMap[b.graphic] = b;
									b.graphic.addEventListener(MouseEvent.MOUSE_DOWN, onObjectClickSensor, false, 0, true);
									if (b.graphic is Sprite) {
										Sprite(b.graphic).buttonMode = true;
										Sprite(b.graphic).mouseEnabled = true;
									}
								}
							}
							
						case CreatorUIStates.MODIFIER_SELECTOR:
							if (b) {
								c = new Constraint();
								_constraints.push(c);
								_space.addConstraint(c);
								_focusObjectStates[md.props.parent] = true;
								if (_focusObject == null) {
									_focusObject = md.props.parent;
									_focusBody = b;
								}
								if (b.hasGraphic && b.graphic) {
									_focusObjectMap[b.graphic] = b;
									b.graphic.addEventListener(MouseEvent.CLICK, onObjectClick, false, 0, true);
									if (b.graphic is Sprite) {
										Sprite(b.graphic).buttonMode = true;
										Sprite(b.graphic).mouseEnabled = true;
									}
								}
							}
							break;
						
						case CreatorUIStates.MODIFIER_ADDER:	
							if (_firstControlledObject == null) _firstControlledObject = md.props.parent;
						case CreatorUIStates.MODIFIER_SPAWNER:
							if (b) {
								removeConstraints(b, true);
								_spawners[b] = md;
								c = new Constraint();
								_constraints.push(c);
								_lastSpawns[b] = -1000;
								_spawnLimits[b] = md.props.amount2;
								_spawnTotals[b] = 0;
								_spawnIntervals[b] = (md.props.amount > 0) ? Math.floor((md.props.amount / 1000) * 42) : 17;
								b.gmass = 0;
								b.shapes.front().sensor = 0;
								b.shapes.front().group = 0;
								bs = b.shapes.front();
								while (bs) {
									bs.sensor = 0;
									bs.group = 0;								
									bs = bs.next;
								}
								if (b.graphic) b.graphic.alpha = 0.25;
								
								
							}
							break;
							
						case CreatorUIStates.MODIFIER_FACTORY:
							if (b && md.props.parent) {
								var m:ModelObject = md.props.parent;
								if (m.group) {
									c = new Constraint();
									_constraints.push(c);
									_lastSpawns[m.group] = -1000;
									_spawnLimits[m.group] = md.props.amount2;
									_spawnTotals[m.group] = 0;
									_spawnIntervals[m.group] = (md.props.amount > 0) ? Math.floor((md.props.amount / 1000) * 42) : 17;
									var n:int = m.group.length;
									var gb:Body;
									while (n--) {
										gb = _bodies[m.group.objects[n]];
										if (gb) {
											gb.gmass = 0;
											bs = gb.shapes.front();
											while (bs) {
												bs.sensor = 0;
												bs.group = 0;								
												bs = bs.next;
											}
											if (gb.graphic) gb.graphic.alpha = 0.25;
											gb.stopAll();
										}
									}
								}
							}					
							
							
					}
				
				}
				
				if (c) {
					c.data = md;
					if (b) _constraintsBodies[c] = b;
					_constraintsAddedStates[c] = true;
				}
				
			}
			

		}
		
		protected function drawConstraints ():void {
			
			//
			// DRAW CONSTRAINTS
			
			var cn:CxFastNode_Constraint = _space.constraints.begin();
			var ce:Constraint;
			var c2:ClassicCons;
	
			var r1x:Number;
            var r1y:Number;
            var r2x:Number;
            var r2y:Number;
			var g:Graphics = _view.constraints.graphics;
			
            g.clear();
			g.lineStyle(8, 0x000000, 0.25);
			
			while (cn) {
				
				ce = cn.elem();
				
				if (ce is ClassicCons) {
					
					c2 = ce as ClassicCons;
					
					r1x = c2.r1x + c2.b1.px; 
					r1y = c2.r1y + c2.b1.py; 
					r2x = c2.r2x + c2.b2.px; 
					r2y = c2.r2y + c2.b2.py; 
						
					g.moveTo(r1x, r1y);
					g.lineTo(r2x, r2y);
						
				} else if (ce is GrooveJoint) {
					
					var cg:GrooveJoint = ce as GrooveJoint;
					
					r1x = cg.gax + cg.b1.px; 
					r1y = cg.gay + cg.b1.py; 
					r2x = cg.gbx + cg.b1.px; 
					r2y = cg.gby + cg.b1.py; 
					
					g.moveTo(r1x, r1y);
					g.lineTo(r2x, r2y);
					
					r1x = cg.r2x + cg.b2.px; 
					r1y = cg.r2y + cg.b2.py; 
					r2x = cg.b2.px; 
					r2y = cg.b2.py; 

					g.moveTo(r1x, r1y);
					g.lineTo(r2x, r2y);
					
					
				}
				
				cn = cn.next;
				
			}			
			
		}
		
		protected function checkCallbacks ():void {
			
			var cbs:CxFastAllocList_Callback = _space.callbacks; 
			//iterate while list contains objects 
			
			while (!cbs.empty()) { 
				
				// grab next object in list 
				
				var cb:Callback = cbs.front(); 
				
				// process callback object based on type. 
				
				switch(cb.type) { 
					
						case Callback.SENSE_BEGIN:
						
							_events.handleSensorEvent(cb);
							break;
							
						case Callback.PHYSOBJ_OUTOFBOUNDS:
						
							_events.handleOutOfBoundsEvent(cb.obj);
							break;
							
				} 
				 
				//remove object from list and free it to the object pool. 
				//note that this is done AFTER processing the object 
				
				cbs.pop(); 
				
			} 		
			
		}
		
		protected function checkControls ():void {
			
			var i:int = _constraints.length;
			var c:Constraint;
			var md:Modifier;
			var m:ModelObject;
			var b:Body;
			var a:Number;
			var active:Boolean;
			var gmass:Number;
			var on_floor:Boolean;
			
			var tt:CxFastList_PhysObj;
			var tb:PhysObj;
			var tn:CxFastNode_PhysObj;
			
			var vs:ViewSprite;
			
			while (i--) {
				
				c = _constraints[i];
				md = c.data as Modifier;
				b = _bodies[md.props.parent];
				m = b.data as ModelObject;
				gmass = b.gmass;
				
				if (b != null && !_bodiesLockStates[b] && 
					m != null && (!_focusObjectStates[m] || _focusObject == m)) {
					
					switch (md.props.type) {
						
						case CreatorUIStates.MODIFIER_ROTATOR:
							
							if (Key.isDown(Keyboard.LEFT) || Key.isDown(Keyboard.RIGHT) ||
								Key.charIsDown("a") || Key.charIsDown("d")) {
									
								if (Key.isDown(Keyboard.LEFT) || Key.charIsDown("a")) {
									SimpleMotor(c).rate = 0 - md.props.amount;
								} else {
									SimpleMotor(c).rate = md.props.amount;
								}
								
								if (m.props.constraint != CreatorUIStates.MOVEMENT_PIN &&
									m.props.shape != CreatorUIStates.SHAPE_CIRCLE) {
										
									if (!_constraintsAddedStates[c]) {
										_space.addConstraint(c);	
										_space.wakeConstraint(c);
										_constraintsAddedStates[c] = true
									}
									
								} else {
									
									SimpleMotor(c).rate *= 2;
									
								}
								
								_space.wakeObject(b);
									
							} else {
								if (m.props.constraint != CreatorUIStates.MOVEMENT_PIN &&
									m.props.shape != CreatorUIStates.SHAPE_CIRCLE) {
										
									if (_constraintsAddedStates[c]) {
										_space.removeConstraint(c);
										_constraintsAddedStates[c] = false;
									}
									
								} else {
								
									SimpleMotor(c).rate = 0;
									_space.wakeConstraint(c);
								
								}
								
							}
							break;
							
						case CreatorUIStates.MODIFIER_MOVER:
						
							if (_constraintsAddedStates[c]) {
								_space.removeConstraint(c);
								_constraintsAddedStates[c] = false;
							}
						
							if ((!md.props.optionB && (Key.isDown(Keyboard.UP) || Key.isDown(Keyboard.DOWN))) ||
								(!md.props.optionA && (Key.charIsDown("w") || Key.charIsDown("s"))) ) {
								
								_space.wakeObject(b);
								
								if (!b.activeMotion()) {
									_space.warmStart();
								}
								
								_force.x = md.props.childOffset.x / 5;
								_force.y = md.props.childOffset.y / 5;
								
								Geom2d.rotate(_force, b.a);
								
								if ((!md.props.optionB && Key.isDown(Keyboard.UP)) ||
									(!md.props.optionA && Key.charIsDown("w"))) {
									b.setVel(b.vx + _force.x, b.vy + _force.y);
								} else {
									b.setVel(b.vx - _force.x, b.vy - _force.y);
								}
								
								b.calcProperties();
								b.gmass = gmass;
								if (m.props.constraint == CreatorUIStates.MOVEMENT_SLIDE) {
									b.stopRotation();
								}
								
							}
							break;
							
						case CreatorUIStates.MODIFIER_JUMPER:
						
							if (_constraintsAddedStates[c]) {
								_space.removeConstraint(c);
								_constraintsAddedStates[c] = false;
							}
													
							if ((!md.props.optionB && Key.isDown(Keyboard.UP)) ||
								(!md.props.optionA && Key.charIsDown("w")) ) {
								
								if ((md.props.optionC && (_jumpedTimes[b] == null || getTimer() - _jumpedTimes[b] > 500)) || !b.activeMotion() || (b.vy > -3 && b.vy < 3 && !_jumpedStates[b]) || _focusObjectOnFloor) {
									
									_space.wakeObject(b);
									
									if (!b.activeMotion()) {
										_space.warmStart();
									}
									
									_force.x = md.props.childOffset.x * 5;
									_force.y = md.props.childOffset.y * 5;
									
									b.setVel(_force.x, _force.y);
									
									_space.wakeObject(b);
									b.calcProperties();
									b.gmass = gmass;
									
									if (m.props.constraint == CreatorUIStates.MOVEMENT_SLIDE) {
										b.stopRotation();
									}
									
									_jumpedStates[b] = true;
									if (md.props.optionC) _jumpedTimes[b] = getTimer();
									
									playSound(b, Sounds.JUMP);
									
								}
								
							} else {
								
								_jumpedStates[b] = false;
								
							}
							break;
						
						case CreatorUIStates.MODIFIER_SLIDER:
						
							if (_constraintsAddedStates[c]) {
								_space.removeConstraint(c);
								_constraintsAddedStates[c] = false;
							}
								
							if ((!md.props.optionB && (Key.isDown(Keyboard.LEFT) || Key.isDown(Keyboard.RIGHT))) ||
								(!md.props.optionA && (Key.charIsDown("a") || Key.charIsDown("d"))) ) {	
								
								_space.wakeObject(b);
								
								if (!b.activeMotion()) {
									_space.warmStart();
								}
								
								_force.x = md.props.childOffset.x / 5;
								_force.y = md.props.childOffset.y / 5;
								
								if (gravity == 0) {
									Geom2d.rotate(_force, b.a);
								}
								
								if ((!md.props.optionB && Key.isDown(Keyboard.LEFT)) ||
									(!md.props.optionA && Key.charIsDown("a"))) {
									b.setVel(b.vx + _force.x, b.vy + _force.y);
								} else {
									b.setVel(b.vx - _force.x, b.vy - _force.y);
								}
								
								b.calcProperties();
								b.gmass = gmass;
								
								if (m.props.constraint == CreatorUIStates.MOVEMENT_SLIDE) {
									b.stopRotation();
								} else if (m.props.constraint == CreatorUIStates.MOVEMENT_PIN) {
									b.stopMovement();
								}
								
							}
							break;
							
						case CreatorUIStates.MODIFIER_ARCADEMOVER:
						
							if (_constraintsAddedStates[c]) {
								_space.removeConstraint(c);
								_constraintsAddedStates[c] = false;
							}
							
							if (gravity != 0) 
							{
								on_floor = Math.abs(b.pre_py - b.py) < 3 && b.p_arbiters_false_false_true_true_Shape_Shape.head != null;
							}
							
							var f_amt:Number = Math.abs(md.props.amount);
							
							if ((!md.props.optionB && (Key.isDown(Keyboard.UP) || Key.isDown(Keyboard.DOWN))) ||
								(!md.props.optionA && (Key.charIsDown("w") || Key.charIsDown("s"))) ||
								(!md.props.optionB && (Key.isDown(Keyboard.LEFT) || Key.isDown(Keyboard.RIGHT))) ||
								(!md.props.optionA && (Key.charIsDown("a") || Key.charIsDown("d"))) ) 
								{	
								
								if (gravity == 0)
								{
									_space.wakeObject(b);
									
									if (!b.activeMotion()) {
										_space.warmStart();
									}
									
									_force.x = _force.y = 0;
									
									if ((!md.props.optionB && Key.isDown(Keyboard.UP)) || (!md.props.optionA && Key.charIsDown("w"))) _force.y -= f_amt;
									if ((!md.props.optionB && Key.isDown(Keyboard.DOWN)) || (!md.props.optionA && Key.charIsDown("s"))) _force.y += f_amt;
									if ((!md.props.optionB && Key.isDown(Keyboard.LEFT)) || (!md.props.optionA && Key.charIsDown("a"))) _force.x -= f_amt;
									if ((!md.props.optionB && Key.isDown(Keyboard.RIGHT)) || (!md.props.optionA && Key.charIsDown("d"))) _force.x += f_amt;
									
									b.setVel(_force.x * 10, _force.y * 10);
									b.calcProperties();
								}
								else 
								{
									_space.wakeObject(b);
									
									if (!b.activeMotion()) {
										_space.warmStart();
									}
									
									_force.x = _force.y = 0;
									
									var jumping:Boolean = false;
									
									if (on_floor)
									{
										if ((!md.props.optionB && Key.isDown(Keyboard.UP)) || (!md.props.optionA && Key.charIsDown("w"))) jumping = true;
										if ((!md.props.optionB && Key.isDown(Keyboard.LEFT)) || (!md.props.optionA && Key.charIsDown("a"))) _force.x -= f_amt * 4;
										if ((!md.props.optionB && Key.isDown(Keyboard.RIGHT)) || (!md.props.optionA && Key.charIsDown("d"))) _force.x += f_amt * 4;
									} else {
										if ((!md.props.optionB && Key.isDown(Keyboard.LEFT)) || (!md.props.optionA && Key.charIsDown("a"))) _force.x -= f_amt;
										if ((!md.props.optionB && Key.isDown(Keyboard.RIGHT)) || (!md.props.optionA && Key.charIsDown("d"))) _force.x += f_amt;
									}
									
									_force.x /= b.imass;
									_force.y /= b.imass;
									if (jumping)
									{
										b.applyRelativeForce(_force.x, f_amt * -1200 / b.imass, 0, 0);
									} else {
										//b.setVel(_force.x * 10, _force.y * 10);
										b.applyRelativeForce(_force.x * 40, 0, 0, 0);
									}
									
								}
								
							} else {
								if (gravity == 0) b.setVel(0, 0);
								else {
									if (on_floor) b.setVel(0, b.vy);
									else b.setVel(b.vx * 0.75, b.vy);
								}
								b.calcProperties();
							}
							
							if (m.props.constraint == CreatorUIStates.MOVEMENT_SLIDE) {
									b.stopRotation();
							}
							b.vx = Math.max( -10 * f_amt, Math.min(20 * f_amt, b.vx));
							break;
							
						case CreatorUIStates.MODIFIER_ADDER:
							
							active = (md.props.optionA) ? _mouseDown : Key.isDown(Keyboard.SPACE);
							
							if (active && _frame - _lastSpawns[b] > _spawnIntervals[b]) {
								_spawnTotals[b] += 1;
								var newb:Body = addObject(m, true, b.px, b.py, true);
								_force.x = md.props.childOffset.x * 2;
								_force.y = md.props.childOffset.y * 2;
								newb.a = b.a;
								Geom2d.rotate(_force, b.a);
								if (b && b.graphic is ViewSprite) {
									vs = ViewSprite(b.graphic);
									if (vs.rotated) {
										Geom2d.rotate(_force, vs.rotation * Geom2d.dtr);
										newb.a += vs.rotation * Geom2d.dtr;
									} else if (vs.flipped) {
										if (newb.graphic) newb.graphic.scaleX = -1;
									} 
								}
								newb.vx = _force.x;
								newb.vy = _force.y;
								playSound(newb, Sounds.SPAWN);
								_spawnedBodyTimes[newb] = _lastSpawns[b] = _frame;
								_spawnedBodyLifespans[newb] = md.props.amount3 == 0 ? 100000000 : md.props.amount3 * 42;
								if (md.props.optionB) _spawnedBodyExplodes[newb] = true;
								if (_spawnLimits[b] > 0 && _spawnTotals[b] >= _spawnLimits[b]) {
									_spawnedBodyModifiers[newb] = md;
									_spawnedBodyLastBodies.push(newb);
									_space.removeConstraint(c);
									if (_constraints.indexOf(c) != -1) {
										_constraints.splice(_constraints.indexOf(c), 1);
									}
									playSound(b, Sounds.EMPTY, 1, false);
								}
								if (_spawnLimits[b]) {
									_events.dispatchEvent(new ObjectEvent(States.EVENT_AMMOLOW, false, false, { x: b.px, y: b.py, total: _spawnLimits[b] - _spawnTotals[b] } ));
								}
								if (newb && md && md.props && md.props.parent) {
									addModifiersForSpawnedObject(newb, md.props.parent)
								}
							} else if (!active) {
								 _lastSpawns[b] = -5000;
							}
							break;
							

							
						case CreatorUIStates.MODIFIER_LAUNCHER:
							
							if (_view.mouseDown) {
								_force.x = _view.viewport.mouseX - b.px;
								_force.y = _view.viewport.mouseY - b.py;
								Geom2d.rotate(_force, b.a);
								b.setVel(_force.x, _force.y);
								
								tt = _space.touching(b);
								
								if (tt && !tt.empty()) {
									tn = tt.head;
									while (tn) {
										tb = tn.elem();
										if (tb.hasGraphic && tb.graphic && b.graphic.hitTestObject(tb.graphic)) {
											tb.setVel(_force.x, _force.y);
										}
										tn = tn.next;
									}
								}
								_space.wakeObject(b);
							} else {
								b.setVel(0, 0);
							}
							break;
							
						case CreatorUIStates.MODIFIER_AIMER:
									
							_origin.x = _view.viewport.mouseX;
							_origin.y = _view.viewport.mouseY;
							_origin2.x = b.px;
							_origin2.y = b.py;
							a = Geom2d.angleBetween(_origin2, _origin);
							a = Geom2d.normalizeAngle(a);
							a -= Geom2d.normalizeAngle(b.a);
							a += Geom2d.HALFPI;
							a %= Geom2d.TWOPI;
							if (a > Geom2d.PI) a -= Geom2d.TWOPI;
							else if (a < 0 - Geom2d.PI) a += Geom2d.TWOPI;
							if (a > 0.05) SimpleMotor(c).rate = 2.5;
							else if (a < -0.05) SimpleMotor(c).rate = -2.5;
							else SimpleMotor(c).rate = 0;
							
							break;
							
							
						case CreatorUIStates.MODIFIER_THRUSTER:
						
							if (_constraintsAddedStates[c]) {
								_space.removeConstraint(c);
								_constraintsAddedStates[c] = false;
							}
						
							if (Key.isDown(md.props.amount)) {
								
								_space.wakeObject(b);
								
								if (!b.activeMotion()) {
									_space.warmStart();
								}
								
								_force.x = (md.props.childOffset.x - md.props.parentOffset.x) * 10000;
								_force.y = (md.props.childOffset.y - md.props.parentOffset.y) * 10000;
								
								if (!md.props.optionA) Geom2d.rotate(_force, b.a);
								
								_origin.x = md.props.parentOffset.x;
								_origin.y = md.props.parentOffset.y;
								
								Geom2d.rotate(_origin, b.a);
								
								_origin.x += b.px;
								_origin.y += b.py;
								
								b.applyGlobalForce(_force.x, _force.y, _origin.x, _origin.y);
								
								b.calcProperties();
								b.gmass = gmass;
								
								if (m.props.constraint == CreatorUIStates.MOVEMENT_SLIDE) {
									b.stopRotation();
								} else if (m.props.constraint == CreatorUIStates.MOVEMENT_PIN) {
									b.stopMovement();
								}
								
							}
							break;
							
							
						
					}
					
				}
					
			}
			
		}
		
		protected function checkActuators ():void {
			
			if (!_running) return;
			if (_events == null || _events.ended) return;
			if (_constraints == null || _bodies == null) return;
			
			var i:int = _constraints.length;
			var c:Constraint;
			var md:Modifier;
			var m:ModelObject;
			var b:Body;
			var a:Number;
			var gmass:Number;
			
			var tt:CxFastList_PhysObj;
			var tb:PhysObj;
			var tn:CxFastNode_PhysObj;
			
			var vs:ViewSprite;
			var vs2:ViewSprite;
			
			while (i--) {
				
				c = _constraints[i];
				md = c.data as Modifier;
				b = _bodies[md.props.parent];
				gmass = b.gmass;
				
				if (b != null && !_bodiesLockStates[b]) {
					
					m = b.data as ModelObject;
					
					switch (md.props.type) {
							
						case CreatorUIStates.MODIFIER_ELEVATOR:
						
							_space.wakeConstraint(c);
							
							_force.x = md.props.parentOffset.x - md.props.childOffset.x;
							_force.y = md.props.parentOffset.y - md.props.childOffset.y;
							_force.normalize(1);
							
							_origin.x = b.px - m.origin.x;
							_origin.y = b.py - m.origin.y;
							
							var perc:Number = Geom2d.percentAlongLine(_origin, md.props.parentOffset, md.props.childOffset);
							
							if (_elevatorStates[md.props.parent]) {
								
								if (perc < 1) {
									
									b.px -= _force.x;
									b.py -= _force.y;
									
								} else {
									
									_elevatorStates[md.props.parent] = false;
									
								}
								
							} else {
								
								if (perc > 0.01) {
									
									b.px += _force.x;
									b.py += _force.y;									
									
								} else {
									
									_elevatorStates[md.props.parent] = true;
									
								}
								
							}
							b.stopMovement();
							b.setVel(
								(b.px - b.pre_px) * 45,
								(b.py - b.pre_py) * 45
								);
							break;
							
						case CreatorUIStates.MODIFIER_SPAWNER:
							if (b && _frame - _lastSpawns[b] > _spawnIntervals[b] && 
								m && md && _spawnTotals[b] != undefined) {
								
								_spawnTotals[b] += 1;
								var newb:Body = addObject(m, true, b.px, b.py, true);
								_force.x = md.props.childOffset.x * 2;
								_force.y = md.props.childOffset.y * 2;
								newb.a = b.a;
								Geom2d.rotate(_force, b.a);
								if (b && b.graphic is ViewSprite) {
									vs = ViewSprite(b.graphic);
									if (vs.rotated) {
										Geom2d.rotate(_force, vs.rotation * Geom2d.dtr);
										newb.a += vs.rotation * Geom2d.dtr;
									} else if (vs.flipped) {
										if (newb.graphic) newb.graphic.scaleX = -1;
									}
								}
								newb.vx = _force.x;
								newb.vy = _force.y;
								playSound(newb, Sounds.SPAWN);
								_spawnedBodyTimes[newb] = _lastSpawns[b] = _frame;
								_spawnedBodyLifespans[newb] = md.props.amount3 == 0 ? 100000000 : md.props.amount3 * 42;
								if (md.props.optionB) _spawnedBodyExplodes[newb] = true;
								if (_spawnLimits[b] > 0 && _spawnTotals[b] >= _spawnLimits[b]) {
									_spawnedBodyModifiers[newb] = md;
									_spawnedBodyLastBodies.push(newb);
									_space.removeConstraint(c);
									if (_constraints.indexOf(c) != -1) {
										_constraints.splice(_constraints.indexOf(c), 1);
									}
									playSound(b, Sounds.EMPTY);
									removeObject(b);
								}				
								if (newb && md && md.props && md.props.parent) {
									addModifiersForSpawnedObject(newb, md.props.parent)
								}
								
							}
							break;
							
						case CreatorUIStates.MODIFIER_FACTORY:
						
							if (b.data is ModelObject && b.data.group) {
								var g:ModelObjectContainer = b.data.group as ModelObjectContainer;
								if (_frame - _lastSpawns[g] > _spawnIntervals[g]) {
									_spawnTotals[g] += 1;
									_lastSpawns[g] = _frame;
									addGroup(g, md.props.amount3, md.props.optionB);
									if (_spawnLimits[g] > 0 && _spawnTotals[g] >= _spawnLimits[g]) {
										if (g.objects.length > 0) {
											if (_bodies[g.objects[0]] is PhysObj) {
												_spawnedBodyModifiers[_bodies[g.objects[0]]] = md;
												_spawnedBodyLastBodies.push(_bodies[g.objects[0]]);
											}
										}
										_space.removeConstraint(c);
										if (_constraints.indexOf(c) != -1) {
											_constraints.splice(_constraints.indexOf(c), 1);
										}
										playSound(b, Sounds.EMPTY);
										removeGroup(g);
									}
									if (g.objects.length > 0 && _bodies[g.objects[0]]) {
										playSound(_bodies[g.objects[0]], Sounds.SPAWN);
									}
								}
							}
							break;	
							
						case CreatorUIStates.MODIFIER_CONNECTOR:
						
							_force.x = md.props.child.x - md.props.parent.x;
							_force.y = md.props.child.y - md.props.parent.y;
							if (b && b.graphic is ViewSprite) {
								vs = ViewSprite(b.graphic);
								if (vs.rotated) {
									Geom2d.rotate(_force, vs.rotation * Geom2d.dtr);
								} else if (vs.flipped) {
									_force.x = 0 - _force.x;
								}
							}
							Geom2d.rotate(_force, b.a);
							
							if (b.added_to_space) {
								_force.x += b.px;
								_force.y += b.py;
								PivotJoint(c).a1x = _force.x;
								PivotJoint(c).a1y = _force.y;
								
								var b2:PhysObj = PivotJoint(c).b2;
								
								if (b.graphic is ViewSprite && b2 && b2.graphic is ViewSprite) {
									vs = ViewSprite(b.graphic);
									vs2 = ViewSprite(b2.graphic);
									vs2.flipped = vs.flipped;
									if (vs.rotated) {
										vs2.rotated = vs.rotated;
										vs2.rotatedRotation = vs.rotation;
									} else if (vs.flipped) {
										vs2.scaleX = -1;
									} else {
										vs2.scaleX = 1;
									}
								}
								
								if (b2 && b2.added_to_space) {
									_force.x -= b2.px;
									_force.y -= b2.py;
									b2.px += _force.x;
									b2.py += _force.y;
									b2.allowAll();
									b2.stopMovement();
									b2.setVel(
										_force.x * 45,
										_force.y * 45
										);
								}
								_space.wakeConstraint(c);
								if (_gearJoints[b2]) {
									_space.wakeConstraint(_gearJoints[b2]);
									if (vs2 && vs2.modelObject) {
										GearJoint(_gearJoints[b2]).biasCoef = 1;
										if (vs2.flipped) {
											GearJoint(_gearJoints[b2]).phase = 0 - vs2.modelObject.rotation * Geom2d.dtr;
										} else {
											GearJoint(_gearJoints[b2]).phase = vs2.modelObject.rotation * Geom2d.dtr;
										}
									}
								}
							}
							break;
							
						case CreatorUIStates.MODIFIER_MAGNET:
							
							tt = _space.touching(b);
							
							if (tt && !tt.empty()) {
								tn = tt.head;
								while (tn) {
									tb = tn.elem();
									if (b && b.graphic && tb && tb != b && 
										tb.data is ModelObject && ModelObject(tb.data).props && ModelObject(tb.data).props.material == CreatorUIStates.MATERIAL_STEEL &&
										tb.graphic && b.graphic.hitTestObject(tb.graphic)) {
										_force.x = b.px - tb.px;
										_force.y = b.py - tb.py;
										_force.x *= Math.min(b.gmass, 2000);
										_force.y *= Math.min(b.gmass, 2000);
										tb.applyRelativeForce(_force.x * 100, _force.y * 100, 0, 0);
										b.applyRelativeForce(0 - _force.x * 100, 0 - _force.y * 100, 0, 0);
									}
									tn = tn.next;
								}
								_space.wakeObject(b);
							}
							
							break;
							
						case CreatorUIStates.MODIFIER_EMAGNET:
							
							if (Key.isDown(Keyboard.SPACE) && !(_emagnetPressed[b])) {
								_emagnetPressed[b] = true;
								_emagnetStates[b] = !_emagnetStates[b];
							} else if (!Key.isDown(Keyboard.SPACE)) {
								_emagnetPressed[b] = false;
							}
							
							if (b.graphic && b.graphic is ViewSprite)  {
								ViewSprite(b.graphic).halo = _emagnetStates[b];
								if (_emagnetStates[b]) ViewSprite(b.graphic).drawExtras();
								else ViewSprite(b.graphic).clearExtras();
							}
							
							if (_emagnetStates[b]) {
								
								tt = _space.touching(b);
								
								if (tt && !tt.empty()) {
									tn = tt.head;
									while (tn) {
										tb = tn.elem();
										if (b && b.graphic && tb && tb != b && 
											tb.data is ModelObject && ModelObject(tb.data).props && ModelObject(tb.data).props.material == CreatorUIStates.MATERIAL_STEEL &&
											tb.graphic && b.graphic.hitTestObject(tb.graphic)) {
											_force.x = b.px - tb.px;
											_force.y = b.py - tb.py;
											_force.x *= Math.min(b.gmass, 2000);
											_force.y *= Math.min(b.gmass, 2000);
											tb.applyRelativeForce(_force.x * 100, _force.y * 100, 0, 0);
											b.applyRelativeForce(0 - _force.x * 100, 0 - _force.y * 100, 0, 0);
										}
										tn = tn.next;
									}
									_space.wakeObject(b);
								}
								
							}
							
							break;
						
							
						case CreatorUIStates.MODIFIER_SWITCHER:
							
							if (_motors[md.props.parent]) {
								var sw_motor:SimpleMotor = _motors[md.props.parent];
								if (Math.random() > 0.99 && _frame - _switchTimes[b] > 33) {
									sw_motor.rate = 0 - sw_motor.rate;
									_switchTimes[b] = _frame;
								}
							}
							
							if (_elevators[md.props.parent]) {
								if (Math.random() > 0.99 && _frame - _switchTimes[b] > 33) {
									_elevatorStates[md.props.parent] = !_elevatorStates[md.props.parent];
									_switchTimes[b] = _frame;
								}
							}
							break;
							
						case CreatorUIStates.MODIFIER_POINTER:
							
							if (_focusObject) {
								
								var fb:Body = _bodies[_focusObject];
								
								if (fb) {
									
									_origin.x = fb.px;
									_origin.y = fb.py;
									_origin2.x = b.px;
									_origin2.y = b.py;
									a = Geom2d.angleBetween(_origin2, _origin);
									a = Geom2d.normalizeAngle(a);
									a -= Geom2d.normalizeAngle(b.a);
									a += Geom2d.HALFPI;
									a %= Geom2d.TWOPI;
									if (a > Geom2d.PI) a -= Geom2d.TWOPI;
									else if (a < 0 - Geom2d.PI) a += Geom2d.TWOPI;
									if (a > 0.05) SimpleMotor(c).rate = 2.5;
									else if (a < -0.05) SimpleMotor(c).rate = -2.5;
									else SimpleMotor(c).rate = 0;
									
								}
								
							}
							
							break;
							
						case CreatorUIStates.MODIFIER_PROPELLER:
						
							if (_constraintsAddedStates[c]) {
								_space.removeConstraint(c);
								_constraintsAddedStates[c] = false;
							}
						
							_space.wakeObject(b);
							
							if (!b.activeMotion()) {
								_space.warmStart();
							}
							
							_force.x = (md.props.childOffset.x - md.props.parentOffset.x) * 5000;
							_force.y = (md.props.childOffset.y - md.props.parentOffset.y) * 5000;
							
							Geom2d.rotate(_force, b.a);
							
							_origin.x = md.props.parentOffset.x;
							_origin.y = md.props.parentOffset.y;
							
							Geom2d.rotate(_origin, b.a);
							
							_origin.x += b.px;
							_origin.y += b.py;
							
							b.applyGlobalForce(_force.x, _force.y, _origin.x, _origin.y);
							
							b.calcProperties();
							b.gmass = gmass;
							
							if (m && m.props) {
								if (m.props.constraint == CreatorUIStates.MOVEMENT_SLIDE) {
									b.stopRotation();
								} else if (m.props.constraint == CreatorUIStates.MOVEMENT_PIN) {
									b.stopMovement();
								}
							}
								
							break;
							
							
						
					}
					
				}
					
			}

		}
		
		protected function checkSpawnedBodies ():void {
			
			var t:int;
			var n:int;
			var p:PhysObj;
			var md:Modifier;
			
			for (var body:Object in _spawnedBodyTimes) {
				
				t = _frame - _spawnedBodyTimes[body];
				
				if (t > _spawnedBodyLifespans[body]) {
				
					delete _spawnedBodyTimes[body];
					delete _spawnedBodyLifespans[body];
					
					if (body is PhysObj) {
						
						p = body as PhysObj;
						n = _spawnedBodyLastBodies.indexOf(p);
						md = _spawnedBodyModifiers[p];
						
						if (n != -1) {
							_events.handleEmptyEvent(p, md);
							_spawnedBodyLastBodies.splice(n, 1);
						}
						
					}
					
					if (_spawnedBodyExplodes[body]) {
						explodeObject(body as PhysObj);
					} else {
						removeObject(body as PhysObj, View.EFFECT_BLOOM);
					}
					
				}
				
			}
			
		}
		
		protected function checkDraggedObject ():void {
			
			if (_dragConstraint) {
				_dragConstraint.a2x = _view.viewport.mouseX; 
				_dragConstraint.a2y = _view.viewport.mouseY; 
				_space.wakeConstraint(_dragConstraint); 
			}
			
		}
		
		protected function checkCollisionForces ():void {
			
			var n:CxFastNode_PhysObj = _space.objects.begin();
			var v:Vec2;
			var p:Number;
			var m:ModelObject;
			var mv:Number;
			var st:Number;
			var crush:Boolean = false;
			var crushed_objs:Vector.<PhysObj> = new Vector.<PhysObj>();
			var cp:PhysObj;
			var cn:int;
			var cmd:Modifier;
			
			do {
				
				if (n && n.elem()) {
					
					cp = n.elem();
					v = _space.impactImpulse(cp);
					p = _space.pressure(cp);
					
					m = cp.data;
					
					if (_focusBody) {
						var ff:Number = Math.abs(_space.totalImpulsesWithFriction(_focusBody).px) / 15000;
						
						if (ff < 1) frictionAmount += (ff - 0.25) * 0.005;
						if (Math.abs(_focusBody.vx) < 5) {
							frictionAmount -= 0.02;
						}
						frictionAmount = Math.min(0.5, Math.max(0, frictionAmount));
						if (_sounds.noisePlaying) {
							_sounds.noiseVolume = frictionAmount * 0.25;
						} else {playSound(cp, Sounds.FRICTION, frictionAmount * 0.25);
						}
						if (_jointedBodies[_focusBody] == null) {
							_focusObjectOnFloor = (_space.totalImpulsesWithFriction(_focusBody).py < -12000);
						}
						
					} else if (_sounds.noisePlaying && _sounds.noiseVolume > 0) {
						_sounds.noiseVolume = 0;
					}
					
					if (m && m.props) {
						
						if (v.lsq() > 1000000) {
							
							mv = v.length() * cp.cmass;
							
							crush = false;
							
							if (m.props.strength != CreatorUIStates.STRENGTH_PERM) {
								
								switch (m.props.strength) {
									case CreatorUIStates.STRENGTH_STRONG:
										st = 500;
										break;
									case CreatorUIStates.STRENGTH_MEDIUM:
										st = 250;
										break;
									case CreatorUIStates.STRENGTH_WEAK:
										st = 100;
										break;
								}
								
								if (mv > st) {
									crush = true;
									playSound(cp, Sounds.CRASH, mv / 600);
									crushed_objs.push(cp);
									
									cn = _spawnedBodyLastBodies.indexOf(cp);
									cmd = _spawnedBodyModifiers[cp];
									
									if (cn != -1) {
										_events.handleEmptyEvent(cp, cmd);
										_spawnedBodyLastBodies.splice(cn, 1);
									}
								}
								
							}
							
							if (!crush && mv > 70) {
								
								if (cp == _focusBody) {
									
										if (mv > 300) {
											playSound(cp, Sounds.SELF_BUMP, 1);
										} else if (mv > 150) {
											playSound(cp, Sounds.BUMP_BIG, 1);
										} else {
											playSound(cp, Sounds.BUMP, 1);
										}
								
								} else if (mv > 500) {
									
									if (m.props.material == CreatorUIStates.MATERIAL_ICE ||
									m.props.material == CreatorUIStates.MATERIAL_STEEL ||
									m.props.material == CreatorUIStates.MATERIAL_MAGNET) {
										
										if (mv > 800) {
											playSound(cp, Sounds.CLANG, mv / 600);
										} else {
											playSound(cp, Sounds.SWOOSH, mv / 600);
										}
										
									} else {
										
										if (mv > 800) {
											playSound(cp, Sounds.RESONATE_LONG, mv / 600);
										} else {
											playSound(cp, Sounds.RESONATE, mv / 600);
										}
										
									}
								}
									
								if (m.props.material == CreatorUIStates.MATERIAL_ICE ||
									m.props.material == CreatorUIStates.MATERIAL_STEEL ||
									m.props.material == CreatorUIStates.MATERIAL_MAGNET) {
									
									if (mv > 500) {
										playSound(cp, Sounds.TINK_BIG, mv / 200);
									} else {
										playSound(cp, Sounds.TINK, mv / 300);
									}
									
									
								} else {
									
																		
									if (mv > 500) {
										playSound(cp, Sounds.BUMP_BIG, mv / 200);
									} else {
										playSound(cp, Sounds.BUMP, mv / 300);
									}

								}
								
							} else if (!crush && mv > 40) {
								
								playSound(cp, Sounds.TOUCH, mv / 300);
								
							}
						
						}
						
					}
					
				}
				
				if (n) n = n.next;
				
			} while (n != null);
			
			
			var i:int = crushed_objs.length;
			
			while (i--) {
				_events.handleCrushEvent(crushed_objs[i]);
				removeObject(crushed_objs[i], View.EFFECT_SHATTER);
			}			
			
		}
		
		protected function onObjectClick (e:MouseEvent):void {
			
			var p:PhysObj = _focusObjectMap[e.target];
			
			if (p && p.data is ModelObject && p.added_to_space) {
				_focusObject = ModelObject(p.data);
				_focusBody = p;
			}
			
		}
		
		protected function onObjectPress (e:MouseEvent):void {
			
			var p:PhysObj = _focusObjectMap[e.target];
			if (p && p.data is ModelObject && p.added_to_space) {
				_dragObject = ModelObject(p.data);
				_dragConstraint = new PivotJoint(p, _space.STATIC, new Vec2(_view.viewport.mouseX, _view.viewport.mouseY)); 
                _dragConstraint.maxBias  = 3e6; 
                _dragConstraint.maxForce = 6e6; 
                _space.addConstraint(_dragConstraint); 
			}
						
		}
		
		protected function onObjectClickSensor (e:MouseEvent):void {
			
			var p:PhysObj = _focusObjectMap[e.target];
			if (p) _events.handleClickSensorEvent(p);
						
		}
		
		protected function onMouseDown (e:MouseEvent):void {
			
			_mouseDown = true;
			
		}
		
		protected function onMouseUp (e:MouseEvent):void {
			
			_mouseDown = false;
			
			if (_dragConstraint) {
				if (_space) _space.removeConstraint(_dragConstraint);
				_dragConstraint = null;
				_dragObject = null;
			}
			
		}
		
		public function start ():void {
			
			if (!_running) {
				
				trace("STARTING", _environment.resistance);
				
				if (_firstControlledObject && _focusObject == null) {
					_focusObject = _firstControlledObject;
					_focusBody = _bodies[_firstControlledObject];
				}
				_container.stage.addEventListener(Event.ENTER_FRAME, stepDouble, false, 0, true);
				_view.zSort();
				
				if (_turbo && _container && _container.stage) _container.stage.quality = StageQuality.LOW
				else _container.stage.quality = StageQuality.HIGH;
				
				_running = true;
				var n:CxFastNode_PhysObj = _space.objects.begin();
				while (n) {
					n.elem().update();
					n = n.next;
				}
				
				if (_environment.vMusic != "") {
					_sounds.resumeSong();
				}
				
			}
			
			//_view.viewport.alpha = 0.5;
			
		}
		
		public function playSound (p:PhysObj, soundID:String, volumeFactor:Number = 1, allowVolumeAdjust:Boolean = true):void {
			
			if (!_running) return;
			
			if (_sounds && soundID.length) {
				
				if (p == _focusBody) volumeFactor = 1;
				
				_sounds.addSound(
					p, soundID, 
					allowVolumeAdjust && _environment.size == Environment.SIZE_FOLLOW, 
					volumeFactor);
					
			}
			
		}
		
		protected function addPivotGroups ():void {
			
			var i:int;
			var b1:Body;
			var b2:Body;
			var c:PivotJoint;
			var g:Group;
			var g2:Group;
			
			var map:Dictionary = _pivotJointGroupMap;
			
			i = _pivotJoints.length;
			
			while (i--) {
				
				c = _pivotJoints[i];
				b1 = c.b1 as Body;
				b2 = c.b2 as Body;
				
				if (b1.group_obj && _groups.indexOf(b1.group_obj) != -1) {
					map[b1] = _groups[_groups.indexOf(b1.group_obj)];
				}
				
				if (b2.group_obj && _groups.indexOf(b2.group_obj) != -1) {
					map[b2] = _groups[_groups.indexOf(b2.group_obj)];
				}
				
				if (map[b1] && map[b2]) {
					
					if (map[b1] != map[b2]) {
						
						g = map[b1] as Group;
						g2 = map[b2] as Group;
						
						var p:CxFastNode_PhysObj = g2.objs.begin();
						
						while (p) {
							g.addObject(p.elem());
							map[p.elem()] = g;
							p = p.next;
						}
						
						if (_pivotJointGroups.indexOf(g2) != -1) {
							_pivotJointGroups.splice(_pivotJointGroups.indexOf(g2), 1);
						}
						
						map[b2] = g;
						
					}
					
				} else {
					
					if (map[b1]) {
						
						g = map[b1] as Group;
						g.addObject(b2);
						map[b2] = g;
						
					} else if (map[b2]) {
						
						g = map[b2] as Group;
						g.addObject(b1);
						map[b1] = g;
						
					} else {
						
						g = new Group();
						g.ignore = true;
						g.addObject(b1);
						map[b1] = g;						
						g.addObject(b2);
						map[b2] = g;
						_pivotJointGroups.push(g);
						
					}
					
				}
				
			}
			
			i = _pivotJointGroups.length;
			
			while (i--) {
				
				_space.addGroup(_pivotJointGroups[i]);
				
			}
			
			_pivotJoints = new Vector.<PivotJoint>();
			_pivotJointGroups = new Vector.<Group>();
			_pivotJointGroupMap = new Dictionary(true);
			
		}
		
		protected function addGroup (group:ModelObjectContainer, lifeSpan:int = 0, explodeOnExpire:Boolean = false):void {
			
			var i:int;
			var m:ModelObject;
			var b:Body;
			
			//
			// GROUP OBJECTS
			
			var cloneMap:Dictionary = new Dictionary(false);
			
			for (i = 0; i < group.length; i++) {
				
				m = group.objects[i];
				b = addObject(m, true);
				if (explodeOnExpire) _spawnedBodyExplodes[b] = true;
				_spawnedBodyTimes[b] = _frame;
				_spawnedBodyLifespans[b] = lifeSpan == 0 ? 100000000 : lifeSpan * 42;
				
				cloneMap[m] = b.data;
				
			}	
			
			//
			// ASSOCIATED MODIFIERS
			
			var md:Modifier;
			
			for (i = 0; i < _model.modifiers.objects.length; i++) {
				
				if (_model.modifiers.objects[i] && 
					_model.modifiers.objects[i].props &&
					_model.modifiers.objects[i].props.type != CreatorUIStates.MODIFIER_FACTORY &&
					_model.modifiers.objects[i].props.parent && 
					group.contains(_model.modifiers.objects[i].props.parent)) {
						
					md = _model.modifiers.objects[i].clone();
					md.props.parent = cloneMap[md.props.parent];
					if (md.props.child && md.props.child.group == group) md.props.child = cloneMap[md.props.child];
					addModifier(md);
				}
				
			}
			
			addPivotGroups();
			
		}
		
		protected function addModifiersForSpawnedObject (p:PhysObj, parentModelObject:ModelObject):void {
			
			//
			// ASSOCIATED MODIFIERS
			
			var md:Modifier;
			
			for (var i:int = 0; i < _model.modifiers.objects.length; i++) {
				
				if (p && p.data is ModelObject && 
					_model.modifiers.objects[i] && 
					_model.modifiers.objects[i].props &&
					_model.modifiers.objects[i].props.parent == parentModelObject &&
					_model.modifiers.objects[i].props.type != CreatorUIStates.MODIFIER_FACTORY &&
					_model.modifiers.objects[i].props.type != CreatorUIStates.MODIFIER_SPAWNER &&
					_model.modifiers.objects[i].props.type != CreatorUIStates.MODIFIER_ADDER &&
					_model.modifiers.objects[i].props.type != CreatorUIStates.MODIFIER_CONNECTOR &&
					_model.modifiers.objects[i].props.type != CreatorUIStates.MODIFIER_UNLOCKER &&
					_model.modifiers.objects[i].props.type != CreatorUIStates.MODIFIER_GROOVEJOINT &&
					_model.modifiers.objects[i].props.type != CreatorUIStates.MODIFIER_GEARJOINT &&
					_model.modifiers.objects[i].props.type != CreatorUIStates.MODIFIER_LAUNCHER &&
					_model.modifiers.objects[i].props.type != CreatorUIStates.MODIFIER_PUSHER &&
					_model.modifiers.objects[i].props.type != CreatorUIStates.MODIFIER_ELEVATOR) {
						
					md = _model.modifiers.objects[i].clone();
					md.props.parent = ModelObject(p.data);
					addModifier(md);
					
				}
				
			}
			
		}
		
		protected function addObject (m:ModelObject, clone:Boolean = false, new_x:Number = NaN, new_y:Number = NaN, forceFree:Boolean = false):Body {
			
			if (clone) m = m.clone();
			
			var s:UniformSpace = _space;
			
			var md:Modifier;
			var b:Body;
			var b2:Body;
			var bs:ViewSprite;
			var x:Number;
			var y:Number;
			var i:int;
			var j:int;
			var pj:PivotJoint;
			var a:Array;
			var poly:GeomPoly;
			var mpv:Vector.<Point>;
		
			b = null;
			
			x = m.origin.x;
			y = m.origin.y;
			
			if (!isNaN(new_x)) x = new_x;
			if (!isNaN(new_y)) y = new_y;
			
			_events.registerActions(m);
			
			switch (m.props.shape) {
				
				case CreatorUIStates.SHAPE_CIRCLE:
					b = Tools.createCircle(
						x, y, m.props.size, 
						0, 0, 0, 
						false,
						true,
						Constants.getMaterial(m.props.material),
						m.props.collision_group,
						m.props.sensor_group
						);
					break;
					

				case CreatorUIStates.SHAPE_BOX:
				case CreatorUIStates.SHAPE_SQUARE:
					b = Tools.createBox(
						x, y, m.props.width, m.props.height, 
						0, 0, 0, 
						false, 
						Constants.getMaterial(m.props.material),
						m.props.collision_group,
						m.props.sensor_group
						);
					break;
					
				case CreatorUIStates.SHAPE_PENT:
				case CreatorUIStates.SHAPE_HEX:
					b = Tools.createRegular(
						x, y, m.props.width / 2, m.props.height / 2, 
						(m.props.shape == CreatorUIStates.SHAPE_PENT) ? 5 : 6,
						0, 0, 0,
						false, true,
						Constants.getMaterial(m.props.material),
						m.props.collision_group,
						m.props.sensor_group
						);
					break;
						
				case CreatorUIStates.SHAPE_RAMP:
					a = [];
					a.push(new Vec2(x + m.props.width / 2, y - m.props.height / 2));
					a.push(new Vec2(x + m.props.width / 2, y + m.props.height / 2));
					a.push(new Vec2(x - m.props.width / 2, y + m.props.height / 2));
					
				case CreatorUIStates.SHAPE_POLY:
					
					if (a == null) {
						a = [];
						mpv = m.props.verticesClone();
						for (j = 0; j < m.props.vertices.length; j++) {
							a.push(new Vec2(mpv[j].x + x, mpv[j].y + y));
						}
					}
					
					poly = new GeomPoly(a);
					if (!poly.selfIntersecting()) {
						if (!poly.cw()) poly.points.reverse();
						b = Tools.createConcave(
							poly, 
							0, 0, 0, 
							false,
							Constants.getMaterial(m.props.material),
							m.props.collision_group,
							m.props.sensor_group
							);
					}
					
					a = null;
					break;
				
			}
			
			if (b) {
				
				_bodies[m] = b;
				_bodiesLockStates[b] = (forceFree) ? false : m.props.locked;
				
				b.properties.angDamp = angDamp;
				b.properties.linDamp = linDamp;
				
				/*
				if (_environment.resistance && 
					(m.props.material == CreatorUIStates.MATERIAL_AIR_BALLOON ||
					m.props.material == CreatorUIStates.MATERIAL_HELIUM_BALLOON)) {
						
						b.properties.angDamp = b.properties.linDamp = 0.9995;
						
					}
				*/
				
				var offset:Point;
				
				if (m.props.shape == CreatorUIStates.SHAPE_POLY) {
					
					var tbs:Sprite = new Sprite();
					Shapes.drawShape(tbs.graphics, m.props.vertices);
					offset = new Point(
						b.graphic.getRect(b.graphic).x - tbs.getRect(tbs).x,
						b.graphic.getRect(b.graphic).y - tbs.getRect(tbs).y
						);
							
				} else if (m.props.shape == CreatorUIStates.SHAPE_PENT || m.props.shape == CreatorUIStates.SHAPE_HEX) {
					
					offset = new Point();
					
				} else {
				
					offset = new Point(
						b.graphic.getRect(b.graphic).x + b.graphic.getRect(b.graphic).width / 2,
						b.graphic.getRect(b.graphic).y + b.graphic.getRect(b.graphic).height / 2
						);
						
				}
				
				bs = _view.register(m, offset, b);
				b.assignGraphic(bs);
				b.update();
				
				if (m.rotation != 0) {
					var o2:Point = offset.clone();
					Geom2d.rotate(o2, m.rotation * Geom2d.dtr);
					o2.x -= offset.x;
					o2.y -= offset.y;
					b.px -= o2.x;
					b.py -= o2.y;
				}
				
				if (m.rotation != 0) {
					b.setAngle(m.rotation * Geom2d.dtr);
					b.update();
				}
				
				b.calcProperties();
				
				if (m.props.material == CreatorUIStates.MATERIAL_AIR_BALLOON) {
					b.gmass = 0;
				} else if (m.props.material == CreatorUIStates.MATERIAL_HELIUM_BALLOON) {
					b.gmass = 0 - b.gmass * 0.2;
				} else if (m.props.material == CreatorUIStates.MATERIAL_MAGNET) {
					var c:Constraint = new Constraint();
					var cmd:Modifier = new Modifier(null, false);
					cmd.props.type = CreatorUIStates.MODIFIER_MAGNET;
					cmd.props.parent = m;
					c.data = cmd;
					_constraints.push(c);
				}
				
				if (!forceFree && m.props.constraint == CreatorUIStates.MOVEMENT_STATIC) {
					b.stopAll();
				}
				
				if (m.props.sensor_group != 0) b.cbType = _sense_id;
				
				if (m.props.passthru_group == -1) s.addObject(b);
				else {
					_groups[m.props.passthru_group].addObject(b);
					if (clone) _space.addObject(b);
				}
				
				//_view.viewport.addChild(b.graphic);
				
				switch (m.props.constraint) {
					
					case CreatorUIStates.MOVEMENT_PIN:
						if (m.pin.x == 0 && m.pin.y == 0) {
							b.stopMovement();
						} else {
							pj = new PivotJoint(s.STATIC, b, new Vec2(x + m.pin.x, y + m.pin.y));
							s.addConstraint(pj);
							_pinnedBodies[b] = pj;
						}
						break;
					
					case CreatorUIStates.MOVEMENT_SLIDE:
						b.stopRotation();
						break;
					
				}
				
				if (!forceFree && m.props.locked && !clone) {
					b.stopAll();
				}
				
				b.data = m;
				
				if (_events.hasActionForEvent(m, 3)) {
					b.cbOutOfBounds = true;
				}
				
			}
			
			return b;
			
		}
		
		public function removeObject (p:PhysObj, viewEffect:int = 0):void {
			
			if (p && p.graphic is ViewSprite) {
				_view.unregister(ViewSprite(p.graphic), viewEffect);
			}
			
			if (p) {
				
				if (_spawnedBodyLifespans[p]) {
					
					var n:int = _spawnedBodyLastBodies.indexOf(p);
					
					if (n != -1) {
						
						var md:Modifier = _spawnedBodyModifiers[p];
						_events.handleEmptyEvent(p, md);
						_spawnedBodyLastBodies.splice(n, 1);
						
					}
				
				}
				
			}
			
			_removedObjs.push(p);
			
			delete _spawnedBodyTimes[p];
			delete _spawnedBodyLifespans[p];
			
			if (p && p.data == _focusObject) {
				
				_focusObject = null;
				_focusBody = null;
				if (p.graphic) p.graphic.removeEventListener(MouseEvent.CLICK, onObjectClick);
				delete _focusObjectStates[p.data];
				delete _focusObjectMap[p];
				
			}
			
			removeConstraints(p);
			_space.removeConstraints(p);
			_space.removeObject(p);
			
			p.graphic = null;
			p.data = null;
			
		}
		
		public function unlockObject (p:PhysObj):void {
			
			if (p is Body && _bodiesLockStates[p]) {
				
				var b:Body = p as Body;
				var m:ModelObject = b.data as ModelObject;
				
				if (m) {
				
					if (b.graphic is ViewSprite) {
						ViewSprite(b.graphic).bling();
					}
					
					if (m.props.constraint == CreatorUIStates.MOVEMENT_FREE) {
						
						b.allowAll();
						
					} else if (m.props.constraint == CreatorUIStates.MOVEMENT_SLIDE) {
						
						b.allowMovement();
						
					} else if (m.props.constraint == CreatorUIStates.MOVEMENT_PIN) {
						
						if (_pinnedBodies[b]) {
							b.allowAll();
							_space.wakeConstraint(_pinnedBodies[b]);
						} else {
							b.allowRotation();
						}
						
					}
					
					_bodiesLockStates[b] = false;
					_space.wakeObject(b);	
					
							
					var md:Modifier;
					
					for (var c:Object in _constraintsBodies) {
						
						if (_constraintsBodies[c] == p) {
							
							if (_constraints.indexOf(c) != -1) {
								
								if (c.data is Modifier) {
									
									md = c.data as Modifier;
									
									if (md.props.type == CreatorUIStates.MODIFIER_CONNECTOR) {
										
										if (p.data == md.props.parent && md.props.child) {
											
											var ch:PhysObj = _bodies[md.props.child];
											
											if (_gearJoints[ch]) {
												
												var g:GearJoint = _gearJoints[ch];
												_space.removeConstraint(g);
												
												_bodiesLockStates[ch] = false;
												_space.removeObject(ch);
												_space.addObject(ch);
												_space.wakeObject(ch);
												
												g = new GearJoint(p, ch, ch.a, 1);
												_space.addConstraint(g);
												
												_gearJoints[ch] = g;
												
											}
											
										}
										
									}
									
								}
								
							}
							
						}
						
					}
					
				}
			
				
			}
			
		}
		
		public function explodeObject (p:PhysObj):void {
			
			var n:Vec2 = new Vec2(p.px, p.py);
			var n2:Vec2 = new Vec2();
			var ray:Ray = new Ray(n, n);
			var rr:RayResult;
			var m:ModelObject;
			var b:Body;
			var res:Number;
			
			var hugeExplode:Boolean = false;
			
			_removedObjs.push(p);
			
			if (p != null) {
				
				var oi:CxFastNode_PhysObj = _space.objects.begin();
				
				while (oi != _space.objects.end()) {
					
					var p_to_hit:PhysObj = oi.elem(); oi = oi.next;
					
					if (p_to_hit == null || p_to_hit == p || !p_to_hit.added_to_space) continue;
					
					if (p_to_hit.data == null) continue;
					
					if (p_to_hit is Body && Body(p_to_hit).shapes.next.group == 0) continue;
					
					var ox:CxFastNode_PhysObj = _space.objects.begin();
					
					ray.ax = p.px;
					ray.ay = p.py;
					ray.vx = p_to_hit.px - p.px;
					ray.vy = p_to_hit.py - p.py;
					
					var hit:Boolean = false;
					
					while (ox != _space.objects.end()) {
						
						var p_to_check:PhysObj = ox.elem(); ox = ox.next;
						if (p_to_check == p_to_hit || p_to_check == p || p_to_hit == p) continue;
						
						if (p_to_check is Body) {
							
							b = Body(p_to_check);
							
							var s:nape.shape.Shape = b.shapes.next;
							
							if (s is Circle) {
								res = RayCast.rayCircle(ray, Circle(s));
							} else if (s is Polygon) {
								res = RayCast.rayPolygon(ray, Polygon(s), n2);
							}
							
							if (res != RayCast.FAIL && p_to_check.data is ModelObject) {
								m = ModelObject(p_to_check.data);
								if (_bodiesLockStates[b] || 
									m.props.constraint == CreatorUIStates.MOVEMENT_LOCKED || 
									m.props.strength == CreatorUIStates.STRENGTH_PERM) {
									hit = true;
								}
								break;
							}
							
						}
						
					}
					
					
					if (!hit) {
						
						if (_removedObjs.indexOf(p_to_hit) != -1) continue;
							
						var dx:Number = p_to_hit.px - p.px;
						var dy:Number = p_to_hit.py - p.py;
						
						var fdist:Number = (Math.abs(dx) + Math.abs(dy));
						fdist *= fdist;
						fdist *= 0.015;
						
						var dist:Number = FastMath.invsqrt(dx * dx + dy * dy);
						dx *= dist*2e7;
						dy *= dist*2e7;
						dx /= fdist;
						dy /= fdist;
						dx *= p.gmass * 0.5;
						dy *= p.gmass * 0.5;
						
						dx = Math.max( -30000000, Math.min(30000000, dx));
						dy = Math.max( -30000000, Math.min(30000000, dy));
						
						var crushed:Boolean = false;
						
						var m_to_hit:ModelObject = p_to_hit.data as ModelObject
						
						if (m_to_hit && m_to_hit.props.strength != CreatorUIStates.STRENGTH_PERM) {
							
							var mv:Number = Math.sqrt((dx * dx) + (dy * dy)) / 100000;
							var st:Number;
								
							switch (m_to_hit.props.strength) {
								case CreatorUIStates.STRENGTH_STRONG:
									st = 400;
									break;
								case CreatorUIStates.STRENGTH_MEDIUM:
									st = 300;
									break;
								case CreatorUIStates.STRENGTH_WEAK:
									st = 200;
									break;
							}
							
							if (mv > st) {
								playSound(p_to_hit, Sounds.CRASH, mv / 600);
								_removedObjs.push(p_to_hit);
								_events.handleCrushEvent(p_to_hit);
								removeObject(p_to_hit, View.EFFECT_SHATTER);
								crushed = true;
							}
									
						}								
						
						if (!crushed) {
							
							if (p.gmass > 5000) hugeExplode = true;
							
							space.wakeObject(p_to_hit);
							p_to_hit.applyRelativeForce(dx, dy, 0, 0);
						
						}
					
					}
					
				}
				
				playSound(p, (hugeExplode) ? Sounds.EXPLODE_HUGE : Sounds.EXPLODE);
				removeObject(p, View.EFFECT_EXPLODE);
				
			}
			
		}
		
		protected function removeGroup (g:ModelObjectContainer):void {
			
			var i:int = g.length;
			var m:ModelObject;
			
			while (i--) {
				
				m = g.objects[i];
				if (_bodies[m] && _bodies[m] is PhysObj) {
					removeObject(_bodies[m] as PhysObj);
				}
				
			}
			
		}
		
		protected function removeConstraints (p:PhysObj, onlyActuators:Boolean = false):void {
			
			var dels:Array = [];
			var md:Modifier;
			
			for (var c:Object in _constraintsBodies) {
				
				if (_constraintsBodies[c] == p) {
					
					if (onlyActuators && c && c.data is Modifier) {
						md = c.data as Modifier;
						if (md.props.type != CreatorUIStates.MODIFIER_PROPELLER &&
							md.props.type != CreatorUIStates.MODIFIER_MAGNET &&
							md.props.type != CreatorUIStates.MODIFIER_UNLOCKER) {
							continue;
						}
					}
					
					if (_constraints.indexOf(c) != -1) {
						
						_constraints.splice(_constraints.indexOf(c), 1);
						dels.push(c);
						
						if (c.data is Modifier) {
							
							md = c.data as Modifier;
							
							if (md.props.type == CreatorUIStates.MODIFIER_CONNECTOR) {
								
								if (p.data == md.props.parent && md.props.child) {
									var ch:PhysObj = _bodies[md.props.child];
									if (ch) removeObject(ch);
								}
								
							}
							
						}
						
					}
					
				}
				
			}
			
			var i:int = dels.length;
			
			while (i--) {
				_constraintsBodies[dels[i]] = null;
				delete _constraintsBodies[dels[i]];
			}
			
		}
		
		public static function localToGlobal (pt:Point, p:PhysObj):Point {
			
			pt = pt.clone();
			if (p.a != 0) Geom2d.rotate(pt, p.a);
			pt.x += p.px;
			pt.y += p.py;
			
			return pt;
			
		}
		
		public function stepDouble (e:Event = null):void {
			
			if (_focusObject && _view.camera && _view.camera.watchObject != _bodies[_focusObject]) {
				_view.camera.startWatching(_bodies[_focusObject], 10);
			}
			
			checkDraggedObject();
			
			checkControls();
			
			checkActuators();
			
			checkCollisionForces();
			
			step(e);
			
			checkCallbacks();
			
			checkActuators();
			
			checkCollisionForces();
			
			step(e);
			
			checkCallbacks();
			
			checkSpawnedBodies();
			
			drawConstraints();
			
			_view.update();
			
			if (_removedObjs.length > 100) {
				_removedObjs = new Vector.<PhysObj>();
			}
			
			_events.checkEndGameStatus();
			
			_frame++;
			
		}
		
		protected function step (e:Event):void {
			
			if (_space) {
				try { 
					_space.step(1 / 45, 6, 6);
				} catch (e:Error) {
					trace("NAPE ERROR", e.getStackTrace());
				}
			}
			
		}
		
		public function stop ():void {
			
			if (_running) {
				if (_container && _container.stage) {
					_container.stage.removeEventListener(Event.ENTER_FRAME, stepDouble);
					_container.stage.quality = StageQuality.HIGH;
				}
				if (_environment.vMusic != "") {
					_sounds.pauseSong();
				}
				_running = false;
			}
			
		}
		
		public function end ():void {
			
			if (_running) stop();
			
			if (_environment.vMusic != "") {
				_sounds.unloadSong();
			}
			
			if (_built) {
				
				if (_container && _container.stage) {
					_container.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					_container.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				}
				
				if (_viewUI) {
					_viewUI.end();
					_viewUI = null;
				}
				
				if (_view) {
					_view.end();
					_view = null;
				}
				
				if (_events) {
					_events.end();
					_events = null;
				}
				
				if (_model && _bodies && _space) {
					var i:int = _model.objects.length;
					while (i--) {
						if (_bodies[_model.objects[i]] is PhysObj) {
							_space.removeConstraints(_bodies[_model.objects[i]]);
							_space.removeObject(_bodies[_model.objects[i]]);
						}
					}
				}
				
				
				_bodies = _bodiesLockStates = _constraintsAddedStates = _constraintsBodies = _elevators = 
					_motors = _switchTimes = _elevatorStates = _lastSpawns = _spawners = _spawnedBodyModifiers = 
					_spawnedBodyTimes = _spawnedBodyExplodes = _spawnedBodyLifespans = _spawnLimits = 
					_spawnTotals = _spawnIntervals = _jumpedStates = _jumpedTimes = _emagnetStates = _emagnetPressed = 
					_pinnedBodies = _gearJoints = _focusObjectStates = _focusObjectMap = null;
	
				_groups = null;

				_spawnedBodyLastBodies = null;
				_constraints = null;	
				_pivotJoints = null;
				_pivotJointGroups = null;
				_pivotJointGroupMap = null;
				
				_firstControlledObject = null;
				_focusObject = null;
				_focusBody = null;
				_removedObjs = null;
				
				if (_space) {
					_space.clear();
					_space = null;
				}
				
				if (_sounds) {
					_sounds.simulation = null;
				}
				
				if (_sounds && _container && _container.stage) {
					_sounds.unregisterStage(_container.stage);
				}
				
				SoundManager.stopAll();
				
				_model = null;
				_environment = null;
				_container = null;
				_built = false;
				
			}
			
		}
		
	}

}