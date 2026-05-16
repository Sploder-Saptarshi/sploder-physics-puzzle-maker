package com.sploder.game 
{
	import com.sploder.builder.model.Environment;
	import com.sploder.builder.model.Model;
	import com.sploder.builder.model.ModelObject;
	import com.sploder.builder.Shapes;
	import com.sploder.game.effect.BackgroundEffect;
	import com.sploder.game.morph.Bloom;
	import com.sploder.game.morph.Shatter;
	import com.sploder.util.Geom2d;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import nape.phys.Body;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class View extends EventDispatcher
	{
		public static const EFFECT_NONE:int = 0;
		public static const EFFECT_BLOOM:int = 1;
		public static const EFFECT_SHATTER:int = 2;
		public static const EFFECT_EXPLODE:int = 3;
		
		public static var _nextID:int = 0;
		protected var _id:int = 0;
		
		public static var stickToOrigin:Boolean = true;
		
		protected var _model:Model;
		protected var _project:Environment;
		
		protected var _container:Sprite;
		protected var _scaleAnchor:Sprite;
		protected var _anchor:Sprite;
		protected var _background:Bitmap;
		protected var _effect:BackgroundEffect;
		protected var _constraints:Shape;
		protected var _effects:Sprite;
		protected var _viewport:Sprite;
		protected var _ui:Sprite;
		protected var _m:Matrix;
		
		protected var _width:uint = 640;
		protected var _height:uint = 480;
		protected var _scale:Number = 1;
		
		protected var _mouseDown:Boolean = false;
		
		protected var _sprites:Vector.<ViewSprite>;
		
		protected var _animations:ViewAnimationManager;
		
		public function get model():Model { return _model; }
		public function set model(value:Model):void 
		{
			_model = value;
		}
		
		public function get project():Environment { return _project; }
		public function set project(value:Environment):void 
		{
			if (_project) {
				_project.removeEventListener(Event.CHANGE, onProjectChange);
			}
			_project = value;
			_project.addEventListener(Event.CHANGE, onProjectChange, false, 0, true);
		}
		
		protected var _turbo:Boolean = false;
		
		protected var _camera:Camera;
		protected var _cameraX:int;
		protected var _cameraY:int;
		
		public function get camera():Camera { return _camera; }
		
		public function get container():Sprite { return _container; }
		public function get anchor():Sprite { return _anchor; }
		public function get viewport():Sprite { return _viewport; }
		public function get constraints():Shape { return _constraints; }
		
		public function get mouseDown():Boolean { return _mouseDown; }
		
		public function get x ():int {
			return _scaleAnchor.x;
		}
		
		public function get y ():int {
			return _scaleAnchor.y;
		}
		
		public function get width():uint 
		{
			return 640 * _scaleAnchor.scaleX;
		}
		
		public function get height():uint 
		{
			return 480 * _scaleAnchor.scaleY;
		}
		
		public function get ui():Sprite 
		{
			return _ui;
		}
		
		public function get animations():ViewAnimationManager 
		{
			return _animations;
		}
		
		public function View (container:Sprite, model:Model, project:Environment, turbo:Boolean = false) 
		{
			init(container, model, project, turbo);
		}
		
		protected function init (container:Sprite, model:Model, project:Environment, turbo:Boolean = false):void {
			
			_container = container;
			_model = model;
			_project = project;
			_turbo = turbo;
			
			_animations = new ViewAnimationManager(this);
			
			_nextID++;
			_id = _nextID;
			
			_m = new Matrix();
			
			if (_project.size != Environment.SIZE_NORMAL) {
				_width = 1280;
				_height = 960;
				if (_project.size == Environment.SIZE_DOUBLE) {
					_scale = 0.5;
				}
			}
			
			var c:Sprite = new Sprite();
			_container.addChild(c);
			_container = c;
			
			_scaleAnchor = new Sprite();
			_container.addChild(_scaleAnchor);
			
			_background = new Bitmap();
			_scaleAnchor.addChild(_background);
			
			BackgroundEffect.skip = (_turbo) ? 4 : 2;
			_effect = new BackgroundEffect(_model.width, _model.height);
			_effect.type = _project.bgEffect;
			if (_effect.type != Environment.EFFECT_NONE) _scaleAnchor.addChild(_effect);
			
			_anchor = new Sprite();
			_scaleAnchor.addChild(_anchor);
			_anchor.scrollRect = new Rectangle(0, 0, 640, 480);
			
			_constraints = new Shape();
			_anchor.addChild(_constraints);
			
			_viewport = new Sprite();
			_anchor.addChild(_viewport);
			
			_effects = new Sprite();
			_anchor.addChild(_effects);
			
			_ui = new Sprite();
			_ui.mouseEnabled = false;
			_ui.mouseChildren = true;
			_container.addChild(_ui);
			
			_effect.scaleX = _effect.scaleY = 
				_constraints.scaleX = _constraints.scaleY = 
				_viewport.scaleX = _viewport.scaleY = 
				_effects.scaleX = _effects.scaleY = _scale;

			if (_project.size == Environment.SIZE_FOLLOW) {
				_camera = new Camera();
				_camera.pixelSnap = true;
			}
			
			_container.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			_container.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			_container.stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
			onResize();
			
			_sprites = new Vector.<ViewSprite>();
			
			onProjectChange();
			
		}
		
		protected function onResize (e:Event = null):void {
			
			if (_container.stage) {
				
				var c:Sprite = _scaleAnchor;
				var cs:Stage = _container.stage;
				
				c.scaleX = c.scaleY = 1;

				if (cs.stageWidth > 0 && cs.stageHeight > 0) {
					
					var aspect:Number = cs.stageWidth / cs.stageHeight;
					
					var gameAspect:Number = 640 / 480;
					
					if (aspect > gameAspect) {
						
						c.scaleX = c.scaleY = Math.min(1, cs.stageHeight / 480);
						if (!stickToOrigin) {
							c.x = (cs.stageWidth - 640 * c.scaleX) * 0.5;
							c.y = (cs.stageHeight - 480 * c.scaleY) * 0.5;
						}
						
					} else {
						
						c.scaleX = c.scaleY = Math.min(1, cs.stageHeight / 480);
						if (!stickToOrigin) {
							c.x = (cs.stageWidth - 640 * c.scaleX) * 0.5;
							c.y = (cs.stageHeight - 480 * c.scaleY) * 0.5;
						}
						
					}
					
				}
				
				dispatchEvent(new Event(Event.RESIZE));
				
			}
			
		}
		
		public function update ():void {
			
			_animations.update();
			
			if (_camera && _camera.watching) {
				
				_camera.update();
				
				var cx:int = Math.round(Math.min(640, Math.max(0, (_camera.x * _scale) - 320)));
				var cy:int = Math.round(Math.min(480, Math.max(0, (_camera.y * _scale) - 240)));
				
				if (cx != _cameraX || cy != _cameraY) {
					
					var r:Rectangle = _anchor.scrollRect;
					
					_cameraX = r.x = cx;
					_cameraY = r.y = cy;
								
					_anchor.scrollRect = r;
					
					if (_effect.type != Environment.EFFECT_NONE) {
						
						if (_project.gravity == 0) {
							_effect.cameraX = cx * 0.5;
							_effect.cameraY = cy * 0.5;							
						} else {
							_effect.cameraX = cx * 0.35;
							_effect.cameraY = cy * 0.35;
						}
						
						if (_effect.isStatic) _effect.update();
					}
				
				}
				
			}
			
		}
		
		protected function drawBackground ():void {
			
			var s:Shape = new Shape();
			var g:Graphics = s.graphics;
			
			g.clear();
			g.beginGradientFill(GradientType.LINEAR, [_project.bgColorTop, _project.bgColorBottom], [1, 1], [0, 255], _m);
			g.drawRect(0, 0, 320, 240);
			g.endFill();
			
			var bd:BitmapData = new BitmapData(320, 240, false, 0);
			bd.draw(s);
			
			if (_background.bitmapData) _background.bitmapData.dispose();
			_background.bitmapData = bd;
			_background.scaleX = _background.scaleY = 2;
			
		}
		
		protected function onProjectChange (e:Event = null):void {
			
			switch (_project.size) {
				case Environment.SIZE_NORMAL:
					_width = 640;
					_height = 480;
					_effect.setSize(320, 240);
					_effect.scaleX = _effect.scaleY = 2;
					_m.createGradientBox(640, 480, Geom2d.dtr * 90);
					break;
				case Environment.SIZE_DOUBLE:
					_width = 640;
					_height = 480;
					_effect.setSize(640, 480);
					_effect.scaleX = _effect.scaleY = 1;
					_m.createGradientBox(640, 480, Geom2d.dtr * 90);
					break;
				case Environment.SIZE_FOLLOW:
					_width = 1280;
					_height = 960;
					_effect.setSize(320, 240);
					_effect.scaleX = _effect.scaleY = 2;
					_m.createGradientBox(640, 480, Geom2d.dtr * 90);
					break;	
			}
			
			drawBackground();
			
		}
		
		protected function onMouseDown (e:MouseEvent):void {
			_mouseDown = true;
		}
			
		protected function onMouseUp (e:MouseEvent):void {
			_mouseDown = false;
		}
		
		public function register (m:ModelObject, offset:Point, body:Body):ViewSprite {
			
			var vs:ViewSprite;
			
			if (_turbo) vs = new ViewSpriteTurbo();
			else vs = new ViewSprite();
			
			vs.offset = offset;
			vs.modelObject = m;
			vs.mouseEnabled = vs.mouseChildren = false;
			
			_viewport.addChild(vs);
			if (_sprites.indexOf(vs) == -1) _sprites.push(vs);
			
			if (m.props.graphic > 0 && (m.props.animation >= 1 || m.props.graphic_flip > 0)) {
				if (m.props.animation == 1 || (m.props.animation == 3 && vs.totalFrames > 0)) vs.doCycle = true;
				_animations.register(vs, body);
			}
			
			return vs;
			
		}
		
		public function unregister (vs:ViewSprite, removeEffect:int = 0):void {
			
			if (vs.parent == _viewport) {
				
				switch (removeEffect) {
					
					case EFFECT_BLOOM:
						
						effectBloom(vs);
						break;
						
					case EFFECT_SHATTER:
					
						effectShatter(vs);
						break;
						
					case EFFECT_EXPLODE:
					
						effectExplode(vs);
						
					default:
						
						break;
					
				}
				
				if (vs.parent == _viewport) _viewport.removeChild(vs);
				
				if (_sprites.indexOf(vs) != -1) _sprites.splice(_sprites.indexOf(vs), 1);
				
				if (vs.modelObject && vs.modelObject.props.animation >= 1) _animations.unregister(vs);
				
			}
			
		}
		
		protected function effectBloom (vs:ViewSprite):void {
			
			var m:ModelObject = vs.modelObject;
			
			if (m) _effects.addChild(new Bloom(vs, 250, true));
			
		}
		
		protected function effectShatter (vs:ViewSprite):void {
			
			var m:ModelObject = vs.modelObject;
			
			var pts:Vector.<Point>;
			
			if (m) {
				
				pts = m.props.vertices;
				if (pts == null) pts = Shapes.getVertices(m.props.shape, m.props.width, m.props.height, 40);
				_effects.addChild(new Shatter(vs, pts, 40, true, 1, null, null, m.props.color, _turbo));
				
			}
			
		}
		
		protected function effectExplode (vs:ViewSprite):void {
			
			var m:ModelObject = vs.modelObject;
			
			var pts:Vector.<Point>;
			
			if (m) {
				
				pts = m.props.vertices;
				if (pts == null) pts = Shapes.getVertices(m.props.shape, m.props.width, m.props.height, 40);
				_effects.addChild(new Bloom(vs, 250, true, true));
				_effects.addChild(new Shatter(vs, pts, 40, true, 3, null, null, 0));
				
			}
			
		}
		
		protected function compare (x:ViewSprite, y:ViewSprite):Number {
			
			if (x.zlayer == y.zlayer) {
				
				if (x.id < y.id) return -1;
				if (x.id > y.id) return 1;
				
			} else {
				
				if (x.zlayer > y.zlayer) return -1;
				if (x.zlayer < y.zlayer) return 1;			
				
			}
			
			return 0;
			
		}
		
		public function zSort ():void {
			
			var i:int = _sprites.length;
			
			if (_sprites.length > _viewport.numChildren) {
				while (i--) {
					if (_sprites[i].parent != _viewport) {
						_sprites.splice(i, 1);
					}
				}
			}
			
			_sprites.sort(compare);
			
			i = _sprites.length;
			
			while (i--) {
				if (_sprites[i].parent == _viewport) {
					_viewport.setChildIndex(_sprites[i], i);
				} else {
					_sprites.splice(i, 1);
				}
			}
			
		}
		
		public function end ():void {
			
			if (_sprites) {
				var i:int = _sprites.length;
				while (i--) unregister(_sprites[i], EFFECT_NONE);
				_sprites = null;
			}
			
			if (_camera) {
				_camera.stopWatching();
				_camera = null;
			}
			
			if (_background) {
				if (_background.bitmapData) _background.bitmapData.dispose();
				if (_background.parent) _background.parent.removeChild(_background);
				_background = null;
			}
			
			if (_effect) {
				_effect.end();
				_effect = null;	
			}
			
			if (_viewport) {
				if (_viewport.parent) _viewport.parent.removeChild(_viewport);
				_viewport = null;
			}
			
			if (_effects) {
				if (_effects.parent) _effects.parent.removeChild(_effects);
				_effects = null;
			}
			
			if (_constraints) {
				if (_constraints.parent) _constraints.parent.removeChild(_constraints);
				_constraints = null;
			}
			
			if (_anchor) {
				if (_anchor.parent) _anchor.parent.removeChild(_anchor);
				_anchor = null;
			}
			
			if (_ui) {
				if (_ui.parent) _ui.parent.removeChild(_ui);
				_ui = null;
			}
			
			if (_scaleAnchor) {
				if (_scaleAnchor.parent) _scaleAnchor.parent.removeChild(_scaleAnchor);
				_scaleAnchor = null;
			}
			
			if (_container) {
				if (_container.stage) {
					_container.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					_container.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					_container.stage.removeEventListener(Event.RESIZE, onResize);
				}
				if (_container.parent) _container.parent.removeChild(_container);
				_container = null;
			}
			
			if (_project) {
				_project.removeEventListener(Event.CHANGE, onProjectChange);
				_project = null;
			}
			
			
		}
		
	}

}