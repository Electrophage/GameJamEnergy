package com.leisure.energyjam.person
{
	import com.leisure.energyjam.blocks.Block;
	import com.leisure.energyjam.eventz.MovementEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import mx.core.mx_internal;
	import mx.events.MoveEvent;
	
	public class TestSubject extends Sprite
	{
		public static const UP:String = "up";
		public static const DOWN:String = "down";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const NONE:String = "none";
		
		private static const NONE_COLOR:int = 0xff8800;
		
		public static const MAX_ENERGY:Number = 300;
		
		public static const DESIRED_WIDTH:int = 100;
		public static const DESIRED_HEIGHT:int = 100;
		
		[Embed(source="assets/gloves/gloves_red_up.png")]
		private var upSkinClass:Class;
		
		[Embed(source="assets/gloves/gloves_blue_down.png")]
		private var downSkinClass:Class;
		
		[Embed(source="assets/gloves/gloves_green_left.png")]
		private var leftSkinClass:Class;
		
		[Embed(source="assets/gloves/gloves_yellow_right.png")]
		private var rightSkinClass:Class;
		
		[Embed(source="assets/gloves/gloves_white_stop.png")]
		private var noneSkinClass:Class;
		
		private var _skin:Bitmap;

		public function get skin():Bitmap
		{
			return _skin;
		}

		public function set skin(value:Bitmap):void
		{
			_skin = value;
		}

		
		public function TestSubject()
		{
			super();
			direction = NONE;
			speed = 20;
			energy = MAX_ENERGY;
			drawDirection();
		}
		
		private var _speed:Number;

		public function get speed():Number
		{
			return _speed;
		}

		public function set speed(value:Number):void
		{
			_speed = value;
		}

		private var _direction:String;

		public function get direction():String
		{
			return _direction;
		}

		public function set direction(value:String):void
		{
			_direction = value;
		}

		private var _energy:Number;

		public function get energy():Number
		{
			return _energy;
		}

		public function set energy(value:Number):void
		{
			_energy = value > MAX_ENERGY ? MAX_ENERGY : value;
		}

		public function step():void
		{
			if( energy <= 0 )
			{
				direction = NONE;
				drawDirection();
			}
			
			drawDirection();
			
			if(direction != NONE)
			{
				--energy;
				dispatchEvent(new MovementEvent(MovementEvent.MOVE));
			}
		}
		
		public function overlapsBlock(block:Block):Boolean
		{
			var blockBounds:Rectangle = block.getBounds(this.parent);
			var myBounds:Rectangle = getBounds(this.parent);
			
			return myBounds.intersects(blockBounds);
		}
		
		private function drawDirection():void
		{
			removeAllChildren();
			var skinClass:Class;
			switch(direction)
			{
				case UP:
					skinClass = upSkinClass;
					break
				
				case DOWN:
					skinClass = downSkinClass;
					break;
				
				case RIGHT:
					skinClass = rightSkinClass;
					break;
				
				case LEFT:
					skinClass = leftSkinClass;
					break;
				
				case NONE:
					skinClass = noneSkinClass;
			}
			
			skin = new skinClass();
			addChild(skin);
		}
		
		private function removeAllChildren():void
		{
			for(var i:int=numChildren-1;i>=0;--i)
			{
				removeChildAt(i);
			}
		}
	}
}