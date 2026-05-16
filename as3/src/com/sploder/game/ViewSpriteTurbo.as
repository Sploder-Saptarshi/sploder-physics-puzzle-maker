package com.sploder.game 
{
	import com.sploder.builder.CreatorUIStates;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author ...
	 */
	public class ViewSpriteTurbo extends ViewSprite 
	{
		override public function set x(value:Number):void 
		{
			if (x != value) super.x = Math.round(value);
		}
		
		override public function set y(value:Number):void 
		{
			if (y != value) super.y = Math.round(value);
		}
		
		override public function set rotation(value:Number):void 
		{
			if ((!_lockRotation || !_initialRotationSet) && rotation != value) {
				super.rotation = Math.round(value);
				_initialRotationSet = true;
			}
		}
		
		protected var _initialRotationSet:Boolean = false;
		protected var _lockRotation:Boolean = false;
		protected var _b:Bitmap;
		
		public function ViewSpriteTurbo() 
		{
			_sharpCorners = true;
			super();
		}
		
		override public function draw(g:Graphics = null, suppressLine:Boolean = false, suppressTexture:Boolean = false, clear:Boolean = true, offset:Point = null):void 
		{
			super.draw(g, suppressLine, suppressTexture, clear, offset);
			
			//if (_modelObject.props.constraint == CreatorUIStates.MOVEMENT_SLIDE || 
			//	_modelObject.props.constraint == CreatorUIStates.MOVEMENT_STATIC) {
					
				if (_shape.width > 0 && _shape.width < 1440 && _shape.height > 0 && _shape.width < 1440) {
					
					var scale:Number = 0.5;
					var bd:BitmapData = new BitmapData(_shape.width * scale, _shape.height * scale, true, 0);
					var r:Rectangle = _shape.getBounds(this);
					var m:Matrix = new Matrix();
					
					m.createBox(scale, scale, 0, 0 - r.x * scale, 0 - r.y * scale);
					bd.draw(this, m);
					if (_shape && _shape.parent) _shape.parent.removeChild(_shape);
					
					_b = new Bitmap(bd);
					_b.x = r.x;
					_b.y = r.y;
					_b.scaleX = _b.scaleY = 1 / scale;
					addChild(_b);
				
				}
				
				if (_modelObject.props.constraint == CreatorUIStates.MOVEMENT_SLIDE || 
					_modelObject.props.constraint == CreatorUIStates.MOVEMENT_STATIC) {
					_lockRotation = true;
					}
		
				if (_modelObject.props.shape == CreatorUIStates.SHAPE_BOX || _modelObject.props.shape == CreatorUIStates.SHAPE_SQUARE) {
					
					if (_modelObject.props.color != -1) {
						if (_modelObject.props.line >= 0) {
							_b.opaqueBackground = _modelObject.props.line;
						} else {
							_b.opaqueBackground = _modelObject.props.color;
						}
						opaqueBackground = 1;
						cacheAsBitmap = true;
					}
					
				}
				
			//}
				
		}
		
	}

}