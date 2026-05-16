package com.sploder.game.morph
{
	import com.sploder.game.ViewSprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.ColorTransform;

	/**
	 * ...
	 * @author Geoff
	 */
	public class Bloom extends Morph {
		
		private var _color:ColorTransform;

		private var _offset:Number = 0;
		
		private var _oldX:Number = 0;
		
		public var colorChange:int = 20;
		public var scaleChange:Number = 0.1;
		public var rotationChange:int = 10;
		
		public function Bloom (clip:ViewSprite, morphTime:uint = 990, startNow:Boolean = true, explode:Boolean = false) {
			
			super(clip, 990, startNow);
			
			if (_clip != null) {
				
				rotation = _clip.rotation;
				_color = new ColorTransform();
				_color.redMultiplier = _color.blueMultiplier = _color.greenMultiplier = 10;
					
				transform.colorTransform = _color;
					
			}
			
			_clip.draw(graphics, true, true);
			
			if (explode) {
				scaleX = scaleY = 2;
				var subclip:Shape = new Shape();
				addChild(subclip);
				subclip.scaleX = subclip.scaleY = 1.5;
				subclip.alpha = 0.5;
				_clip.draw(subclip.graphics, true, true);
			}
			
		}
		
		override protected function doMorph(e:Event):void 
		{
			
			if (alpha > 0) {
			
				alpha -= 0.1;
				
				scaleX += scaleChange;
				scaleY += scaleChange;
				
				_color = transform.colorTransform;
				
				_offset += colorChange;
				_color.redOffset = _color.blueOffset = _color.greenOffset = _offset;
				
				transform.colorTransform = _color;
			
			}
			
			super.doMorph(e);
			
		}
		
	}
	
}