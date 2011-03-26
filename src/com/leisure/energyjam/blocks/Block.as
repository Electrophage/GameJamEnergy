package com.leisure.energyjam.blocks
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	public class Block extends Sprite
	{
		public static const RED:String = "blood";
		public static const GREEN:String = "GREEEN!";
		public static const BLUE:String = "balls";
		public static const YELLOW:String = "piss";
		public static const WHITE:String = "NRG";
		public static const BLACK:String = "drain";
		public static const RAINBOW:String = "unicorns";
		public static const GREY:String = "wall-e";
		
		[Embed(source="assets/blocks/block_up_red.png")]
		private var redSkinClass:Class;
		
		[Embed(source="assets/blocks/block_left_green.png")]
		private var greenSkinClass:Class;
		
		[Embed(source="assets/blocks/block_down_blue.png")]
		private var blueSkinClass:Class;
		
		[Embed(source="assets/blocks/block_right_yellow.png")]
		private var yellowSkinClass:Class;
		
		[Embed(source="assets/blocks/block_battery_white.png")]
		private var whiteSkinClass:Class;
		
		[Embed(source="assets/blocks/block_drain_black.png")]
		private var blackSkinClass:Class;
		
		[Embed(source="assets/blocks/block_change_rainbow.png")]
		private var rainbowSkinClass:Class;
		
		[Embed(source="assets/blocks/block_reverse_orange.png")]
		private var greySkinClass:Class;
		
		private var _skin:Bitmap;

		public function get skin():Bitmap
		{
			return _skin;
		}

		public function set skin(value:Bitmap):void
		{
			_skin = value;
		}

		
		private var _type:String;

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}
		
		public function Block(type:String=GREY)
		{
			super();
			this.type = type;
			
			var skinClass:Class = skinClassForType;
			
			skin = new skinClass();
			addChild(skin);
		}
		
		protected function get skinClassForType():Class
		{
			var skinClass:Class;
			switch(type)
			{
				case RED:
					skinClass = redSkinClass;
					break;
				
				case BLUE:
					skinClass = blueSkinClass;
					break;
				
				case GREEN:
					skinClass = greenSkinClass;
					break;
				
				case YELLOW:
					skinClass = yellowSkinClass;
					break;
				
				case WHITE:
					skinClass = whiteSkinClass;
					break;
				
				case BLACK:
					skinClass = blackSkinClass;
					break;
				
				case RAINBOW:
					skinClass = rainbowSkinClass;
					break;
				
				case GREY:
				default:
					skinClass = greySkinClass;
					break;
			}
			
			return skinClass;
		}
	}
}