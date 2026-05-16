package com.sploder.game 
{
	import com.sploder.builder.Textures;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import nape.phys.Body;
	/**
	 * ...
	 * @author Geoff
	 */
	public class ViewAnimationManager 
	{
		protected var _view:View;
		protected var _viewSprites:Vector.<ViewSprite>;
		protected var _bodies:Dictionary;
		protected var _ended:Boolean;
		protected var _origin:Point;
		protected var _lastFrame:Dictionary;
		
		protected var _frame:int = 0;
		
		public function ViewAnimationManager (view:View) 
		{
			init(view);
		}
		
		protected function init (view:View):void {
			
			_view = view;
			_viewSprites = new Vector.<ViewSprite>();
			_origin = new Point();
			_lastFrame = new Dictionary(true);
			_bodies = new Dictionary(true);
			_ended = false;
			
		}
		
		public function register (vs:ViewSprite, body:Body):void {
			
			if (_ended) return;
			
			if (_viewSprites.indexOf(vs) == -1) {
				_viewSprites.push(vs);
				_bodies[vs] = body;
				_lastFrame[vs] = _frame;
			}
			
		}
		
		public function unregister (vs:ViewSprite):void {
			
			if (_ended) return;
			
			if (_viewSprites.indexOf(vs) != -1) {
				_viewSprites.splice(_viewSprites.indexOf(vs), 1);
				_bodies[vs] = null;
				delete _bodies[vs];
			}			
			
		}
		
		public function update ():void {
			
			if (_ended) return;
			
			_frame++;
			
			var i:int = _viewSprites.length;
			var vs:ViewSprite;
			var b:Body;
			var bd:BitmapData;
			
			while (i--) {
				
				vs = _viewSprites[i];
				
				if (vs.visible) {
					
					if (vs.modelObject && vs.modelObject.props.graphic_flip) {
						
						if (_bodies[vs] is Body) {
							b = Body(_bodies[vs]);
							if (b.vx > 2 && vs.flipped) {
								vs.flipped = false;
								vs.scaleX = 1;
							}
							if (b.vx < -2 && !vs.flipped) {
								vs.flipped = true;
								vs.scaleX = -1;
							}
						}
						
					}
					
					if (vs.modelObject && vs.modelObject.props.animation >= 3) {
						
						if (_bodies[vs] is Body) {
							b = Body(_bodies[vs]);
							var vxa:Number = Math.abs(b.vx);
							var vya:Number = Math.abs(b.vy);
							
							if (vxa > vya) {
								
								if (b.vx > 0.15) {
									
									vs.rotated = true;
									vs.rotatedRotation = 90;
									
									
								} else if (b.vx < -0.15) {
									
									vs.rotated = true;
									vs.rotatedRotation = -90;
									
								}
								
							} else {
								
								if (b.vy > 0.15) {
									
									vs.rotated = true;
									vs.rotatedRotation = 180;
									
								} else if (b.vy < -0.15) {
									
									vs.rotated = true;
									vs.rotatedRotation = 0;
									
								}
								
							}
							
						}
						
						if (!vs.doCycle && vs.modelObject && vs.modelObject.props.animation == 4) {
							
							if (_bodies[vs] is Body) {
								b = Body(_bodies[vs]);
								if (b.vx > 10 || b.vx < -10 || b.vy > 10 || b.vy < -10) {
									vs.doCycle = true;
								}
							}
							
							if (!vs.doCycle && vs.frame != 0) {
								
								vs.frame = 0;
								
								bd = Textures.getScaledBitmapData(vs.textureName, 8, vs.frame);
								if (bd) vs.bitmapData.copyPixels(bd, vs.r, _origin);
								
								_lastFrame[vs] = _frame;
								
							}
							
						}
						
					} else if (!vs.doCycle && vs.modelObject && vs.modelObject.props.animation == 2) {
						
						if (_bodies[vs] is Body) {
							b = Body(_bodies[vs]);
							
							if (b.vx > 25 || b.vx < -25) {
								vs.doCycle = true;
							} else if (b.space.gravityy == 0 && (b.vy > 25 || b.vy < -25)) {
								vs.doCycle = true;
							}
						}
						
						if (!vs.doCycle && vs.frame != 0) {
							
							vs.frame = 0;
							
							bd = Textures.getScaledBitmapData(vs.textureName, 8, vs.frame);
							if (bd) vs.bitmapData.copyPixels(bd, vs.r, _origin);
							
							_lastFrame[vs] = _frame;
							
						}
						
					}
					
					if (vs.doCycle && _frame - Number(_lastFrame[vs]) >= 7) {
						
						vs.frame = (vs.frame < vs.totalFrames - 1) ? vs.frame + 1 : 0;
						
						bd = Textures.getScaledBitmapData(vs.textureName, 8, vs.frame);
						if (bd) vs.bitmapData.copyPixels(bd, vs.r, _origin);
						
						_lastFrame[vs] = _frame;
						
						if (vs.frame == vs.totalFrames - 1 && 
							vs.modelObject && 
							(vs.modelObject.props.animation == 2 || 
							vs.modelObject.props.animation == 4)) {
								
							vs.doCycle = false;	
								
						}
						
					}
				
				}
				
			}
			
		}
		
		public function end ():void {
			
			_viewSprites = null;
			_ended = true;
			
		}
		
	}

}