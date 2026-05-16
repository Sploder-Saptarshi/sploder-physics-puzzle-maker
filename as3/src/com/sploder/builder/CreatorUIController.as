package com.sploder.builder 
{
	import com.sploder.builder.model.Environment;
	import com.sploder.builder.model.ModelController;
	import com.sploder.builder.model.ModelObject;
	import com.sploder.builder.model.ModelObjectContainer;
	import com.sploder.builder.model.ModelObjectProperties;
	import com.sploder.builder.model.ModelObjectSprite;
	import com.sploder.builder.model.ModelSelection;
	import com.sploder.builder.model.Modifier;
	import com.sploder.game.effect.BackgroundEffect;
	import com.sploder.asui.ClipButton;
	import com.sploder.asui.Collection;
	import com.sploder.asui.Component;
	import com.sploder.asui.Prompt;
	import com.sploder.asui.Tagtip;
	import com.sploder.asui.ToggleButton;
	import com.sploder.asui.TweenManager;
	import com.sploder.util.Geom2d;
	import com.sploder.util.Key;
	import com.sploder.util.ScrollHelper;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Geoff
	 */
	public class CreatorUIController
	{
		
		protected var _creator:Creator;
		protected var _currentToolState:String = CreatorUIStates.TOOL_SELECT;
		public function get currentToolState():String { return _currentToolState; }
		
		protected var _currentTray:Collection;
		protected var _m:Matrix;
		public var scrollHelper:ScrollHelper;
		
		protected var _tweener:TweenManager;
		public function get tweener():TweenManager { return _tweener; }
		
		public var keyboardEnabled:Boolean = true;
		private var _prefabAppearanceNoticeSent:Boolean = false;
		
		private var _ui:CreatorUI;
		private var _mc:ModelController;
		
		public function get isZoomedOut ():Boolean {
			
			return _creator.model.container.scaleX < 1;
			
		}
		
		public function CreatorUIController(main:Creator) 
		{
			super();
			init(main);
			
		}
		
		protected function init (main:Creator):void {
			
			_creator = main;
			_m = new Matrix();
			_tweener = new TweenManager(true);
	
		}
		
		public function connect ():void {
			
			var i:int;
			
			_ui = _creator.ui;
			_mc = _creator.modelController;
			
			_ui.trayButtons.addEventListener(Component.EVENT_CHANGE, onTrayMenuChange);
			
			for (var tray:String in _ui.trays) {
				if (tray != CreatorUIStates.TRAY_PREFABS) _ui.trays[tray].addEventListener(Component.EVENT_DROP, onDragFromTray);
				if (tray != CreatorUIStates.TRAY_PREFABS) _ui.trays[tray].addEventListener(Component.EVENT_MOVE, onDragFromTrayMove);
				_ui.trays[tray].addEventListener(Component.EVENT_DROP, onDropFromTray);
			}
			
			_currentTray = _ui.trays[CreatorUIStates.TRAY_PREFABS];
			
			_ui.trayPager.addEventListener(Component.EVENT_CLICK, onClick);
			
			_ui.tools.addEventListener(Component.EVENT_CLICK, onClick);
			
			_ui.shapes.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.constraints.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.materials.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.strengths.addEventListener(Component.EVENT_CLICK, onClick);
			
			_ui.moveLock.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.layersButton.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.actionsButton.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.layersButtons.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.moveGroup.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.delSelection.addEventListener(Component.EVENT_CLICK, onClick);
			
			_ui.fills.addEventListener(Component.EVENT_SELECT, onClick);
			_ui.lines.addEventListener(Component.EVENT_SELECT, onClick);
			_ui.textures.addEventListener(Component.EVENT_SELECT, onClick);
			_ui.zlayers.addEventListener(Component.EVENT_SELECT, onClick);
			_ui.opaque.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.scribble.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.graphicsPanelToggle.addEventListener(Component.EVENT_CLICK, onClick);
			
			_ui.animationToggle.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.ddAnimation.addEventListener(Component.EVENT_BLUR, onBlur);
			_ui.animNormal.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.animFlip.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.animWalk.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.animRotate.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.animRotateWalk.addEventListener(Component.EVENT_CLICK, onClick);
			
			_ui.advancedTextureToggle.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.layerViewToggle.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.ddLayerView.addEventListener(Component.EVENT_BLUR, onBlur);
			for (i = 0; i < 5; i++) {
				_ui.layerViewButtons[i].addEventListener(Component.EVENT_CLICK, onClick);
			}
			_ui.layerDefaultButtons.addEventListener(Component.EVENT_CLICK, onClick);
			updateLayerViewDisplay();
			
			_mc.selection.addEventListener(Event.CHANGE, onChange);
			_creator.model.modifiers.addEventListener(Event.SELECT, onModifierSelect);
			
			for (i = 0; i < 5; i++) {
				ToggleButton(_ui.layers["p_" + i]).addEventListener(Component.EVENT_CLICK, onPassthruButtonClick);
			}
			
			_ui.world.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.bkgd.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.goals.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.music.addEventListener(Component.EVENT_CLICK, onClick);
			_ui.clipboard.addEventListener(Component.EVENT_CLICK, onClick);
			
			_creator.environment.addEventListener(Event.CHANGE, onEnvironmentChange);
			
			_ui.testEndButton.addEventListener(Component.EVENT_CLICK, onClick);
			
			_ui.undoButton.addEventListener(MouseEvent.CLICK, undo);
			Tagtip.connectButton(_ui.undoButton, "Undo last edit (CTRL-Z)");
			_ui.redoButton.addEventListener(MouseEvent.CLICK, redo);
			Tagtip.connectButton(_ui.redoButton, "Redo last undo (CTRL-Y)");
			
			_ui.helpButton.addEventListener(MouseEvent.CLICK, showHelp);
			
			_creator.project.addEventListener(CreatorProject.EVENT_NEW, onProjectChange);
			_creator.project.addEventListener(CreatorProject.EVENT_LOAD, onProjectChange);
			
			drawBackground();
			
			scrollHelper = new ScrollHelper();
			scrollHelper.hScroller = _ui.hScroll;
			scrollHelper.vScroller = _ui.vScroll;
			
			_ui.zoomToggle.addEventListener(Component.EVENT_CLICK, onClick);
			
			Component.mainStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			Component.mainStage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			
			_creator.model.modifiers.addEventListener(Event.CLEAR, onModifierDelete, false, 0, true);
			
			_mc.history.addEventListener(Event.CHANGE, onHistoryChange);
			onHistoryChange();
			
			if (_ui.stage.stageWidth < 720) {
				notice("<font color=\"#FFFFFF\">Yikes! Your screen is too small!</font> Your browser may not have it's zoom settings set at 100%. Try changing your browser settings and start again.");
			}
			
			_ui.ddGraphics.connect();
			
		}
		
		protected function zoomIn ():void {
			
			if (isZoomedOut) {
				if (_ui.zoomToggle.toggled) _ui.zoomToggle.toggle();
				_creator.model.container.scaleX = _creator.model.container.scaleY = 1;
				_ui.playfieldContainer.x = 136;
				_ui.playfieldContainer.contentX = 0;
				_ui.playfieldContainer.contentY = 0;
				_ui.vScroll.reset();
				_ui.hScroll.reset();
				_ui.vScroll.show();
				_ui.hScroll.show();
			}
			
		}
		
		protected function zoomOut ():void {
			
			if (!isZoomedOut && (_creator.environment.size != Environment.SIZE_NORMAL)) {
				if (!_ui.zoomToggle.toggled) _ui.zoomToggle.toggle();
				_creator.model.container.scaleX = _creator.model.container.scaleY = 0.5;
				_ui.playfieldContainer.x = 180;
				_ui.playfieldContainer.contentX = 0;
				_ui.playfieldContainer.contentY = 0;
				_ui.vScroll.hide();
				_ui.hScroll.hide();
			}
			
		}
		
		public function confirm (context:Object, callback:Function, args:Array = null, message:String = ""):void {
			
			_ui.ddConfirm.confirm(context, callback, args, message);
			
		}
		
		public function alert (message:String = ""):void {
			
			if (message.length) _ui.ddAlert.alert(message);
			
		}
		
		public function notice (message:String = ""):void {
			
			if (message.length) _ui.notice.show(message);
			
		}
		
		protected function onModifierSelect (e:Event):void {
			
			if (_creator.model.modifiers.focusObject != null) {
				
				var m:Modifier = _creator.model.modifiers.focusObject;
				
				switch (m.props.type) {
					
					case CreatorUIStates.MODIFIER_THRUSTER:
					case CreatorUIStates.MODIFIER_ADDER:
					case CreatorUIStates.MODIFIER_SPAWNER:
					case CreatorUIStates.MODIFIER_FACTORY:
					case CreatorUIStates.MODIFIER_MOVER:
					case CreatorUIStates.MODIFIER_ARCADEMOVER:
					case CreatorUIStates.MODIFIER_JUMPER:
					case CreatorUIStates.MODIFIER_SLIDER:
						
						_ui.modifierPropertiesEditor.show(m);
						return;
						
				}
				
			}
				
			if (_ui.modifierPropertiesEditor.showing) {
				_ui.modifierPropertiesEditor.hide();
			}

		}
		
		protected function onModifierDelete (e:Event):void {
			
			if (_ui.modifierPropertiesEditor.showing) {
				_ui.modifierPropertiesEditor.hide();
			}			
			
		}
		
		protected function onChange (e:Event):void {
				
			switch (e.target) {
				
				case (_mc.selection):
					
					updateSubToolsDisplay();
					break;
					
			}
			
		}
		
		protected function onEnvironmentChange (e:Event = null):void {
			
			if (_creator.environment.size == Environment.SIZE_NORMAL) {
				
				if (_creator.model.width != 640) {
					if (e) zoomIn();
					Styles.playfieldStyle.bgGradientRatios = [0, 100, 200];
					_ui.playfieldContainer.x = 180;
					_ui.playfieldContainer.resizeCell(640, 480);
					_ui.playfield.resizeCell(640, 480);
					_ui.vScroll.reset();
					_ui.hScroll.reset();
					_ui.vScroll.hide();
					_ui.hScroll.hide();
					_ui.zoomToggle.hide();
					_creator.model.resize(640, 480);
				}
				
			} else {
				
				if (_creator.model.width != 1280) {
					if (e) zoomIn();
					_ui.playfieldContainer.x = 136;
					Styles.playfieldStyle.bgGradientRatios = [0, 180, 255];
					_ui.playfieldContainer.resizeCell(720, 480);
					_ui.playfield.resizeCell(1304, 984);
					_ui.vScroll.onTargetCellChange();
					_ui.hScroll.onTargetCellChange();
					_ui.vScroll.show();
					_ui.hScroll.show();
					_ui.vScroll.x = 838;
					_ui.vScroll.y = 92;
					_ui.hScroll.x = 138;
					_ui.hScroll.y = 548;
					_ui.zoomToggle.show();
					var g:Graphics = _ui.playfield.bkgd.graphics;
					g.beginFill(0x003366, 1);
					g.drawRect(0, 960, 1304, 24);
					g.drawRect(1280, 0, 24, 960);
					g.endFill();
					_creator.model.resize(1280, 960);
				}
				
			}
			
			drawBackground();
			
		}
		
		protected function onHistoryChange (e:Event = null):void {
			
			_ui.undoButton.enabled = _mc.history.hasUndo;
			_ui.undoButton.alpha = (_mc.history.hasUndo) ? 1 : 0.5;
			
			_ui.redoButton.enabled = _mc.history.hasRedo;
			_ui.redoButton.alpha = (_mc.history.hasRedo) ? 1 : 0.5;
			
		}
		
		protected function drawBackground ():void {
			
			var w:uint;
			var h:uint;
			var e:BackgroundEffect = _creator.model.backgroundEffect;
			
			e.type = _creator.environment.bgEffect;
			
			switch (_creator.environment.size) {
				case Environment.SIZE_NORMAL:
					w = 640;
					h = 480;
					e.setSize(320, 240);
					e.scaleX = e.scaleY = 2;
					_m.createGradientBox(640, 480, Geom2d.dtr * 90);
					break;
				case Environment.SIZE_DOUBLE:
					w = 1280;
					h = 960;
					e.setSize(640, 480);
					e.scaleX = e.scaleY = 2;
					_m.createGradientBox(1280, 960, Geom2d.dtr * 90);
					break;
				case Environment.SIZE_FOLLOW:
					w = 1280;
					h = 960;
					e.setSize(640, 480);
					e.scaleX = e.scaleY = 2;
					_m.createGradientBox(1280, 960, Geom2d.dtr * 90);
					break;	
			}
			
			var g:Graphics = _creator.model.background.graphics;
			
			g.clear();
			g.beginGradientFill(GradientType.LINEAR, [_creator.environment.bgColorTop, _creator.environment.bgColorBottom], [1, 1], [0, 255], _m);
			g.drawRect(0, 0, w, h);
			g.endFill();
			
		}
		
		private function onProjectChange (e:Event):void {
			
			_mc.selection.clear();
			
			if (e.type == CreatorProject.EVENT_NEW) {
				_mc.history.clear();
			} else if (e.type == CreatorProject.EVENT_LOAD) {
				_mc.history.clear();
				_mc.history.record();
			}
			
		}
		
		protected function onTrayMenuChange (e:Event):void {
			
			for (var tray:String in _ui.trays) {
				_ui.trays[tray].hide();
			}
			
			_currentTray = _ui.trays[_ui.trayButtons.value];
			_ui.trays[_ui.trayButtons.value].show();
			
			if (_ui.trayPager.toggled) {
				_ui.trayPager.toggle();
			}
				
			_tweener.removeTweensOnObject(_currentTray);
			_currentTray.contentY = 0;
			
		}
		
		protected function onMouseOut (e:Event):void {
			
			switch (e.target) {
				
				case (_ui.layersMenu):
					
					_ui.layersMenu.hide();
					break;
				
			}
			
		}
		
		protected function onClick (e:Event):void {
			
			var i:int;
			var tval:Boolean;
			var slen:int = _mc.selection.length;
			var o:ModelObject;
			if  (_mc.selection.length > 0) o = _mc.selection.objects[0];
			
			switch (e.target) {
				
				case (_ui.menuItems.test):
					_creator.model.modifiers.focusObject = null;
					_mc.selection.clear();
					_creator.test();
					break;
					
				case (_ui.trayPager):
					if (_ui.trayPager.toggled) {
						_tweener.createTween(_currentTray, "contentY", _currentTray.contentY, 0 - (_currentTray.contentHeight - _currentTray.height) - 3, 0.25);
					} else {
						_tweener.createTween(_currentTray, "contentY", _currentTray.contentY, 0, 0.25);
					}
					break;
					
				case (_ui.tools):
					_currentToolState = Component(e.target).value;
					_ui.ddGraphics.hide();
					updateSubToolsDisplay();
					break;
					
				case (_ui.constraints):
				case (_ui.materials):
				case (_ui.strengths):
					if (slen > 0) {
						_mc.updateSelection(e.target.name);
						if (o && o.props && o.props.constraint == CreatorUIStates.MOVEMENT_STATIC) _ui.moveLock.disable();
						else _ui.moveLock.enable();
					}
					break;
					
				case (_ui.moveLock):
					if (_ui.moveLock.toggled) {
						_mc.lockSelectedObjects();
					} else {
						_mc.unlockSelectedObjects();
					}
					break;
					
				case (_ui.layersButton):
					if (_ui.layersMenu.visible) {
						_ui.layersMenu.hide();
					} else {
						_ui.layersMenu.show();
					}
					break;
					
				case (_ui.actionsButton):
					_ui.ddActionMatrix.show();
					break;
					
				case (_ui.layersButtons):
					_mc.updateLayersForSelection();
					break;
						
				case (_ui.moveGroup):
					if (slen > 1) {
						if (_mc.selection.selectionIsSingleGroup()) {
							_mc.ungroupSelectedObjects();
						} else {
							_mc.groupSelectedObjects();
						}
					}
					break;
					
				case (_ui.delSelection):
					var dsl:int = _mc.selection.length;	
					if (dsl > 0) {
						confirm(
							_mc.selection, 
							_mc.selection.destroyObjects,
							null,
							(dsl == 1) ? "Do you really want to delete this object?" :
								"Do you really want to delete these " + dsl + " objects?"
							);
					}
					break;
					
				case (_ui.fills):
					if (_ui.fills.value == CreatorUIStates.NONE) _mc.paintFillColor = -1;
					else _mc.paintFillColor = parseInt(_ui.fills.value);
					_mc.updateSelection(CreatorUIStates.DECORATE_FILL);
					break;
					
				case (_ui.lines):
					if (_ui.lines.value == CreatorUIStates.NONE) _mc.paintLineColor = -1;
					else if (_ui.lines.value == CreatorUIStates.GLOW) _mc.paintLineColor = -2;
					else _mc.paintLineColor = parseInt(_ui.lines.value);
					_mc.updateSelection(CreatorUIStates.DECORATE_LINE);
					break;
					
				case (_ui.textures):
					_mc.paintTexture = CreatorUIStates.textures_iconmap.indexOf(_ui.textures.value);
					_mc.updateSelection(CreatorUIStates.TEXTURE);
					_ui.animationToggle.disable();
					break;
					
				case (_ui.zlayers):
					_mc.paintLayer = parseInt(_ui.zlayers.value.split("icon_layer_").join(""));
					_mc.updateSelection(CreatorUIStates.DECORATE_ZLAYER);
					break;
					
				case (_ui.opaque):
					_mc.paintOpaque = (_ui.opaque.toggled) ? 0 : 1;
					_mc.updateSelection(CreatorUIStates.OPAQUE);
					break;
				
				case (_ui.scribble):
					_mc.paintScribble = (_ui.scribble.toggled) ? 1 : 0;
					_mc.updateSelection(CreatorUIStates.SCRIBBLE);
					break;
					
				case (_ui.graphicsPanelToggle):
					if (_ui.graphicsPanelToggle.toggled) _ui.ddGraphics.show();
					else _ui.ddGraphics.hide();
					break;
					
				case (_ui.animationToggle):
					if (_ui.animationToggle.toggled) {
						_ui.ddAnimation.show();
						updateAnimationDisplay();
					} else {
						_ui.ddAnimation.hide();
					}
					break;
					
				case (_ui.advancedTextureToggle):
					if (_ui.advancedTextureToggle.toggled) {
						_ui.ddTextureGen.show();
					} else {
						_ui.ddTextureGen.hide();
					}
					break;
					
				case (_ui.layerViewToggle):
					if (_ui.layerViewToggle.toggled) {
						_ui.ddLayerView.show();
						updateLayerViewDisplay();
					} else {
						_ui.ddLayerView.hide();
					}
					break;
					
				case (_ui.layerDefaultButtons):
					if (_ui.layerDefaultButtons.value != null)
					{
						var default_layer:int = parseInt(_ui.layerDefaultButtons.value.split(" ")[1]);
						_mc.paintLayer = default_layer;
					}
					break;
					
				case (_ui.animNormal):
					if (o && o.props.graphic > 0) {
						if (o.props.animation > 1) o.props.animation = 1;
						o.props.graphic_flip = 0;
					}
					break;
					
				case (_ui.animFlip):
					if (o && o.props.graphic > 0) {
						if (o.props.animation > 1) o.props.animation = 1;
						o.props.graphic_flip = 1;
					}
					break;
				
				case (_ui.animWalk):
					if (o && o.props.graphic > 0) {
						o.props.animation = 2;
						o.props.graphic_flip = 1;
					}
					break;
					
				case (_ui.animRotate):
					if (o && o.props.graphic > 0) {
						o.props.animation = 3;
						o.props.graphic_flip = 0;
						o.props.constraint = CreatorUIStates.MOVEMENT_SLIDE;
					}
					break;
				
				case (_ui.animRotateWalk):
					if (o && o.props.graphic > 0) {
						o.props.animation = 4;
						o.props.graphic_flip = 0;
						o.props.constraint = CreatorUIStates.MOVEMENT_SLIDE;
					}
					break;
					
				case (_ui.world):
					_ui.ddEnvironment.show();
					break;
					
				case (_ui.bkgd):
					_ui.ddBackground.show();
					break;
					
				case (_ui.zoomToggle):
					if (isZoomedOut) {
						zoomIn();
					} else {
						zoomOut();
					}
					break;
					
				case (_ui.goals):
					_ui.ddGoals.show();
					break;
					
				case (_ui.music):
					_ui.ddMusic.show();
					break;
					
				case (_ui.clipboard):
					
					if (_mc.selection && _mc.selection.length) {
						copy();
					}
					_ui.ddClipboard.show();
					break;
					
				case (_ui.testEndButton):
					_creator.testEnd();
					break;
					
			}
			
			if (e.target.name != null && e.target.name.indexOf("layerview_") == 0)
			{
				var layer_button:ClipButton = e.target as ClipButton;
				var layer_num:int = parseInt(layer_button.name.charAt(10));
				_creator.model.setLayerView(layer_num, layer_button.toggled);
			}
			
		}
		
		protected function onBlur (e:Event):void {
			
			switch (e.target) {
				
				case _ui.ddAnimation:
					if (_ui.animationToggle.toggled) _ui.animationToggle.toggle();
					break;
				
				case _ui.ddLayerView:
					if (_ui.layerViewToggle.toggled) _ui.layerViewToggle.toggle();
					break;
			}
			
		}
		
		protected function onKeyDown (e:KeyboardEvent):void {
			
			if (!keyboardEnabled) return;
			
			var sel:ModelSelection = _mc.selection;
			
			switch (e.keyCode) {
				
				case (Keyboard.UP):
					sel.moveSelection(0, -10);
					break;
					
				case (Keyboard.DOWN):
					sel.moveSelection(0, 10);
					break;
					
				case (Keyboard.LEFT):
					sel.moveSelection(-10, 0);
					break;
					
				case (Keyboard.RIGHT):
					sel.moveSelection(10, 0);
					break;
				
			}
			
		}
		
		protected function onKeyUp (e:KeyboardEvent):void {
			
			if (!keyboardEnabled) return;
			
			var sel:ModelSelection = _mc.selection;
			
			switch (e.keyCode) {
				
				case (Keyboard.DELETE):
					var dsl:int = sel.length;	
					if (dsl > 0) {
						confirm(
							sel, 
							sel.destroyObjects,
							null,
							(dsl == 1) ? "Do you really want to delete this object?" :
								"Do you really want to delete these " + dsl + " objects?"
							);
					}
					break;
					
				case (Key.char("a")):
					if (e.ctrlKey) {
						sel.clear();
						sel.addObjects(_creator.model.objects);
					}
					break;
					
				case (Key.char("d")):
					if (e.ctrlKey) {
						sel.clear();
					}
					break;
					
				case (Key.char("c")):
					if (e.ctrlKey) copy();
					break;
					
				case (Key.char("x")):
					if (e.ctrlKey) cut();
					break;
					
				case (Key.char("v")):
					if (e.ctrlKey) paste();
					break;
					
				case (Key.char("z")):
					if (e.ctrlKey) undo();
					break;
					
				case (Key.char("y")):
					if (e.ctrlKey) redo();
					break;
								
					
			}
			
			
		}
		
		public function copy ():void {
			
			var sel:ModelSelection = _mc.selection;
			
			if (sel.length > 0) {
				_mc.clipboard = _creator.model.selectionToString(sel.objects);
				System.setClipboard(_mc.clipboard);
			}
			
			CreatorUI.stage.focus = Component.mainStage;

		}
		
		public function cut ():void {
			
			var sel:ModelSelection = _mc.selection;
			
			if (sel.length > 0) {
				_mc.history.record();
				_mc.clipboard = _creator.model.selectionToString(sel.objects);
				System.setClipboard(_mc.clipboard);
				sel.destroyObjects();
				notice("Your selection was cut from the game level and placed in the clipboard. Hit CTRL-V to paste it back into the scene.");
			}
			
			CreatorUI.stage.focus = Component.mainStage;
			
		}
		
		public function undo (e:MouseEvent = null):void {
			
			_mc.history.stepBack();
			
			CreatorUI.stage.focus = Component.mainStage;
			
		}
		
		public function redo (e:MouseEvent = null):void {
			
			_mc.history.stepForward();
			
			CreatorUI.stage.focus = Component.mainStage;
			
		}
		
		public function paste (placeAtMouse:Boolean = false, objectString:String = "", retainLayers:Boolean = false):void {
			
			var sel:ModelSelection = _mc.selection;
			var is_empty:Boolean = _creator.model.objects.length == 0;
			
			var newString:String = (objectString.length) ? objectString : _mc.clipboard;
			
			if (newString.length) {
				
				var newStuff:Array = _creator.model.fromString(newString);
				
				var objs:Array = newStuff[0];
				
				if (objs && objs.length > 0) {
					
					_mc.history.record();
					
					var vo:Vector.<ModelObject> = new Vector.<ModelObject>();
					var n:int = objs.length;
					while (n--) vo.unshift(objs[n]);
					sel.clear();
					sel.addObjects(vo);
					
					if (_creator.environment.size == Environment.SIZE_NORMAL) {
						
						n = vo.length;
						
						while (n--) if (vo[n].origin.x > 640 || vo[n].origin.y > 480) {
							_creator.environment.size = Environment.SIZE_DOUBLE;
							break;
						}
						
					}
					
					if (!retainLayers) {
						
						n = vo.length;
						
						while (n--) {
							if (vo[n] != null && vo[n].props != null) vo[n].props.zlayer = _mc.paintLayer;
						}
						
					}
					
					if (placeAtMouse) {
						
						var mousePos:Point = new Point();
						
						mousePos.x = Math.round(_ui.playfield.mc.mouseX / 10) * 10;
						mousePos.y = Math.round(_ui.playfield.mc.mouseY / 10) * 10;
						
						var loc:Point = sel.objects[0].origin.clone();
						mousePos = mousePos.subtract(loc);
						
						sel.moveSelection(mousePos.x, mousePos.y);
						
					} else if (!is_empty) {
						
						sel.moveSelection(10, 10);
						
					}
					
				}
				
			}
			
			CreatorUI.stage.focus = Component.mainStage;
			
		}
		
		protected function showHelp (e:Event):void {
			
			navigateToURL(new URLRequest("javascript: launchHelp()"), "_self");
			
		}
		
		protected function onPassthruButtonClick (e:Event):void {
			
			for (var i:int = 0; i < 5; i++) {
				
				var cb:ToggleButton = e.target as ToggleButton;
				var pb:ToggleButton = _ui.layers["p_" + i];
				
				if (cb != pb && pb.toggled) pb.toggle();
				
			}
			
			_mc.updateLayersForSelection();
			
		}
		
		protected function onDragFromTray (e:Event):void { 
			
			if (_ui.tools.value != CreatorUIStates.TOOL_SELECT && 
				_ui.tools.value != CreatorUIStates.TOOL_WINDOW) {
				_ui.tools.value = CreatorUIStates.TOOL_SELECT;
				}
			
		}
		
		protected function onDragFromTrayMove (e:Event):void { 
			
			var objName:String = Collection(e.target).selectedMembers[0].value;
			var dropPoint:Point = Collection(e.target).dropPoint;
			
			_mc.focusObject = _creator.model.objectAtPoint(dropPoint);
			
			if (objName == CreatorUIStates.MODIFIER_FACTORY) {
				
				if (_mc.focusObject && _mc.focusObject.group) {
					_mc.selection.clear();
					_mc.selection.addObjects(_mc.focusObject.group.objects);
				}
			
			}

		}
		
		
		protected function onDropFromTray (e:Event):void { 
			
			var i:int;
			var objName:String = Collection(e.target).selectedMembers[0].value;
			
			if (objName.indexOf("prefab") != -1) {
				onDropPrefab(e);
				return;
			}
			
			var dropPoint:Point = Collection(e.target).dropPoint;
			
			_mc.focusObject = _creator.model.objectAtPoint(dropPoint);
			
			if (_mc.focusObject == null && _ui.stage.mouseX > 90) {
				notice("You can only drop these onto objects you've created with the drawing tool!");
				return;
			}
			
			_mc.history.record();
			
			switch (objName) {
				
				case CreatorUIStates.MODIFIER_MOTOR:
				case CreatorUIStates.MODIFIER_PUSHER:
				case CreatorUIStates.MODIFIER_ROTATOR:
				case CreatorUIStates.MODIFIER_MOVER:
				case CreatorUIStates.MODIFIER_SLIDER:
				case CreatorUIStates.MODIFIER_JUMPER:
				case CreatorUIStates.MODIFIER_THRUSTER:
				case CreatorUIStates.MODIFIER_PROPELLER:
				case CreatorUIStates.MODIFIER_LAUNCHER:
				case CreatorUIStates.MODIFIER_SELECTOR:
				case CreatorUIStates.MODIFIER_AIMER:
				case CreatorUIStates.MODIFIER_DRAGGER:
				case CreatorUIStates.MODIFIER_POINTER:
				case CreatorUIStates.MODIFIER_ADDER:
				case CreatorUIStates.MODIFIER_SPAWNER:
				case CreatorUIStates.MODIFIER_GROOVEJOINT:
				case CreatorUIStates.MODIFIER_ELEVATOR:
				case CreatorUIStates.MODIFIER_SWITCHER:
				case CreatorUIStates.MODIFIER_CLICKER:
				case CreatorUIStates.MODIFIER_ARCADEMOVER:
					if (_mc.focusObject) {
						if (_mc.selection.length <= 1) {
							_mc.createNewModifier(objName, _mc.focusObject);
						} else {
							confirm(
								_creator.modelController, 
								_mc.addModifiersParentOnly, 
								[objName],
								"Do you really want to add this to " + _mc.selection.length + " objects?"
								);
						}
					}
					break;
					
				case CreatorUIStates.MODIFIER_PINJOINT:
				case CreatorUIStates.MODIFIER_DAMPEDSPRING:
				case CreatorUIStates.MODIFIER_LOOSESPRING:
				case CreatorUIStates.MODIFIER_GEARJOINT:
					if (_mc.focusObject) {
						if (_mc.selection.length <= 2) {
							_mc.createNewModifier(objName, _mc.focusObject);
						} else {
							confirm(
								_creator.modelController, 
								_mc.addModifiersParentChildStep, 
								[objName],
								"Do you really want to add this to " + _mc.selection.length + " objects?"
								);
						}
					}
					break;
					
				case CreatorUIStates.MODIFIER_CONNECTOR:
					if (_mc.focusObject) {
						if (_mc.selection.length == 2) {
							_mc.createNewModifier(objName, 
								_mc.focusObject,
								(_mc.focusObject == _mc.selection.objects[0]) ? 
								_mc.selection.objects[1] : _mc.selection.objects[0]
								);
						} else {
							notice("You must select exactly 2 objects to connect, then drag the connector onto the parent object.");
						}
					}
					break;
					
				case CreatorUIStates.MODIFIER_FACTORY:
					if (_mc.focusObject && 
						_mc.focusObject.group) {
							
						_mc.createNewModifier(objName, _mc.focusObject);
						
					} else if (_mc.focusObject && 
						_mc.selection.length > 1 &&
						!_mc.selection.selectionContainsGroup()) {
						
						_mc.groupSelectedObjects();
						_mc.createNewModifier(objName, _mc.focusObject);
						
					} else {
						notice("You can only add factory modifiers to grouped objects or a selection of multiple objects");
					}
					break;
					
				case CreatorUIStates.MODIFIER_UNLOCKER:
					if (_mc.focusObject) {
						if (_mc.selection.length <= 1) {
							_mc.createNewModifier(objName, _mc.focusObject);
							if (_mc.focusObject.props.sensor_group == 0) {
								notice("Don't forget to select at least one sensor layer for this object and any trigger objects.");
							}
						} else {
							confirm(
								_creator.modelController, 
								_mc.addModifiersParentChildSpoke, 
								[objName],
								"Do you really want to add this to " + _mc.selection.length + " objects?"
								);
						}
					}
					break;
					
				case CreatorUIStates.MODIFIER_EMAGNET:
					if (_mc.focusObject) {
						if (_mc.focusObject.props.material != CreatorUIStates.MATERIAL_MAGNET) {
							_mc.createNewModifier(objName, _mc.focusObject);
						} else {
							notice("You can't add an electromagnet widget to a permanent magnet. Try another material!");
						}
					}
					break;
				
			}
			
			CreatorUI.stage.focus = Component.mainStage;
				
		} 
		
		protected function onDropPrefab (e:Event):void {
			
			if (_ui.stage.mouseX > 90) {
				
				_mc.history.record();
				
				var i:int;
				var objName:String = Collection(e.target).selectedMembers[0].value;
				var dropPoint:Point = Collection(e.target).dropPoint;
				
				_mc.focusObject = _creator.model.objectAtPoint(dropPoint);
				
				if (_mc.focusObject != null) {
					notice("You probably don't want to drag prefabs onto existing objects, since that will make a mess! Try dragging onto an empty area of the canvas!");
					return;
				}
				
				switch (objName) {
					
					case CreatorUIStates.PREFAB_BADDIE:
						paste(true, CreatorUIStates.PREFAB_BADDIE_DATA);
						break;
					case CreatorUIStates.PREFAB_BALLOON:
						paste(true, CreatorUIStates.PREFAB_BALLOON_DATA);
						break;
					case CreatorUIStates.PREFAB_CAR:
						paste(true, CreatorUIStates.PREFAB_CAR_DATA);
						break;
					case CreatorUIStates.PREFAB_COIN:
						paste(true, CreatorUIStates.PREFAB_COIN_DATA);
						break;
					case CreatorUIStates.PREFAB_EXTRALIFE:
						paste(true, CreatorUIStates.PREFAB_EXTRALIFE_DATA);
						break;
					case CreatorUIStates.PREFAB_KEYDOOR:
						paste(true, CreatorUIStates.PREFAB_KEYDOOR_DATA);
						break;
					case CreatorUIStates.PREFAB_PLATFORM:
						paste(true, CreatorUIStates.PREFAB_PLATFORM_DATA);
						break;
					case CreatorUIStates.PREFAB_PLAYER:
						paste(true, CreatorUIStates.PREFAB_PLAYER_DATA);
						break;
					case CreatorUIStates.PREFAB_ROBOT:
						paste(true, CreatorUIStates.PREFAB_ROBOT_DATA);
						break;
					case CreatorUIStates.PREFAB_SHIP:
						paste(true, CreatorUIStates.PREFAB_SHIP_DATA);
						break;
					case CreatorUIStates.PREFAB_SPIKES:
						paste(true, CreatorUIStates.PREFAB_SPIKES_DATA);
						break;
					case CreatorUIStates.PREFAB_TURRET:
						paste(true, CreatorUIStates.PREFAB_TURRET_DATA);
						break;

				}
				
				if (_currentToolState == CreatorUIStates.TOOL_DRAW) {
					_ui.tools.activateTab(null, _ui.tools.tabs[CreatorUIStates.TOOL_SELECT]);
				}
				
				if (_currentToolState != CreatorUIStates.TOOL_PAINT && _currentToolState != CreatorUIStates.TOOL_PICK) {
					var anotice:String = "You just added a ready-made object!  To see what it will look like in the game, choose the <font color=\"#FFFFFF\">paint</font> or <font color=\"#FFFFFF\">pick</font> tool.";
					if (!_prefabAppearanceNoticeSent) {
						notice(anotice);
						_prefabAppearanceNoticeSent = true;
					} else {
						Prompt.prompt(anotice);
					}
				}
				
			}
			
			CreatorUI.stage.focus = Component.mainStage;
			
		}
		
		protected function updateSubToolsDisplay ():void {
			
			_ui.moveGroup.disable();
			_ui.moveLock.disable();
			_ui.shapes.disable();
			_ui.constraints.disable();
			_ui.materials.disable();
			_ui.strengths.disable();
			_ui.moveLock.disable();
			_ui.layersButton.disable();
			_ui.layersMenu.hide();
			_ui.moveGroup.disable();
			_ui.delSelection.disable();
			_ui.editProps.hide();
			_ui.drawProps.hide();
			_ui.paintProps.hide();
			_ui.gameProps.hide();
			_ui.actionsButton.disable();
			_ui.animationToggle.disable();
			_ui.advancedTextureToggle.disable();
			
			_creator.model.background.visible = false;
			_creator.model.backgroundEffect.visible = false;
			
			var slen:int = _mc.selection.length;
			var o:ModelObject;
			if  (_mc.selection.length > 0) o = _mc.selection.objects[0];
			
			switch (_currentToolState) {
				
				case CreatorUIStates.TOOL_DRAW:
				
					_ui.drawProps.show();
					_ui.gameProps.hide();
					_ui.shapes.enable();
					_ui.constraints.enable();
					_ui.materials.enable();
					_ui.strengths.enable();
					
					if (_ui.moveLock.toggled) {
						_ui.moveLock.enable();
						_ui.moveLock.toggle();
						_ui.moveLock.disable();
					}
					if (_ui.moveGroup.toggled) {
						_ui.moveGroup.enable();
						_ui.moveGroup.toggle();
						_ui.moveGroup.disable();
					}
					_creator.model.setViewMode(ModelObjectSprite.VIEW_CONSTRUCT);
					Prompt.prompt("Click and drag on the game area to draw new objects.");

					break;
					
				case CreatorUIStates.TOOL_SELECT:
					Prompt.prompt("Click or drag objects or modifiers to edit them.");
				case CreatorUIStates.TOOL_WINDOW:
				
					if (slen > 0) {
						_ui.drawProps.show();
						_ui.gameProps.hide();
						_ui.editProps.show();

						if (o && o.props && o.props.constraint == CreatorUIStates.MOVEMENT_STATIC) _ui.moveLock.disable();
						else _ui.moveLock.enable();
						_ui.constraints.enable();
						_ui.materials.enable();
						_ui.strengths.enable();
						_ui.layersButton.enable();
						_ui.actionsButton.enable();
						if (slen > 1) _ui.moveGroup.enable();

						updateAttribsDisplay();
					} else {
						_ui.drawProps.hide();
						_ui.gameProps.show();						
					}
					
					if (slen > 0) {
						Prompt.prompt("Drag objects to move them, press CTRL-C to copy, CTRL-V to paste objects.");
					} else if (_currentToolState != CreatorUIStates.TOOL_SELECT) {
						Prompt.prompt("Drag a window along the game background to select multiple objects.");
					}
					_creator.model.setViewMode(ModelObjectSprite.VIEW_CONSTRUCT);
					break;
					
				case CreatorUIStates.TOOL_PAINT:
				case CreatorUIStates.TOOL_PICK:
				
					_ui.paintProps.show();
					_creator.model.background.visible = true;
					_creator.model.backgroundEffect.visible = true;
					_creator.model.setViewMode(ModelObjectSprite.VIEW_DECORATE);
					
					if (slen == 1 && o.props.graphic > 0) {
						if (o.props.shape != CreatorUIStates.SHAPE_POLY && o.props.shape != CreatorUIStates.SHAPE_RAMP) {
							_ui.animationToggle.enable();
						}
					}
					
					if (slen > 0) {
						_ui.advancedTextureToggle.enable();
					}
					
					if (slen == 1 && _currentToolState == CreatorUIStates.TOOL_PAINT) {
						_ui.zlayers.select(o.props.zlayer - 1);
					}
					
					if (_currentToolState == CreatorUIStates.TOOL_PAINT) {
						Prompt.prompt("Select objects and use the menus to change the color, line, texture and layer. Double-click to apply current colors.");
					} else {
						Prompt.prompt("Click on an object to copy its color, line, texture and layer.");
					}
					break;
				
			}
			
		}
		
		protected function updateAttribsDisplay ():void {
			
			var i:int = _mc.selection.length;
			var o:ModelObject;
			
			if  (_mc.selection.length > 0) o = _mc.selection.objects[0];
			
			if (o) {
				
				if (i == 1) {
					_ui.shapes.value = o.props.shape;
					_ui.constraints.value = o.props.constraint;
					_ui.materials.value = o.props.material;
					_ui.strengths.value = o.props.strength;
				}
				if (i == 1) {
					_ui.moveLock.toggled = o.props.locked;
				} else {
					var locked:Boolean = true;
					while (i--) {
						if (_mc.selection.objects[i].props.locked == false) {
							locked = false;
							break;
						}
					}
					_ui.moveLock.toggled = locked;
				}
				_ui.moveGroup.toggled = _mc.selection.selectionIsSingleGroup();
				_ui.delSelection.enable();
				
				updateLayersDisplay();
				
			} else {
				
				_ui.moveLock.toggled = _ui.moveGroup.toggled = false;
				_ui.delSelection.disable();
				
			}
			
		}
		
		protected function updateLayersDisplay ():void {
			
			var selection:ModelSelection = _mc.selection;
			var i:int = selection.length;
			var o:ModelObject;
			
			if  (i > 0) o = selection.objects[0];
			
			if (i == 1 && o) {
				
				var n:int;
				var t:ToggleButton;
				var z:ClipButton;
				
				for (n = 0; n < 5; n++) {
					
					t = ToggleButton(_ui.layers["c_" + n]);
					if (_mc.getLayerState(o, n, ModelObjectProperties.LAYER_COLLISION) != t.toggled) t.toggle();
					
					t = ToggleButton(_ui.layers["p_" + n]);
					if (_mc.getLayerState(o, n, ModelObjectProperties.LAYER_PASSTHRU) != t.toggled) t.toggle();
					
					z = ClipButton(_ui.layers["s_" + n]);
					if (_mc.getLayerState(o, n, ModelObjectProperties.LAYER_SENSOR) != z.toggled) z.toggle();
					
				}
				
			}
			
		}
		
		public function updateAnimationDisplay ():void {
			
			var selection:ModelSelection = _mc.selection;
			
			var slen:int = selection.length;
			var o:ModelObject;
			if  (slen > 0) o = selection.objects[0];
			
			if (o.props.animation == 0) {
				_ui.animWalk.disable();
			} else {
				_ui.animWalk.enable();
			}
			
			if (o.props.graphic_flip == 0 && o.props.animation <= 1) _ui.animNormal.checked = true;
			else if (o.props.graphic_flip == 1 && o.props.animation <= 1) _ui.animFlip.checked = true;
			else if (o.props.animation == 2) _ui.animWalk.checked = true;
			else if (o.props.animation == 3) _ui.animRotate.checked = true;
			else if (o.props.animation == 4) _ui.animRotateWalk.checked = true;
			
		}
		
		public function updateLayerViewDisplay ():void {
			
			var i:int;
			var selection:ModelSelection = _mc.selection;
			var indicators:Array = _ui.ddLayerSelectionIndicators;
			
			for (i = 0; i < 5; i++) {
				
				var button:ClipButton = _ui.layerViewButtons[i];
				var view_state:Boolean = _creator.model.getLayerView(i);
				if (view_state != button.toggled) button.toggle();
				
			}
			
			for (i = 0; i < 5; i++)
			{
				indicators[i].visible = false;
			}
			
			i = selection.length;
			
			while (i--)
			{
				var obj:ModelObject = selection.objects[i];
				
				if (obj != null && obj.props != null && obj.props.zlayer <= 5)
				{
					if (indicators[obj.props.zlayer - 1] != null)
					{
						indicators[obj.props.zlayer - 1].visible = true;
					}
				}
			}
			
		}
		
		public function getLayersState ():Array {
			
			var c:String = "";
			var p:int = -1;
			var s:String = "";
			var n:int;
			var t:ToggleButton;
			var z:ClipButton;
		
			for (n = 0; n < 5; n++) {
				
				t = ToggleButton(_ui.layers["c_" + n]);
				c += (t.toggled) ? "1" : "0";
				
				t = ToggleButton(_ui.layers["p_" + n]);
				p = (t.toggled) ? n : p;
				
				z = ClipButton(_ui.layers["s_" + n]);
				s += (z.toggled) ? "1" : "0";
				
			}
			
			return [c, p.toString(10), s];
			
		}
		
		public function getPaintState ():void {
			
			var mc:ModelController = _creator.modelController;
			var fc:int = mc.paintFillColor;
			var lc:int = mc.paintLineColor;
			var tx:int = mc.paintTexture;
			var zl:int = mc.paintLayer;
			var op:int = mc.paintOpaque;
			var sc:int = mc.paintScribble;
			
			_ui.fills.value = (fc >= 0) ? fc.toString() : CreatorUIStates.NONE;
			_ui.lines.value = (lc >= 0) ? lc.toString() : (lc >= -1) ? CreatorUIStates.NONE : CreatorUIStates.GLOW;
			_ui.textures.value = CreatorUIStates.textures[tx];
			_ui.zlayers.value = "icon_layer_" + zl;
			
			if (_ui.opaque.toggled != (op == 0)) _ui.opaque.toggle();
			if (_ui.scribble.toggled != (sc == 1)) _ui.scribble.toggle();
			
		}

	}

}