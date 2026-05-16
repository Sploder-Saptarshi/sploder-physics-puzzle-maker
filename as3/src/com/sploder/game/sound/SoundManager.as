package com.sploder.game.sound {
	
	import com.sploder.game.Simulation;
	import com.sploder.game.sound.Sounds;
	import com.sploder.util.Geom2d;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.Dictionary;
	import nape.phys.PhysObj;
	import neoart.flod.ModProcessor;
	
	
	
	
    public class SoundManager {

		protected var _simulation:Simulation;
		protected var _initialized:Boolean = false;
		
		public static var baseURL:String = "http://sploder.s3.amazonaws.com/";
		
		public static var mainInstance:SoundManager;
		
		public function initialize (stage:Stage):void {
			
			if (stage) {
				stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			}
			
		}
		
		public function unregisterStage (stage:Stage):void {
			
			if (stage) stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
		}
		
        private static var _hasSound:Boolean = true;
        public static function get hasSound ():Boolean { return _hasSound; }
        public static function set hasSound (val:Boolean):void { 
			_hasSound = val;
			if (!_hasSound) {
				stopAll();
			}
		}
		
		protected var _ptA:Point;
		protected var _ptB:Point;
		
		protected static var _synths:Dictionary;
		
		protected static var _soundIDs:Array = [
			Sounds.FRICTION,
			Sounds.TOUCH, 
			Sounds.BUMP,
			Sounds.BUMP_BIG,
			Sounds.SELF_BUMP,
			Sounds.SPAWN,
			Sounds.JUMP,
			Sounds.CLANG, 
			Sounds.TINK,
			Sounds.TINK_BIG,
			Sounds.CRASH,
			Sounds.EXPLODE,
			Sounds.SCORE, 
			Sounds.PENALTY, 
			Sounds.UNLOCK, 
			Sounds.SENSOR,
			Sounds.LOSELIFE, 
			Sounds.ADDLIFE, 
			Sounds.RESONATE, 
			Sounds.RESONATE_LONG,
			Sounds.EXPLODE_HUGE,
			Sounds.TICK,
			Sounds.SWOOSH,
			Sounds.LEVEL_COMPLETE,
			Sounds.EMPTY,
			Sounds.WINLEVEL,
			Sounds.LOSEGAME
		]
		
		protected static var _soundsGenerated:Boolean = false;
		public static function get soundsGenerated():Boolean { return _soundsGenerated; }
		
		protected static var _soundGenerationPercent:Number = 0;
		public static function get soundGenerationPercent():Number { return _soundGenerationPercent; }
		
		public function get noiseVolume():Number 
		{
			return _noiseVolume;
		}
		
		public function set noiseVolume(value:Number):void 
		{
			if (!_hasSound) value = 0;
			_noiseVolume = value;
			if (_noiseChannel) {
				var st:SoundTransform = _noiseChannel.soundTransform;
				st.volume = _noiseVolume;
				_noiseChannel.soundTransform = st;
			}
		}
		
		public function get noisePlaying():Boolean 
		{
			return _noisePlaying;
		}
		
		public function set noisePlaying(value:Boolean):void 
		{
			_noisePlaying = value;
			if (!_noisePlaying && _noiseChannel) {
				_noiseChannel.stop();
			}
		}
		
		public function get simulation():Simulation 
		{
			return _simulation;
		}
		
		public function set simulation(value:Simulation):void 
		{
			_simulation = value;
		}
		
		
		protected static var _soundToGenerate:int = 0;
		protected static var _genStarted:Boolean = false;
		
		protected var _noiseChannel:SoundChannel;
		protected var _noisePlaying:Boolean = false;
		protected var _noiseVolume:Number = 0;
		
		public static function generateSounds ():void {
			
			if (_genStarted) return;
			_genStarted = true;
			
			_synths = new Dictionary();
			
			generateNextSound();
			
		}
		
		protected static function generateNextSound ():void {
			
			var s:SfxrSynth;
			
			if (_soundToGenerate < _soundIDs.length) {
				
				if (_soundIDs[_soundToGenerate]) {
					
					s = _synths[_soundIDs[_soundToGenerate]] = new SfxrSynth();
					s.params.setSettingsString(_soundIDs[_soundToGenerate]);
					s.cacheSound(generateNextSound, 10);
				
				}
				
				_soundToGenerate++;
				
				_soundGenerationPercent = _soundToGenerate / _soundIDs.length;
				
				trace("Generating sounds:", Math.floor(_soundGenerationPercent * 100) + "%");
				
				if (_soundGenerationPercent >= 1) _soundsGenerated = true;
				
			}
			
		}
		
		//	Required to replay a mod
		private var music:Sound;
		private var stream:ByteArray;
		private var processor:ModProcessor;
		private var songLoader:URLLoader;
		
        //
        //
        //
        public function SoundManager () {
			
			var s:SfxrSynth;
			
			mainInstance = this;
			
			_ptA = new Point();
			_ptB = new Point();
			
			if (!soundsGenerated && !_genStarted) generateSounds();
			
        }
		
        //
        //
        //
        public function addSound (obj:PhysObj = null, soundID:String = null, allowVolumeAdjust:Boolean = true, volumeFactor:Number = 1):void {
            
			if (_initialized) return;
			if (!_hasSound) return;
			
			if (soundID == Sounds.FRICTION && _noisePlaying) {
				noiseVolume = volumeFactor;
				return;
			}
			
			if (volumeFactor == 0) return;
			
            var volume:Number = 100;
			
			var s:SfxrSynth = _synths[soundID];
			
			if (s == null || s.busy || !s.ready) return;
			
			if (allowVolumeAdjust && (_simulation.view == null || _simulation.view.camera == null)) return;
			
			if (allowVolumeAdjust && obj != null && _simulation.view.camera.watchObject && obj != _simulation.view.camera.watchObject) {
				
				_ptA.x = obj.px;
				_ptA.y = obj.py;
				_ptB.x = _simulation.view.camera.watchObject.px;
				_ptB.y = _simulation.view.camera.watchObject.py;
				
				volume = Math.floor(Math.min(100, 5000 / Math.max(1, (Geom2d.distanceBetween(_ptA, _ptB) - 20))));
				
			}
			
			s.play();
			s.busy = true;
			
			if (s.channel) {
				var st:SoundTransform = s.channel.soundTransform;
				st.volume = (volume / 100) * Math.max(0, Math.min(1, volumeFactor));
				s.channel.soundTransform = st;
			}
			
			if (soundID == Sounds.FRICTION) {
				_noiseChannel = s.channel;
				if (_noiseChannel) {
					_noiseVolume = volumeFactor;
					_noiseChannel.addEventListener(Event.SOUND_COMPLETE, onNoiseComplete, false, 0, true);
					_noisePlaying = true;
				}
			}
			
        }

		public function onNoiseComplete (e:Event):void {
			
			_noiseChannel.removeEventListener(Event.SOUND_COMPLETE, onNoiseComplete);
			_noisePlaying = false;
			addSound(_simulation.focusBody, Sounds.FRICTION, false, _noiseVolume);
			
		}
		
		public function onEnterFrame (e:Event):void {
			
			for each (var synth:Object in _synths) {
				
				SfxrSynth(synth).busy = false;
				
			}
			
		}
        
		//
		//
		//
		public static function stopAll ():void {
			
			if (mainInstance) mainInstance.noisePlaying = false;
			SoundMixer.stopAll();
			
		}
        
		public function loadSong (url:String):void {
			
			unloadSong();
			
			songLoader = new URLLoader();
			songLoader.addEventListener(Event.COMPLETE, onSongLoaded, false, 0, true);
			songLoader.addEventListener(IOErrorEvent.IO_ERROR, onSongError, false, 0, true);
			songLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSongError, false, 0, true);
			songLoader.dataFormat = URLLoaderDataFormat.BINARY;
			songLoader.load(new URLRequest(baseURL + "music/modules/" + url));
			
		}
		
		public function pauseSong ():void {
			
			if (processor && processor.isPlaying) processor.pause();
			
		}
		
		public function resumeSong ():void {
			
			if (processor && !processor.isPlaying) {
				processor.play(music);
				var st:SoundTransform = processor.soundChannel.soundTransform;
				st.volume = 0.5;
				processor.soundChannel.soundTransform = st;
			}
			
		}
		
		public function unloadSong ():void {
			
			if (songLoader) {
				try { songLoader.close(); } catch (e:Error) { };
				songLoader = null;
			}
			
			if (processor) {
				processor.stop();	
				processor = null;
			}
			
			if (music) {
				music = null;
			}
			
		}
		
		
		
		protected function onSongLoaded (e:Event):void {
			
			songLoader.removeEventListener(Event.COMPLETE, onSongLoaded);
			songLoader.removeEventListener(IOErrorEvent.IO_ERROR, onSongError);
			songLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSongError);
			
			if (processor) processor.stop();
			processor = new ModProcessor();
			
			if (songLoader.data) {
				processor.load(songLoader.data);
				processor.loopSong = true;
				processor.stereo = 0.2;
				music = new Sound();
				processor.play(music);
				var st:SoundTransform = processor.soundChannel.soundTransform;
				st.volume = 0.5;
				processor.soundChannel.soundTransform = st;
			}
			
		}
		
		protected function onSongError (e:Event):void {
			
			trace("Song load error!");
			
		}
		
    }
}
