package com.sploder.builder.ui 
{
	import com.sploder.builder.Creator;
	import com.sploder.builder.model.Environment;
	import com.sploder.builder.CreatorUIStates;
	import com.sploder.builder.model.ModelObject;
	import com.sploder.builder.Styles;
	import com.sploder.asui.Cell;
	import com.sploder.asui.CheckBox;
	import com.sploder.asui.Clip;
	import com.sploder.asui.Component;
	import com.sploder.asui.HRule;
	import com.sploder.asui.HTMLField;
	import com.sploder.asui.Position;
	import com.sploder.asui.RadioButton;
	import com.sploder.texturegen_internal.TextureAttributes;
	import com.sploder.util.ObjectEvent;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.SecurityDomain;
	
	import flash.display.Loader;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class DialogueTextureGen extends Dialogue
	{
		[Embed(source="../../../../../lib/TextureGen.swf", mimeType="application/octet-stream")]
		public var TextureGenSWF:Class;
		
		protected var _loaded:Boolean = false;
		protected var _loader:Loader;
		
		public var textureData:String;
		
		public function DialogueTextureGen(creator:Creator, width:int = 300, height:int = 300, title:String = "Title", buttons:Array = null) 
		{
			super(creator, width, height, title, buttons);	
		}
		
		override public function create():void 
		{
			super.create();
			
			dbox.contentPadding = 18;
			dbox.contentBottomMargin = 115;
			dbox.contentHasBackground = false;
			_creator.ui.uiContainer.addChild(dbox);
			dbox.addButtonListener(Component.EVENT_CLICK, onClick);
			
			textureData = "";
			
			createContent();
			hide();
			
		}
		
		public function createContent ():void {
			
			if (_contentCreated) return;
			
			if (_loader == null)
			{
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,completeHandler);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				
				var context:LoaderContext = new LoaderContext();
				context.allowCodeImport = true;
				context.applicationDomain = new ApplicationDomain();
				context.parameters = { textureData: textureData};
				_loader.loadBytes(new TextureGenSWF(), context);
			}	
			
			_contentCreated = true;
			
		}
		
		private function completeHandler(e:Event):void {
			_loaded = true;
			if (_creator != null && _creator.stage != null) _creator.stage.addEventListener(Event.ENTER_FRAME, onLoadWait);
		}
		
		private function onLoadWait (e:Event):void
		{
			if (_creator != null && _creator.stage != null) _creator.stage.removeEventListener(Event.ENTER_FRAME, onLoadWait);
			
			_loader.x = 0;
			_loader.y = 40;
			dbox.mc.addChild(_loader);
			
			_loader.addEventListener(Event.CANCEL, onCancel);
			_loader.addEventListener(Event.COMPLETE, onComplete);
		}

		private function ioErrorHandler(e:Event):void {
			_loaded = false;
			_loader = null;
			trace("loader error " + e);
		}

		private function securityErrorHandler(e:Event):void {
			_loaded = false;
			_loader = null;
			trace("loader error " + e);
		}
		
		private function onCancel (e:Event):void {
			hide();
		}
		
		private function onComplete (e:*):void
		{
			textureData = e.relatedObject + "";
			applyChanges();
			hide();
		}
		
		override protected function getSettings():void 
		{
			if (_creator.modelController.selection.length > 0)
			{
				for (var i:int = 0; i < _creator.modelController.selection.length; i++)
				{
					var obj:ModelObject = _creator.modelController.selection.objects[i];
					if (obj != null && obj.props != null && obj.props.custom_texture != null && obj.props.custom_texture.length > 0)
					{
						textureData = obj.props.custom_texture;
						break;
					}
				}
				
				if (textureData.length > 0)
				{
					try {
						var objEventClass:Class = _loader.contentLoaderInfo.applicationDomain.getDefinition("com.sploder.util.ObjectEvent") as Class;
						if (objEventClass != null) _loader.content.dispatchEvent(new objEventClass("texture_change", false, false, textureData));
					} catch (e:Error) {
						trace("TextureGen event class not defined");
					}
				}
			}
		}
		
		override protected function applyChanges():void 
		{
			if (_creator.modelController.selection.length > 0)
			{
				for (var i:int = 0; i < _creator.modelController.selection.length; i++)
				{
					var obj:ModelObject = _creator.modelController.selection.objects[i];
					if (obj != null && obj.props != null) 
					{
						obj.props.custom_texture = textureData;
						trace("applying", textureData);
					}
				}
			}
		}
		
		override public function show():void 
		{
			if (!_contentCreated) createContent();
			else getSettings();
			super.show();
		}
		
		override public function hide():void 
		{
			super.hide();
			if (_creator.ui.advancedTextureToggle.toggled) _creator.ui.advancedTextureToggle.toggle();
		}
		
	}

}