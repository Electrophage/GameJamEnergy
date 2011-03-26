package com.leisure.energyjam.room
{
	import com.leisure.energyjam.blocks.Block;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class TestChamber extends Sprite
	{
		public static const DESIRED_WIDTH:int = 5000;
		public static const DESIRED_HEIGHT:int = 5000;
		
		[Embed(source="assets/background.jpg")]
		private var backgroundClass:Class;
		
		[Embed(source="assets/level01.png")]
		private var levelClass:Class;
		
		private var background:Bitmap;
		
		private var _blocks:Array;
		
		public function get blocks():Array
		{
			return _blocks;
		}
		
		public function set blocks(value:Array):void
		{
			_blocks = value;
		}
		
		private var _level:Bitmap;

		public function get level():Bitmap
		{
			return _level;
		}

		public function set level(value:Bitmap):void
		{
			_level = value;
		}

		
		public function TestChamber()
		{
			super();
			initChamber();
			initBlockSpace();
		}
		
		
		public function pointToBlockGrid(point:Point):Point
		{
			var index:Point = new Point();
			
			index.x = Math.floor((-(x)+point.x)/20.0);
			index.y = Math.floor((-(y)+point.y)/20.0);
			
			return index;
		}
		
		public function blocksInArea(origin:Point, areaWidth:Number, areaHeight:Number):Array
		{
			var retval:Array = new Array();
			var indexOrigin:Point = pointToBlockGrid(origin);
			var indicesLong:int = areaWidth/20;
			var indicesHigh:int = areaHeight/20;
			var block:Block;
			for(var i:int=0;i<indicesLong;++i)
			{
				for(var j:int=0;j<indicesHigh;++j)
				{
					block = blocks[i][j];
					if(block != null)
					{
						retval.push(block);
					}
				}
			}
			
			return retval;
		}
		
		private function initChamber():void
		{
			background = new backgroundClass();
			addChild(background);
			
			level = new levelClass();
			addChild(level);
		}
		
		private function initBlockSpace():void
		{
			blocks = new Array(GameJamEnergy.WIDTH);
			for(var i:int=0;i<blocks.length;++i)
			{
				blocks[i] = new Array(GameJamEnergy.HEIGHT);
			}
		}
	}
}