package com.sploder.game
{
	import com.sploder.builder.model.Environment;
	import com.sploder.game.sound.SoundManager;
	import com.sploder.game.sound.Sounds;
	import com.sploder.asui.Library;
	import com.sploder.asui.ObjectEvent;
	import com.sploder.util.PlayTimeCounter;
	import com.sploder.util.StringUtils;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.Timer;
	
	
	/**
	 * ...
	 * @author ...
	 */
	public class ViewUI {
		
		public static var library:Library;
		
		protected var _simulation:Simulation;
		
		protected var _clip:Sprite;
		
		public static var _nextID:int = 0;
		protected var _id:int = 0;
		
		protected var _lifeTF:TextField;
		protected var _penaltyTF:TextField;
		protected var _scoreTF:TextField;
		protected var _levelClip:Sprite;
		protected var _levelTF:TextField;
		protected var _timerClip:Sprite;
		protected var _timerTF:TextField;
		protected var _soundStatusTF:TextField;
				
		protected var _topBar:MovieClip;
		protected var _taskNotice:MovieClip;
		protected var _bottomBar:MovieClip;
		protected var _bottomBarBackground:MovieClip;
		protected var _helpButton:SimpleButton;
		protected var _retryButton:SimpleButton;
		protected var _musicIcon:MovieClip;
		protected var _logo:Sprite;
		protected var _soundToggle:MovieClip;
		protected var _soundToggleButton:SimpleButton;
		protected var _copyClip:MovieClip;
		protected var _copyButton:SimpleButton;
		
		protected var _clockTimer:Timer;
		protected var _taskNoticeTimer:Timer;
		protected var _soundStatusInterval:int;
		protected var _playtimeText:TextField;
		protected var _playtimeInterval:int;
		protected var _prevSecondsCounted:int = -1;
		protected var _prevComplete:Boolean = false;
		
		protected var _origin:Point;
			
		//
		//
		public function ViewUI (sim:Simulation) 
		{
			_simulation = sim;
			
			_nextID++;
			_id = _nextID;

			if (library) build();
			
		}
		
		//
		//
		protected function build ():void {
			
			_clip = library.getDisplayObject("console") as Sprite;
			_clip.mouseEnabled = true;
			_clip.mouseChildren = true;
			_clip.tabEnabled = false;
			_clip.tabChildren = false;
			_clip.focusRect = false;
			_simulation.view.ui.addChild(_clip);
			
			_origin = new Point();
			
			initConsole();
			
		}
		
		//
		//
		protected function initConsole ():void {
			
			_topBar = _clip["topbar"];
			_lifeTF = _clip["life"];
			_penaltyTF = _clip["penalty"];
			_scoreTF = _clip["score"];
			_levelClip = _clip["level"];
			_levelTF = _levelClip["tf"];
			_timerClip = _clip["time"];
			_timerTF = _timerClip["tf"];
			_helpButton = _clip["help"];
			_retryButton = _clip["retry"];
			_taskNotice = _clip["taskNotice"];
			_bottomBar = _clip["bottom_bar"];
			_playtimeText = _bottomBar["playtime"];
			_logo = _bottomBar["logo"];
			_musicIcon = _bottomBar["music"];
			_soundStatusTF = _bottomBar["soundstatus"];
			_soundToggle = _bottomBar["soundtoggle"];
			_soundToggleButton = _soundToggle["btn"];
			_bottomBarBackground = _bottomBar["bkgd"];
			_copyClip = _bottomBar["copy"];
			_copyButton = _copyClip["btn"];
			
			_clip.mouseEnabled = false;
			_clip.mouseChildren = true;
			_topBar.mouseEnabled = _topBar.mouseChildren = false;
			_bottomBar.mouseEnabled = false;
			_bottomBar.mouseChildren = true;
			_bottomBarBackground.stop();
			_bottomBarBackground.mouseEnabled = false;
			
			_copyClip.visible = false;
			_taskNotice.visible = false;
			_musicIcon.visible = false;
			
			if (!SoundManager.soundsGenerated) {
				_soundStatusInterval = setInterval(updateSoundStatus, 500);
			} else {
				_soundStatusTF.text = "";
			}
			
			_soundStatusTF.mouseEnabled = false;
			
			if (SoundManager.hasSound) _soundToggle.gotoAndStop(1);
			else _soundToggle.gotoAndStop(2);
			
			_soundToggleButton.addEventListener(MouseEvent.CLICK, onSoundToggleButtonClicked, false, 0, true);
			
			onResize();
			setInitialValues();
			updateSoundStatus();
			
			_simulation.view.addEventListener(Event.RESIZE, onResize, false, 0, true);
			
			_simulation.events.addEventListener(States.ACTION_ADDLIFE, onStatus, false, 0, true);
			_simulation.events.addEventListener(States.ACTION_ENDGAME, onStatus, false, 0, true);
			_simulation.events.addEventListener(States.ACTION_LOSELIFE, onStatus, false, 0, true);
			_simulation.events.addEventListener(States.ACTION_PENALTY, onStatus, false, 0, true);
			_simulation.events.addEventListener(States.ACTION_SCORE, onStatus, false, 0, true);
			_simulation.events.addEventListener(States.EVENT_AMMOLOW, onStatus, false, 0, true);
			

			if (PlayTimeCounter.showTime) {
				if (PlayTimeCounter.timeLimit > 0) _playtimeInterval = setInterval(updatePlayTime, 500);
				else updatePlayScore();
				_bottomBarBackground.gotoAndStop(2);
				_logo.visible = false;
				_soundToggle.x -= 104;
				_copyClip.x -= 104;
			} else {
				_playtimeText.visible = false;
			}
			
		}
		
		public function onResize (e:Event = null):void {
			
			if (_simulation && _simulation.view) {
				
				var width:int = _simulation.view.width;
				var height:int = _simulation.view.height;
				
				_topBar.width = width;
				
				_levelClip.x = width - 160;
				_timerClip.x = width - 64;

				_taskNotice.x = (width - _taskNotice.width) * 0.5;
				_taskNotice.y = height - 80;

				_bottomBar.y = height - 20;
				
				_bottomBarBackground.width = width;
				
				_logo.x = width - Math.floor(_logo.width) - 20;
				
				_helpButton.y = _retryButton.y = height - 29;
				
				_copyClip.x = _logo.x - 10;
				
				_soundToggle.x = width - 14;
				
				_clip.x = Math.floor(_simulation.view.x);
				_clip.y = Math.floor(_simulation.view.y);
				
				if (_simulation.environment.vMusic == "") {
					_musicIcon.visible = false;
					_soundStatusTF.x = 115;
				} else {
					_musicIcon.visible = true;
					_soundStatusTF.x = 125;
				}
				
			}
			
		}
		
		public function setInitialValues ():void {
			
			_lifeTF.text = _simulation.environment.total_lives + "";
			
			if (_simulation.environment.total_penalties) {
				_penaltyTF.text = "0" + "/" + _simulation.environment.total_penalties;
			} else {
				_penaltyTF.text = "0";
			}
			
			if (_simulation.environment.total_score) {
				_scoreTF.text = 0 + "/" + _simulation.environment.total_score;
			} else {
				_scoreTF.text = 0 + "";
			}
					
			_levelTF.text = "LEVEL " + EventHandler.levelNum + "/" + EventHandler.totalLevels;
			
			if (_simulation.environment.total_time == 0) {
				_timerClip.visible = false;
				_levelClip.x = _timerClip.x - 27;
			} else {
				_clockTimer = new Timer(250, 0);
				_clockTimer.addEventListener(TimerEvent.TIMER, updateClock, false, 0, true);
				_clockTimer.start();
			}
			
		}
		
		
		//
		//
		protected function onStatus (e:Event = null):void {
			
			switch (e.type) {
				
				case States.ACTION_ADDLIFE:
					_lifeTF.text = Math.max(0, _simulation.events.lives) + "";
					addEventEffect("event_addlife");
					break;
					
				case States.ACTION_ENDGAME:
					if (_simulation.events.won) {
						if (_simulation.environment.total_score > 0) _taskNotice.gotoAndStop("win_score");
						else _taskNotice.gotoAndStop("win_time");
					} else {
						if (_simulation.events.lives <= 0) _taskNotice.gotoAndStop("lose");
						else _taskNotice.gotoAndStop("lose_time")
					}
					_taskNotice.visible = true;
					break;
					
				case States.ACTION_LOSELIFE:
					_lifeTF.text = Math.max(0, _simulation.events.lives) + "";
					addEventEffect("event_loselife");
					break;
					
				case States.ACTION_PENALTY:
					if (_simulation.environment.total_penalties) {
						_penaltyTF.text = Math.max(0, _simulation.events.penalty) + "/" + _simulation.environment.total_penalties;
					} else {
						_penaltyTF.text = Math.max(0, _simulation.events.penalty) + "";
					}
					addEventEffect("event_penalty");
					break;
					
				case States.ACTION_SCORE:	
					if (_simulation.environment.total_score) {
						_scoreTF.text = Math.max(0, _simulation.events.score) + "/" + _simulation.environment.total_score;
					} else {
						_scoreTF.text = Math.max(0, _simulation.events.score) + "";
					}
					addEventEffect("event_score");
					if (PlayTimeCounter.scoreLimit > 0) updatePlayScore();
					break;
					
				case States.EVENT_AMMOLOW:
					
					if (e is ObjectEvent) {
						var total:int = parseInt(ObjectEvent(e).object.total);
						
						if (total < 10) {
							var effect:Sprite = addEventEffect("event_ammolow");
							effect.x = ObjectEvent(e).object.x;
							effect.y = ObjectEvent(e).object.y;
							if (_simulation.environment.size == Environment.SIZE_DOUBLE) {
								effect.x *= 0.5;
								effect.y *= 0.5;
								effect.scaleX = effect.scaleY = 0.5;
							} else {
								effect.scaleX = effect.scaleY = 1;
							}
							TextField(effect["tf"]).text = total + "";
						}
					}
					break;
				
			}
			
		}
		
		protected function addEventEffect (clipName:String):Sprite {
			
			var pt:Point = _simulation.view.viewport.localToGlobal(_simulation.events.lastEventPos);
			pt = _clip.globalToLocal(pt);
			var clip:Sprite = library.getDisplayObject(clipName) as Sprite;
			
			if (clip) {
				clip.scaleX = clip.scaleY = _simulation.view.viewport.scaleX * 2;
				clip.x = pt.x;
				clip.y = pt.y;
				_clip.addChild(clip);
			}
			
			return clip;
			
		}
		
		//
		//
		protected function updateClock (e:TimerEvent = null):void {
			
			var time:String = _timerTF.text;
			
			setGameTime(_timerTF);
			
			if (_timerTF.text != time) {
				
				if (_simulation.events.timeElapsed  <= _simulation.environment.total_time &&
					_simulation.environment.total_time - _simulation.events.timeElapsed <= 10) {
					
					_simulation.playSound(null, Sounds.TICK, 1, false);
					
				}
				
			}
				
		}
		
		
		//
		//
		public function reinit ():void {
			
			initConsole();
			
		}
		
        //
        //
        public function setGameTime (field:TextField):void {
			
			if (_simulation == null) return;
			if (_simulation.environment == null) return;
			if (_simulation.events == null) return;
			
			var gameTime:int = Math.max(0, _simulation.environment.total_time - _simulation.events.timeElapsed);
    
            if (gameTime > 0) {
                
                if (gameTime > 60) {
                    field.text = Math.floor(gameTime / 60) + ":";
                } else {
                    field.text = "0:";
                }
                
                if (gameTime % 60 == 0) {
                    field.appendText("00");
                } else if (gameTime % 60 < 10) {
                    field.appendText("0" + (gameTime % 60));
                } else {
                    field.appendText("" + gameTime % 60);
                }
                
            } else {
                
                field.text = "-:--";
                
            }
            
        }
		
		protected function updateSoundStatus ():void {
			
			if (_soundStatusTF == null ) return;
			
			if (SoundManager.soundsGenerated) {
				if (_musicIcon.visible) {
					var tag:Array = _simulation.environment.vMusic.split("/");
					var c_title:String = String(tag[1]).split("?")[0];
					c_title = StringUtils.titleCase(unescape(c_title).split(".mod").join("").split("-").join(" "));
					_soundStatusTF.htmlText = c_title + ' - ' + '<font color="#ffec00"><a href="http://www.sploder.com/music/author_redirect.php?author=' + tag[0] + '" target="_blank">' + tag[0] + ' ¬</a></font>';
					_soundStatusTF.visible = true;
					_soundStatusTF.mouseEnabled = true;
				} else {
					_soundStatusTF.text = "";
					_soundStatusTF.visible = false;
				}
				if (_soundStatusInterval) clearInterval(_soundStatusInterval);
			} else {
				_soundStatusTF.text = "GENERATING SOUNDS: " + Math.floor(SoundManager.soundGenerationPercent * 100) + "%";
				_soundStatusTF.visible = true;
			}
			
		}
		
		
		protected function updatePlayTime ():void {
			
			if (PlayTimeCounter.mainInstance != null) {
				
				var st:int = PlayTimeCounter.mainInstance.secondsCounted;
				
				if (_playtimeText != null && (_prevSecondsCounted != st || _prevComplete != PlayTimeCounter.mainInstance.complete)) {
					
					_prevSecondsCounted = st;
					_prevComplete = PlayTimeCounter.mainInstance.complete;
					
					if (PlayTimeCounter.timeLimit == 0) {
						_playtimeText.htmlText = StringUtils.timeInMinutes(_prevSecondsCounted);
					} else {
						var timeleft:int = Math.max(0, PlayTimeCounter.timeLimit - _prevSecondsCounted);
						var timeleftDisplay:String = StringUtils.timeInMinutes(timeleft);
						if (_prevComplete && timeleft > 0)
						{
							_playtimeText.htmlText = '<font color="#00ff66">' + timeleftDisplay + '</font>';
						}
						else if (timeleft < 20) {
							_playtimeText.htmlText = '<font color="#ff3300">' + timeleftDisplay + '</font>';
						} else {
							_playtimeText.htmlText = timeleftDisplay;
						}
					}
					
				}
			
			}
			
		}
		
		protected function updatePlayScore ():void {
			
			var new_score:int = EventHandler.totalScore + _simulation.events.score;
			
			if (PlayTimeCounter.scoreLimit > 0 && new_score >= PlayTimeCounter.scoreLimit) {
				_playtimeText.htmlText = '<font color="#00ff66">' + new_score + '</font>';
			} else {
				_playtimeText.htmlText = !isNaN(new_score) ? new_score + "" : "0";
			}
			
		}
		
		//
		//
		public function allowCopying ():void {
			
			if (_copyButton) {
				_copyClip.visible = true;
				_copyButton.addEventListener(MouseEvent.CLICK, onCopyButtonClicked, false, 0, true);
			}
			
		}
		
		//
		//
		protected function onCopyButtonClicked (e:MouseEvent):void {
			
			System.setClipboard(_simulation.model.toString());
			_copyClip.gotoAndPlay(2);
			
		}

		//
		//
		protected function onSoundToggleButtonClicked (e:MouseEvent):void {
			
			SoundManager.hasSound = !SoundManager.hasSound;
			
			if (SoundManager.hasSound) _soundToggle.gotoAndStop(1);
			else _soundToggle.gotoAndStop(2);
			
			if (SoundManager.hasSound && _simulation.environment.vMusic != "") {
				Simulation.sounds.pauseSong();
				Simulation.sounds.resumeSong();
			}
			
		}
		
		
		//
		//
		public function end ():void {
			
			if (_soundStatusInterval) {
				clearInterval(_soundStatusInterval);
				_soundStatusInterval = 0;
			}
			
			
			
			if (_soundToggleButton) {
				_soundToggleButton.removeEventListener(MouseEvent.CLICK, onSoundToggleButtonClicked);
				_soundToggleButton = null;
			}
			
			if (_simulation) {
				if (_simulation.view) {
					_simulation.view.removeEventListener(Event.RESIZE, onResize);
				}
				if (_simulation.events) {
					_simulation.events.removeEventListener(States.ACTION_ADDLIFE, onStatus);
					_simulation.events.removeEventListener(States.ACTION_ENDGAME, onStatus);
					_simulation.events.removeEventListener(States.ACTION_LOSELIFE, onStatus);
					_simulation.events.removeEventListener(States.ACTION_PENALTY, onStatus);
					_simulation.events.removeEventListener(States.ACTION_SCORE, onStatus);					
				}
			}
			
			if (_clockTimer) {
				_clockTimer.removeEventListener(TimerEvent.TIMER, updateClock);
				_clockTimer.stop();
				_clockTimer = null;
			}
			
			if (_clip && _clip.parent) _clip.parent.removeChild(_clip);
			
			_lifeTF = _penaltyTF = _scoreTF = _levelTF = _timerTF = _soundStatusTF = null;
			_levelClip = _timerClip = _logo = null;
			_topBar = _taskNotice = _bottomBar = _bottomBarBackground = _soundToggle = _copyClip = null;
			_helpButton = _retryButton = _soundToggleButton = _copyButton = null;
		
			_clip = null;
			
		}
		
		public function get helpButton():SimpleButton 
		{
			return _helpButton;
		}
		
		public function get retryButton():SimpleButton 
		{
			return _retryButton;
		}
		
	}
	
}