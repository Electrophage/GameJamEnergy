package com.leisure.energyjam.room
{
	import com.leisure.energyjam.blocks.Block;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TestChamber extends Sprite
	{
		public static const DESIRED_WIDTH:int = 5000;
		public static const DESIRED_HEIGHT:int = 5000;
		
		public static const BLOCK_SIZE:Number = 40.0;
		
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
			
			index.x = Math.floor((-(x)+point.x)/BLOCK_SIZE);
			index.y = Math.floor((-(y)+point.y)/BLOCK_SIZE);
			
			return index;
		}
		
		public function blocksInArea(origin:Point, areaWidth:Number, areaHeight:Number):Array
		{
			var retval:Array = new Array();
			var indexOrigin:Point = pointToBlockGrid(origin);
			var indicesLong:int = areaWidth/BLOCK_SIZE;
			var indicesHigh:int = areaHeight/BLOCK_SIZE;
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
			if(blocks[index.x][index.y] != null)
			{
				(blocks[index.x][index.y] as Block).type = block.type;
			}else{
				blocks[index.x][index.y] = block;
				addChild(block);
			}
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
		//	removeChild(block);
		}
		
		public function createBlockOfBlocks(rect:Rectangle, type:String):void
		{
			for(var i:int=rect.x;i<rect.right;++i)
			{
				for(var j:int=rect.y;j<rect.bottom;++j)
				{
					addBlockAt(new Block(type),i,j);
				}
			}
		}
		
		private function initChamber():void
		{
		/*	background = new backgroundClass();
			addChild(background);*/
			graphics.beginFill(0xffffff,1);
			graphics.drawRect(0,0,DESIRED_WIDTH,DESIRED_HEIGHT);
			graphics.endFill();
		}
		
		private function initBlockSpace():void
		{
			blocks = new Array(width/BLOCK_SIZE);
			for(var i:int=0;i<blocks.length;++i)
			{
				blocks[i] = new Array(height/BLOCK_SIZE);
			}
		}
		
		private function blockSpaceToChamber(point:Point):Point
		{
			var location:Point = new Point();
			location.x = point.x*BLOCK_SIZE;
			location.y = point.y*BLOCK_SIZE;
			return location;
		}
		
		private function blockOriginToBlockSpace(point:Point):Point
		{
			var index:Point = new Point();
			
			index.x = Math.floor(point.x/BLOCK_SIZE);
			index.y = Math.floor(point.y/BLOCK_SIZE);
			
			return index;
		}
	}
}