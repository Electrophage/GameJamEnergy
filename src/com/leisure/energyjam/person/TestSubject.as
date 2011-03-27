package com.leisure.energyjam.person
{
	import com.leisure.energyjam.blocks.Block;
	import com.leisure.energyjam.eventz.EnergyChangeEvent;
	import com.leisure.energyjam.eventz.MovementEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
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
		
		public static const DESIRED_WIDTH:int = 140;
		public static const DESIRED_HEIGHT:int = 140;
		
		private static const MAX_SPEED:int = 40;
		private static const MIN_SPEED:int = 5;
		
		[Embed(source="assets/gloves/gloves_red_up.png")]
		private var upSkinClass:Class;
		[Embed(source="assets/gloves/overlays/overlay_red_up.png")]
		private var upOverlayClass:Class;
		[Embed(source="assets/gloves/dudes/dudeup.png")]
		private var upDudeClass:Class;
		
		[Embed(source="assets/gloves/gloves_blue_down.png")]
		private var downSkinClass:Class;
		[Embed(source="assets/gloves/overlays/overlay_blue_down.png")]
		private var downOverlayClass:Class;
		[Embed(source="assets/gloves/dudes/dudedown.png")]
		private var downDudeClass:Class;
		
		[Embed(source="assets/gloves/gloves_green_left.png")]
		private var leftSkinClass:Class;
		[Embed(source="assets/gloves/overlays/overlay_green_left.png")]
		private var leftOverlayClass:Class;
		[Embed(source="assets/gloves/dudes/dudeleft.png")]
		private var leftDudeClass:Class;
		
		[Embed(source="assets/gloves/gloves_yellow_right.png")]
		private var rightSkinClass:Class;
		[Embed(source="assets/gloves/overlays/overlay_yellow_right.png")]
		private var rightOverlayClass:Class;
		[Embed(source="assets/gloves/dudes/duderight.png")]
		private var rightDudeClass:Class;
		
		[Embed(source="assets/gloves/gloves_white_stop.png")]
		private var noneSkinClass:Class;
		
		private var upEngineSource:String = "assets/sounds/UpFist.mp3";
		private var downEngineSource:String = "assets/sounds/UpFist.mp3";
		private var rightEngineSource:String = "assets/sounds/UpFist.mp3";
		private var leftEngineSource:String = "assets/sounds/UpFist.mp3";
		
		private var gain1SoundSource:String = "assets/sounds/GainT01.mp3";
		private var drain1SoundSource:String = "assets/sounds/DrainT01.mp3";
		private var drain2SoundSource:String = "assets/sounds/DrainT02.mp3";
		private var drain3SoundSource:String = "assets/sounds/DrainT03.mp3";
		private var drain4SoundSource:String = "assets/sounds/DrainT04.mp3";
		private var down1SoundSource:String = "assets/sounds/DownT01.mp3";
		private var down2SoundSource:String = "assets/sounds/DownT02.mp3";
		private var down3SoundSource:String = "assets/sounds/DownT03.mp3";
		private var left2SoundSource:String = "assets/sounds/LeftT02.mp3";
		private var right1SoundSource:String = "assets/sounds/RightT01.mp3";
		private var up1SoundSource:String = "assets/sounds/UpT01.mp3";
		private var up2SoundSource:String = "assets/sounds/UpT02.mp3";
		private var test1SoundSource:String = "assets/sounds/TestT01.mp3";
		
		private var yell:Sound;
		private var yellChannel:SoundChannel;
		
		private var upEngine:Sound;
		private var downEngine:Sound;
		private var leftEngine:Sound;
		private var rightEngine:Sound;
		private var engineChannel:SoundChannel;
		
		private var unplayed:Array;
		private var played:Array;
		
		private var overlay:Bitmap;
		private var dude:Bitmap;
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
			_direction = NONE;
			speed = 40;
			energy = MAX_ENERGY;
			
			drawDirection();
			initYells();
			startYourEngines();
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
			if(_direction != value)
			{
				if(energy <= 0 && _direction == NONE)
				{
					return;
				}else{
					transitioningTo = value;
					transitioning = true;
				}
			}
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
		
		private var transitioning:Boolean = false;
		private var transitioningTo:String;

		public function step():void
		{
			if( energy <= 0 )
			{
				direction = NONE;
				drawDirection();
			}
			
			if(transitioning)
			{
				transition();
			}
			
			if(direction != NONE)
			{
				--energy;
				if(energy <= 0)
				{
					dispatchEvent(new EnergyChangeEvent(EnergyChangeEvent.OUT_OF_POWER));
				}
				dispatchEvent(new MovementEvent(MovementEvent.MOVE));
			}
		}
		
		public function overlapsBlock(block:Block):Boolean
		{
			var blockBounds:Rectangle = block.getBounds(this.parent);
			var myBounds:Rectangle = getBounds(this.parent);
			
			return myBounds.intersects(blockBounds);
		}
		
		private function transition():void
		{
			if(transitioningTo == direction)
			{
				if(speed < MAX_SPEED)
				{
					speed += 5;
				}else{
					transitioning = false;
				}
			}else{
				if(speed > MIN_SPEED)
				{
					speed /= 2;
				}else{
					_direction = transitioningTo;
					if(yellChannel)
					{
						yellChannel.stop();
					}
					
					if(engineChannel)
					{
						engineChannel.stop();
					}
					
					var randIndex:int = Math.floor(Math.random()*unplayed.length);
					yell = unplayed[randIndex];
					
					played.push(yell);
					unplayed = removeArrayItemAt(unplayed,randIndex);
					if(unplayed.length == 0)
					{
						unplayed = played;
						played = new Array();
					}
					yellChannel = yell.play();
					
					var engine:Sound = engineForDirection;
					if(engine != null)
					{
						engineChannel = engine.play();
					}
					
					drawDirection();
				}
			}
		}
		
		private function drawDirection():void
		{
			removeAllChildren();
			var skinClass:Class;
			var overlayClass:Class;
			var dudeClass:Class;
			switch(direction)
			{
				case UP:
					skinClass = upSkinClass;
					overlayClass = upOverlayClass;
					dudeClass = upDudeClass;
					break
				
				case DOWN:
					skinClass = downSkinClass;
					overlayClass = downOverlayClass;
					dudeClass = downDudeClass;
					break;
				
				case RIGHT:
					skinClass = rightSkinClass;
					overlayClass = rightOverlayClass;
					dudeClass = rightDudeClass;
					break;
				
				case LEFT:
					skinClass = leftSkinClass;
					overlayClass = leftOverlayClass;
					dudeClass = leftDudeClass;
					break;
				
				case NONE:
					skinClass = noneSkinClass;
			}
			
			/*if(overlayClass != null)
			{
				overlay = new overlayClass();
				addChild(overlay);
			}*/
			if(dudeClass != null)
			{
				dude = new dudeClass();
				addChild(dude);
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
		
		private function initYells():void
		{
			unplayed = new Array();
			played = new Array();
			
			//"Gains"
			var yellReq:URLRequest = new URLRequest(gain1SoundSource);
			yell = new Sound();
			yell.load(yellReq);
			
			unplayed.push(yell);
			
			//"Drains"
			yellReq = new URLRequest(drain1SoundSource);
			yell = new Sound();
			yell.load(yellReq);
			
			unplayed.push(yell);
			
			yellReq = new URLRequest(drain2SoundSource);
			yell = new Sound();
			yell.load(yellReq);
			
			unplayed.push(yell);
			
			yellReq = new URLRequest(drain3SoundSource);
			yell = new Sound();
			yell.load(yellReq);
			
			unplayed.push(yell);
			
			yellReq = new URLRequest(drain4SoundSource);
			yell = new Sound();
			yell.load(yellReq);
			
			unplayed.push(yell);
			
			//"Ups"
			yellReq = new URLRequest(up1SoundSource);
			yell = new Sound();
			yell.load(yellReq);
			
			unplayed.push(yell);
			
			yellReq = new URLRequest(up2SoundSource);
			yell = new Sound();
			yell.load(yellReq);
			
			unplayed.push(yell);
			
			//"Downs"
			yellReq = new URLRequest(down1SoundSource);
			yell = new Sound();
			yell.load(yellReq);
			
			unplayed.push(yell);
			
			yellReq = new URLRequest(down2SoundSource);
			yell = new Sound();
			yell.load(yellReq);
			
			unplayed.push(yell);
			
			yellReq = new URLRequest(down3SoundSource);
			yell = new Sound();
			yell.load(yellReq);
			
			unplayed.push(yell);
			
			//"Lefts"
			yellReq = new URLRequest(left2SoundSource);
			yell = new Sound();
			yell.load(yellReq);
			
			unplayed.push(yell);
			
			//"Rights"
			yellReq = new URLRequest(right1SoundSource);
			yell = new Sound();
			yell.load(yellReq);
			
			unplayed.push(yell);
			
			//Test
			yellReq = new URLRequest(test1SoundSource);
			yell = new Sound();
			yell.load(yellReq);
			
			unplayed.push(yell);
		}
		
		protected function get engineForDirection():Sound
		{
			switch(direction)
			{
				case UP:
					return upEngine;
					
				case DOWN:
					return downEngine;
					
				case LEFT:
					return leftEngine;
					
				case RIGHT:
					return rightEngine;
			}
			
			return null;
		}
		
		private function startYourEngines():void
		{
			var engineReq:URLRequest;
			
			engineReq = new URLRequest(upEngineSource);
			upEngine = new Sound();
			upEngine.load(engineReq);
			
			engineReq = new URLRequest(downEngineSource);
			downEngine = new Sound();
			downEngine.load(engineReq);
			
			
			engineReq = new URLRequest(leftEngineSource);
			leftEngine = new Sound();
			leftEngine.load(engineReq);
			
			
			engineReq = new URLRequest(rightEngineSource);
			rightEngine = new Sound();
			rightEngine.load(engineReq);
		}
		
		private function removeArrayItemAt(arr:Array, index:int):Array
		{
			arr[index] = null;
			arr = arr.filter(function filterFunct(obj:Object, index:int, arr:Array):Boolean
			{
				return !(obj == null);
			});
			return arr;
		}
	}
}