package com.leisure.energyjam.blocks
{
	import com.leisure.energyjam.person.TestSubject;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	public class Block extends Sprite
	{
		public static const RED_UP:String = "blood";
		public static const GREEN_LEFT:String = "GREEEN!";
		public static const BLUE_DOWN:String = "balls";
		public static const YELLOW_RIGHT:String = "piss";
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
			
			if(type == WHITE)
			{
				energyChange = 20;
			}else if(type == BLACK)
			{
				energyChange = -20;
			}else{
				energyChange = 1;
			}
		}
		
		private var _energyChange:Number = 1;

		public function get energyChange():Number
		{
			return _energyChange;
		}

		public function set energyChange(value:Number):void
		{
			_energyChange = value;
		}

		
		public function Block(type:String=GREY)
		{
			super();
			this.type = type;
			
			var skinClass:Class = skinClassForType;
			
			skin = new skinClass();
			addChild(skin);
		}
		
		public function brokenByDirection(direction:String):Boolean
		{
			switch(type)
			{
				case RED_UP:
					return direction == TestSubject.UP;
				
				case GREEN_LEFT:
					return direction == TestSubject.LEFT;
					
				case BLUE_DOWN:
					return direction == TestSubject.DOWN;
					
				case YELLOW_RIGHT:
					return direction == TestSubject.RIGHT;
					
				case WHITE:
				case BLACK:
					return true;
					
				default:
					return false;
			}
		}
		
		protected function get skinClassForType():Class
		{
			var skinClass:Class;
			switch(type)
			{
				case RED_UP:
					skinClass = redSkinClass;
					break;
				
				case BLUE_DOWN:
					skinClass = blueSkinClass;
					break;
				
				case GREEN_LEFT:
					skinClass = greenSkinClass;
					break;
				
				case YELLOW_RIGHT:
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