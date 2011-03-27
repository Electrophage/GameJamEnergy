package com.leisure.energyjam
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	public class Credits extends Sprite
	{
		[Embed(source="assets/credits.png")]
		private var skinClass:Class;
		
		private var _skin:Bitmap

		public function get skin():Bitmap
		{
			return _skin;
		}

		public function set skin(value:Bitmap):void
		{
			_skin = value;
		}

		public function Credits()
		{
			super();
			
			skin = new skinClass();
			addChild(skin);
		}
	}
}