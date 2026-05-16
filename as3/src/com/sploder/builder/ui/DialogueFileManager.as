package com.sploder.builder.ui {
	
	import com.sploder.builder.Creator;
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.builder.Styles;
	import com.sploder.data.User;
	import com.sploder.asui.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	

	
	public class DialogueFileManager extends Dialogue {
		
		public static const EVENT_SELECT:String = "select";
		public static const EVENT_CONFIRM:String = "confirm";
		
		public static const MODE_LOAD:int = 1;
		public static const MODE_SAVE:int = 2;
		
		public function get title ():String {
			if (dbox && dbox.titleField) return dbox.titleField.value;
			return "";
		}
		public function set title(value:String):void {
			if (dbox && dbox.titleField) dbox.titleField.value = '<p align="center"><h3>' + value + '</h3></p>';
		}
		
		protected var _mode:int = 1;
		
		public function get mode():int { return _mode; }
		
		public function set mode(value:int):void 
		{
			_mode = value;
			if (_mode == MODE_LOAD) {
				_nameFieldSelectable = false;
			} else {
				_nameFieldSelectable = true;
			}
		}
		
		protected var _nameFieldSelectable:Boolean = false;
		
		protected var _loadingPrompt:HTMLField;
		protected var _serverMessage:HTMLField;
		protected var _cancelButton:BButton;
		protected var _confirmButton:BButton;
		protected var _pageBack:BButton;
		protected var _pageNext:BButton;
		
		protected var _listContainer:Collection;
		protected var _nameField:FormField;
		
		protected var _xml:XMLDocument;
		
		protected var _listURL:String = "";
		public function get listURL():String { return _listURL; }
		public function set listURL(value:String):void { _listURL = value; }
	
		protected var _listParamString:String = "";
		public function get listParamString():String { return _listParamString; }
		public function set listParamString(value:String):void { _listParamString = value; }
		
		protected var _groupType:String = "";
		
		protected var _items:Object;
		protected var _totalItems:int = 0;
		protected var _resultStart:int = 0;
		protected var _resultsPerPage:int = 10;
		protected var _resultsNum:int = 0;
		protected var _resultsTotal:int = 0;
		protected var _totalPages:int = 0;
		protected var _pageNum:int = 0;
		
		protected var _selectedProject:CollectionItem;
		
		protected var _currentProjectID:String = "";
		
		private var _nameFieldTitle:HTMLField;
		public function get currentProjectID():String { return _currentProjectID; }
		public function set currentProjectID(value:String):void { _currentProjectID = value; }
		
		public function get currentProjectTitle():String { if (_nameField) return _nameField.value else return ""; }
		public function set currentProjectTitle(value:String):void { if (_nameField) _nameField.value = value; }
		
		
		//
		//
		public function DialogueFileManager (creator:Creator, width:int = 300, height:int = 300, title:String = "Title", buttons:Array = null) 
		{
			super(creator, width, height, title, buttons);
		}
		
		override public function create():void 
		{
			scroll = true;
			super.create();
			
			dbox.contentPadding = 20;
			dbox.contentBottomMargin = 80;
			dbox.contentHasBackground = true;
			dbox.contentHasBorder = true;
			_creator.ui.uiContainer.addChild(dbox);
			dbox.addButtonListener(Component.EVENT_CLICK, onClick);
			
			hide();
			
		}
		
		public function createContent():void 
		{
			if (_contentCreated) return;
			
			var colStyle:Style = new Style( {
				padding: 10,
				round: 10,
				highlightTextColor: 0xffffff,
				selectedButtonBorderColor: 0xffffff
			 } );
			
			_listContainer = new Collection(null, 417, NaN, 417, 74, 2, new Position ( { margins: 3 } ), colStyle);
			_listContainer.allowDrag = false;
			_listContainer.allowRearrange = false;
			_listContainer.defaultItemComponent = "Clip";
			
			_listContainer.defaultItemStyle = new Style ( {
				padding: 12,
				round: 5,
				background: true,
				bgGradient: true,
				bgGradientColors: [0x555555, 0x222222],
				highlightTextColor: 0xffffff,
				htmlFont: "Myriad Web",
				font: "Myriad Web",
				fontSize: 13,
				embedFonts: true,
				borderWidth: 2,
				borderColor: 0
				} );
				
			_listContainer.useSnap = true;
		
			dbox.contentCell.addChild(_listContainer);
			
			_listContainer.addEventListener(Component.EVENT_SELECT, onProjectSelect);
				
			var subControls:Cell = new Cell(null, _width - 54, 50, false, false, 0, new Position( { margin_left: 20 } ));
			dbox.addChild(subControls);
				
			_nameFieldTitle = new HTMLField(null, '<h3>TITLE OF YOUR GAME:</h3>', 200, false, Styles.floatPosition.clone( { margin_top: 20 } ), Styles.dialogueStyle.clone( { titleFontSize: 11, titleColor: 0xffec00 } ) );
			subControls.addChild(_nameFieldTitle);
			
			var pbPos:Position = new Position(null, 
				Position.ALIGN_RIGHT, 
				Position.PLACEMENT_FLOAT_RIGHT, 
				Position.CLEAR_NONE, "10 0 10 0");
			
			var pbStyle:Style = Styles.dialogueStyle.clone();
			pbStyle.buttonColor = 0;
			pbStyle.padding = 0;
			pbStyle.inactiveColor = 0;
			pbStyle.unselectedColor = 0;
			
			_pageBack = new BButton(null, { icon: Create.ICON_ARROW_RIGHT, text: "NEWER" }, -1, 80, 26, false, false, false, pbPos, pbStyle);
			subControls.addChild(_pageBack);
			_pageBack.addEventListener(Component.EVENT_CLICK, onClick);
			
			_pageNext = new BButton(null, { icon: Create.ICON_ARROW_LEFT, text: "OLDER", first: "false" }, -1, 80, 26, false, false, false, pbPos, pbStyle);
			subControls.addChild(_pageNext);
			_pageNext.addEventListener(Component.EVENT_CLICK, onClick);
			
			_nameField = new FormField(null, "Enter your game title here...", 425, 30, true, new Position( { margin_top: 10 } ));
			_nameField.x = 20;
			_nameField.y = 285;
			_nameField.restrict = "a-z A-Z 0-9";
			_nameField.maxChars = 35;
			subControls.addChild(_nameField);
			
			_loadingPrompt = new HTMLField(null, "<br><br><br><p align=\"center\"><h1>Loading...</h1></p>", 417, true, Styles.absPosition, Styles.dialogueStyle);
			dbox.contentCell.addChild(_loadingPrompt);
			_loadingPrompt.x = _loadingPrompt.y = 0;
			
			_serverMessage = new HTMLField(null, "<p align=\"center\"><h1>Server message</h1></p>", 317, true, Styles.absPosition, Styles.dialogueStyle);
			dbox.contentCell.addChild(_serverMessage);
			_serverMessage.x = _serverMessage.y = 50;
			
			_contentCreated = true;
			
			connect();
			
		}
		
		//
		//
		protected function connect ():void {
			
			_cancelButton = dbox.buttons[0];
			_confirmButton = dbox.buttons[1];
			
			_nameField.addEventListener(Component.EVENT_CHANGE, onTitleChanged);
			_nameField.addEventListener(Component.EVENT_FOCUS, onTitleFocus);
			
			addEventListener(EVENT_CONFIRM, _creator.project.onManagerConfirm);
			
		}
		
		override protected function onClick (e:Event):void {
			
			switch (e.target) {
				
				case (_pageBack):
					_resultStart -= _resultsPerPage;
					_resultStart = Math.max(0, _resultStart);
					loadList();
					break;
					
				case (_pageNext):
					_resultStart += _resultsPerPage;
					_resultStart = Math.min(_resultsTotal, _resultStart);
					loadList();
					break;
				
				case (_cancelButton):
					hide();
					break;
					
				case (_confirmButton):
					confirm();
					break;
				
			}
			
		}
		
		//
		//
		protected function confirm ():void {
			
			dispatchEvent(new Event(EVENT_CONFIRM));
			hide();
			
		}
		
        //
        //
        protected function getList ():void {

			CreatorMain.dataLoader.loadXMLData(
				_listURL + CreatorMain.dataLoader.getCacheString(_listParamString + "&num=" + _resultsPerPage + "&start=" + _resultStart), 
				true, 
				onListLoaded
				);
				
			_loadingPrompt.show();
   
        }
		
		//
		//
		protected function onListLoaded (e:Event):void {
			
			_loadingPrompt.hide();
			
			_xml = new XMLDocument();
			_xml.ignoreWhite = true;
			_xml.parseXML(e.target.data);
			
			if (_mode == MODE_SAVE) _nameField.selectable = true;
			
			populate();
			
		}
		
		//
		//
		protected function onTitleChanged (e:Event = null):void {
			
			if (_nameField.value.length > 3 && _nameField.value.indexOf("...") == -1) toggleConfirmButton(true);
			else toggleConfirmButton(false);
			
		}
		
		//
		//
		protected function onTitleFocus (e:Event = null):void {
			
			_currentProjectID = "";
			
			if (_selectedProject != null) {
				_selectedProject.clip["thumbnail"].frame.gotoAndStop("inactive");
			}
			
		}
		
		//
		//
		public function loadList (e:Event = null):void {
			
			if (!_contentCreated) createContent();
			
			if (e == null || e.type == EVENT_CONFIRM) {
				
				_listContainer.clear();
				_selectedProject = null;
				
				if (!dbox.visible) show();
				getList();
				
			}
			
		}
		

        // 
        // 
        // ADDITEM adds an item to the manager
        protected function addItem (xmlRef:XMLNode, itemtype:String, num:int):CollectionItem {
            
			var title:String = unescape(xmlRef.attributes.title);
            var date:String = xmlRef.attributes.date;
			var projID:String = xmlRef.attributes.id;
			
			var thumb_base:String = CreatorMain.dataLoader.baseURL;
			if (xmlRef.attributes.archived == "1") thumb_base = "http://sploder.s3.amazonaws.com";
			
			var thumb_url:String = thumb_base + User.thumbspath + projID + ".png" + CreatorMain.dataLoader.getCacheString();
			
			var items:Array = _listContainer.addMembers([
				{ 
					title: "<h2>" + title + "</h2><p>" + date + "</p>", 
					raw_title: title,
					raw_date: date,
					icon: thumb_url,
					id: xmlRef.attributes.id
				}
				]);
			
            return items[0];
            
        }
    
        // 
        // 
        // POPULATE populates the manager with items when its XML has loaded
        public function populate ():void {
            
			var XMLref:XMLNode ;
			
            trace("populating manager");
           
			_items = { };
			
			if (_xml != null && _xml.firstChild != null) {
					
				_groupType = _xml.firstChild.nodeName;
				
				_resultsTotal = parseInt(_xml.firstChild.attributes.total);
				
				if (_xml.firstChild.attributes.start != undefined) {
					_resultStart = parseInt(_xml.firstChild.attributes.start);
				} else {
					_resultStart = 0;
				}
				
				if (_xml.firstChild.attributes.num != undefined) {
					_resultsNum = parseInt(_xml.firstChild.attributes.num);	
					_totalPages = Math.ceil(_resultsTotal / _resultsNum);
				} else {
					_resultsNum = _resultsTotal;
					_pageNum = _totalPages = 1;
				}
				
				if (_resultStart == 0) {
					_pageNum = 1;
					_pageBack.disable();
				} else {
					_pageNum = Math.ceil(_resultStart / _resultsNum) + 1;
					_pageBack.enable();
				}
				
				if ((_resultStart + _resultsNum) >= _resultsTotal) {
					_pageNext.disable();
				} else {
					_pageNext.enable();
				}

				XMLref = _xml.firstChild.firstChild;
				
			} else {
				
				_groupType = "projects";
				
			}
            
            // if there are objects that have been found
            if (XMLref != null) {
                
                var itemType:String = XMLref.nodeName;
                trace(XMLref);
                _totalItems = 0;
                
                while (XMLref != null) {
                    
					_items[XMLref.attributes.id] = addItem(XMLref, itemType, _totalItems);
                    _totalItems++;
                    XMLref = XMLref.nextSibling;
					if (_currentProjectID != null && 
						XMLref != null && 
						XMLref.attributes.id == _currentProjectID) selectProject(XMLref.attributes.id);
                    
                }
                
            } else { // if no objects found
            
                if (_title == "Save Your Game") {
                    
                    showServerMessage("Enter the title of your game below.");
					_serverMessage.show();
                    _nameField.focus();
                    
                } else {
                    
                    var stext:String = "No " + _groupType + " found.";
    
                    if (_groupType == "projects") {
						if (_mode == MODE_LOAD) {
							stext += "\nDrag Objects onto your playfield to begin.";
						} else {
							stext += "\nEnter your game title below.";
						}
                    }
					
					showServerMessage(stext);
					_serverMessage.show();
                    
                }
				
				if (_mode == MODE_LOAD) {
					if (_resultStart == 0) _pageBack.disable();
					else _pageBack.enable();
					_pageNext.disable();
				} else {
					_pageBack.disable();
					_pageNext.disable();
				}
                
            }
			
			dbox.scrollbar.reset();
            
        }

		//
		//
		protected function onThumbError (e:IOErrorEvent):void {

			var projID:String = String(e.toString()).split("thumbs/")[1].split(".png")[0];

			var c:Container = _items[projID];
			
			//if (c.clip != null && c.clip["thumbnail"] != null) c.clip["thumbnail"].proxy.addChild(Creator.UIlibrary.getDisplayObject("notfound"));		

		}
        
		//
		//
        protected function onProjectSelect (e:Event):void {
			
            selectProject();

        }	
		
		//
		//
		protected function selectProject (projID:String = null):void {
			
			if (projID != null || _listContainer.selectedMembers.length > 0) {
				
				_selectedProject = (projID != null) ? _items[projID] : _listContainer.selectedMembers[0];
				
				var ref:Object = _selectedProject.reference;
				
				_currentProjectID = ref.id;
				_nameField.value = unescape(_xml.idMap[_currentProjectID].attributes.title);
				
				toggleConfirmButton(true);
				
			} else {
				
				_selectedProject = null;
				_currentProjectID = "";
	
				setNameFieldDefault();
				toggleConfirmButton(false);
				
			}

		}
		
		//
		//
		protected function setNameFieldDefault ():void {
			
			if (_selectedProject == null) {
				if (_mode == MODE_LOAD) _nameField.value = "Select a game from the list above...";
				else _nameField.value = "Enter your game title here...";
			}
			
		}
		
		
		//
		//
		protected function toggleConfirmButton (on:Boolean = false):void {
			
			if (on) {
				_confirmButton.enable();
			} else {
				_confirmButton.disable();	
			}
			
		}
		
		//
		//
		protected function showServerMessage (msg:String = ""):void {
			
			_serverMessage.value = "<p align=\"center\"><h1>" + msg + "</h1></p>";
			_serverMessage.show();
			
		}
		
		//
		//
		override public function show():void 
		{
			if (!_contentCreated) createContent();
			super.show();
	
			_resultStart = 0;
			_loadingPrompt.hide();
			_serverMessage.hide();
			_nameField.selectable = _nameFieldSelectable;
			onTitleChanged();
			setNameFieldDefault();
			
			if (_listContainer) _listContainer.allowKeyboardEvents = false;
			
			_creator.uiController.scrollHelper.hScroller = null;
			_creator.uiController.scrollHelper.vScroller = dbox.scrollbar;
			_creator.uiController.scrollHelper.multiplier = 5;
			
		}
		
		override public function hide():void 
		{
			super.hide();
			
			if (_listContainer) _listContainer.allowKeyboardEvents = false;
			
			if (_creator.uiController) {
				_creator.uiController.scrollHelper.hScroller = _creator.ui.hScroll;
				_creator.uiController.scrollHelper.vScroller = _creator.ui.vScroll;
				_creator.uiController.scrollHelper.multiplier = 1;
			}
		}
		
	}
	
}