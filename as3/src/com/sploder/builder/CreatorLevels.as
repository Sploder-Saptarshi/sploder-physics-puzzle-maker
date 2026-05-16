package com.sploder.builder 
{
	import com.sploder.asui.ColorTools;
	import com.sploder.asui.Component;
	import com.sploder.builder.model.ModelObjectSprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.xml.XMLDocument;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class CreatorLevels
	{
		protected var _creator:Creator;
		
		protected var _currentLevel:uint = 0;
		public function get currentLevel():uint { return _currentLevel; }
		
		public function get currentLevelName ():String {
			
			return "Level " + (_currentLevel + 1);
			
		}
		
		public function get totalLevels():uint { return _levelData.length; }
		
		protected var _levelData:Array;
		protected var _levelEnv:Array;
		
		protected var _defaultNum:uint;
		
					
		//
		//
		public function CreatorLevels (creator:Creator) 
		{
			init(creator);
		}
		
		//
		//
		protected function init (creator:Creator):void {
			
			_creator = creator;
						
			_levelData = [];
			_levelEnv = [];
			
			_creator.ui.levelSelector.addEventListener(Component.EVENT_CHANGE, changeLevel);
			_creator.ui.addLevelButton.addEventListener(Component.EVENT_CLICK, addLevel);
			_creator.ui.removeLevelButton.addEventListener(Component.EVENT_CLICK, removeLevel);
			_creator.ui.removeLevelButton.disable();
			_creator.ui.moveLevelButton.addEventListener(Component.EVENT_CLICK, moveLevel);
			
			_creator.project.addEventListener(CreatorProject.EVENT_LOAD, onProjectLoaded);
			_creator.project.addEventListener(CreatorProject.EVENT_NEW, reset);
			
		}
		
		
		public function loadCurrentLevel ():void {
			
			if (_creator.model) {
				_creator.model.clear();
				_creator.modelController.history.clear();
				if (ModelObjectSprite.library != null) ModelObjectSprite.library.cleanTextureQueue();
				_creator.model.fromString(exportLevelData(_currentLevel));
			}
			
		}
		
		public function loadCurrentEnvironment ():void {
			
			if (_creator.environment) {
				_creator.environment.setDefaults();
				_creator.environment.fromString(exportEnvironmentData(_currentLevel));
			}
			
		}
		
		//
		//
		public function saveCurrentLevel ():void {
			
			_levelData[_currentLevel] = _creator.model.toString();

		}
		
		//
		//
		public function saveCurrentEnvironment ():void {
			
			_levelEnv[_currentLevel] = _creator.environment.toString();
			
		}
		
		//
		//
		public function clearCurrentLevel ():void {
			
			_levelData[_currentLevel] = "";
			
		}
		
		//
		//
		public function clearCurrentEnvironment ():void {
			
			_levelEnv[_currentLevel] = "";
			
		}		
		
		//
		//
		public function reset (e:Event = null):void {
			
			_creator.ui.levelSelector.removeEventListener(Component.EVENT_CHANGE, changeLevel);
			
			_levelData = [];
			_levelData.push("");
			_currentLevel = 0;
			_creator.ui.levelSelector.choices = ["Level 1"];
			
			_creator.ui.addLevelButton.enable();
			_creator.ui.removeLevelButton.disable();
			_creator.ui.moveLevelButton.disable();
			_creator.environment.setDefaults();
			
			_levelEnv = [];
			_levelEnv.push(_creator.environment.toString());
			
			loadCurrentLevel();
			loadCurrentEnvironment();
			
			_creator.ui.levelSelector.addEventListener(Component.EVENT_CHANGE, changeLevel);

		}
		
		//
		//
		protected function onProjectLoaded (e:Event):void {
			
			_creator.ui.levelSelector.removeEventListener(Component.EVENT_CHANGE, changeLevel);
			
			_levelData = [];
			_levelEnv = [];
			_currentLevel = 0;
			var levels:Array = [];
			
			for (var i:int = 0; i < _creator.project.getTotalLevels(); i++) {
				importLevelData(i);
				importEnvironmentData(i);
				levels.push("Level " + (i + 1));
			}
		
			_creator.ui.levelSelector.choices = levels;
			_creator.ui.levelSelector.select(0);
			
			if (_levelData.length > 1) _creator.ui.removeLevelButton.enable();
			else _creator.ui.removeLevelButton.disable();
			
			if (_levelData.length < 9) _creator.ui.addLevelButton.enable();
			else _creator.ui.addLevelButton.disable();
			
			_creator.ui.moveLevelButton.disable();
			
			loadCurrentLevel();
			loadCurrentEnvironment();
			
			_creator.ui.levelSelector.addEventListener(Component.EVENT_CHANGE, changeLevel);
			
		}
		
		//
		//
		public function importLevelData (level:int = -1):void {
			
			if (level >= 0) _levelData[level] = _creator.project.getObjects(level);
			
		}
		
		//
		public function importEnvironmentData (level:int = -1):void {
			
			if (level >= 0) _levelEnv[level] = _creator.project.getEnvironment(level);
			
		}
		
		//
		//
		public function exportLevelData (level:int):String {
			
			if (_levelData.length > level) return _levelData[level];
			
			return "";
			
		}
		
		//
		//
		public function exportEnvironmentData (level:int):String {
			
			if (_levelEnv.length > level) return _levelEnv[level];
			
			return "";
			
		}
		
		//
		//
		public function exportLevels ():Array {
			
			var lv:Array = [];
			
			for (var i:int = 0; i < _levelData.length; i++) {
				
				lv.push(exportLevelData(i));
				
			}
			
			return lv;
			
		}
		
		//
		//
		public function exportEnvironments ():Array {
			
			var lv:Array = [];
			
			for (var i:int = 0; i < _levelEnv.length; i++) {
				
				lv.push(exportEnvironmentData(i));
				
			}
			
			return lv;
			
		}
		
		//
		//
		public function exportGraphics ():Object {
			
			var graphics:Object = { };
			
			for (var j:int = 0; j < _levelData.length; j++) {
				
				var level:Array = exportLevelData(j).split("$");
				var level_objects:Array = String(level[0]).split("|");
			
				for (var i:int = 0; i < level_objects.length; i++) {
					
					if (level_objects[i] && String(level_objects[i]).length) {
						
						var objProps:Array = level_objects[i].split("#")[5].split(";");
						
						if (parseInt(objProps[18]) > 0) {
							var name:String = parseInt(objProps[18]) + "_" + parseInt(objProps[19]);
							graphics[name] = Textures.getOriginal(name);
						}
						
					}
					
				}
				
			}
			
			return graphics;
			
		}
		
		//
		//
		protected function changeLevel (e:Event):void {
			
			if (_creator.ui.levelSelector != null) {
				
				if (_creator.ui.levelSelector.value.length > 0) {
					
					var newLevel:uint = parseInt(_creator.ui.levelSelector.value.split(" ")[1]) - 1;
					
					if (newLevel != _currentLevel) {
						
						saveCurrentLevel();
						saveCurrentEnvironment();
						
						_currentLevel = newLevel;
						
						loadCurrentLevel();
						loadCurrentEnvironment();
						
						if (_currentLevel == 0) _creator.ui.moveLevelButton.disable();
						else _creator.ui.moveLevelButton.enable();
						
					}
					
				}
				
			}
			
		}
		
		//
		//
		protected function addLevel (e:Event):void {
			
			saveCurrentLevel();
			saveCurrentEnvironment();
			
			_creator.ui.levelSelector.removeEventListener(Component.EVENT_CHANGE, changeLevel);
			
			var levels:Array = _creator.ui.levelSelector.choices.concat();
			levels.push("Level " + (levels.length + 1));
			_creator.ui.levelSelector.choices = levels;
			
			_creator.ui.removeLevelButton.enable();
			if (levels.length >= 9) _creator.ui.addLevelButton.disable();
			
			_levelData.push("");
			_levelEnv.push("");
			
			_currentLevel = _levelData.length - 1;
			
			if (_currentLevel == 0) _creator.ui.moveLevelButton.disable();
			else _creator.ui.moveLevelButton.enable();
			
			loadCurrentLevel();
			loadCurrentEnvironment();
			
			_creator.ui.levelSelector.addEventListener(Component.EVENT_CHANGE, changeLevel);
			
			_creator.uiController.notice("You just added a level to your game! You can switch between levels to edit them one at a time.");
			
		}
		
		//
		//
		protected function removeLevel (e:Event):void {
			
			_creator.uiController.confirm(
				this, 
				doRemoveLevel, 
				null, 
				"Removing this level will remove all of the contents of the level."
				);
			
		}
		
		public function doRemoveLevel ():void {
			
			_creator.ui.levelSelector.removeEventListener(Component.EVENT_CHANGE, changeLevel);
				
			var levels:Array = _creator.ui.levelSelector.choices.concat();
			levels.pop();
			
			_creator.ui.levelSelector.choices = levels;
			
			_levelData.splice(_currentLevel, 1);
			_levelEnv.splice(_currentLevel, 1);
			
			if (_levelData.length > 1) _creator.ui.removeLevelButton.enable();
			else _creator.ui.removeLevelButton.disable();
		
			if (_levelData.length < 9) _creator.ui.addLevelButton.enable();
			
			_currentLevel = Math.max(0, Math.min(_currentLevel, _levelData.length - 1));
			
			if (_currentLevel == 0) _creator.ui.moveLevelButton.disable();
			else _creator.ui.moveLevelButton.enable();
			
			loadCurrentLevel();
			loadCurrentEnvironment();

			_creator.ui.levelSelector.addEventListener(Component.EVENT_CHANGE, changeLevel);
			
		}

		protected function moveLevel (e:Event):void {
			
			if (_currentLevel > 0) {
				
				saveCurrentLevel();
				
				var prevLevel:String = _levelData[_currentLevel - 1];
				_levelData[_currentLevel - 1] = _levelData[_currentLevel];
				_levelData[_currentLevel] = prevLevel;
				
				var prevEnv:String = _levelEnv[_currentLevel - 1];
				_levelEnv[_currentLevel - 1] = _levelEnv[_currentLevel];
				_levelEnv[_currentLevel] = prevEnv;
				
				_currentLevel -= 1;
				
				_creator.ui.levelSelector.removeEventListener(Component.EVENT_CHANGE, changeLevel);
				
				_creator.ui.levelSelector.select(_currentLevel);
				
				_creator.ui.levelSelector.addEventListener(Component.EVENT_CHANGE, changeLevel);
				
				loadCurrentLevel();
				loadCurrentEnvironment();
				
				_creator.project.saveLocalProject();
				
			}
			
		}
		
	}

}