package com.leisure.energyjam.blocks
{
	import com.leisure.energyjam.person.TestSubject;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	
	import flashx.textLayout.formats.Direction;
	
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
		[Embed(source="assets/blocks/splodes/up01.png")]
		private var redSplodeClass1:Class;
		[Embed(source="assets/blocks/splodes/up02.png")]
		private var redSplodeClass2:Class;
		[Embed(source="assets/blocks/splodes/up03.png")]
		private var redSplodeClass3:Class;
		
		[Embed(source="assets/blocks/block_left_green.png")]
		private var greenSkinClass:Class;
		[Embed(source="assets/blocks/splodes/left01.png")]
		private var greenSplodeClass1:Class;
		[Embed(source="assets/blocks/splodes/left02.png")]
		private var greenSplodeClass2:Class;
		[Embed(source="assets/blocks/splodes/left03.png")]
		private var greenSplodeClass3:Class;
		
		[Embed(source="assets/blocks/block_down_blue.png")]
		private var blueSkinClass:Class;
		[Embed(source="assets/blocks/splodes/down01.png")]
		private var blueSplodeClass1:Class;
		[Embed(source="assets/blocks/splodes/down02.png")]
		private var blueSplodeClass2:Class;
		[Embed(source="assets/blocks/splodes/down03.png")]
		private var blueSplodeClass3:Class;
		
		[Embed(source="assets/blocks/block_right_yellow.png")]
		private var yellowSkinClass:Class;
		[Embed(source="assets/blocks/splodes/right01.png")]
		private var yellowSplodeClass1:Class;
		[Embed(source="assets/blocks/splodes/right02.png")]
		private var yellowSplodeClass2:Class;
		[Embed(source="assets/blocks/splodes/right03.png")]
		private var yellowSplodeClass3:Class;
		
		[Embed(source="assets/blocks/block_battery_white.png")]
		private var whiteSkinClass:Class;
		[Embed(source="assets/blocks/splodes/battery01.png")]
		private var whiteSplodeClass1:Class;
		[Embed(source="assets/blocks/splodes/battery02.png")]
		private var whiteSplodeClass2:Class;
		[Embed(source="assets/blocks/splodes/battery03.png")]
		private var whiteSplodeClass3:Class;
		
		[Embed(source="assets/blocks/block_drain_black.png")]
		private var blackSkinClass:Class;
		[Embed(source="assets/blocks/splodes/drain01.png")]
		private var blackSplodeClass1:Class;
		[Embed(source="assets/blocks/splodes/drain02.png")]
		private var blackSplodeClass2:Class;
		[Embed(source="assets/blocks/splodes/drain03.png")]
		private var blackSplodeClass3:Class;
		
		[Embed(source="assets/blocks/block_change_rainbow.png")]
		private var rainbowSkinClass:Class;
		
		[Embed(source="assets/blocks/block_stop_gray.png")]
		private var greySkinClass:Class;
		
		private var skinClass:Class;
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
				energyChange = -5;
			}else{
				energyChange = 1;
			}
			
			setSkinForType();
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
		
		private var _breaking:Boolean = false;

		public function get breaking():Boolean
		{
			return _breaking;
		}

		public function set breaking(value:Boolean):void
		{
			_breaking = value;
		}
		
		public function Block(type:String=GREY)
		{
			super();
			this.type = type;
		}
		
		public function setSkinForType():void
		{
			skinClass = skinClassForType;
			if(skin!= null && contains(skin))
			{
				removeChild(skin);
			}
			skin = new skinClass();
			addChild(skin);
		}
		
		public function animateBreaking():Boolean
		{
			return callAnimationForType();
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
				case RAINBOW:
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
		
		private function callAnimationForType():Boolean
		{
			switch(type)
			{
				case RED_UP:
					return animateRed();
					break;
				
				case GREEN_LEFT:
					return animateGreen();
					break;
				
				case BLUE_DOWN:
					return animateBlue();
					break;
				
				case YELLOW_RIGHT:
					return animateYellow();
					break;
				
				case WHITE:
					return animateWhite();
					break;
				
				case BLACK:
					return animateBlack();
					break;
			}
			
			return true;
		}
		
		private function animateRed():Boolean
		{
			removeChild(skin);
			
			if(skinClass == redSkinClass)
			{
				skinClass = redSplodeClass1;
				skin = new skinClass();
			}else if(skinClass == redSplodeClass1)
			{
				skinClass = redSplodeClass2;
				skin = new skinClass();
			}else if(skinClass == redSplodeClass2)
			{
				skinClass = redSplodeClass3;
				skin = new skinClass();
			}else{
				return true;
			}
			
			skin.x = -60;
			skin.y = -60;
			addChild(skin);
			return false;
		}
		
		private function animateBlue():Boolean
		{
			removeChild(skin);
			
			if(skinClass == blueSkinClass)
			{
				skinClass = blueSplodeClass1;
				skin = new skinClass();
			}else if(skinClass == blueSplodeClass1)
			{
				skinClass = blueSplodeClass2;
				skin = new skinClass();
			}else if(skinClass == blueSplodeClass2)
			{
				skinClass = blueSplodeClass3;
				skin = new skinClass();
			}else{
				return true;
			}
			
			skin.x = -60;
			skin.y = -60;
			addChild(skin);
			return false;
		}
		
		private function animateYellow():Boolean
		{
			removeChild(skin);
			
			if(skinClass == yellowSkinClass)
			{
				skinClass = yellowSplodeClass1;
				skin = new skinClass();
			}else if(skinClass == yellowSplodeClass1)
			{
				skinClass = yellowSplodeClass2;
				skin = new skinClass();
			}else if(skinClass == yellowSplodeClass2)
			{
				skinClass = yellowSplodeClass3;
				skin = new skinClass();
			}else{
				return true;
			}
			
			skin.x = -60;
			skin.y = -60;
			addChild(skin);
			return false;
		}
		
		private function animateGreen():Boolean
		{ 
			removeChild(skin);
			
			if(skinClass == greenSkinClass)
			{
				skinClass = greenSplodeClass1;
				skin = new skinClass();
			}else if(skinClass == greenSplodeClass1)
			{
				skinClass = greenSplodeClass2;
				skin = new skinClass();
			}else if(skinClass == greenSplodeClass2)
			{
				skinClass = greenSplodeClass3;
				skin = new skinClass();
			}else{
				return true;
			}
			
			skin.x = -60;
			skin.y = -60;
			addChild(skin);
			return false;
		}
		
		private function animateWhite():Boolean
		{
			removeChild(skin);
			
			if(skinClass == whiteSkinClass)
			{
				skinClass = whiteSplodeClass1;
				skin = new skinClass();
			}else if(skinClass == whiteSplodeClass1)
			{
				skinClass = whiteSplodeClass2;
				skin = new skinClass();
			}else if(skinClass == whiteSplodeClass2)
			{
				skinClass = whiteSplodeClass3;
				skin = new skinClass();
			}else{
				return true;
			}
			
			skin.x = -60;
			skin.y = -60;
			addChild(skin);
			return false;
		}
		
		private function animateBlack():Boolean
		{
			removeChild(skin);
			
			if(skinClass == blackSkinClass)
			{
				skinClass = blackSplodeClass1;
				skin = new skinClass();
			}else if(skinClass == blackSplodeClass1)
			{
				skinClass = blackSplodeClass2;
				skin = new skinClass();
			}else if(skinClass == blackSplodeClass2)
			{
				skinClass = blackSplodeClass3;
				skin = new skinClass();
			}else{
				return true;
			}
			
			skin.x = -60;
			skin.y = -60;
			addChild(skin);
			return false;
		}
	}
}