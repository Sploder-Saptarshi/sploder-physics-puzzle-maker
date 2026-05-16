package com.sploder.builder 
{
	import com.sploder.asui.BButton;
	import com.sploder.asui.Cell;
	import com.sploder.asui.ClipButton;
	import com.sploder.asui.ClipChooser;
	import com.sploder.asui.Collection;
	import com.sploder.asui.CollectionItem;
	import com.sploder.asui.ColorClipChooser;
	import com.sploder.asui.ComboBox;
	import com.sploder.asui.Component;
	import com.sploder.asui.Create;
	import com.sploder.asui.Divider;
	import com.sploder.asui.DrawingMethods;
	import com.sploder.asui.HTMLField;
	import com.sploder.asui.Library;
	import com.sploder.asui.Position;
	import com.sploder.asui.Prompt;
	import com.sploder.asui.RadioButton;
	import com.sploder.asui.ScrollBar;
	import com.sploder.asui.Style;
	import com.sploder.asui.TabGroup;
	import com.sploder.asui.Tagtip;
	import com.sploder.asui.ToggleButton;
	import com.sploder.asui.VisualGrid;
	import com.sploder.builder.model.ModelObjectSprite;
	import com.sploder.builder.model.ModifierSprite;
	import com.sploder.builder.ui.DialogueActionMatrix;
	import com.sploder.builder.ui.DialogueAlert;
	import com.sploder.builder.ui.DialogueBackground;
	import com.sploder.builder.ui.DialogueClipboard;
	import com.sploder.builder.ui.DialogueConfirm;
	import com.sploder.builder.ui.DialogueEmbed;
	import com.sploder.builder.ui.DialogueEnvironment;
	import com.sploder.builder.ui.DialogueFileManager;
	import com.sploder.builder.ui.DialogueGoals;
	import com.sploder.builder.ui.DialogueMusicManager;
	import com.sploder.builder.ui.DialoguePublish;
	import com.sploder.builder.ui.DialoguePublishComplete;
	import com.sploder.builder.ui.DialogueServer;
	import com.sploder.builder.ui.DialogueTextureGen;
	import com.sploder.builder.ui.DialogueWelcome;
	import com.sploder.builder.ui.ModifierPropertiesEditor;
	import com.sploder.builder.ui.Notice;
	import com.sploder.builder.ui.PanelGraphics;
	import com.sploder.game.library.EmbeddedLibrary;
	import com.sploder.texturegen_internal.TextureRendering;
	import com.sploder.texturegen_internal.util.ThreadedQueue;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class CreatorUI extends Sprite
	{
		protected var _creator:Creator;
		public static var stage:Stage;
		
		[Embed(source = "../../../../lib/font_myriad.swf", mimeType="application/octet-stream")]
		protected var FontLibrarySWF:Class;
		public static var fontLibrary:Library;
		
		[Embed(source = "../../../../lib/creator_library.swf", mimeType="application/octet-stream")]
		protected var LibrarySWF:Class;
		public static var library:EmbeddedLibrary;
		
		public var playfieldContainer:Cell;
		public var playfield:Cell;
		protected var _ui:Cell;
		public var menu:Cell;
		public var tools:TabGroup;
		protected var _subtools:Cell;
		public var gameProps:Cell;
		public var drawProps:Cell;
		public var paintProps:Cell;
		public var editProps:Cell;
		protected var menuButtonTitles:Array;
		protected var menuButtonPrompts:Array;
		public var vScroll:ScrollBar;
		public var hScroll:ScrollBar;
		public var zoomToggle:ClipButton;
		public var defaultLayer:int = 2;
		
		public var menuItems:Object;
		
		protected var _levelSelector:ComboBox;
		public function get levelSelector():ComboBox { return _levelSelector; }
		
		protected var _addLevelButton:BButton;
		public function get addLevelButton():BButton { return _addLevelButton; }
		
		protected var _removeLevelButton:BButton;
		public function get removeLevelButton():BButton { return _removeLevelButton; }
		
		protected var _moveLevelButton:BButton;
		public function get moveLevelButton():BButton { return _moveLevelButton; }
		
		public function get uiContainer():Cell { return _ui; }
		
		protected var _tray:Cell;
		public var trayButtons:TabGroup;
		protected var _trayButtonTitles:Array;

		public var trays:Object;
		
		public var currentTray:Collection;
		
		protected var _trayObjectsPrefabs:Array;
		protected var _trayObjectsPrefabsAlts:Array;
		protected var _trayObjectsPhysics:Array;
		protected var _trayObjectsPhysicsAlts:Array;
		protected var _trayObjectsControls:Array;
		protected var _trayObjectsControlsAlts:Array;
		protected var _trayObjectsWidgets:Array;
		protected var _trayObjectsWidgetsAlts:Array;
		
		protected var _toolIconSymbols:Array;
		protected var _toolIconAlts:Array;
		
		public var shapes:ClipChooser;
		protected var _iconsShapes:Array;
		protected var _iconsShapesAlt:String;
		protected var _iconsShapesAlts:Array;
		
		public var constraints:ClipChooser;
		protected var _iconsConstraints:Array;
		protected var _iconsConstraintsAlt:String;
		protected var _iconsConstraintsAlts:Array;
		
		public var materials:ClipChooser;
		protected var _iconsMaterials:Array;
		protected var _iconsMaterialsAlt:String;
		protected var _iconsMaterialsAlts:Array;
		
		public var strengths:ClipChooser;
		protected var _iconsStrengths:Array;
		protected var _iconsStrengthsAlt:String;
		protected var _iconsStrengthsAlts:Array;
		
		public var moveLock:ClipButton;
		protected var _moveLockAlt:String;
		protected var _moveLockAltToggled:String;
		
		public var layersButton:ClipButton;
		protected var _layersButtonAlt:String;
		
		public var actionsButton:ClipButton;
		protected var _actionsButtonAlt:String;
		
		public var layers:Object;
		public var layersMenu:Cell;
		public var layersButtons:Cell;
		protected var _layersSensorSymbols:Array;
		public var ddLayerView:Cell;
		public var layerViewToggle:ClipButton;
		public var layerViewButtons:Array;
		public var layerDefaultButtons:TabGroup;
		public var ddLayerSelectionIndicators:Array;
			
		public var moveGroup:ClipButton;
		protected var _moveGroupAlt:String;
		protected var _moveGroupAltToggled:String;
		
		public var delSelection:ClipButton;
		public var _delSelectionAlt:String;
		
		public var testMask:Sprite;
		
		private var _testEndButtonContainer:Cell;
		public function get testEndButtonContainer():Cell { return _testEndButtonContainer; }
		
		private var _testEndButton:BButton;
		public function get testEndButton():BButton { return _testEndButton; }
		
		public var modifierPropertiesEditor:ModifierPropertiesEditor;
		
		public var world:BButton;
		public var bkgd:BButton;
		public var goals:BButton;
		public var music:BButton;
		public var clipboard:BButton;
		
		public var fills:ClipChooser;
		public var lines:ClipChooser;
		public var zlayers:ClipChooser;
		
		public var textures:ClipChooser;
		protected var _iconsTextures:Array;
		protected var _iconsTexturesAlt:String;

		public var ddEnvironment:DialogueEnvironment;
		public var ddBackground:DialogueBackground;
		public var ddConfirm:DialogueConfirm;
		public var ddAlert:DialogueAlert;
		public var notice:Notice;
		public var ddManager:DialogueFileManager;
		public var ddMusic:DialogueMusicManager;
		public var ddGraphics:PanelGraphics;
		public var ddTextureGen:DialogueTextureGen;

		public var opaque:ClipButton;
		public var scribble:ClipButton;
		public var graphicsPanelToggle:ClipButton;
		public var animationToggle:ClipButton;
		public var advancedTextureToggle:ClipButton;
		
		public var ddAnimation:Cell;
		public var animNormal:RadioButton;
		public var animFlip:RadioButton;
		public var animWalk:RadioButton;
		public var animRotate:RadioButton;
		public var animRotateWalk:RadioButton;
		
		public var ddClipboard:DialogueClipboard;
		public var ddActionMatrix:DialogueActionMatrix;
		public var ddPublish:DialoguePublish;
		public var ddPublishComplete:DialoguePublishComplete;
		public var ddEmbed:DialogueEmbed;
		public var ddServer:DialogueServer;
		public var ddGoals:DialogueGoals;
		public var trayPager:ToggleButton;
		public var prompt:Prompt;
		public var ddWelcome:DialogueWelcome;
		public var sensorLayersTitle:HTMLField;
		public var undoButton:SimpleButton;
		public var redoButton:SimpleButton;
		public var helpButton:SimpleButton;
		
		
		public function CreatorUI(creator:Creator) 
		{
			super();
			init(creator);
			
		}
		
		protected function init (creator:Creator):void {
			
			_creator = creator;
			CreatorUI.stage = _creator.stage;

			menuButtonTitles = ["New", "Load", "Save", "Save As", "Test", "Publish"];
			menuButtonPrompts = [
				"Click to start making a new game project.",
				"Click to load a game project.",
				"Click to save your game project. This will not publish or share your game.",
				"Click to save your game as a different game project.",
				"Click to test your game level in the creator",
				"Click to publish your game to share it with others"
				];
			
			_toolIconSymbols = [
				CreatorUIStates.TOOL_DRAW,
				CreatorUIStates.TOOL_SELECT, 
				CreatorUIStates.TOOL_WINDOW,
				CreatorUIStates.TOOL_PAINT, 
				CreatorUIStates.TOOL_PICK
				];
				
			_toolIconAlts = [
				"Draw a new object",
				"Select and edit a single object, or edit physics, controls and widgets",
				"Select multiple objects, and hide physics, controls and widgets",
				"View and change the appearance of objects",
				"Pick appearance attributes from objects for copying with the paint tool"
				]
				
			_iconsShapes = [
				CreatorUIStates.SHAPE_CIRCLE, 
				CreatorUIStates.SHAPE_SQUARE, 
				CreatorUIStates.SHAPE_BOX,
				CreatorUIStates.SHAPE_RAMP,
				CreatorUIStates.SHAPE_PENT, 
				CreatorUIStates.SHAPE_HEX, 
				CreatorUIStates.SHAPE_POLY
				];
				
			_iconsShapesAlt = "Choose a type of shape to create or draw";
				
			_iconsShapesAlts = [
				"Simple circular object with variable radius",
				"Square object, same width and height",
				"Rectangular object, variable width and/or height",
				"Ramp shape (right triangle), variable width and/or height",
				"Pentagon, variable size",
				"Hexagon, variable size",
				"Polygon that can be drawn and vertices tweaked"
				];
				
			_iconsConstraints = [
				CreatorUIStates.MOVEMENT_FREE, 
				CreatorUIStates.MOVEMENT_PIN, 
				CreatorUIStates.MOVEMENT_SLIDE,
				CreatorUIStates.MOVEMENT_STATIC
				];
				
			_iconsConstraintsAlt = "Choose how to constrain the physical motion of this object";
			
			_iconsConstraintsAlts = [
				"Object moves and rotates naturally with no constraints",
				"Object rotates but does not move, like it is pinned to the background",
				"Object moves but does not rotate, as if it is sliding",
				"Object does not move or rotate, ever"
				];
				
			_iconsMaterials = [
				CreatorUIStates.MATERIAL_WOOD, 
				CreatorUIStates.MATERIAL_STEEL, 
				CreatorUIStates.MATERIAL_ICE,
				CreatorUIStates.MATERIAL_RUBBER,
				CreatorUIStates.MATERIAL_GLASS,
				CreatorUIStates.MATERIAL_TIRE,
				CreatorUIStates.MATERIAL_AIR_BALLOON,
				CreatorUIStates.MATERIAL_HELIUM_BALLOON,
				CreatorUIStates.MATERIAL_MAGNET,
				CreatorUIStates.MATERIAL_SUPERBALL
				];
				
			_iconsMaterialsAlt = "Choose the materials physical properties for friction, bounce and density";
			
			_iconsMaterialsAlts = [
				"Wood-like material with average friction, bounce and very low density",
				"Steel-like material with average friction, bounce and very high density",
				"Ice-like material with very low friction, low bounce and density",
				"Rubber-like material with high friction, bounce, and high density",
				"Glass-like material with low friction, bounce, and average density",
				"Tire-like material with very high friction, high bounce and low density",
				"Magic material with very low friction and no gravity effect",
				"Magic material with very low friction and negative gravity effect",
				"Permanent magnetic material with average friction and high density. Other steel objects stick to this",
				"Super-bouncy material that launches objects away when touched"
				];
				
			_iconsStrengths = [
				CreatorUIStates.STRENGTH_PERM,
				CreatorUIStates.STRENGTH_STRONG,
				CreatorUIStates.STRENGTH_MEDIUM,
				CreatorUIStates.STRENGTH_WEAK
				];
				
			_iconsStrengthsAlt = "Choose how the object reacts to crushing forces";
			
			_iconsStrengthsAlts = [
				"Object is not affected by curshing forces",
				"Object is barely affected by crushing forces",
				"Object can be crushed by average forces",
				"Object is brittle, and can be crushed easily"
				];
				
			_moveLockAlt = "Click to lock movement on this object";
			_moveLockAltToggled = "Click to unlock movement on this object";
			_layersButtonAlt = "Click to change collision and/or sensor layers";
			_actionsButtonAlt = "Click to add actions to events that happen to this object";
			
			_layersSensorSymbols = [
				CreatorUIStates.SUIT_CLUB,
				CreatorUIStates.SUIT_DIAMOND,
				CreatorUIStates.SUIT_HEART,
				CreatorUIStates.SUIT_SPADE,
				CreatorUIStates.SUIT_MON
				];
			
			_moveGroupAlt = "Click to group objects together for convenient editing";
			_moveGroupAltToggled = "Click to ungroup objects";
			_delSelectionAlt = "Delete selected objects";
			
			_iconsTextures = CreatorUIStates.textures_iconmap.concat();
				
			_iconsTexturesAlt = "Click to change the texture of selected objects";
			
			_trayButtonTitles = [ 
				{ text: CreatorUIStates.TRAY_PREFABS, icon: Create.ICON_ARROW_LEFT, first: "false", iconToggled: Create.ICON_ARROW_DOWN },
				{ text: CreatorUIStates.TRAY_PHYSICS, icon: Create.ICON_ARROW_LEFT, first: "false", iconToggled: Create.ICON_ARROW_DOWN },
				{ text: CreatorUIStates.TRAY_CONTROLS, icon: Create.ICON_ARROW_LEFT, first: "false", iconToggled: Create.ICON_ARROW_DOWN }, 
				{ text: CreatorUIStates.TRAY_WIDGETS, icon: Create.ICON_ARROW_LEFT, first: "false", iconToggled: Create.ICON_ARROW_DOWN }
				];
				
			_trayObjectsPrefabs = [
				{ title: CreatorUIStates.TITLE_PLAYER, icon: CreatorUIStates.TRAY_PREFAB_PLAYER, value: CreatorUIStates.PREFAB_PLAYER },
				{ title: CreatorUIStates.TITLE_BADDIE, icon: CreatorUIStates.TRAY_PREFAB_BADDIE, value: CreatorUIStates.PREFAB_BADDIE },
				{ title: CreatorUIStates.TITLE_PLATFORM, icon: CreatorUIStates.TRAY_PREFAB_PLATFORM, value: CreatorUIStates.PREFAB_PLATFORM },
				{ title: CreatorUIStates.TITLE_COIN, icon: CreatorUIStates.TRAY_PREFAB_COIN, value: CreatorUIStates.PREFAB_COIN },
				{ title: CreatorUIStates.TITLE_SPIKES, icon: CreatorUIStates.TRAY_PREFAB_SPIKES, value: CreatorUIStates.PREFAB_SPIKES },
				{ title: CreatorUIStates.TITLE_EXTRALIFE, icon: CreatorUIStates.TRAY_PREFAB_EXTRALIFE, value: CreatorUIStates.PREFAB_EXTRALIFE },
				{ title: CreatorUIStates.TITLE_KEYDOOR, icon: CreatorUIStates.TRAY_PREFAB_KEYDOOR, value: CreatorUIStates.PREFAB_KEYDOOR },
				{ title: CreatorUIStates.TITLE_SHIP, icon: CreatorUIStates.TRAY_PREFAB_SHIP, value: CreatorUIStates.PREFAB_SHIP },
				{ title: CreatorUIStates.TITLE_TURRET, icon: CreatorUIStates.TRAY_PREFAB_TURRET, value: CreatorUIStates.PREFAB_TURRET },
				{ title: CreatorUIStates.TITLE_ROBOT, icon: CreatorUIStates.TRAY_PREFAB_ROBOT, value: CreatorUIStates.PREFAB_ROBOT },
				{ title: CreatorUIStates.TITLE_BALLOON, icon: CreatorUIStates.TRAY_PREFAB_BALLOON, value: CreatorUIStates.PREFAB_BALLOON },
				{ title: CreatorUIStates.TITLE_CAR, icon: CreatorUIStates.TRAY_PREFAB_CAR, value: CreatorUIStates.PREFAB_CAR },
				];
			
			_trayObjectsPrefabsAlts = [
				"Drag this onto the canvas to create a new ready-made player that can jump and move from side to side",
				"Drag this onto the canvas to create a new ready-made baddie that moves side to side randomly",
				"Drag this onto the canvas to create a new ready-made platform that you can walk on",
				"Drag this onto the canvas to create a new ready-made coin that will add to the score when the player touches it",
				"Drag this onto the canvas to create a new ready-made spikes block that will cause the player to lose a life",
				"Drag this onto the canvas to create a new ready-made extra-life block that will give the player an extra life when it is touched",
				"Drag this onto the canvas to create a new ready-made key and door combo you can use to unlock an area in the game",
				"Drag this onto the canvas to create a new ready-made ship you can use in top-down games without gravity",
				"Drag this onto the canvas to create a new ready-made turret that shoots at your player if you get near it",
				"Drag this onto the canvas to create a new ready-made robot that you can make walk back and forth and shoot",
				"Drag this onto the canvas to create a new ready-made balloon with an electro-magnet that can pick up metal",
				"Drag this onto the canvas to create a new ready-made Turret car that can roll back and forth and shoot",
				];
				
			_trayObjectsPhysics = [ 
				{ title: CreatorUIStates.TITLE_MOTOR, icon: CreatorUIStates.TRAY_MODIFIER_MOTOR, value: CreatorUIStates.MODIFIER_MOTOR },
				{ title: CreatorUIStates.TITLE_PUSHER, icon: CreatorUIStates.TRAY_MODIFIER_PUSHER, value: CreatorUIStates.MODIFIER_PUSHER },
				{ title: CreatorUIStates.TITLE_PINJOINT, icon: CreatorUIStates.TRAY_MODIFIER_PINJOINT, value: CreatorUIStates.MODIFIER_PINJOINT },
				{ title: CreatorUIStates.TITLE_GROOVEJOINT, icon: CreatorUIStates.TRAY_MODIFIER_GROOVEJOINT, value: CreatorUIStates.MODIFIER_GROOVEJOINT },
				{ title: CreatorUIStates.TITLE_DAMPEDSPRING, icon: CreatorUIStates.TRAY_MODIFIER_DAMPEDSPRING, value: CreatorUIStates.MODIFIER_DAMPEDSPRING },
				{ title: CreatorUIStates.TITLE_LOOSESPRING, icon: CreatorUIStates.TRAY_MODIFIER_LOOSESPRING, value: CreatorUIStates.MODIFIER_LOOSESPRING },		
				{ title: CreatorUIStates.TITLE_GEARJOINT, icon: CreatorUIStates.TRAY_MODIFIER_GEARJOINT, value: CreatorUIStates.MODIFIER_GEARJOINT }
				];
				
			_trayObjectsPhysicsAlts = [
				"Drag this onto an object to make it turn at a set speed",
				"Drag this onto an object to make it push objects that collide with it",
				"Drag this onto an object to connect it to a fixed-length joint. You can drag both ends, and if you drag them together you make a special bolt joint that sticks objects together without colliding.",
				"Drag this onto an object to connect it to a groove that it can slide along",
				"Drag this onto an object to connect it to a tight spring",
				"Drag this onto an object to connect it to a loose spring",
				"Drag this onto an object to mirror the rotation of the parent object, as if it were connected by a gear"
				];
				
			_trayObjectsControls = [
				{ title: CreatorUIStates.TITLE_ROTATOR, icon: CreatorUIStates.TRAY_MODIFIER_ROTATOR, value: CreatorUIStates.MODIFIER_ROTATOR },
				{ title: CreatorUIStates.TITLE_MOVER, icon: CreatorUIStates.TRAY_MODIFIER_MOVER, value: CreatorUIStates.MODIFIER_MOVER },
				{ title: CreatorUIStates.TITLE_SLIDER, icon: CreatorUIStates.TRAY_MODIFIER_SLIDER, value: CreatorUIStates.MODIFIER_SLIDER },
				{ title: CreatorUIStates.TITLE_JUMPER, icon: CreatorUIStates.TRAY_MODIFIER_JUMPER, value: CreatorUIStates.MODIFIER_JUMPER },
				{ title: CreatorUIStates.TITLE_ARCADEMOVER, icon: CreatorUIStates.TRAY_MODIFIER_ARCADEMOVER, value: CreatorUIStates.MODIFIER_ARCADEMOVER },
				{ title: CreatorUIStates.TITLE_SELECTOR, icon: CreatorUIStates.TRAY_MODIFIER_SELECTOR, value: CreatorUIStates.MODIFIER_SELECTOR },
				{ title: CreatorUIStates.TITLE_ADDER, icon: CreatorUIStates.TRAY_MODIFIER_ADDER, value: CreatorUIStates.MODIFIER_ADDER },
				{ title: CreatorUIStates.TITLE_LAUNCHER, icon: CreatorUIStates.TRAY_MODIFIER_LAUNCHER, value: CreatorUIStates.MODIFIER_LAUNCHER },
				{ title: CreatorUIStates.TITLE_AIMER, icon: CreatorUIStates.TRAY_MODIFIER_AIMER, value: CreatorUIStates.MODIFIER_AIMER },
				{ title: CreatorUIStates.TITLE_DRAGGER, icon: CreatorUIStates.TRAY_MODIFIER_DRAGGER, value: CreatorUIStates.MODIFIER_DRAGGER },
				{ title: CreatorUIStates.TITLE_THRUSTER, icon: CreatorUIStates.TRAY_MODIFIER_THRUSTER, value: CreatorUIStates.MODIFIER_THRUSTER },
				{ title: CreatorUIStates.TITLE_CLICKER, icon: CreatorUIStates.TRAY_MODIFIER_CLICKER, value: CreatorUIStates.MODIFIER_CLICKER }
				];
				
			_trayObjectsControlsAlts = [
				"Rotates an object using the keyboard (left and right arrow keys or A and D keys)",
				"Pushes an object with the keyboard (up and down arrow keys or W and S keys)",
				"Pushes an object with the keyboard (left and right arrow keys or A and D keys)",
				"Makes an object appear to jump by pushing it up quickly (up arrow key or W key)",
				"Allows for tighter arcade movement without acceleration using WASD or arrow keys. Platformer mode in playfield with gravity",
				"Allow ONLY ONE object to be controlled at a time by selecting (mouse click)",
				"Adds a copy of the object to the game (spacebar)",
				"Bounces touching objects towards the mouse (mouse click)",
				"Allow an object to be aimed toward the location of the mouse",
				"Allow an object to be dragged with the mouse",
				"Pushes an object with the keyboard in one direction from any location you choose and any key you choose",
				"Triggers the On Sensor event by clicking on the object with the mouse"
				];
				
			_trayObjectsWidgets = [
				{ title: CreatorUIStates.TITLE_ELEVATOR, icon: CreatorUIStates.TRAY_MODIFIER_ELEVATOR, value: CreatorUIStates.MODIFIER_ELEVATOR },
				{ title: CreatorUIStates.TITLE_SPAWNER, icon: CreatorUIStates.TRAY_MODIFIER_SPAWNER, value: CreatorUIStates.MODIFIER_SPAWNER },
				{ title: CreatorUIStates.TITLE_CONNECTOR, icon: CreatorUIStates.TRAY_MODIFIER_CONNECTOR, value: CreatorUIStates.MODIFIER_CONNECTOR },
				{ title: CreatorUIStates.TITLE_FACTORY, icon: CreatorUIStates.TRAY_MODIFIER_FACTORY, value: CreatorUIStates.MODIFIER_FACTORY },
				{ title: CreatorUIStates.TITLE_UNLOCKER, icon: CreatorUIStates.TRAY_MODIFIER_UNLOCKER, value: CreatorUIStates.MODIFIER_UNLOCKER },
				{ title: CreatorUIStates.TITLE_SWITCHER, icon: CreatorUIStates.TRAY_MODIFIER_SWITCHER, value: CreatorUIStates.MODIFIER_SWITCHER },
				{ title: CreatorUIStates.TITLE_EMAGNET, icon: CreatorUIStates.TRAY_MODIFIER_EMAGNET, value: CreatorUIStates.MODIFIER_EMAGNET },
				{ title: CreatorUIStates.TITLE_POINTER, icon: CreatorUIStates.TRAY_MODIFIER_POINTER, value: CreatorUIStates.MODIFIER_POINTER },
				{ title: CreatorUIStates.TITLE_PROPELLER, icon: CreatorUIStates.TRAY_MODIFIER_PROPELLER, value: CreatorUIStates.MODIFIER_PROPELLER }
				];
				
			_trayObjectsWidgetsAlts = [
				"Moves an object back and forth along a groove joint",
				"Adds a copy of the object to the game at a specified interval",
				"Select 2 objects and drag onto the main object to connect a smaller object. Connected objects do not collide with anything. Good for connecting spawners to moving objects",
				"Drag this onto a set of grouped items to create a Spawner for the whole group (including joints, etc)",
				"Drag this onto an object to make its events also happen to another object. After adding, drag the flag onto a target object, then apply an unlock, remove or explode action to the target.",
				"Drag this onto an object with an elevator or motor to switch the direction randomly",
				"Drag this onto an object to turn it into a magnet, which you can switch on and off with the keyboard (spacebar)",
				"Drag this onto an object to make it always point at whichever object is being controlled with the keyboard or mouse",
				"Drag this onto an object to have it propel in one direction from any location you choose" 
				];
				
			Prompt.defaultMessage = "Need help? Hold your mouse over a button to find out what it does!";
			
			menuItems = { };
			layers = { };
			trays = { };
			
		}
		
		public function start ():void {
			
			initializeFontLibrary(LibrarySWF);
			
		}
		
		//
		//
		protected function initializeFontLibrary (LibrarySWF:Class):void {
			
			fontLibrary = new Library(FontLibrarySWF, true);	
			fontLibrary.addEventListener(Event.INIT, onFontLibraryInitialized);		

		}
		
		//
		//
		protected function onFontLibraryInitialized (e:Event):void {
			
			fontLibrary.removeEventListener(Library.INITIALIZED, onFontLibraryInitialized);
			Styles.initializeFonts(fontLibrary);
			initializeLibrary(LibrarySWF);

		}
		
		//
		//
		protected function initializeLibrary (LibrarySWF:Class):void {
			
			library = new EmbeddedLibrary(LibrarySWF);	
			library.addEventListener(Event.INIT, onLibraryInitialized);		
			
		}
		
		//
		//
		protected function onLibraryInitialized (e:Event):void {
			
			library.removeEventListener(Library.INITIALIZED, onLibraryInitialized);
			
			Textures.library = library;
			ModelObjectSprite.library = library;
			ModifierSprite.library = library;
			ModifierSprite.mainStage = stage;
			TextureRendering.mainStage = stage;
			ThreadedQueue.mainStage = stage;
			
			build();
			dispatchEvent(new Event(Event.INIT));
			
		}
		
		protected function build ():void {
			
			var i:int;
			
			Styles.initialize();
			
			Component.library = library;
			
			Tagtip.initialize(stage);
			
			graphics.clear();
			graphics.beginFill(0x003366);
			graphics.drawRect(136, 90, 724, 480);
			graphics.endFill();

			playfieldContainer = new Cell(this, 640, 480, false, false, 0, Styles.absPosition, Styles.playfieldStyle);
			playfieldContainer.x = 180;
			playfieldContainer.y = 90;
			
			playfield = new Cell(null, 640, 480, true, false, 0, Styles.absPosition, Styles.playfieldStyle);
			playfield.fixedContentSize = true;
			playfieldContainer.addChild(playfield);
			playfield.addChild(new VisualGrid(null, 1280, 960));
			
			prompt = new Prompt();
			prompt.style = Styles.promptStyle;
			prompt.tween = false;
			prompt.promptWidth = 860;
			prompt.promptHeight = 30;
			prompt.promptTopMargin = 7;
			prompt.x = 0;
			prompt.y = 570;
			addChild(prompt);
			
			var dd:Divider;
			var bb:BButton;
			
			_ui = new Cell(this, 860, 600);
				
			menu = new Cell(null, 860, 41, true, false, 0, new Position( { zindex: 100 } ), Styles.menuStyle);
			_ui.addChild(menu);
			
			for (i = 0; i < menuButtonTitles.length; i++) {
				
				bb = new BButton(null, 
					menuButtonTitles[i], 
					-1, NaN, 41, false, false, false, 
					Styles.floatPosition, 
					Styles.menuStyle
					);
				
				var name:String = "";
				if (menuButtonTitles[i] is String) name = menuButtonTitles[i].split(" ").join("").toLowerCase();
				else name = menuButtonTitles[i].text.split(" ").join("").toLowerCase();
				menuItems[name] = bb;
				
				menu.addChild(bb);
				Prompt.connectButton(bb.mc, menuButtonPrompts[i]);
				
				dd = new Divider(null, NaN, 41, true, Styles.floatPosition, Styles.menuStyle);
				menu.addChild(dd);
				
			}
				
			menuItems.save.enabled = false;
			menuItems.saveas.enabled = false;
			
			// LEVEL SELECTOR
			
			var ccp:Position = new Position( { 
				margin_right: 2, 
				margin_top: 9 } , 
				-1, 
				Position.PLACEMENT_FLOAT
				);
				
			var ccp2:Position = new Position( { 
				margin_left: 144, 
				margin_top: 9, 
				margin_right: 1 } , 
				-1, 
				Position.PLACEMENT_FLOAT);
				
			var ccs:Style = new Style( {
				round: 0,
				font: "Myriad Web",
				titleFont: "Myriad Web Bold",
				buttonFont: "Myriad Web Bold",
				embedFonts: true,
				fontSize: 11,
				buttonFontSize: 11,
				buttonTextColor: 0xcccccc
				} );
			
			var ccs2:Style = new Style( {
				fontSize: 10,
				buttonFontSize: 10
				} );

			var ccs3:Style = new Style( {
				borderWidth: 2,
				inactiveColor: 0x660066
				} );

			_levelSelector = new ComboBox(null, "Level", ["Level 1"], 0, "Level", 100, ccp2, ccs2);
			menu.addChild(_levelSelector);
			Prompt.connectButton(_levelSelector.mc, "Click to change the level you are working on");
			
			var dv:Divider = new Divider(null, 1, 23, true, ccp.clone( { margin_right: 8 } ), ccs3.clone( { borderColor: 0x990099 } ));
			menu.addChild(dv);
			
			_addLevelButton = new BButton(null, Create.ICON_PLUS, -1, 23, 23, false, false, false, ccp, ccs3);
			_addLevelButton.alt = "Click to add a level to your game";
			menu.addChild(_addLevelButton);
			Prompt.connectButton(_addLevelButton.mc, _addLevelButton.alt);
			
			_removeLevelButton = new BButton(null, Create.ICON_MINUS, -1, 23, 23, false, false, false, ccp, ccs3);
			_removeLevelButton.alt = "Click to remove this level from your game";
			menu.addChild(_removeLevelButton);
			_removeLevelButton.disable();
			Prompt.connectButton(_removeLevelButton.mc, _removeLevelButton.alt);
			
			_moveLevelButton = new BButton(null, Create.ICON_ARROW_UP, -1, 23, 23, false, false, false, ccp, ccs3);
			_moveLevelButton.alt = "Click to move this level up so it plays before the previous level";
			menu.addChild(_moveLevelButton);
			_moveLevelButton.disable();
			Prompt.connectButton(_moveLevelButton.mc, _moveLevelButton.alt);
			
			_ui.addChild(new Cell(null, 860, 2, true));
			
			// TRAY
			
			_tray = new Cell(null, 135, stage.stageHeight - 73, true, false, 0, Styles.floatPosition, Styles.trayStyle); 
			_ui.addChild(_tray);
			
			var t2:Cell = new Cell(null, 1, stage.stageHeight - 73, false, false, 0, Styles.floatPosition);
			_ui.addChild(t2);
			
			trayButtons = new TabGroup(null, _trayButtonTitles, null, 0, 135, true, new Position( { align: Position.ALIGN_LEFT } ), Styles.trayStyle);
			_tray.addChild(trayButtons);
			
			// TRAY OBJECTS
			
			var trayCell:Cell = new Cell(null, 135, NaN, false, false, 0, new Position({ margin_left: 3, margin_top: -6 }));
			_tray.addChild(trayCell);
			
			// Prefabs >
			var tr:Collection;
			
			tr = trays[CreatorUIStates.TRAY_PREFABS] = new Collection(null, 129, 384, 125, 60, 4, new Position(null, -1, Position.PLACEMENT_ABSOLUTE), Styles.trayItemStyle);
			tr.allowDrag = true;
			tr.maskContent = true;
			tr.allowRemoveOnDrag = false;
			tr.allowKeyboardEvents = false;
			tr.defaultItemComponent = "Clip";
			trayCell.addChild(tr);
			
			tr.addMembers(_trayObjectsPrefabs, -1, false, true);
			tr.addAlts(_trayObjectsPrefabsAlts);
			
			for (i = 0; i < tr.members.length; i++) {
				Prompt.connectButton(CollectionItem(tr.members[i]).mc, "Drag this onto the canvas to create new ready-made objects.");
			}
			
			// Physics >
			
			tr = trays[CreatorUIStates.TRAY_PHYSICS] = new Collection(null, 129, 384, 125, 60, 4, new Position(null, -1, Position.PLACEMENT_ABSOLUTE), Styles.trayItemStyle);
			tr.allowDrag = true;
			tr.maskContent = true;
			tr.allowRemoveOnDrag = false;
			tr.allowKeyboardEvents = false;
			tr.defaultItemComponent = "Clip";
			trayCell.addChild(tr);
			tr.hide()
			
			tr.addMembers(_trayObjectsPhysics, -1, false, true);
			tr.addAlts(_trayObjectsPhysicsAlts);
			
			for (i = 0; i < tr.members.length; i++) {
				Prompt.connectButton(CollectionItem(tr.members[i]).mc, "Drag this onto a game object to modify its physics behavior.");
			}
			
			// Controls >
			
			tr = trays[CreatorUIStates.TRAY_CONTROLS] = new Collection(null, 129, 384, 125, 60, 4, new Position(null, -1, Position.PLACEMENT_ABSOLUTE), Styles.trayItemStyle);
			tr.allowDrag = true;
			tr.maskContent = true;
			tr.allowRemoveOnDrag = false;
			tr.allowKeyboardEvents = false;
			tr.defaultItemComponent = "Clip";
			trayCell.addChild(tr);
			
			tr.addMembers(_trayObjectsControls, -1, false, true);
			tr.addAlts(_trayObjectsControlsAlts);
			tr.hide();
			
			for (i = 0; i < tr.members.length; i++) {
				Prompt.connectButton(CollectionItem(tr.members[i]).mc, "Drag this onto a game object to allow control with the keyboard or mouse.");
			}
			
			// Widgets >
			
			tr = trays[CreatorUIStates.TRAY_WIDGETS] = new Collection(null, 129, 384, 125, 60, 4, new Position(null, -1, Position.PLACEMENT_ABSOLUTE), Styles.trayItemStyle);
			tr.allowDrag = true;
			tr.maskContent = true;
			tr.allowRemoveOnDrag = false;
			tr.allowKeyboardEvents = false;
			tr.defaultItemComponent = "Clip";
			trayCell.addChild(tr);
			
			tr.addMembers(_trayObjectsWidgets, -1, false, true);
			tr.addAlts(_trayObjectsWidgetsAlts);
			tr.hide();
			
			for (i = 0; i < tr.members.length; i++) {
				Prompt.connectButton(CollectionItem(tr.members[i]).mc, "Drag this onto a game object to add automated actions or controls.");
			}
			
			var tpStyle:Style = Styles.dialogueStyle.clone();
			tpStyle.buttonColor = tpStyle.unselectedColor = tpStyle.inactiveColor = 0;
			tpStyle.round = 30;
			
			trayPager = new ToggleButton(null, 
				Create.ICON_ARROW_DOWN, Create.ICON_ARROW_UP, 
				false, -1, 125, 30,
				new Position(null, -1, Position.PLACEMENT_ABSOLUTE, -1, null, 386, 2), 
				tpStyle);
				
			trayCell.addChild(trayPager);
			
			Prompt.connectButton(trayPager.mc, "Click to view more items.");
			
			
			// SECONDARY MENU
			// ----------------------
			
			var cc:Cell = new Cell(null, 724, 47, true, false, 0, Styles.floatPosition);
			_ui.addChild(cc);
			
			// GRAPHICS PANEL
			
			ddGraphics = new PanelGraphics(_creator);
			ddGraphics.create(cc);
			
			// ANIMATION PANEL
			
			ddAnimation = new Cell(null, 145, 130, true, true, 0, Styles.absPosition.clone( { top: 45, left: 560, padding: 20 } ), Styles.dialogueStyle);
			cc.addChild(ddAnimation);
			ddAnimation.hide();
			ddAnimation.hideOnMouseOut = true;
			
			animNormal = new RadioButton(null, "Normal Mode", "1", "anim", true, NaN, NaN, "Graphic displays without changes from simulation", new Position( { margins: "12 0 0 15" } ), Styles.dialogueStyle);
			ddAnimation.addChild(animNormal);
			
			animFlip = new RadioButton(null, "Flip Mode", "1", "anim", false, NaN, NaN, "Graphic flips horizontally depending on direction of movement", new Position( { margins: "0 0 0 15" } ), Styles.dialogueStyle);
			ddAnimation.addChild(animFlip);
			
			animWalk = new RadioButton(null, "Walk Mode", "1", "anim", false, NaN, NaN, "Graphic flips and animates only on horizontal movement", new Position( { margins: "0 0 0 15" } ), Styles.dialogueStyle);
			ddAnimation.addChild(animWalk);
			
			animRotate = new RadioButton(null, "Rotate Mode", "1", "anim", false, NaN, NaN, "Graphic rotates to match movement. Use only with sliding objects and no gravity.", new Position( { margins: "0 0 0 15" } ), Styles.dialogueStyle);
			ddAnimation.addChild(animRotate);
			
			animRotateWalk = new RadioButton(null, "Walk & Rotate", "1", "anim", false, NaN, NaN, "Graphic rotates and animates only when moving. Use only with sliding objects and no gravity.", new Position( { margins: "0 0 0 15" } ), Styles.dialogueStyle);
			ddAnimation.addChild(animRotateWalk);
			
			
			// TOOLS
			
			var toolsPos:Position = new Position( { 
				placement: Position.PLACEMENT_FLOAT, 
				margin_top: 2,
				margin_left: 3
				} );
			var toolsStyle:Style = new Style( { 
				buttonColor: 0, 
				border: 0,
				round: 0,
				borderColor: 0, 
				selectedButtonColor: 0x003399,
				padding: 0
				} );
	
			tools = new TabGroup(null, _toolIconSymbols, _toolIconAlts, 1, 41, false, toolsPos, toolsStyle);
			tools.clipMode = true;
			tools.clipScale = 1;
			cc.addChild(tools);	
			
			var tt:Array = tools.tabs as Array;
			
			for (i = 0; i < tt.length; i++) {
				Prompt.connectButton(tt[i].mc, _toolIconAlts[i]);
			}
			
			dd = new Divider(null, 2, 41, true, Styles.floatPosition.clone( { margin_left: 10, margin_right: 10, margin_top: 2 } ) , Styles.menuStyle.clone( { borderWidth: 2 } ));
			cc.addChild(dd);
			
			_subtools = new Cell(null, 380, 41, false, false, 0, Styles.floatPosition);
			cc.addChild(_subtools);
			
			
			// ATTRIBS
			
			drawProps = new Cell(null, 510, 41, false, false, 0, Styles.absPosition);
			_subtools.addChild(drawProps);
			
			var drawPropsPos:Position = toolsPos.clone( {
				margin_left: 0,
				margin_right: 4
				} );
				
			var drawPropsStyle:Style = toolsStyle.clone( {
				buttonColor: 0x000000,
				unselectedColor: 0x333333,
				backgroundColor: 0x555555,
				borderColor: 0xffffff,
				inactiveColor: 0x111111,
				round: 4
				} );
				
			drawPropsStyle.buttonTextColor = 0xffffff;
			drawPropsStyle.unselectedTextColor = 0xffffff;
			drawPropsStyle.inactiveTextColor = 0x999999;
			drawPropsStyle.inverseTextColor = 0xffffff;
			
			var c:ClipChooser;
			var cp:Position = new Position( { margin_top: 5, margin_left: 5 } );
			
			c = new ClipChooser(null, "", _iconsShapes, _iconsShapesAlts, 0, "", 60, 41, Position.POSITION_BELOW, drawPropsPos, drawPropsStyle);
			c.rowLength = 1;
			c.name = CreatorUIStates.SHAPE;
			c.alt = _iconsShapesAlt;
			c.addEventListener(Component.EVENT_CLICK, onClick);
			drawProps.addChild(c);
			shapes = c;
			
			c = new ClipChooser(null, "", _iconsConstraints, _iconsConstraintsAlts, 0, "", 60, 41, Position.POSITION_BELOW, drawPropsPos, drawPropsStyle);
			c.rowLength = 1;
			c.name = CreatorUIStates.MOVEMENT;
			c.alt = _iconsConstraintsAlt;
			c.addEventListener(Component.EVENT_CLICK, onClick);
			drawProps.addChild(c);
			constraints = c;

			c = new ClipChooser(null, "", _iconsMaterials, _iconsMaterialsAlts, 0, "", 60, 41, Position.POSITION_BELOW, drawPropsPos, drawPropsStyle);
			c.rowLength = 1;
			c.name = CreatorUIStates.MATERIAL;
			c.alt = _iconsMaterialsAlt;
			c.addEventListener(Component.EVENT_CLICK, onClick);
			drawProps.addChild(c);
			materials = c;
			
			c = new ClipChooser(null, "", _iconsStrengths, _iconsStrengthsAlts, 0, "", 60, 41, Position.POSITION_BELOW, drawPropsPos, drawPropsStyle);
			c.rowLength = 1;
			c.name = CreatorUIStates.STRENGTH;
			c.alt = _iconsStrengthsAlt;
			c.addEventListener(Component.EVENT_CLICK, onClick);
			drawProps.addChild(c);
			strengths = c;
			
			// PAINT ATTRIBS
			
			paintProps = new Cell(null, 510, 41, false, false, 0, Styles.absPosition);
			_subtools.addChild(paintProps);
			
			var colors:Array = [];
			var r:uint;
			var g:uint;
			var b:uint;
			var bw:uint;
			colors.push(CreatorUIStates.NONE);
			colors.push(0);
			for (bw = 0; bw <= 0xff; bw += 0x11) {
				colors.push(bw << 16 | bw << 8 | bw);
			}
			for (b = 0; b <= 0xff; b += 0x33) {
				for (r = 0; r <= 0x66; r += 0x33) {
					for (g = 0; g <= 0xff; g += 0x33) {
						colors.push(r << 16 | g << 8 | b);
					}				
				}
			}
			for (b = 0; b <= 0xff; b += 0x33) {
				for (r = 0x99; r <= 0xff; r += 0x33) {
					for (g = 0; g <= 0xff; g += 0x33) {
						colors.push(r << 16 | g << 8 | b);
					}				
				}
			}
			
			c = new ColorClipChooser(null, "", colors.concat(), ["No Fill"], 127, "", 60, 41, Position.POSITION_BELOW, drawPropsPos, drawPropsStyle);
			c.rowLength = 18;
			c.choicesPadding = 0;
			c.choicesShrink = 24;
			c.choicesOffsetX = -60;
			c.name = CreatorUIStates.DECORATE_FILL;
			c.alt = "Choose a new fill color for selected objects";
			c.addEventListener(Component.EVENT_CLICK, onClick);
			paintProps.addChild(c);
			fills = c;
			
			colors[1] = CreatorUIStates.GLOW;
			
			c = new ColorClipChooser(null, "", colors, ["No Line", "Glowing Edges"], 134, "", 60, 41, Position.POSITION_BELOW, drawPropsPos, drawPropsStyle);
			c.rowLength = 18;
			c.choicesPadding = 0;
			c.choicesShrink = 24;
			c.choicesOffsetX = -60;
			c.choicesLineMode = true;
			c.name = CreatorUIStates.DECORATE_LINE;
			c.alt = "Choose a new line color for selected objects";
			c.addEventListener(Component.EVENT_CLICK, onClick);
			paintProps.addChild(c);
			lines = c;
			
			c = new ClipChooser(null, "", _iconsTextures, [""], 8, "", 60, 41, Position.POSITION_BELOW, drawPropsPos, drawPropsStyle);
			c.rowLength = 4;
			c.choicesShrink = 11;
			c.name = CreatorUIStates.TEXTURE;
			c.alt = _iconsTexturesAlt;
			c.addEventListener(Component.EVENT_CLICK, onClick);
			paintProps.addChild(c);
			textures = c;
			
			c = new ClipChooser(null, "",
				[CreatorUIStates.LAYER_1, CreatorUIStates.LAYER_2, CreatorUIStates.LAYER_3, CreatorUIStates.LAYER_4, CreatorUIStates.LAYER_5], 
				["Front Layer", "", "", "", "Back Layer"], 2, "", 60, 41, Position.POSITION_BELOW, drawPropsPos, drawPropsStyle);
			c.rowLength = 1;
			c.name = CreatorUIStates.DECORATE_ZLAYER;
			c.alt = "Choose the overlapping layer for selected objects. Higher layers are in front of others.";
			c.addEventListener(Component.EVENT_CLICK, onClick);
			paintProps.addChild(c);
			zlayers = c;
			
			paintProps.hide();
			
			editProps = new Cell(null, 200, 41, false, false, 0, Styles.floatPosition);
			drawProps.addChild(editProps);
			
			var cbp:Position = Styles.floatPosition.clone( {
				margins: "13 0 0 6"
				} );
			
			moveLock = new ClipButton(null, 
				CreatorUIStates.MOVEMENT_UNLOCKED, 
				CreatorUIStates.MOVEMENT_LOCKED, 
				1, 30, 30, 10, false, false, false, false,
				cbp,
				drawPropsStyle
				);
				
			moveLock.name = CreatorUIStates.LOCK;
			moveLock.alt = _moveLockAlt;
			moveLock.toggledAlt = _moveLockAltToggled;
			editProps.addChild(moveLock);
			
			layersButton = new ClipButton(null, 
				CreatorUIStates.LAYERS, "", 
				1, 30, 30, 10, false, false, false, false,
				cbp,
				drawPropsStyle
				);
			layersButton.alt = _layersButtonAlt;
			editProps.addChild(layersButton);
			
			actionsButton = new ClipButton(null, 
				CreatorUIStates.ICON_ACTIONS, "", 
				1, 30, 30, 10, false, false, false, false,
				cbp,
				drawPropsStyle
				);
			actionsButton.alt = _actionsButtonAlt;
			editProps.addChild(actionsButton);
			
			var smStyle:Style = drawPropsStyle.clone();
			smStyle.round = 0;
			smStyle.background = false;
			smStyle.gradient = false;
			
			moveGroup = new ClipButton(null, 
				CreatorUIStates.MOVEMENT_UNGROUPED, 
				CreatorUIStates.MOVEMENT_GROUPED, 
				1, 30, 30, 10, false, false, false, false,
				cbp,
				drawPropsStyle
				);
				
			moveGroup.alt = _moveGroupAlt;
			moveGroup.toggledAlt = _moveGroupAltToggled;
			editProps.addChild(moveGroup);
			
			delSelection = new ClipButton(null,
				CreatorUIStates.DELETE, "",
				1, 30, 30, 10, false, false, false, false,
				cbp,
				drawPropsStyle
				);
				
			delSelection.alt = _delSelectionAlt;
			editProps.addChild(delSelection);
			
			opaque = new ClipButton(null, 
				CreatorUIStates.FILL_OPAQUE, 
				CreatorUIStates.FILL_TRANSPARENT, 
				1, 30, 30, 10, false, false, false, false,
				cbp,
				drawPropsStyle
				);
				
			opaque.name = CreatorUIStates.OPAQUE;
			opaque.alt = "Click to make fills transparent";
			opaque.toggledAlt = "Click to make fills opaque";
			paintProps.addChild(opaque);
			
			scribble = new ClipButton(null, 
				CreatorUIStates.EDGE_STRAIGHT, 
				CreatorUIStates.EDGE_SCRIBBLE, 
				1, 30, 30, 10, false, false, false, false,
				cbp,
				drawPropsStyle
				);
				
			scribble.name = CreatorUIStates.SCRIBBLE;
			scribble.alt = "Click to make edges scribbly";
			scribble.toggledAlt = "Click to make edges straight";
			paintProps.addChild(scribble);
			
			graphicsPanelToggle = new ClipButton(null, 
				CreatorUIStates.ICON_GRAPHICS_PANEL, 
				CreatorUIStates.ICON_GRAPHICS_PANEL, 
				1, 30, 30, 10, false, false, false, false,
				cbp,
				drawPropsStyle
				);
				
			graphicsPanelToggle.name = CreatorUIStates.ICON_GRAPHICS_PANEL;
			graphicsPanelToggle.alt = "Click to show graphics panel";
			graphicsPanelToggle.toggledAlt = "Click to hide graphics panel";
			paintProps.addChild(graphicsPanelToggle);
			
			animationToggle = new ClipButton(null, 
				CreatorUIStates.ICON_ANIMATION, 
				CreatorUIStates.ICON_ANIMATION, 
				1, 30, 30, 10, false, false, false, false,
				cbp,
				drawPropsStyle
				);
				
			animationToggle.name = CreatorUIStates.ICON_ANIMATION;
			animationToggle.alt = "Click to show graphic animation choices";
			animationToggle.toggledAlt = "Click to hide graphic animation choices";
			paintProps.addChild(animationToggle);
			animationToggle.disable();
			
			advancedTextureToggle = new ClipButton(null, 
				CreatorUIStates.ICON_ADVANCED_TEXTURES, 
				CreatorUIStates.ICON_ADVANCED_TEXTURES, 
				1, 30, 30, 10, false, false, false, false,
				cbp,
				drawPropsStyle
				);
				
			advancedTextureToggle.name = CreatorUIStates.ICON_ANIMATION;
			advancedTextureToggle.alt = "Click to show the advanced texture editor";
			advancedTextureToggle.toggledAlt = "Click to hide the advanced texture editor";
			paintProps.addChild(advancedTextureToggle);
			advancedTextureToggle.disable();
			
			// LAYERS MENU
			
			var layersMenuStyle:Style = drawPropsStyle.clone();
			layersMenuStyle.backgroundColor = 0x333333;
			layersMenuStyle.borderColor = 0;
			layersMenuStyle.borderWidth = 2;
			layersMenuStyle.bgGradientColors = [0x434343, 0x111111];
			layersMenuStyle.bgGradientHeight = 100;
			layersMenuStyle.bgGradient = true;
			
			layersMenu = new Cell(
				null, 130, 160, true, true, 8, 
				new Position(null, -1, Position.PLACEMENT_ABSOLUTE, -1, null, 44, -46, 2),
				layersMenuStyle);
			editProps.addChild(layersMenu);
			layersMenu.hideOnMouseOut = true;
			layersMenu.hideOnlyAfterMouseOver = true;
			
			layersButtons = new Cell(null, 110, 140, false, false, 0, new Position( { margins: "10 0 0 10" } ));
			layersMenu.addChild(layersButtons);
			
			var csbStyle:Style = drawPropsStyle.clone();
			csbStyle.backgroundColor = 0x333333;
			csbStyle.buttonFont = "Myriad Web Bold";
			csbStyle.embedFonts = true;
			csbStyle.buttonFontSize = 12;
			csbStyle.unselectedTextColor = 0x999999;
			csbStyle.borderWidth = 1;
			csbStyle.buttonTextColor = 0xffffff;
			csbStyle.inverseTextColor = 0xffffff;
			csbStyle.unselectedBorderColor = 0x666666;
			csbStyle.buttonBorderColor = 0xffffff;
			csbStyle.border = true;
			
			var csbbStyle:Style = csbStyle.clone( { } );
			csbbStyle.buttonTextColor = 0x0;
			csbbStyle.border = false;
			csbbStyle.buttonColor = 0x777777;
			
			var csbp:Position = Styles.floatPosition.clone({});
			csbp.margin_right = 2;
			csbp.margin_bottom = 2;
			
			var csb:ToggleButton;
			var n:int;
			
			var h:HTMLField;
			
			h = new HTMLField(null, "Collision Layers <a class=\"litelink\" href=\"event:showtag\">(?)</a>:", 110, false,
				new Position( { margin_left: -3 } ), 
				Styles.menuStyle);	
			h.alt = "Objects on the same layers will collide with eachother";
			layersButtons.addChild(h);
				
			for (n = 0; n < 5; n++) {
				csb = new ToggleButton(
					null, n + "", n + "", false, -1, 20, 20, 
					csbp,
					csbStyle);
				csb.alt = "Click to add this object to the layer";
				csb.toggledAlt = "Click to remove this object from the layer";
				layersButtons.addChild(csb);
				layers["c_" + n] = csb;
			}
				
			h = new HTMLField(null, "Passthru Layers <a class=\"litelink\" href=\"event:showtag\">(?)</a>:", 115, false, 
				new Position( { margin_top: 5, margin_left: -3 } ), 
				Styles.menuStyle);
			h.alt = "Objects on the same layers will pass through eachother";
			layersButtons.addChild(h);
			
			for (n = 0; n < 5; n++) {
				csb = new ToggleButton(
					null, String.fromCharCode(65 + n), String.fromCharCode(65 + n), false, -1, 20, 20, 
					csbp,
					csbStyle);
				csb.alt = "Click to add this object to the layer";
				csb.toggledAlt = "Click to remove this object from the layer";
				layersButtons.addChild(csb);
				layers["p_" + n] = csb;
			}
			
			h = new HTMLField(null, "Sensor Layers <a class=\"litelink\" href=\"event:showtag\">(?)</a>:", 110, false,
				new Position( { margin_top: 5, margin_left: -3 } ), 
				Styles.menuStyle)
			h.alt = "Objects on the same layers will send out Sense events when they touch eachother";
			layersButtons.addChild(h);
			sensorLayersTitle = h;
			
			var ccb:ClipButton;
			var ccbStyle:Style = csbStyle.clone();
			ccbStyle.selectedButtonColor = 0;
			for (n = 0; n < 5; n++) {
				ccb = new ClipButton(null, _layersSensorSymbols[n], _layersSensorSymbols[n] + "_selected", 0.6, 20, 20, 10, false, false, false, false, csbp, ccbStyle); 
				ccb.alt = "Click to add this object to the layer";
				ccb.toggledAlt = "Click to remove this object from the layer";
				layersButtons.addChild(ccb);
				layers["s_" + n] = ccb;
			}
			
			layersMenu.hide();
			
			drawProps.hide();
			
			
			// LAYER VIEW PANEL
			
			ddLayerView = new Cell(null, 135, 154, true, true, 0, Styles.absPosition.clone( { top: 45, left: 585, padding: 0 } ), Styles.dialogueStyle);
			cc.addChild(ddLayerView);
			ddLayerView.hide();
			ddLayerView.hideOnMouseOut = true;
			
			layerViewButtons = [];
			ddLayerSelectionIndicators = [];
			
			var d_button:BButton;
			var l_button:ClipButton;
			var l_dot:Shape;
			
			var l_pos:Position = new Position();
			l_pos.placement = Position.PLACEMENT_ABSOLUTE;
			l_pos.align = Position.ALIGN_LEFT;
			l_pos.top = 2;
			l_pos.left = 16;
			
			layerDefaultButtons = new TabGroup(null, ["Layer 1", "Layer 2", "Layer 3", "Layer 4", "Layer 5"], null, 2, 100, true, l_pos, Styles.trayStyle.clone( { padding: 12 } ));
			ddLayerView.addChild(layerDefaultButtons);
			ddLayerView.addChild(new Cell(null, 135, 2));
			
			var cp2:Position = new Position( { margin_left: 2 } );
			
			for (i = 0; i < 5; i++) {
			
				l_button = new ClipButton(null, 
					CreatorUIStates.EYE_CLOSED, 
					CreatorUIStates.EYE,
					1, 30, 30, 10, false, false, false, false,
					cp2,
					Styles.trayStyle
					);
					
				l_button.name = "layerview_" + i;
				l_button.value = i + "";
				
				ddLayerView.addChild(l_button);
				layerViewButtons.push(l_button);
				
				l_dot = new Shape();
				l_dot.graphics.beginFill(0xffec00);
				l_dot.graphics.drawCircle(0, 0, 4);
				l_dot.graphics.endFill();
				l_dot.x = 120;
				l_dot.y = 17 + i * 30;
				l_dot.blendMode = BlendMode.SCREEN;
				l_dot.visible = false;
				
				ddLayerView.mc.addChild(l_dot);
				ddLayerSelectionIndicators.push(l_dot);
				
			}
			
			
			
			
				
			// LAYERS VIEW TOGGLE
			
			layerViewToggle = new ClipButton(null, 
				CreatorUIStates.EYE, 
				CreatorUIStates.EYE, 
				1, 30, 30, 10, false, false, false, false,
				Styles.absPosition.clone( { top: 13, left: 690 } ),
				drawPropsStyle
				);
				
			layerViewToggle.name = CreatorUIStates.LAYERS_VIEW;
			layerViewToggle.alt = "Click to show and hide layers";
			cc.addChild(layerViewToggle);	
			
			// GLOBAL SETTINGS
			
			gameProps = new Cell(null, 410, 41, false, false, 0, Styles.absPosition);
			_subtools.addChild(gameProps);
			
			var settingsStyle:Style = Styles.menuStyle.clone( {
				buttonColor: 0,
				round: "6",
				buttonFontSize: 12,
				borderColor: 0x333333,
				buttonBorderColor: 0x333333,
				inverseTextColor: 0xcccccc,
				border: true,
				borderWidth: 1
				} );

			var settingsPos:Position = new Position( { 
				placement: Position.PLACEMENT_FLOAT, 
				margin_top: 17,
				margin_right: 3
				} );
			
			
			world = new BButton(null, "Playfield", -1, 80, NaN, false, false, false, settingsPos, settingsStyle);
			world.alt = "Edit the size of this level";
			gameProps.addChild(world);
			
			bkgd = new BButton(null, "Background", -1, 90, NaN, false, false, false, settingsPos, settingsStyle);
			bkgd.alt = "Change the background image for this level";
			bkgd.forceWidth = true;
			gameProps.addChild(bkgd);
			
			goals = new BButton(null, "Goals", -1, 50, NaN, false, false, false, settingsPos, settingsStyle);
			goals.alt = "Manage and edit the goals for this level";
			goals.forceWidth = true
			gameProps.addChild(goals);
			
			music = new BButton(null, "Music", -1, 50, NaN, false, false, false, settingsPos, settingsStyle);
			music.alt = "Add music to this level";
			music.forceWidth = true;
			gameProps.addChild(music);
			
			/*
			dd = new Divider(null, 2, 25, true, Styles.floatPosition.clone( { margin_left: 7, margin_right: 10, margin_top: 18 } ) , Styles.menuStyle.clone( { borderWidth: 2 } ));
			gameProps.addChild(dd);
			
			clipboard = new BButton(null, "Clipboard", -1, NaN, NaN, false, false, false, settingsPos, settingsStyle);
			clipboard.alt = "Copy and paste stuff into the game";
			gameProps.addChild(clipboard);
			*/
			
			//
			// SCROLLBARS
			
			var scrollStyle:Style = Styles.dialogueStyle.clone();
			scrollStyle.buttonColor = 0;
			scrollStyle.unselectedColor = 0;
			
			vScroll = new ScrollBar(this, 20, 454, Position.ORIENTATION_VERTICAL, Styles.absPosition, scrollStyle);
			vScroll.targetCell = playfieldContainer;
			vScroll.x = 838;
			vScroll.y = 92;
			vScroll.hide();
			
			hScroll = new ScrollBar(this, 698, 20, Position.ORIENTATION_HORIZONTAL, Styles.absPosition, scrollStyle);
			hScroll.targetCell = playfieldContainer;
			hScroll.x = 138;
			hScroll.y = 548;
			hScroll.hide();
			
			zoomToggle = new ClipButton(this, 
				CreatorUIStates.ZOOM_OUT, CreatorUIStates.ZOOM_IN, 
				0.1, 20, 20, 2, false, false, false, false, Styles.absPosition, scrollStyle);
			zoomToggle.x = 838;
			zoomToggle.y = 548;
			zoomToggle.alt = "Zoom out and view whole game area";
			zoomToggle.toggledAlt = "Zoom in and view a part of the game for more precise editing";
			zoomToggle.hide();
			
			setChildIndex(playfieldContainer.mc, 0);
			setChildIndex(vScroll.mc, 1);
			setChildIndex(hScroll.mc, 2);
			setChildIndex(zoomToggle.mc, 3);
			
			clipboard = new BButton(this, "Clipboard", -1, 100, 30, false, false, false, null, toolsStyle);
			clipboard.x = 860 - 100 - 61;
			clipboard.y = 600 - 30;
			clipboard.alt = "Copy and paste stuff into the game";
			//_ui.addChild(clipboard);
			
			undoButton = library.getDisplayObject(CreatorUIStates.BUTTON_UNDO) as SimpleButton;
			undoButton.x = 860 - 45;
			undoButton.y = 600 - 15;
			addChild(undoButton);
			
			redoButton = library.getDisplayObject(CreatorUIStates.BUTTON_REDO) as SimpleButton;
			redoButton.x = 860 - 15;
			redoButton.y = 600 - 15;
			addChild(redoButton);
			
			helpButton = library.getDisplayObject(CreatorUIStates.BUTTON_HELP) as SimpleButton;
			helpButton.x = 860 - 20;
			helpButton.y = 20;
			menu.mc.addChild(helpButton);
			
			modifierPropertiesEditor = new ModifierPropertiesEditor(this);
			
			buildDialogues();
			
			testMask = new Sprite();
			DrawingMethods.rect(testMask, true, 0, 0, stage.stageWidth, stage.stageHeight, 0, 0.25);
			DrawingMethods.rect(testMask, false, 136, 90, 44, stage.stageHeight - 90 - 20, 0x333333, 1);
			DrawingMethods.rect(testMask, false, 820, 90, 40, stage.stageHeight - 90 - 20, 0x333333, 1);
			addChild(testMask);
			testMask.visible = false;
			
			var tStyle:Style = Styles.dialogueStyle.clone();
			tStyle.buttonColor = 0;
			tStyle.round = 10;
			tStyle.border = true;
			tStyle.borderWidth = 2;
			tStyle.unselectedBorderColor = 0x3333333;
			
			_testEndButtonContainer = new Cell(this, 724, 43, true, false, 0, Styles.absPosition, new Style( { backgroundColor: 0x000000 } ));
			_testEndButtonContainer.x = 136;
			_testEndButtonContainer.y = 44;
			
			_testEndButtonContainer.addChild(new HTMLField(null, "<p>Testing Game Level:</p>", 300, false, Styles.floatPosition.clone( { margins: "11 0 0 12" } ), Styles.dialogueStyle.clone( { fontSize: 16 } ))); 
			
			_testEndButton = new BButton(null, "Click here when you are done testing", -1, 240, 32, false, false, false, new Position( { placement: Position.PLACEMENT_FLOAT, margins: "5 0 0 164" } ), tStyle);
			_testEndButtonContainer.addChild(_testEndButton);
			_testEndButtonContainer.hide();
			
		}
		
		protected function buildDialogues ():void {
			
			notice = new Notice();
			notice.style = Styles.dialogueStyle;
			notice.icon = CreatorUIStates.ALERT;
			stage.addChild(notice);
			
			ddWelcome = new DialogueWelcome(_creator, 320, 320);
			ddWelcome.create();
			
			ddClipboard = new DialogueClipboard(_creator, 560, 280, "Clipboard");
			ddClipboard.create();
			
			ddActionMatrix = new DialogueActionMatrix(_creator, 580, 500, "Object Actions");
			ddActionMatrix.create();
			
			ddEnvironment = new DialogueEnvironment(_creator, 440, 420, "Playfield Settings");
			ddEnvironment.create();
			
			ddBackground = new DialogueBackground(_creator, 580, 420, "Background Settings");
			ddBackground.create();
			
			ddGoals = new DialogueGoals(_creator, 500, 360, "Level Goals");
			ddGoals.create();
			
			ddConfirm = new DialogueConfirm(_creator, 440, 150, "Confirm Action");
			ddConfirm.create();
			
			ddAlert = new DialogueAlert(_creator, 440, 130, "");
			ddAlert.create();
			
			ddPublish = new DialoguePublish(_creator, 440, 220, "Publish Game");
			ddPublish.create();
			
			ddPublishComplete = new DialoguePublishComplete(_creator, 440, 240, "Game Publish");
			ddPublishComplete.create();
			
			ddEmbed = new DialogueEmbed(_creator, 440, 240, "Embed your Game", ["Cancel", "Copy to Clipboard"]);
			ddEmbed.create();
			
			ddServer = new DialogueServer(_creator, 440, 240, "Server Interaction", ["Close"]);
			ddServer.create();
			
			ddManager = new DialogueFileManager(_creator, 480, 420, "Load a Game", ["Cancel", "OK"]);
			ddManager.create();
			
			ddMusic = new DialogueMusicManager(_creator, 330, 480, "Add Music", ["Cancel", "Remove Music", "Select Music"]);
			ddMusic.create();
			
			ddTextureGen = new DialogueTextureGen(_creator, 560, 410, "Advanced Texture Editor", []);
			ddTextureGen.create();
				
		}
		
		protected function onClick (e:Event):void {
			
			//trace(e.target.name);
			
		}
		
	}

}