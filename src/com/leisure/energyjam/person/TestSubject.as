package com.leisure.energyjam.person
{
	import flash.display.Sprite;
	
	import mx.core.mx_internal;
	import mx.events.MoveEvent;
	
	public class TestSubject extends Sprite
	{
		public static const UP:String = "up";
		public static const DOWN:String = "down";
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const NONE:String = "none";
		
		private static const UP_COLOR:int = 0xff0000;
		private static const DOWN_COLOR:int = 0x0000ff;
		private static const LEFT_COLOR:int = 0x00ff00;
		private static const RIGHT_COLOR:int = 0xffff00;
		private static const NONE_COLOR:int = 0xff8800;
		
		public static const MAX_ENERGY:Number = 100;
		
		public static const DESIRED_WIDTH:int = 25;
		public static const DESIRED_HEIGHT:int = 25;
		
		public function TestSubject()
		{
			super();
			direction = NONE;
			speed = 80;
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
			_energy = value;
		}

		public function step():void
		{
			if( energy == 0 )
			{
				direction = NONE;
			}else{
				--energy;
			}
			
			drawDirection();
			dispatchEvent(new MoveEvent(MoveEvent.MOVE));
		}
		
		private function drawDirection():void
		{
			var color:int;
			graphics.clear();
			
			switch(direction)
			{
				case UP:
					color = UP_COLOR;
					break
				
				case DOWN:
					color = DOWN_COLOR;
					break;
				
				case RIGHT:
					color = RIGHT_COLOR;
					break;
				
				case LEFT:
					color = LEFT_COLOR;
					break;
				
				case NONE:
					color = NONE_COLOR;
					break;
			}
			
			graphics.beginFill(color);
			graphics.drawRect(0,0,DESIRED_WIDTH,DESIRED_HEIGHT);
			graphics.endFill();
		}
	}
}