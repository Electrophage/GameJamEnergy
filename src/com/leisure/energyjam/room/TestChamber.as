package com.leisure.energyjam.room
{
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public class TestChamber extends Sprite
	{
		public static const DESIRED_WIDTH:int = 5000;
		public static const DESIRED_HEIGHT:int = 5000;
		
		[Embed(source="assets/background.jpg")]
		private var backgroundClass:Class
		
		private var background:Bitmap;
		
		public function TestChamber()
		{
			super();
			initChamber();
		}
		
		private function initChamber():void
		{
			background = new backgroundClass();
			addChild(background);
		}
	}
}