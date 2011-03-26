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
			for(var i:int=indexOrigin.x;i<indexOrigin.x+indicesLong;++i)
			{
				for(var j:int=indexOrigin.y;j<indexOrigin.y+indicesHigh;++j)
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
		
		public function addBlock(block:Block):void
		{
			var index:Point = blockOriginToBlockSpace(new Point(block.x,block.y));
			blocks[index.x][index.y] = block;
			addChild(block);
		}
		
		public function addBlockAt(block:Block, indexX:int, indexY:int):void
		{
			var origin:Point = blockSpaceToChamber(new Point(indexX,indexY));
			block.x = origin.x;
			block.y = origin.y;
			addBlock(block);
		}
		
		public function removeBlock(block:Block):void
		{
			var index:Point = blockOriginToBlockSpace(new Point(block.x,block.y));
			blocks[index.x][index.y] = null;
			removeChild(block);
		}
		
		private function initChamber():void
		{
			background = new backgroundClass();
			addChild(background);
		}
		
		private function initBlockSpace():void
		{
			blocks = new Array(width/20);
			for(var i:int=0;i<blocks.length;++i)
			{
				blocks[i] = new Array(height/20);
			}
		}
		
		private function blockSpaceToChamber(point:Point):Point
		{
			var location:Point = new Point();
			location.x = point.x*20;
			location.y = point.y*20;
			return location;
		}
		
		private function blockOriginToBlockSpace(point:Point):Point
		{
			var index:Point = new Point();
			
			index.x = Math.floor(point.x/20.0);
			index.y = Math.floor(point.y/20.0);
			
			return index;
		}
	}
}