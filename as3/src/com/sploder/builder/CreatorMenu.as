package com.sploder.builder 
{
	
	import com.sploder.builder.ui.DialogueFileManager;
	import com.sploder.asui.BButton;
	import com.sploder.asui.Component;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setInterval;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CreatorMenu {
		
		protected var _creator:Creator;

		protected var _saveToggle:BButton;
		protected var _saveAsToggle:BButton;
		protected var _publishToggle:BButton;

		public function get saveEnabled():Boolean { return _saveAsToggle.enabled; }
		public function set saveEnabled(value:Boolean):void 
		{
			if (value) _saveToggle.enable();
			else _saveToggle.disable();	
		}
		
		public function get saveAsEnabled():Boolean { return _saveAsToggle.enabled; }
		public function set saveAsEnabled(value:Boolean):void 
		{
			if (value) _saveAsToggle.enable();
			else _saveAsToggle.disable();
		}
		
		public function get publishEnabled():Boolean { return _publishToggle.enabled; }
		public function set publishEnabled(value:Boolean):void 
		{
			if (value) _publishToggle.enable();
			else _publishToggle.disable();
		}
		

		//
		//
		public function CreatorMenu(creator:Creator) {
			
			init(creator);
			
		}
		
		//
		//
		protected function init (creator:Creator):void {
			
			_creator = creator;
			
			var b:Array = _creator.ui.menu.childNodes;
			
			for (var i:int = 0; i < b.length; i++) {
				
				if (b[i] is BButton) {
					
					switch (b[i].value) {
						
						case "New":
							break;
							
						case "Load":
							break;
						
						case "Save":
							_saveToggle = b[i];
							break;
							
						case "Save As":
							_saveAsToggle = b[i];
							break;
							
						case "Test":
							break;
							
						case "Publish":
							_publishToggle = b[i];
							break;
							
					}
					
					BButton(b[i]).addEventListener(Component.EVENT_CLICK, onClick);
					
				}
			}

		}
		
		//
		//
		protected function onClick (e:Event):void {
			
			var buttonValue:String = e.target.value;

			if (e.target.name == "btn") buttonValue = e.target.parent.name;

			_creator.project.savingAs = false;
			
			switch (buttonValue) {
				
				case "New":
					requestNewProject();
					break;
					
				case "Load":
					requestLoadProject();
					break;
				
				case "Save":
					if (saveEnabled) _creator.project.saveProject();
					break;
					
				case "Save As":
					_creator.project.savingAs = true;
					if (saveAsEnabled) _creator.project.saveProjectAs();
					break;
					
				case "Test":
					_creator.project.testProject();
					break;
					
				case "Publish":
					if (publishEnabled) _creator.project.publishGame();
					break;
				
			}
	
		}
		
		
		protected function requestNewProject ():void {
			
			if (_creator.model.objects.length > 0) {
				
				_creator.uiController.confirm(
					_creator.project, 
					_creator.project.newProject, 
					null, 
					"Creating a new game will erase any unsaved game you are working on."
					);
				
			} else {
				
				_creator.project.newProject();
				
			}
			
		}
		
		protected function requestLoadProject ():void {
			
			_creator.ui.ddManager.title = "Load a Game";
			_creator.ui.ddManager.mode = DialogueFileManager.MODE_LOAD;
			
			if (!_creator.demo && _creator.model.objects.length > 0) {
				
				_creator.uiController.confirm(
					_creator.ui.ddManager, 
					_creator.ui.ddManager.loadList,
					null,
					"Loading an existing game will erase any unsaved game you are working on."
					);
				
			} else {
				
				_creator.ui.ddManager.loadList();
				
			}
			
		}
	
	}
	
}