package com.sploder.game
{
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.builder.model.ModelObject;
	import com.sploder.builder.Shapes;
	import com.sploder.builder.Textures;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class ViewSprite extends Sprite
	{
		public var offset:Point;

		protected var _modelObject:ModelObject;
		public function get modelObject():ModelObject { return _modelObject; }
		public function set modelObject(value:ModelObject):void { 
			_modelObject = value;
			id = _modelObject.id;
			zlayer = _modelObject.props.zlayer;
			draw();
		}
		
		override public function get rotation():Number 
		{
			return super.rotation;
		}
		
		override public function set rotation(value:Number):void 
		{
			if (!rotated) super.rotation = value;
		}
		
		public function set rotatedRotation (value:Number):void {
			
			super.rotation = value;
			
		}
		
		public function get bitmapData():BitmapData { return _bitmapData; }
		public function get m():Matrix { return _m;}
		public function get r():Rectangle { return _r; }
		
		public function get textureName ():String {
			if (_modelObject && _modelObject.props) return _modelObject.props.textureName;
			return "";
		}
		
		public var id:int = 0;
		public var zlayer:int = 3;
		public var frame:int = 0;
		public var totalFrames:int = 1;
		public var flipped:Boolean = false;
		public var rotated:Boolean = false;
		public var doCycle:Boolean = false;
		
		protected var _m:Matrix;
		protected var _r:Rectangle;
		
		public var halo:Boolean = false;

		protected var _shape:Shape;
		protected var _blingTime:int;
		protected var _blingAmount:int;
		protected var _sharpCorners:Boolean = false;
		protected var _bitmapData:BitmapData;
		
		public function ViewSprite () 
		{
			super();
			_shape = new Shape();
			addChild(_shape);
			offset = new Point();
		}
		
		public function draw (g:Graphics = null, suppressLine:Boolean = false, suppressTexture:Boolean = false, clear:Boolean = true, offset:Point = null):void
		{
			var bsv:Vector.<Point> 
			
			if (offset == null) offset = this.offset;
			
			if (_modelObject == null || _modelObject.deleted) return;
			if (_modelObject.props.shape == CreatorUIStates.SHAPE_NONE) return;
			
			var m:ModelObject = _modelObject;
			var bd:BitmapData;
			
			if ((m.props.texture > 0 || m.props.graphic > 0 || m.props.attribs != null) && _m == null) {
				_m = new Matrix();
				if (m.props.attribs != null)
				{
					bd = Textures.library.getTextureBitmapData(m.props.attribs, 64);
				}
				else if (m.props.texture > 0 || m.props.graphic > 0) {
					frame = 0;
					bd = Textures.getScaledBitmapData(m.props.textureName, 8, 0, this);
					if (bd && m.props.graphic > 0) {
						if (m.props.animation >= 1) {
							bd = bd.clone();
							var abd:BitmapData = Textures.getOriginal(m.props.textureName);
							if (abd) totalFrames = abd.width / abd.height;
						} else {
							totalFrames = 1;
						}
					}
				}
			}
			
			if (g == null) g = _shape.graphics;
			if (clear) g.clear();
						
			var glow:Boolean = (m.props.color >= 0 && m.props.line == -2);
			
			if (suppressLine && suppressTexture) {
				
				if (m.props.shape == CreatorUIStates.SHAPE_CIRCLE && m.props.scribble == 0) {
					
					Shapes.drawCircle(g, m.props.size, offset, 0xffffff, 1, NaN, 0, 1, false);
					
				} else {
				
					bsv = (m.props.vertices) ? m.props.vertices : Shapes.getVertices(m.props.shape, m.props.width, m.props.height, 30, m.props.scribble * 2, _modelObject.id);
					if (m.props.vertices && m.props.scribble == 1) bsv = Shapes.tesselate(m.props.verticesClone(), 30, 2, _modelObject.id);
					
					Shapes.drawShape(g, bsv, offset, 0xffffff, 1, NaN, 0, 1, false);
					
				}					
				
			} else if (m.props.shape == CreatorUIStates.SHAPE_CIRCLE && m.props.scribble == 0) {
				
				if (glow && !suppressLine) {
					Shapes.drawCircle(g, m.props.size, offset, 0, 0, 8, m.props.color, 0.65, false);
					Shapes.drawCircle(g, m.props.size, offset, 0, 0, 16, m.props.color, 0.4, false);
				}
				
				if (m.props.color >= 0 || (m.props.line >= 0 && !suppressLine)) {
					Shapes.drawCircle(g, m.props.size, offset, 
						m.props.color >= 0 ? m.props.color : 0, 
						m.props.color >= 0 ? ((m.props.opaque == 1) ? 1 : 0.5) : 0.01, 
						(m.props.line >= 0 && !suppressLine) ? 4 : NaN, 
						(m.props.line >= 0 && !suppressLine) ? m.props.line : 0,
						1, false);
				}
				
				if (!suppressTexture && (m.props.texture > 0 || m.props.graphic > 0 || m.props.attribs != null)) {
					
					if (bd) {
						_m.createBox(m.props.size / (bd.width * 0.5), m.props.size / (bd.height * 0.5), 0, m.props.size, m.props.size);
						g.beginBitmapFill(bd, _m, true, true);
						g.drawCircle(0, 0, m.props.size);
						g.endFill();
						_bitmapData = bd;
						_r = new Rectangle(0, 0, bd.width, bd.height);
					}
					
				}
				
			} else {
			
				bsv = (m.props.vertices) ? m.props.vertices : Shapes.getVertices(m.props.shape, m.props.width, m.props.height, 30, m.props.scribble * 2, _modelObject.id);
				if (m.props.vertices && m.props.scribble == 1) bsv = Shapes.tesselate(m.props.verticesClone(), 30, 2, _modelObject.id);
				
				if (glow && !suppressLine) {
					Shapes.drawShape(g, bsv, offset, 0, 0, 8, m.props.color, 0.65, false, _sharpCorners);
					Shapes.drawShape(g, bsv, offset, 0, 0, 16, m.props.color, 0.4, false, _sharpCorners);
				}
				
				if (m.props.color >= 0 || (m.props.line >= 0 && !suppressLine)) {
					Shapes.drawShape(g, bsv, offset, 
						m.props.color >= 0 ? m.props.color : 0, 
						m.props.color >= 0 ? ((m.props.opaque == 1) ? 1 : 0.5) : 0.01, 
						(m.props.line >= 0 && !suppressLine) ? 4 : NaN, 
						(m.props.line >= 0 && !suppressLine) ? m.props.line : 0,
						1, false, _sharpCorners);
				}
				
				if (!suppressTexture && (m.props.texture > 0 || m.props.graphic > 0 || m.props.attribs != null)) {
					
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
								_m.createBox(0.25, 0.25, 0, bd.width * 0.125 + offset.x, bd.height * 0.125 + offset.y);
								//_m.createBox(0.25, 0.25, 0, 20 + offset.x, 20 + offset.y);
								break;
						}
						
						Shapes.drawTexture(g, bsv, bd, _m, offset, true);
						_bitmapData = bd;
						_r = new Rectangle(0, 0, bd.width, bd.height);
						
					}
					
				}
				
			}
				
			return;
				
		}
		
		public function drawExtras ():void {
			
			if (_modelObject == null || _modelObject.deleted) return;
			if (_modelObject.props.shape == CreatorUIStates.SHAPE_NONE) return;
			
			var m:ModelObject = _modelObject;
			
			var g:Graphics = graphics;
			g.clear();
			
			var size:Number = (getTimer() % 500) / 25;
			
			if (m.props.shape == CreatorUIStates.SHAPE_CIRCLE && m.props.scribble == 0) {
				
				if (halo) {
					Shapes.drawCircle(g, m.props.size, offset, 0, 0, 12 + size, 0xffffff, 0.25, false);
					Shapes.drawCircle(g, m.props.size, offset, 0, 0, (12 + size) * 0.5, 0xffffff, 0.5, false);
				}
				
				if (_blingAmount > 0) {
					Shapes.drawCircle(g, m.props.size, offset, 0, 0, 6 + _blingAmount / 50, 0xffffff, 0.25, false);
					Shapes.drawCircle(g, m.props.size, offset, 0, 0, (6 + _blingAmount / 50) * 0.5, 0xffffff, 0.5, false);
				}
				
			} else {
			
				var bsv:Vector.<Point> = (m.props.vertices) ? m.props.vertices : Shapes.getVertices(m.props.shape, m.props.width, m.props.height, 30, m.props.scribble * 2, _modelObject.id);
				if (m.props.vertices && m.props.scribble == 1) bsv = Shapes.tesselate(m.props.verticesClone(), 30, 2, _modelObject.id);
				
				if (halo) {
					Shapes.drawShape(g, bsv,offset, 0, 0, 12 + size, 0xffffff, 0.25, false);
					Shapes.drawShape(g, bsv, offset, 0, 0, (12 + size) * 0.5, 0xffffff, 0.5, false);
				}
				
				if (_blingAmount > 0) {
					Shapes.drawShape(g, bsv, offset, 0, 0, 6 + _blingAmount / 50, 0xffffff, 0.25, false);
					Shapes.drawShape(g, bsv, offset, 0, 0, (6 + _blingAmount / 50) * 0.5, 0xffffff, 0.5, false);
				}
				
			}
		}
		
		public function clear ():void {
			
			if (_shape) _shape.graphics.clear();
			
		}
		
		public function clearExtras ():void {
			
			graphics.clear();
			
		}
		
		public function bling ():void {
			
			if (_blingAmount == 0) {
				
				_blingTime = getTimer();
				if (stage) stage.addEventListener(Event.ENTER_FRAME, doBling, false, 0, true);
				
			}
			
		}
		
		protected function doBling (e:Event):void {
			
			_blingAmount = 500 - (getTimer() - _blingTime);
			
			if (_blingAmount <= 0 && stage) {
				_blingAmount = 0;
				graphics.clear();
				stage.removeEventListener(Event.ENTER_FRAME, doBling);
				return;
			}
			
			drawExtras();
			
		}
		
		public function end ():void {
			
			if (stage) {
				stage.removeEventListener(Event.ENTER_FRAME, doBling);
			}
			
			graphics.clear();
			
			if (_shape) {
				_shape.graphics.clear();
				if (_shape.parent) _shape.parent.removeChild(_shape);
				_shape = null;
			}
			
			_modelObject = null;
			_m = null;
			
		}
		
	}

}