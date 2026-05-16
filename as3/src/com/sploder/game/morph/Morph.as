package com.sploder.game.morph
{
	import com.sploder.game.ViewSprite;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;

	/**
	 * ...
	 * @author Geoff
	 */
	public class Morph extends Sprite {

		protected var _clip:ViewSprite;
		protected var _startTime:uint;
		protected var _morphTime:uint;
		
		public function Morph (clip:ViewSprite, morphTime:uint = 990, startNow:Boolean = true) {
			
			super();
			
			init(clip, morphTime, startNow);
			
		}
		
		protected function init (clip:ViewSprite, morphTime:uint = 990, startNow:Boolean = true):void {
			
			_clip = clip;
			_morphTime = morphTime;
			
			if (_clip != null && _clip.parent) {
				
				x = _clip.x;
				y = _clip.y;
				
				if (startNow) {
					if (stage) startMorph();
					else addEventListener(Event.ADDED_TO_STAGE, startMorph);
				}
			
			}
			
		}
		
		public function startMorph (e:Event = null):void {
				
			if (e) removeEventListener(Event.ADDED_TO_STAGE, startMorph);
			
			if (stage) {
				stage.addEventListener(Event.ENTER_FRAME, doMorph, false, 0, true);
			}
			
			_startTime = getTimer();
			
		}

		protected function doMorph (e:Event):void {

			if (getTimer() - _startTime > _morphTime) completeMorph();
			
		}
		
		protected function completeMorph ():void {
			
			if (stage) {
				stage.removeEventListener(Event.ENTER_FRAME, doMorph);
			}
			
			if (parent != null) parent.removeChild(this);

		}
		
	}

}