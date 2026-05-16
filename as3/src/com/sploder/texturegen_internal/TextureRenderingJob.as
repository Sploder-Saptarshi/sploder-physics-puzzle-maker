package com.sploder.texturegen_internal
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TextureRenderingJob
	{	
		public var bitmapData:BitmapData;
		public var finished:Boolean;
		public var canceled:Boolean;
		public var autoApply:Boolean;
		public var highQuality:Boolean;
		public var transparent:Boolean;
		public var borderType:int;
		public var destinationRect:Rectangle;
		public var destinationPoint:Point;
		public var destination:BitmapData;
		public var attribs:TextureAttributes;
		
		private static var destMatrix:Matrix;
		
		public function TextureRenderingJob():void
		{
		}
		
		public function initWithProperties(attribs:TextureAttributes, destination:BitmapData, destinationRect:Rectangle, borderType:int = 0, transparent:Boolean = false, highQuality:Boolean = false, autoApply:Boolean = true):*
		{
			this.attribs = attribs.copy();
			this.destination = destination;
			this.destinationRect = destinationRect;
			this.destinationPoint = new Point(destinationRect.x, destinationRect.y);
			this.borderType = borderType;
			this.transparent = transparent;
			this.highQuality = highQuality;
			this.autoApply = autoApply;
			
			if (destMatrix == null)
			{
				destMatrix = new Matrix();
				destMatrix.createBox(4, 4);
			}
			
			bitmapData = new BitmapData(Math.floor(destinationRect.width / 4), Math.floor(destinationRect.height / 4), transparent, 0);
			
			return this;
		}

		public function finish():void
		{
			if (finished)
				return;
			if (autoApply)
				apply();
			finished = true;
		}
		
		public function cancel():void
		{
			canceled = true;
		}
		
		public function apply():void
		{
			if (!finished)
			{
				//destination.copyPixels(bitmapData, bitmapData.rect, destinationPoint);
				destination.draw(bitmapData, destMatrix);
				finished = true;
			}
		}	
		
		public function destroy():void
		{
			if (finished && bitmapData != null)
			{
				bitmapData.dispose();
				bitmapData = null;
			}
		}
	}
}
