package com.sploder.builder 
{
	
	import com.adobe.images.PNGEncoder;
	import com.sploder.builder.model.Environment;
	import com.sploder.builder.ui.DialogueFileManager;
	import com.sploder.data.User;
	import com.sploder.game.Simulation;
	import com.sploder.game.sound.SoundManager;
	import com.sploder.util.Base64;
	import com.sploder.util.Cleanser;
	import com.sploder.util.Settings;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	
	
	/**
	 * ...
	 * @author ...
	 */
	public class CreatorProject extends EventDispatcher {
		
		public static const EVENT_LOAD:String = "load";
		public static const EVENT_SAVE:String = "save";
		public static const EVENT_NEW:String = "new";
		public static const EVENT_TEST:String = "test";
		
		protected var _creator:Creator;
		
		protected var _xml:XMLDocument;
		public function get xml():XMLDocument { return _xml; }
		public function set xml(value:XMLDocument):void { _xml = value;	}
		
		protected var _sharedObjectName:String = "creator5temp";
		public function get sharedObjectName():String { return _sharedObjectName; }

        public var previewWidth:Number = 480;
        public var previewHeight:Number = 360;
		
        public var isprivate:Boolean = false;
        public var comments:Boolean = true;
		public var turbo:Boolean = false;
		public var allowcopying:Boolean = false;
		
        public var pubkey:String;

		public var title:String;
		public var author:String;
		public var projID:String;
		public var pubDate:Date;
		
		public var saved:Boolean = false;
		
		protected var _version:int = 5;
		public function get version():int { return _version; }
		
        public var gameXML:XMLDocument;
		
		protected var _newXMLString:String = '<project title=""><levels id="levels"><level></level></levels><graphics></graphics></project>';
		protected var _prevXMLString:String = "";
		
		
		protected var _saveURL:String = "";
		protected var _saveParams:String = "";
		protected var _publishURL:String = "";
		
		protected var _projectVars:URLVariables;
		protected var _projectRequest:URLRequest;
		protected var _projectSaver:URLLoader;
		
		protected var _gameVars:URLVariables;
		protected var _gameRequest:URLRequest;
		protected var _gameSaver:URLLoader;
		
		protected var _savingAs:Boolean = false;
		public function get savingAs():Boolean { return _savingAs; }
		public function set savingAs(value:Boolean):void { _savingAs = value; }
		
		protected var _bigThumb:ByteArray;
		protected var _smallThumb:ByteArray;
		protected var _bigThumbRequest:URLRequest;
		protected var _smallThumbRequest:URLRequest;
		protected var _bigThumbSaver:URLLoader;
		protected var _smallThumbSaver:URLLoader;
		
		protected var _getProjectURL:String = "/php/getproject.php";
		protected var _thumbPostURL:String = "/php/savethumb.php";
		
		protected var _localSaveTimer:Timer;
		
		protected var _transferring:Boolean = false;
		
		//
		//
		public function CreatorProject(creator:Creator, saveURL:String, saveParams:String = "", publishURL:String = "") {
			
			init(creator, saveURL, saveParams, publishURL);
			
		}
		
		//
		//
		protected function init (creator:Creator, saveURL:String, saveParams:String = "", publishURL:String = ""):void {
			
			_creator = creator;
			_saveURL = saveURL;
			_saveParams = saveParams;
			_publishURL = publishURL;
			
			_sharedObjectName = "creator" + Creator.GAME_VERSION + "temp";
			
			_localSaveTimer = new Timer(10000, 0);
			_localSaveTimer.addEventListener(TimerEvent.TIMER, saveLocalProject);
			_localSaveTimer.start();
			
			_xml = new XMLDocument(_newXMLString);
				
		}
		
		//
		//
		public function onManagerConfirm (e:Event):void {
			
			trace("MANAGER CONFIRM");
			
			if (_creator.ui.ddManager.mode == DialogueFileManager.MODE_LOAD) {
				loadProject();
			} else if (_creator.ui.ddManager.mode == DialogueFileManager.MODE_SAVE) {
				saveProject();
			}

		}
		
        //
        //
        //
        public function getObjects (level:uint = 0):String {
           
			var objectsNode:XMLNode;
			
			if (_xml != null &&
				_xml.idMap["levels"] != null) {
			
				if (_xml.idMap["levels"].childNodes.length > level) {
				
					objectsNode = _xml.idMap["levels"].childNodes[level];  

					return objectsNode.firstChild.nodeValue;
				
				}
			
			} else if (_xml != null &&
				_xml.firstChild.firstChild != null) {
			
				if (_xml.firstChild.firstChild.childNodes.length > level) {
				
					objectsNode = _xml.firstChild.firstChild.childNodes[level];  

					return objectsNode.firstChild.nodeValue;
				
				}
				
			}
			
			return "";
            
        }
		
 		//
        //
        //
        public function getEnvironment (level:uint = 0):String {
            
			var objectsNode:XMLNode;
			
			if (_xml != null &&
				_xml.idMap["levels"] != null) {
			
				if (_xml.idMap["levels"].childNodes.length > level) {
				
					objectsNode = _xml.idMap["levels"].childNodes[level];  

					if (objectsNode != null && objectsNode.attributes["env"] != null) return objectsNode.attributes["env"];
				
				}
			
			} else if (_xml != null &&
				_xml.firstChild.firstChild != null) {
			
				if (_xml.firstChild.firstChild.childNodes.length > level) {
				
					objectsNode = _xml.firstChild.firstChild.childNodes[level];  

					if (objectsNode != null && objectsNode.attributes["env"] != null) return objectsNode.attributes["env"];
				
				}
			
			}
			
			return "";
            
        }
		

		//
		//
		public function getTotalLevels ():uint {
			
			if (_xml != null &&
				_xml.idMap["levels"] != null) {
			
				return _xml.idMap["levels"].childNodes.length;
				
			} else if (_xml != null &&
				_xml.firstChild.firstChild != null) {
			
				return _xml.firstChild.firstChild.childNodes.length;
				
			}
				
			return 0;
			
		}
		
		
        //
        //
        // BUILD BLANK PROJECT XML
        public function newDocument ():void {

            _xml = new XMLDocument(_newXMLString);
			pubkey = projID = null;
			title = "";
			comments = true;
			isprivate = false;
			turbo = false;
			allowcopying = false;

			_version = 5;
			
			clearLocalProject();
			
		}
        
        //
        //
        //
        public function buildDocument (currentLevelOnly:Boolean = false, addGraphics:Boolean = false):void {
			
			if (_xml == null) newDocument();
			
			_creator.levels.saveCurrentLevel();
			_creator.levels.saveCurrentEnvironment();
			
			var levelsNodes:String = "";
			var i:int;
			
			if (!currentLevelOnly) {
				
				for (i = 0; i < _creator.levels.totalLevels; i++) {
					
					levelsNodes += "<level env=\"" + _creator.levels.exportEnvironmentData(i) + "\">" + _creator.levels.exportLevelData(i) + "</level>";
				
				}
			
			} else {
				
				levelsNodes += "<level env=\"" + _creator.levels.exportEnvironmentData(_creator.levels.currentLevel) + "\">" + _creator.levels.exportLevelData(_creator.levels.currentLevel) + "</level>";
				
			}
			
			var template:String = _newXMLString;
			template = template.split("<level></level>").join(levelsNodes);
			
			// add graphics
			
			if (addGraphics) {
				var graphics:Object = _creator.levels.exportGraphics();
				var graphicsNodes:String = "";
				for (var name:String in graphics) {
					var newGraphicsNode:String = "";
					try {
						if (graphics[name] is BitmapData && BitmapData(graphics[name]).width > 0 && BitmapData(graphics[name]).height > 0) {	
							var png:ByteArray = PNGEncoder.encode(BitmapData(graphics[name]));
							if (png is ByteArray) {
								var bString:String = Base64.encodeByteArray(png);
								newGraphicsNode = "<graphic name=\"" + name + "\">" + bString + "</graphic>";
							}
						}
					} catch (e:Error) {
						if (e.errorID == 2015) {
							newGraphicsNode = "";
						}
					}
					graphicsNodes += newGraphicsNode;
				}
				template = template.split("<graphics></graphics>").join("<graphics>" + graphicsNodes + "</graphics>");
			}
			
			_xml = new XMLDocument(template);
			
			if (projID != null && projID.length > 0) _xml.firstChild.attributes.id = projID;
			_xml.firstChild.attributes.pubkey = pubkey;
			
			_xml.firstChild.attributes.title = escape(title);
			if (author != null && author.length > 0) _xml.firstChild.attributes.author = author;
			else _xml.firstChild.attributes.author = "demo";
			
            _xml.firstChild.attributes.mode = _creator.gameMode;
			_xml.firstChild.attributes.date = _creator.today;
			_xml.firstChild.attributes.comments = (comments) ? "1" : "0";
			_xml.firstChild.attributes.isprivate = (isprivate) ? "1" : "0";
			_xml.firstChild.attributes.turbo = (turbo) ? "1" : "0";
			_xml.firstChild.attributes.allowcopying = (allowcopying) ? "1" : "0";
			
        }
		
        //
        //
        //
        public function buildProject ():void {

			trace("Building Project...");
			_creator.ui.ddServer.hide();
			
			_version = 5;
			
			if (_xml.firstChild.attributes.id != undefined) {
				projID = _xml.firstChild.attributes.id;
			} else {
				projID = "";
			}
			
			if (_xml.firstChild.attributes.title != undefined) {
				title = unescape(_xml.firstChild.attributes.title);
			} else {
				title = "";
			}
			
			if (_xml.firstChild.attributes.mode != undefined) {
				_creator.setGameMode(parseInt(_xml.firstChild.attributes.mode));
			} else {
				_creator.setGameMode(5);
			}
			
			turbo = (_xml.firstChild.attributes.turbo == "1");
			comments = (_xml.firstChild.attributes.comments != "0");
			isprivate = (_xml.firstChild.attributes.isprivate == "1");
			allowcopying = (_xml.firstChild.attributes.allowcopying == "1");
			
			extractGraphicsFromXMLDocument();
			
        }
		
		protected function extractGraphicsFromXMLDocument ():void {
			
			_creator.graphics.clean();
			
			if (_xml && 
				_xml.firstChild && 
				_xml.firstChild.firstChild && 
				_xml.firstChild.firstChild.nextSibling) {
				
				var graphicsNode:XMLNode = _xml.firstChild.firstChild.nextSibling;
				
				for (var i:int = 0; i < graphicsNode.childNodes.length; i++) {
					
					var name:String = XMLNode(graphicsNode.childNodes[i]).attributes.name;
					
					if (name && !Textures.isLoaded(name)) {
						
						var pngString:String = XMLNode(graphicsNode.childNodes[i]).firstChild.nodeValue;
						
						if (pngString) {
							
							var bytes:ByteArray = Base64.decodeToByteArray(pngString);
							
							if (bytes) {
								
								var loader:Loader = new Loader();
								loader.name = name;
								loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onGraphicExtracted);
								loader.loadBytes(bytes);
								
							}
							
						}
						
					}
					
				}
				
			}
			
		}
		
		protected function onGraphicExtracted (e:Event):void {
			
			if (e.target is LoaderInfo) {
				var loader:Loader = LoaderInfo(e.target).loader;
				if (loader.content is Bitmap) {
					Textures.addBitmapDataToCache(loader.name, Bitmap(loader.content).bitmapData);
				} else {
					trace("Error: loaded file is not bitmap", loader.name, loader.content);
				}
			}
			
		}
			
        //
        //
        // GETPROJECT loads the project XML from the server
        public function getProject (id:uint):void {
            
            _creator.ui.ddServer.alert("Loading Project...");
			
			_transferring = true;
			
			CreatorMain.dataLoader.loadXMLData(
				_getProjectURL + CreatorMain.dataLoader.getCacheString("u=" + User.u + "&c=" + User.c + "&p=" + id), 
				true, 
				onProjectLoaded, onProjectLoadError
				);
            
        }
		
		//
		//
		public function onProjectLoaded (e:Event):void {
		
			_xml = new XMLDocument();
			_xml.ignoreWhite = true;
			_xml.parseXML(e.target.data);
			
			_transferring = false;
			
			_creator.ui.ddServer.hide();
			
			buildProject();
			
			clearLocalProject();
			
			dispatchEvent(new Event(EVENT_LOAD));
			
		}
		
		//
		//
		public function onProjectLoadError (e:IOErrorEvent):void {
		
			_transferring = false;
			
			_creator.ui.ddServer.hide();
			_creator.uiController.alert("Unable to load project.  There was a problem loading it from the server");
			
		}
		
        //
        //
        //
        public function newProject ():void {
            
			_creator.graphics.clean();
			
			newDocument();
			
			pubkey = "";
			_creator.ui.ddManager.currentProjectID = null;
			_creator.ui.ddManager.currentProjectTitle = "";
			projID = "";
			
			dispatchEvent(new Event(EVENT_NEW));
			
			_transferring = false;
			

        }
		
		//
		//
		public function saveLocalProject (e:TimerEvent = null):void {
			
			if (!_transferring && !_creator.model.populating && _creator.model.objects.length > 0) {
				
				buildDocument(false, true);
				
				var xmlString:String = _xml.toString();
				
				if (xmlString != _prevXMLString) {

					Settings.saveSetting(_sharedObjectName, xmlString);
					_prevXMLString = xmlString;
					
				}
			
			}
			
		}
		
		//
		//
		public function get hasLocalProject ():Boolean {
				
			return (Settings.loadSetting(_sharedObjectName) != null && String(Settings.loadSetting(_sharedObjectName)).length > 0);
			
		}
		
		//
		//
		public function confirmLoadLocalProject ():void {
			
			_creator.uiController.confirm(this, loadLocalProject, null, "Your project was saved in memory.  Click OK to restore it.");
			
		}
		
		//
		//
		public function loadLocalProject (e:Event = null):void {
			
			if (hasLocalProject) {
				
				_prevXMLString = Settings.loadSetting(_sharedObjectName) as String;
				_xml = new XMLDocument(_prevXMLString);
				
				buildProject();
				
				dispatchEvent(new Event(EVENT_LOAD));
				
			}
			
		}
		
		//
		//
		public function clearLocalProject ():void {
			
			Settings.saveSetting(_sharedObjectName, "");
			trace("clearing local project");
			_prevXMLString = _xml.toString();
			
		}
		
        //
        //
        //
        public function testProject (e:Event = null, currentLevelOnly:Boolean = false):void {
   
			buildDocument(currentLevelOnly);

			User["data"] = "";
			
			User["data"] = _xml.toString();

			_creator.test();
			
			dispatchEvent(new Event(EVENT_TEST));

        }
		
        //
        //
        //
        public function loadProject ():void {
            
			trace("loading project...");

			getProject(parseInt(_creator.ui.ddManager.currentProjectID.split("proj").join("")));

        }
		
       
        //
        //
        //
        public function saveProject ():void {

            if ((_creator.model.objects.length > 0) && !_creator.demo) {

				if (_xml && 
					_creator.ui.ddManager.currentProjectID != null && 
					_creator.ui.ddManager.currentProjectID.length > 0 &&
					_creator.ui.ddManager.currentProjectID != _xml.firstChild.attributes.id &&
					_creator.ui.ddManager.currentProjectTitle != null &&
					_creator.ui.ddManager.currentProjectTitle.length > 0
					) {

					projID = _creator.ui.ddManager.currentProjectID;
					title = Cleanser.cleanse(_creator.ui.ddManager.currentProjectTitle);
					if (title.length == 0) title = "My New Game";
					trace("saving project data over old project...");
					
					saveConfirm();
					
				} else if (_xml && _xml.firstChild.attributes.id != undefined && !_savingAs) {

					projID = _xml.firstChild.attributes.id;
					title = unescape(_xml.firstChild.attributes.title);
					trace("saving existing project data...");
					saveProjectData();
					
				} else if (_xml && _creator.ui.ddManager.currentProjectTitle != null &&
					_creator.ui.ddManager.currentProjectTitle.length > 0 && 
					_creator.ui.ddManager.currentProjectTitle.indexOf("...") == -1) {

					projID = "";
					_creator.ui.ddManager.currentProjectID = "";
					delete _xml.firstChild.attributes.id;
					title = Cleanser.cleanse(_creator.ui.ddManager.currentProjectTitle);
					if (title.length == 0) title = "My New Game";
					trace("saving new project data...");
					saveProjectData();
						
				} else {
					
					trace("saving project as...");
					saveProjectAs();

				}
				
            }
            
        }
        
        //
        //
        // SAVEPROJECTAS shows the game manager to save games...
        public function saveProjectAs ():void {
            
            if (_creator.model.objects.length > 0 && !_creator.demo) {
				
				_creator.ui.ddManager.title = "Save Your Game";
				if (_xml) {
					_creator.ui.ddManager.currentProjectID = _xml.firstChild.attributes.id;
					_creator.ui.ddManager.currentProjectTitle = unescape(_xml.firstChild.attributes.title);
				} else {
					_creator.ui.ddManager.currentProjectID = "";
					_creator.ui.ddManager.currentProjectTitle = "";
				}
				_creator.ui.ddManager.mode = DialogueFileManager.MODE_SAVE;
				_creator.ui.ddManager.loadList();

			}

        }
        
        //
        //
        // SAVECONFIRM Checks user confirmation and saves a show to the server
        public function saveConfirm (confirm:Boolean = false):void {

			_creator.uiController.confirm(
				this, 
				overwriteProjectData, 
				null, 
				"Saving this project will overwrite your previous project."
				);
            
        }
		
		//
		//
		protected function overwriteProjectData (e:Event = null):void {
			
			if (projID != null && projID.length > 0 && title != null && title.length > 0) {
				_xml.firstChild.attributes.id = projID;
				saveProjectData();
			}
			
		}
        
        //
        //
        // SAVEPROJECTDATA saves the project XML to the server
        public function saveProjectData ():void {
            
			_creator.ui.ddServer.alert("Saving Game Project...");
			CreatorMain.mainStage.invalidate();
			
            buildDocument(false, true);

			_projectVars = new URLVariables();
			
            if ((_xml.firstChild.attributes.id == undefined) || (_xml.firstChild.attributes.id.length < 3)) {
                
                trace("saving unsaved project");
                _xml.firstChild.attributes.id = "noid-unsaved-project";
				
				trace("saving project", CreatorMain.dataLoader.baseURL, _saveURL, CreatorMain.dataLoader.getCacheString(_saveParams));
                _projectRequest = new URLRequest(CreatorMain.dataLoader.baseURL + _saveURL + CreatorMain.dataLoader.getCacheString(_saveParams));

                
            } else {
                
                trace("saving previously saved project:", CreatorMain.dataLoader.baseURL + _saveURL + CreatorMain.dataLoader.getCacheString(_saveParams + "&projid=" + _xml.firstChild.attributes.id));
				_projectRequest = new URLRequest(CreatorMain.dataLoader.baseURL + _saveURL + CreatorMain.dataLoader.getCacheString(_saveParams + "&projid=" + _xml.firstChild.attributes.id));
    
				
            }
            
            _xml.firstChild.attributes.title = escape(unescape(unescape(_xml.firstChild.attributes.title)));
			_projectVars.xml = _xml.toString();
			
			_projectRequest.method = URLRequestMethod.POST;
			_projectRequest.data = _projectVars;
			
			_projectSaver = new URLLoader();
			_projectSaver.addEventListener(Event.COMPLETE, saveResult);
			_projectSaver.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_projectSaver.load(_projectRequest);
			
			_transferring = true;
            
        }  
		
		//
		//
		public function onSaveError (e:Event):void {

			_projectSaver.removeEventListener(Event.COMPLETE, saveResult);
			_projectSaver.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			
			_creator.uiController.alert("There was an error saving your project. It has been saved to memory.  Please try again later.");
			
			_transferring = false;
			
			saveLocalProject();
			
		}
        
        
        //
        //
        //
        public function saveResult (e:Event):void {
			
			_projectSaver.removeEventListener(Event.COMPLETE, saveResult);
			_projectSaver.removeEventListener(IOErrorEvent.IO_ERROR, CreatorMain.dataLoader.onXMLDataError);
			
			try {
				var result:XML = new XML(e.target.data);
			} catch (err:Error) {
				_creator.ui.ddServer.alert("There was a problem saving your project.");
				_creator.uiController.notice(e.target.data);
				//trace(e.target.data);
				return;
			}
			
			_creator.ui.ddServer.hide();
			
			if (result.@result == "success") {
				
				var newID:String = result.@id;
				
				if (newID != null && newID.length > 0) {
					projID = _xml.firstChild.attributes.id = newID;
				}
				
				generateThumbnails();
				saveThumbnails();
			
				if (pubkey != null && pubkey.length > 0) {
					_creator.uiController.alert("Your game was successfully saved.");	
				} else {
					_creator.uiController.alert("Your game was successfully saved.  When you are done, don't forget to publish!");
				}
				
				clearLocalProject();
				
			} else {
				
				_creator.uiController.alert("Sorry! save failed. Please try again in a few seconds.");
				_creator.uiController.notice(result.@message);
				delete _xml.firstChild.attributes.id;
				
			}
			
			
			if (_xml.firstChild.attributes.id == "noid_unsaved_project") {
				delete _xml.firstChild.attributes.id;
			}
			
			_transferring = false;
            
        }
		

        //
        //
        // PUBLISHGAME publishes the game
        public function publishGame ():void {
            
            if ((_creator.model.objects.length > 0) && !_creator.demo && (_xml.firstChild.attributes.id != "noid-unsaved-project") && (_xml.firstChild.attributes.id != undefined)) {
                  
                _creator.ui.ddPublish.show();
                
            } else {
                
				if (_creator.demo) {
					
					saveLocalProject();
					_creator.uiController.alert(CreatorUIStates.MESSAGE_GAME_DEMO);
					
				} else if ((_xml.firstChild.attributes.id == "noid-unsaved-project") || (_xml.firstChild.attributes.id == undefined)) {
					
					_creator.uiController.alert("You must save your project before you publish it. Click 'Save' to save your work.");

				} else if (_creator.model.objects.length < 1) {
					
					_creator.uiController.alert("You must have objects on the playfield to publish your game.  Drag some objects onto the playfield.");

				}

            }
            
        }
    
        //
        //
        // PUBLISHPROJECT saves the optimized XML for the game
        public function publishProject ():void {
            
            buildDocument(false, true);
			
			gameXML = new XMLDocument(_xml.toString());
			
			_gameVars = new URLVariables();
			
            if ((_xml.firstChild.attributes.id == undefined) || (_xml.firstChild.attributes.id.length < 3)) {
                _gameRequest = new URLRequest(CreatorMain.dataLoader.baseURL + _publishURL + CreatorMain.dataLoader.getCacheString("projid=temp"));        
            } else {
                _gameRequest = new URLRequest(CreatorMain.dataLoader.baseURL + _publishURL + CreatorMain.dataLoader.getCacheString("projid=" + _xml.firstChild.attributes.id + "&comments=" + (comments ? "1" : "0") + "&private=" + (isprivate ? "1" : "0")));
            }
			
			_gameVars.xml = gameXML.toString();
			
            _creator.ui.ddServer.alert("Publishing Game ...");
			
			_gameRequest.method = URLRequestMethod.POST;
			_gameRequest.data = _gameVars;
			
			_gameSaver = new URLLoader();
			_gameSaver.addEventListener(Event.COMPLETE, publishResult);
			_gameSaver.addEventListener(IOErrorEvent.IO_ERROR, CreatorMain.dataLoader.onXMLDataError);
			_gameSaver.load(_gameRequest);
			
			_transferring = true;
            
        }    
    
    
        //
        //
        //
        public function publishResult (e:Event):void {
			
			_gameSaver.removeEventListener(Event.COMPLETE, publishResult);
			_gameSaver.removeEventListener(IOErrorEvent.IO_ERROR, CreatorMain.dataLoader.onXMLDataError);

			try {
				var result:XML = new XML(e.target.data);
			} catch (err:Error) {
				_creator.ui.ddServer.alert("There was a problem publishing your game.");
				_creator.uiController.notice(e.target.data);
				return;
			}
			
			_creator.ui.ddServer.hide();
			
			if (result.@result == "success") {
				
				 pubkey = result.@pubkey;
				_creator.ui.ddPublishComplete.alert("Playing published game.  If you are blocking pop-ups, click 'PLAY AGAIN'.");
				navigateToURL(new URLRequest("javascript: playPubMovie('" + pubkey + "',480);"), "_self");
				
			} else {
				
				_creator.uiController.alert("Sorry! Publish failed. Please try again in a few seconds.");
				_creator.uiController.notice(result.@message);
				
			}
			
			_transferring = false;

        }
		
		//
		//
		public function playPubMovie (e:MouseEvent = null):void {
			
			if (pubkey != null && pubkey.length > 0) navigateToURL(new URLRequest("javascript: playPubMovie('" + pubkey + "',480);"), "_self");
			
		}
		
		//
		//
		public function generateThumbnails ():void {
			
			var s:Sprite = new Sprite();
			CreatorMain.mainStage.addChild(s);
			
			var size:int = _creator.environment.size;
			if (_creator.environment.size == Environment.SIZE_FOLLOW) {
				_creator.environment.size = Environment.SIZE_DOUBLE;
			}
			
			CreatorMain.mainStage.quality = StageQuality.BEST;
			
			SoundManager.hasSound = false;
			
			var sim:Simulation = new Simulation(s, _creator.model, _creator.environment, false);
			sim.build();
			sim.start();
			for (var i:int = 0; i < 10; i++) sim.stepDouble();
			
			var gon:MovieClip = CreatorUI.library.getDisplayObject(CreatorUIStates.ICON_NUMLEVELS) as MovieClip;
			gon.gotoAndStop(_creator.levels.totalLevels);
			
			var bA:BitmapData = new BitmapData(220, 220, false, 0x000000);
			var m:Matrix = new Matrix();
			m.createBox(220 / 640, 220 / 640, 0, 0, 80 * (220 / 640));
			bA.draw(s, m, null, null, null, true);
			m.createBox(1, 1, 0, 140, 140);
			bA.draw(gon);
			_bigThumb = PNGEncoder.encode(bA);
			
			// TEST
			//CreatorMain.mainStage.addChild(new Bitmap(bA));
			
			var bB:BitmapData = new BitmapData(80, 80, false, 0x000000);
			var m2:Matrix = new Matrix();
			m2.createBox(80 / 480, 80 / 480, 0, -80 * (80 / 480), 0);
			bB.draw(s, m2, null, null, null, true);
			bB.draw(gon);
			
			_smallThumb = PNGEncoder.encode(bB);
			
			sim.stop();
			if (s.parent) s.parent.removeChild(s);
			sim.end();
			
			SoundManager.hasSound = true;
			
			_creator.environment.size = size;
			CreatorMain.mainStage.quality = StageQuality.HIGH;
			
			// TEST
			//CreatorMain.mainStage.addChild(new Bitmap(bB));
			
		}
		
		//
		//
		protected function saveThumbnails ():void {
			
			_smallThumbRequest = new URLRequest(CreatorMain.dataLoader.baseURL + _thumbPostURL + CreatorMain.dataLoader.getCacheString("projid=" + _xml.firstChild.attributes.id + "&size=small"));
			_smallThumbRequest.method = URLRequestMethod.POST;
			_smallThumbRequest.contentType = "application/octet-stream";
			_smallThumbRequest.data = _smallThumb;
			trace("SMALL PNG SIZE:" + _smallThumb.length);
			_smallThumbSaver = new URLLoader();
			_smallThumbSaver.addEventListener(IOErrorEvent.IO_ERROR, onSmallThumbError);
			_smallThumbSaver.addEventListener(Event.COMPLETE, onSmallThumbSaved);
			_smallThumbSaver.load(_smallThumbRequest);

		}
		
		//
		//
		protected function onSmallThumbError (e:IOErrorEvent):void {
			
			_smallThumbSaver.removeEventListener(IOErrorEvent.IO_ERROR, onSmallThumbError);
			_smallThumbSaver.removeEventListener(Event.COMPLETE, onSmallThumbSaved);	
			_creator.uiController.alert("There was a problem saving your game thumbnail.");
			
		}
		
		//
		//
		protected function onSmallThumbSaved (e:Event):void {
			
			_smallThumbSaver.removeEventListener(IOErrorEvent.IO_ERROR, onSmallThumbError);
			_smallThumbSaver.removeEventListener(Event.COMPLETE, onSmallThumbSaved);	
			
			_bigThumbRequest = new URLRequest(CreatorMain.dataLoader.baseURL + _thumbPostURL + CreatorMain.dataLoader.getCacheString("projid=" + _xml.firstChild.attributes.id + "&size=big"));
			_bigThumbRequest.method = URLRequestMethod.POST;
			_bigThumbRequest.contentType = "application/octet-stream";
			_bigThumbRequest.data = _bigThumb;
			trace("BIG PNG SIZE:" + _bigThumb.length);
			_bigThumbSaver = new URLLoader();
			_bigThumbSaver.addEventListener(IOErrorEvent.IO_ERROR, onBigThumbError);
			_bigThumbSaver.addEventListener(Event.COMPLETE, onBigThumbSaved);
			_bigThumbSaver.load(_bigThumbRequest);
			
		}
		
		//
		//
		protected function onBigThumbError (e:IOErrorEvent):void {
			
			_bigThumbSaver.removeEventListener(IOErrorEvent.IO_ERROR, onBigThumbError);
			_bigThumbSaver.removeEventListener(Event.COMPLETE, onBigThumbSaved);
			_creator.uiController.alert("There was a problem saving your game thumbnail.");

		}
		
		//
		//
		protected function onBigThumbSaved (e:Event):void {
			
			_bigThumbSaver.removeEventListener(IOErrorEvent.IO_ERROR, onBigThumbError);
			_bigThumbSaver.removeEventListener(Event.COMPLETE, onBigThumbSaved);

		}
	
	}
	
}