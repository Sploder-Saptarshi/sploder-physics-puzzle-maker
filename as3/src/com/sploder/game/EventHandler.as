package com.sploder.game 
{
	import com.sploder.builder.model.Environment;
	import com.sploder.builder.model.Model;
	import com.sploder.builder.model.ModelObject;
	import com.sploder.builder.model.Modifier;
	import com.sploder.game.sound.Sounds;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.utils.clearInterval;
	import flash.utils.Dictionary;
	import flash.utils.setInterval;
	import nape.callbacks.Callback;
	import nape.phys.Body;
	import nape.phys.PhysObj;
	
	/**
	 * ...
	 * @author ...
	 */
	public class EventHandler extends EventDispatcher
	{
		protected var _sim:Simulation;
		protected var _model:Model;
		protected var _environment:Environment;
		
		public static var _nextID:int = 0;
		protected var _id:int = 0;
		
		protected var _actions:Dictionary;
		protected var _events:Dictionary;
		protected var _sense_pairs:Dictionary;
		protected var _sense_links:Dictionary;
		
		protected var _lives:int = 0;
		protected var _penalty:int = 0;
		protected var _score:int = 0;
		public static var levelNum:int = 0;
		public static var totalLevels:int = 0;
		public static var totalTime:int = 0;
		public static var totalScore:int = 0;
		protected var _timeElapsed:int = 0;
		protected var _timeInterval:int;
		protected var _ended:Boolean = false;
		protected var _won:Boolean = false;
		protected var _loseIfNotWon:Boolean = false;
		protected var _loseNextFrame:Boolean = false;
		
		protected var _lastEventPos:Point;
		
		public function get lives():int 
		{
			return _lives;
		}
		
		public function get penalty():int 
		{
			return _penalty;
		}
		
		public function get score():int 
		{
			return _score;
		}
		
		public function get timeElapsed():int 
		{
			return _timeElapsed;
		}
		
		public function get lastEventPos():Point 
		{
			return _lastEventPos;
		}
		
		public function get ended():Boolean 
		{
			return _ended;
		}
		
		public function get won():Boolean 
		{
			return _won;
		}
		
		public function EventHandler (sim:Simulation, model:Model, environment:Environment)
		{
			_sim = sim;
			_model = model;
			_environment = environment;
			
			_nextID++;
			_id = _nextID;
			
			_actions = new Dictionary();
			_events = new Dictionary();
			_sense_pairs = new Dictionary();
			_sense_links = new Dictionary();
			
			_lives = _environment.total_lives;
			
			_lastEventPos = new Point();
			
			_timeInterval = setInterval(updateElapsedTime, 250);
			
		}
		
		protected function endGame (won:Boolean = false):void {
			
			if (_ended) return;
			
			_won = won;
			_ended = true;
			stopTimer();
			totalTime += _timeElapsed;
			totalScore += _score;
			
			if (_won) {
				_sim.playSound(null, Sounds.WINLEVEL, 1, false);
			} else {
				_sim.playSound(null, Sounds.LOSEGAME, 1, false);
			}
			
			dispatchEvent(new Event(States.ACTION_ENDGAME));
				
		}
		
		public function checkEndGameStatus ():void {
			
			if (_ended) return;
			
			if (_loseNextFrame && !_won) {
				_score = 0;
				endGame();
			} else if (_loseIfNotWon && !_won) {
				_loseNextFrame = true;
			}
			
		}
		
		protected function updateElapsedTime ():void {
			
			_timeElapsed = _sim.frame / 42;
			
			if (_environment.total_time > 0) {
				
				if (_timeElapsed >= _environment.total_time) {
				
					if (_environment.total_score > 0 && _score < _environment.total_score) {
						_loseIfNotWon = true;
					} else {
						endGame(true);
					}
					
				}
				
			}
			
		}
		
		protected function stopTimer ():void {
			
			if (_timeInterval) clearInterval(_timeInterval);
			_timeInterval = 0;
			
		}
		
		public function registerActions (m:ModelObject):void 
		{
			var a:int;
			var e:int;
			var astate:uint = m.props.actions;
			
			var actions:String = astate.toString(16);
			while (actions.length < States.ACTIONS.length) actions = "0" + actions;
			
			var events:String = "";
			
			for (a = 0; a < States.ACTIONS.length; a++) {
				
				events = parseInt(actions.charAt(a), 16).toString(2);
				while (events.length < States.EVENTS.length) events = "0" + events;
				
				for (e = 0; e < States.EVENTS.length; e++) {
					
					_actions[getActionKey(m, e, a)] = (events.charAt(e) == "1");
					_events[getEventKey(m, e)] = (_events[getEventKey(m, e)] || (events.charAt(e) == "1"));
					
				}
				
			}
			
		}
	
		public function hasActionForEvent (m:ModelObject, event:int):Boolean {
			
			return (_events[getEventKey(m, event)] === true);
			
		}
		
		protected function processActions (p:PhysObj, event:int, isLink:Boolean = false):void {
			
			if (_ended) return;
			
			var m:ModelObject = p.data as ModelObject;
			
			if (m) {
				
				_lastEventPos.x = p.px;
				_lastEventPos.y = p.py;
				
				if (!isLink) {
					
					if (_actions[getActionKey(m, event, 0)]) { // SCORE ACTION
						
						_score++;
						dispatchEvent(new Event(States.ACTION_SCORE));
						_sim.playSound(p, Sounds.SCORE, 1, false);
						
						if (_environment.total_score > 0 && _score >= _environment.total_score) {
							endGame(true);
						}	
						
					}
					
					if (_actions[getActionKey(m, event, 1)]) { // PENALTY ACTION
						
						_penalty++;
						
						_sim.playSound(p, Sounds.PENALTY, 1, false);
						
						if (_environment.total_penalties > 0 && _penalty >= _environment.total_penalties) {
							_lives--;
							_penalty = 0;
							dispatchEvent(new Event(States.ACTION_LOSELIFE));
						}
						
						dispatchEvent(new Event(States.ACTION_PENALTY));
						
					}
					
					if (_actions[getActionKey(m, event, 2)]) { // LOSE LIFE ACTION
						
						_lives--;
						dispatchEvent(new Event(States.ACTION_LOSELIFE));
						_sim.playSound(p, Sounds.LOSELIFE, 1, false);
								
					}
					
					if (_actions[getActionKey(m, event, 3)]) { // ADD LIFE ACTION
						
						_lives++;
						dispatchEvent(new Event(States.ACTION_ADDLIFE));
						_sim.playSound(p, Sounds.ADDLIFE, 1, false);
						
					}
					
				}
				
				if (_actions[getActionKey(m, event, 4)]) { // UNLOCK ACTION
					
					_sim.unlockObject(p);
					_sim.playSound(p, Sounds.UNLOCK);
					
				}
				
				if (_actions[getActionKey(m, event, 5)]) { // REMOVE ACTION
					
					_sim.removeObject(p, View.EFFECT_BLOOM);
					
				}
				
				if (_actions[getActionKey(m, event, 6)]) { // EXPLODE ACTION
					
					_sim.explodeObject(p);
					
				}
				
				if (!_won && ((_environment.total_lives > 0 && _lives == 0) || _actions[getActionKey(m, event, 7)])) { // END GAME ACTION
					
					while (_lives > 0) {
						_lives--;
						var lp:Point = _lastEventPos.clone();
						_lastEventPos.x = lp.x + Math.random() * 80 - 40;
						_lastEventPos.y = lp.y + Math.random() * 80 - 40;
						dispatchEvent(new Event(States.ACTION_LOSELIFE));
					}
					
					_loseIfNotWon = true;
					return;
					
				}
				
			}
			
		}
		
		protected function getEventKey (m:ModelObject, event:int):String {
			
			return m.id + "_" + event;
			
		}
		
		protected function getActionKey (m:ModelObject, event:int, action:int):String {
			
			return m.id + "_" + event + "_" + action;
			
		}
		
		protected function getSensePairKey (p1:PhysObj, p2:PhysObj):String {
			
			return (p1.id < p2.id) ? p1.id + "_" + p2.id : p2.id + "_" + p1.id;
			
		}
		
		protected function checkSensorLinks (p1:PhysObj, p2:PhysObj):Boolean {
			
			var vm:Vector.<Modifier> = null;
			var md:Modifier;
			var linked:PhysObj;
			var trigger:PhysObj;
			var k:String;
			
			if (p1 && _sense_links[p1] is Vector.<Modifier>) {
				
				vm = _sense_links[p1];
				_sense_links[p1] = null;
				delete _sense_links[p1];
				trigger = p2;
				
			} else if (p2 && _sense_links[p2] is Vector.<Modifier>) {
				
				vm = _sense_links[p2];
				_sense_links[p2] = null;
				delete _sense_links[p2];
				trigger = p1;
				
			}
			
			var mi:int;
			
			if (vm && trigger) {
				
				mi = vm.length;
				
				while (mi--) {
					
					md = vm.pop();
						
					if (md && md.props && md.props.child && _sim.bodies[md.props.child] is PhysObj) {
						
						linked = _sim.bodies[md.props.child];
						
						k = getSensePairKey(linked, trigger);
						
						if (_sense_pairs[k] == null) {
							processActions(_sim.bodies[md.props.child], 0, true);
						}
						
						_sense_pairs[k] = true;
						
					}
					
				}
				
				return true;
				
			}
			
			return false;
			
		}
		
		public function handleSensorEvent (cb:Callback):void {
			
			if (_ended) return;
			
			var p1:PhysObj;
			var p2:PhysObj;
				
			if (cb.obj_arb && cb.obj_arb.p1 && cb.obj_arb.p2) {
				
				p1 = cb.obj_arb.p1;
				p2 = cb.obj_arb.p2;

				if (p1 && p1.added_to_space && p2 && p2.added_to_space) {
					
					var k:String = getSensePairKey(p1, p2);
					
					checkSensorLinks(p1, p2);
					
					// handle event
					
					if (_sense_pairs[k]) return;
				
					_sense_pairs[k] = true;
					
					var m1:ModelObject = p1.data as ModelObject;
					var m2:ModelObject = p2.data as ModelObject;
					
					if (m1 && hasActionForEvent(m1, 0)) {
						processActions(p1, 0);
						_sim.playSound(p1, Sounds.SENSOR, 0.5);
						if (p1.graphic is ViewSprite) ViewSprite(p1.graphic).bling();
					}
					
					if (m2 && hasActionForEvent(m2, 0)) {
						processActions(p2, 0);
						_sim.playSound(p2, Sounds.SENSOR, 0.5);
						if (p2.graphic is ViewSprite) ViewSprite(p2.graphic).bling();
					}
					
					
					
				}
			
			}
			
		}
		
		public function handleClickSensorEvent (p:PhysObj):void {
			
			if (_ended) return;
			
			if (p && p.added_to_space) {
				
				// handle event
				var m:ModelObject = p.data as ModelObject;
				
				checkEventLinks(p, 0);
				
				if (m && hasActionForEvent(m, 0)) {
					processActions(p, 0);
					_sim.playSound(p, Sounds.SENSOR, 0.5);
					if (p.graphic is ViewSprite) ViewSprite(p.graphic).bling();
				}
			}
			
		}
		
		public function handleCrushEvent (p:PhysObj):void {
			
			if (_ended) return;
			
			if (p && p.added_to_space) {
				
				var m:ModelObject = p.data as ModelObject;
				
				checkEventLinks(p, 1);
				
				if (m && hasActionForEvent(m, 1)) {
					processActions(p, 1);
				}
				
			}
			
		}
		

		protected function checkEventLinks (parent:PhysObj, event:int):Boolean {
			
			var vm:Vector.<Modifier> = null;
			var md:Modifier;
			var linked:PhysObj;
			var k:String;
			
			if (parent && _sense_links[parent] is Vector.<Modifier>) {
				
				vm = _sense_links[parent];
				_sense_links[parent] = null;
				delete _sense_links[parent];
				
			}
			
			var mi:int;
			
			if (vm && parent) {
				
				mi = vm.length;
				
				while (mi--) {
					
					md = vm.pop();
					
					if (md && md.props && md.props.child && _sim.bodies[md.props.child] is PhysObj) {
						
						linked = _sim.bodies[md.props.child];
						
						if (linked) {
							
							processActions(linked, event, true);
						
						}
							
					}
					
				}
				
				return true;			
				
			}
			
			return false;
			
		}
		
		public function handleEmptyEvent (p:PhysObj, md:Modifier = null):void {
			
			if (_ended) return;
			
			if (p && p.added_to_space) {
				
				var m:ModelObject = p.data as ModelObject;
				
				if (md && _sim.bodies[md.props.parent] is PhysObj) checkEventLinks(_sim.bodies[md.props.parent], 2);
				
				if (m && hasActionForEvent(m, 2)) {
					processActions(p, 2);
				}
				
			}
			
		}
		
		public function handleOutOfBoundsEvent (p:PhysObj):void {
			
			if (_ended) return;
			
			if (p) {
				
				var m:ModelObject = p.data as ModelObject;
				
				checkEventLinks(p, 3);
				
				if (m && hasActionForEvent(m, 3)) {
					processActions(p, 3);
					_sim.removeObject(p);
				}
			
			}
			
		}
		
		public function addSensorLink (p:PhysObj, link:Modifier):void {
			
			if (_sense_links[p] == undefined) _sense_links[p] = new Vector.<Modifier>();
			_sense_links[p].push(link);			
			
		}
		
		public function end ():void {
			trace("ENDING EVENTS");
			stopTimer();
			
		}
		
	}

}