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
		
		[Embed(source="assets/nextButton.png")]
		private var nextClass:Class;
		
		[Embed(source="assets/winText.png")]
		private var winClass:Class;
		
		
		private var _skin:Bitmap

		public function get skin():Bitmap
		{
			return _skin;
		}

		public function set skin(value:Bitmap):void
		{
			_skin = value;
		}
		
		private var _winText:Sprite;

		public function get winText():Sprite
		{
			return _winText;
		}

		public function set winText(value:Sprite):void
		{
			_winText = value;
		}

		
		private var _nextButton:Sprite;

		public function get nextButton():Sprite
		{
			return _nextButton;
		}

		public function set nextButton(value:Sprite):void
		{
			_nextButton = value;
		}


		public function Credits()
		{
			super();
			
			skin = new skinClass();
			addChild(skin);
			
			nextButton = new Sprite();
			nextButton.addChild(new nextClass());
			nextButton.width = 260;
			nextButton.height = 44;
			nextButton.x = 118;
			nextButton.y = 450;
			addChild(nextButton);
			
			winText = new Sprite();
			winText.addChild(new winClass());
			winText.y = 350;
			addChild(winText);
			winText.visible = false;
		}
	}
}