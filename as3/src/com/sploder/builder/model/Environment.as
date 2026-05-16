package com.sploder.builder.model 
{
	import com.sploder.game.effect.BackgroundEffect;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.describeType;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class Environment extends EventDispatcher
	{
		public static const SIZE_NORMAL:uint = 0;
		public static const SIZE_DOUBLE:uint = 1;
		public static const SIZE_FOLLOW:uint = 2;
		
		public static const EXTENTS_ENCLOSED:uint = 0;
		public static const EXTENTS_GROUND:uint = 1;
		public static const EXTENTS_OPEN:uint = 2;
		
		public static const EFFECT_NONE:String = "None";
		public static const EFFECT_SNOW:String = "Snow";
		public static const EFFECT_RAIN:String = "Rain";
		public static const EFFECT_CLOUDS:String = "Clouds";
		public static const EFFECT_STARS:String = "Stars";
		public static const EFFECT_SILK:String = "Silk";
		public static const EFFECT_LEAFY:String = "Leafy";
		public static const EFFECT_SMOKE:String = "Smoke";
		public static const EFFECT_GRID:String = "Grid";
		
		protected var _size:uint = 0;
		protected var _gravity:uint = 1;
		protected var _resistance:uint = 0;
		protected var _extents:uint = 0;
		protected var _wrap:uint = 0;
		protected var _total_lives:uint = 3;
		protected var _total_penalties:uint = 3;
		protected var _total_score:uint = 10;
		protected var _total_time:uint = 0;
		protected var _vInstructions:String = "";
		protected var _vMusic:String = "";
		
		
		protected var _bgColorTop:uint = 0x330099;
		protected var _bgColorBottom:uint = 0x000000;
		protected var _bgEffect:String = EFFECT_NONE;
		
		public function Environment () 
		{
			super();
		}
		
		public function setDefaults ():void {
			
			_size = 0;
			_gravity = 1;
			_resistance = 0;
			_extents = 0;
			
			_bgColorTop = 0x330099;
			_bgColorBottom = 0x000000;
			_bgEffect = EFFECT_NONE;
			
			_total_lives = 3;
			_total_penalties = 3;
			_total_score = 10;
			_total_time = 0;
			
			_vInstructions = "";
			_vMusic = "";
			
			dispatchEvent(new Event(Event.CHANGE));
			
		}
		
		public function get size():uint { return _size; }
		public function set size(value:uint):void 
		{
			_size = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get gravity():uint { return _gravity; }
		public function set gravity(value:uint):void 
		{
			_gravity = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get resistance():uint { return _resistance; }
		public function set resistance(value:uint):void 
		{
			_resistance = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get extents():uint { return _extents; }
		public function set extents(value:uint):void 
		{
			_extents = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get bgColorTop():uint { return _bgColorTop; }
		public function set bgColorTop(value:uint):void 
		{
			_bgColorTop = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get bgColorBottom():uint { return _bgColorBottom; }
		public function set bgColorBottom(value:uint):void 
		{
			_bgColorBottom = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get bgEffect():String { return _bgEffect; }
		public function set bgEffect(value:String):void 
		{
			_bgEffect = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get wrap():uint { return _wrap; }
		public function set wrap(value:uint):void 
		{
			_wrap = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get total_lives():uint 
		{
			return _total_lives;
		}
		
		public function set total_lives(value:uint):void 
		{
			_total_lives = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get total_penalties():uint 
		{
			return _total_penalties;
		}
		
		public function set total_penalties(value:uint):void 
		{
			_total_penalties = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get total_score():uint 
		{
			return _total_score;
		}
		
		public function set total_score(value:uint):void 
		{
			_total_score = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get total_time():uint 
		{
			return _total_time;
		}
		
		public function set total_time(value:uint):void 
		{
			_total_time = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get vInstructions():String 
		{
			return unescape(unescape(_vInstructions));
		}
		
		public function set vInstructions(value:String):void 
		{
			_vInstructions = escape(unescape(value));
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get vMusic():String 
		{
			return _vMusic;
		}
		
		public function set vMusic(value:String):void 
		{
			_vMusic = value;
		}
		
		override public function toString ():String {
			
			var params:XMLList = describeType(this)..accessor;
			var p:Array = [];
			var n:String;
			
			for each (var param:XML in params) {
				n = param.@name;
				if (param.@access == "readwrite" && this["_" + n] != undefined) {
					p.push( { name: n, value: this[n] } );
				}
			}
			
			var f:Function = function callback(item:*, index:int, array:Array):void {
				array[index] = item["value"];
			}
			
			p.sortOn("name");
			p.forEach(f);
			
			return p.join(";");
			
		}
		
		public function fromString (data:String):void {
			
			if (data == null || data.length == 0) {
				setDefaults();
				return;
			}
			
			var params:XMLList = describeType(this)..accessor;
			var p:Array = [];
			var n:String;
			
			for each (var param:XML in params) {
				n = param.@name;
				if (param.@access == "readwrite" && this["_" + n] != undefined) {
					p.push(n);
				}
			}
			
			p.sort();
			
			var d:Array = data.split(";");
			var i:int = p.length;
			
			while (i--) {
				if (this[p[i]] is String) {
					this[p[i]] = d[i];
				} else if (this[p[i]] is Boolean) {
					this[p[i]] = (d[i] == "true");
				} else {
					this[p[i]] = parseFloat(d[i]);
				}
			}
			
			if (_vInstructions == "0") _vInstructions = "";
			if (_vMusic == "0") _vMusic = "";
			
		}
		
		public function getGameInfo ():String {
			
			var info:String = "";
			
			if (_total_time == 0) {
				
				info += "Score " + _total_score + " points to win. ";
				
			} else {
				
				if (_total_score == 0) {
					
					info += "SURVIVAL MODE: Stay alive for " + _total_time + " seconds. ";
					
				} else {
					
					info += "TIMED MODE: Score " + _total_score + " points in " + _total_time + " seconds. ";
					
				}
				
			}
			
			if (_total_lives > 0) {
				
				info += "You start with " + _total_lives + " lives. ";
				
			}
			
			if (_total_penalties > 0) {
				
				if (_total_penalties > 1) info += "Lose a life for every " + _total_penalties + " penalties.";
				else info += "Lose a life for every penalty.";
				
			}
			
			if (info.length) return info;
			else return "There seems to be no objective for this game. Play around and have fun!";
			
		}
		
	}

}