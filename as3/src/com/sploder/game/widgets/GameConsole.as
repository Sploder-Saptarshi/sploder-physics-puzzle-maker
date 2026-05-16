package com.sploder.game.widgets
{
	import com.sploder.data.*;
	import com.sploder.game.Game;
	import com.sploder.game.GameLevel;
	import com.sploder.game.States;
	import flash.display.FrameLabel;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.Timer;
	
	
	/**
	 * ...
	 * @author ...
	 */
	public class GameConsole extends EventDispatcher {
		
		public static const TEST_COMPLETE:String = "test_complete";
		
		protected var _game:Game;
		protected var _container:Sprite;
		protected var _width:int;
		protected var _height:int;
		
		protected var _clip:Sprite;
		protected var _titleScreen:MovieClip;
		protected var _pauseScreen:Sprite;
		protected var _retryScreen:MovieClip;
		protected var _endScreen:MovieClip;
		protected var _leaderboard:Leaderboard;
		protected var _voteWidget:VoteWidget;
				
		protected var _winEventSent:Boolean = false;
		
		protected var _wonGame:Boolean = false;
		protected var _finishing:Boolean = false;
		protected var _finishTimer:Timer;
		
		protected var _displayedLives:int = 1;
		
		protected var _taskNoticeTimer:Timer;
		private var _playInterval:Number;
			
		//
		//
		public function GameConsole (game:Game, container:Sprite, width:int, height:int) 
		{
			_game = game;
			_container = container;
			_width = width;
			_height = height;

			build();
			
		}
		
		//
		//
		protected function build ():void {
			
			_clip = new Sprite();
			_clip.mouseEnabled = true;
			_clip.mouseChildren = true;
			_clip.tabEnabled = false;
			_clip.tabChildren = false;
			_clip.focusRect = false;
			_container.addChild(_clip);
			
			initConsole();
			showTitleScreen();
			
		}
		
		//
		//
		protected function initConsole ():void {
			
			updateStatus();
			
			if (_container && _container.stage) {
				_container.stage.addEventListener(Event.RESIZE, onResize);
			}
			
		}
		
		public function onResize (e:Event = null):void {
			
			if (_container && _container.stage && _container.stage.stageWidth > 0) {
				
				var c:Sprite = _container;
				var cs:Stage = _container.stage;
				
				_width = cs.stageWidth;
				_height = cs.stageHeight;
				
				if (_titleScreen) {
					
					_titleScreen.x = Math.floor(_width * 0.5 - _titleScreen.width * 0.5) + 10;
					_titleScreen.y = Math.floor(_height * 0.5 - _titleScreen.height * 0.5);
					
				}
				
				if (_pauseScreen) {
					
					_pauseScreen.x = Math.floor(_width * 0.5)
					_pauseScreen.y = Math.floor(_height * 0.5) - 10;
					
				}
				
				if (_retryScreen) {
					
					_retryScreen.x = Math.floor(_width * 0.5)
					_retryScreen.y = Math.floor(_height * 0.5) - 10;
					
				}
				
				if (_endScreen) {
					
					_endScreen.x = Math.floor(_width * 0.5 - _endScreen.width * 0.5);
					_endScreen.y = Math.floor(_height * 0.5 - _endScreen.height * 0.5);					
					
				}
				
			}
			
		}

		//
		//
		public function updateStatus (e:Event = null):void {
			
		}
		
		//
		//
		public function reinit ():void {
			
			initConsole();
			
		}
		
		
		//
		//
		public function finishGame (won:Boolean):void {
			
			if (!_finishing) {
				
				_finishing = true;
				
				_wonGame = won;
				
				_finishTimer = new Timer(1000, 1);
				_finishTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onFinishGameTimer);
				_finishTimer.start();
				
			}
			
		}
		
		//
		//
		protected function onFinishGameTimer (e:TimerEvent):void {
			
			if (_finishTimer) {
				_finishTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onFinishGameTimer);
				Game.endGame(_wonGame);
				showEndScreen();
				_finishTimer = null;
			}
			
		}
		
		//
		//
		public function showPauseScreen ():void {
			
			if (_pauseScreen) {
				_pauseScreen.visible = true;
			} else {
				_pauseScreen = _game.uiLibrary.getDisplayObject("pausescreen") as Sprite;
				_pauseScreen.mouseEnabled = _pauseScreen.mouseChildren = false;
				_pauseScreen.x = Math.floor(_width * 0.5)
				_pauseScreen.y = Math.floor(_height * 0.5) - 10;	
			}
			_container.addChild(_pauseScreen);
			
		}
		
		//
		//
		public function hidePauseScreen ():void {
			
			if (_pauseScreen) {
				_pauseScreen.visible = false;
				if (_pauseScreen.parent) _pauseScreen.parent.removeChild(_pauseScreen);
			}
		}
		
		//
		//
		public function showRetryScreen ():void {
			
			if (_retryScreen) {
				_retryScreen.visible = true;
			} else {
				_retryScreen = _game.uiLibrary.getDisplayObject("retryscreen") as MovieClip;
				_retryScreen.x = Math.floor(_width * 0.5)
				_retryScreen.y = Math.floor(_height * 0.5) - 10;
				_retryScreen["no"].addEventListener(MouseEvent.CLICK, onRetryNo);
				_retryScreen["yes"].addEventListener(MouseEvent.CLICK, onRetryYes);
			}
			_container.addChild(_retryScreen);	
		}
		
		//
		//
		public function hideRetryScreen ():void {
			
			if (_retryScreen) {
				_retryScreen.visible = false;
				if (_retryScreen.parent) _retryScreen.parent.removeChild(_retryScreen);
			}
		}
		
		//
		//
		public function showTitleScreen ():void {
			
			if (_titleScreen) {
				_titleScreen.visible = true;
				_titleScreen.gotoAndPlay(1);	
			} else {
				_titleScreen = _game.uiLibrary.getDisplayObject("titledialogue") as MovieClip;
				_titleScreen.mouseEnabled = true;
				_titleScreen.mouseChildren = true;
				_titleScreen.x = Math.floor(_width * 0.5 - _titleScreen.width * 0.5) + 10;
				_titleScreen.y = Math.floor(_height * 0.5 - _titleScreen.height * 0.5);
				
				
				initTitleScreen();
			}
			_container.addChild(_titleScreen);
			
		}
		
		//
		//
		public function hideTitleScreen ():void {
			
			if (_titleScreen) {
				_titleScreen.visible = false;
				_titleScreen.gotoAndStop(1);
				if (_titleScreen.parent) _titleScreen.parent.removeChild(_titleScreen);
			}
			
		}
		
		//
		//
		protected function initTitleScreen ():void {
			
			if (_titleScreen == null) return;
			
			for each (var lbl:FrameLabel in _titleScreen.currentLabels) _titleScreen.addFrameScript(lbl.frame - 1, onTitleScreenLabel);
			
		}
		
		//
		//
		protected function onTitleScreenLabel ():void {
			
			if (_titleScreen == null) return;
			
			var labelName:String = _titleScreen.currentLabel;
			
			switch (labelName) {
					
				case "getInstructions":
				
					var gtf:TextField = _titleScreen.goals;
					var itf:TextField = _titleScreen.instructions;
					
					gtf.text = Game.gameInstance.currentLevel.environment.getGameInfo();
					
					var instructions:String = Game.gameInstance.currentLevel.environment.vInstructions;
					if (instructions.length == 0) instructions = Game.gameInstance.currentLevel.model.modifiers.guessInstructions();
					
					itf.text = instructions;
					
					gtf.autoSize = TextFieldAutoSize.LEFT;
					itf.y = gtf.y + gtf.height + 10;
					
					var controls:Array = Game.gameInstance.currentLevel.model.modifiers.getControls();
					
					if (controls.indexOf(States.CONTROLS_MOUSE) != -1) {
						_titleScreen.mouse.alpha = 1;
					}
					if (controls.indexOf(States.CONTROLS_UPDOWN) != -1) {
						_titleScreen.updown.alpha = 1;
					}
					if (controls.indexOf(States.CONTROLS_LEFTRIGHT) != -1) {
						_titleScreen.leftright.alpha = 1;
					}
					if (controls.indexOf(States.CONTROLS_SPACEBAR) != -1) {
						_titleScreen.spacebar.alpha = 1;
					}
					
					var fastmode_button:SimpleButton = SimpleButton(_titleScreen.fastmode);
					
					if (_game.currentLevel.turbo) {
						fastmode_button.visible = false;
					} else {
						fastmode_button.addEventListener(MouseEvent.CLICK, onFastmodeButtonClicked, false, 0, true);
					}
					
					break;
					
				case "getPlayAction":
					SimpleButton(_titleScreen.game_play).addEventListener(MouseEvent.MOUSE_UP, onPlayButtonClicked, false, 0, true);
					_titleScreen.stop();
					break;
					
				case "end":
					_container.removeChild(_titleScreen);
					_titleScreen.stop();
					_titleScreen = null;
					break;
				
			}

		}
		
		protected function onFastmodeButtonClicked (e:MouseEvent):void {
			
			GameLevel.forceTurbo = true;
			Game.restartGame();
			
		}
		
		//
		//
		protected function onPlayButtonClicked (e:MouseEvent):void {
			
			SimpleButton(_titleScreen.game_play).removeEventListener(MouseEvent.MOUSE_UP, onPlayButtonClicked);
			_titleScreen.play();
			clearInterval(_playInterval);
			_playInterval = setInterval(doThePlaying, 500);
			Game.sendEvent(1);

		}
		
		protected function doThePlaying ():void {
			
			clearInterval(_playInterval);
			_game.currentLevel.start();
			
		}

		//
		//
		public function showEndScreen ():void {
			
			if (_endScreen == null) _endScreen = _game.uiLibrary.getDisplayObject("enddialogue") as MovieClip;
			
			if (_endScreen != null) {
				
				_endScreen.mouseEnabled = true;
				_endScreen.mouseChildren = true;
				_endScreen.x = Math.floor(_width * 0.5 - _endScreen.width * 0.5);
				_endScreen.y = Math.floor(_height * 0.5 - _endScreen.height * 0.5);
				_container.addChild(_endScreen);
				
				initEndScreen();
				
			}
			
		}
		
		//
		//
		public function removeEndScreen ():void {
			
			if (_endScreen != null && _container.getChildIndex(_endScreen) != -1) {
				_container.removeChild(_endScreen);
				_endScreen = null;
			}
			
		}
		
		//
		//
		protected function initEndScreen ():void {
			
			for each (var lbl:FrameLabel in _endScreen.currentLabels) _endScreen.addFrameScript(lbl.frame - 1, onEndScreenLabel);
			
		}
		
		//
		//
		protected function onEndScreenLabel ():void {
			
			var btn:SimpleButton;
			
			if (_endScreen == null) return;
			
			var labelName:String = _endScreen.currentLabel;
			
			switch (labelName) {
				
				case "setResult":
					if (Game.wonGame) _endScreen["result"].gotoAndPlay(30);
					break;
					
				case "checkSubmission":
					if (Game.gameResultSubmitted) _endScreen.play();
					else _endScreen.gotoAndPlay(75);
					break;
					
				case "showGameTime":
					if (_endScreen["game_time"] != null) setGameTime(_endScreen["game_time"]);
					break;
					
				case "showGameResult":
					if (_endScreen["game_result"] != null) {
						if (Game.wonGame) {
							_endScreen["game_result"].gotoAndStop(3);
						} else {
							_endScreen["game_result"].gotoAndStop(2);
						}
					}
					
				case "showAuthor":
					if (_endScreen["game_author"] != null) setGameAuthor(_endScreen["game_author"]);
					if (_endScreen["author_button"] != null) {
						btn = _endScreen["author_button"];
						btn.addEventListener(MouseEvent.CLICK, onAuthorNameClicked, false, 0, true);
					}
					break;
					
				case "showLeaderboard":
					// leaderboard
					_leaderboard = new Leaderboard(_endScreen["leaderboard"]);
					break;
					
				case "voteWidget":
					if (_endScreen["vote_widget"] != null) {
						_voteWidget = new VoteWidget(_endScreen["vote_widget"]);
					}
					if (_endScreen["try_again_button"] != null) {
						btn = _endScreen["try_again_button"];
						if (Game.wonGame) btn.visible = false;
					}
					break;
					
				case "buildComplete":

					if (_endScreen["try_again_button"] != null) {
						btn = _endScreen["try_again_button"];
						btn.addEventListener(MouseEvent.CLICK, onReplayButtonClicked, false, 0, true);
					}
					if (_endScreen["replay_game_button"] != null) {
						btn = _endScreen["replay_game_button"];
						btn.addEventListener(MouseEvent.CLICK, onReplayButtonClicked, false, 0, true);
					}
					if (_endScreen["play_more_games_button"] != null) {
						btn = _endScreen["play_more_games_button"];
						btn.addEventListener(MouseEvent.CLICK, onPlayMoreGamesButtonClicked, false, 0, true);
					}
					
					_endScreen.stop();
					
					break;
				
			}

		}
		
        //
        //
        public function setGameTime (field:TextField):void {

			var gameTime:int = Game.totalTime;
    
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
		
        //
        //
        public function setGameAuthor (field:TextField, showArrow:Boolean = true):void {

            
            var arrow:String = "";
            
            if (showArrow) {
                arrow = unescape('%20%AC%AC');
            }
            
            field.htmlText = '<a href="http://www.sploder.com/games/members/' + Game.author.toLowerCase() + '/">' + Game.author.toUpperCase() + arrow + '</a>';
    
        }
		
		//
		//
		public function onAuthorNameClicked (e:MouseEvent):void {
			
			var request:URLRequest = new URLRequest("http://www.sploder.com/games/members/" + Game.author.toLowerCase() + "/");
			
			try {
				navigateToURL(request, "_blank");
			} catch (e:Error) {
				
			}
			
		}
		
		//
		//
		public function onRetryNo (e:MouseEvent):void {
			
			hideRetryScreen();
			_game.currentLevel.resume();
			
		}
		
		//
		//
		public function onRetryYes (e:MouseEvent):void {
			
			removeEndScreen();
			hideRetryScreen();
			hidePauseScreen();
			hideTitleScreen();
			_finishing = false;
			Game.restartLevel();
			
		}
		
		//
		//
		public function onReplayButtonClicked (e:MouseEvent):void {
			
			removeEndScreen();
			_finishing = false;
			if (Game.wonGame) {
				Game.restartGame();
			} else {
				Game.restartLevel();
			}
			
		}
		
		//
		//
		public function onPlayMoreGamesButtonClicked (e:MouseEvent):void {
			
			if (_endScreen["play_more_games_button"] != null) {
				
				var btn:SimpleButton = _endScreen["play_more_games_button"];
				btn.removeEventListener(MouseEvent.CLICK, onPlayMoreGamesButtonClicked);
				
				loadLinks();
				
			}
			
		}
		
		//
		//
		protected function loadLinks():void {
			
			var linksSWFURL:String;
			if (Main.dataLoader.baseURL.indexOf("http://sploder.home") == -1 && Main.dataLoader.baseURL.indexOf("192.168.") == -1 && Main.dataLoader.embedParameters.onsplodercom == undefined) {
				linksSWFURL = "http://www.sploder.com/gamelinks.swf";
			} else {
				linksSWFURL = "gamelinks.swf";
			}
			
			var myLoader:Loader = new Loader();
			_container.addChild(myLoader); 
			var url:URLRequest = new URLRequest(linksSWFURL); 
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLinksLoaded);
			myLoader.load(url);
		
		}
		
		//
		//
		protected function onLinksLoaded (e:Event):void {
			
			removeEndScreen();
			
		}
		
		//
		//
		public function end ():void {
			
			if (_container && _container.stage) {
				_container.stage.removeEventListener(Event.RESIZE, onResize);
			}
			
			if (_clip && _container) _container.removeChild(_clip);
			
			_container = null;
			_clip = null;
			_voteWidget = null;
			_leaderboard = null;
			
		}
		
	}
	
}