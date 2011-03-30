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
	import flash.media.SoundTransform;
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
		
		[Embed(source="assets/gloves/gloves_red_up01.png")]
		private var upSkinClass1:Class;
		[Embed(source="assets/gloves/gloves_red_up02.png")]
		private var upSkinClass2:Class;
		[Embed(source="assets/gloves/gloves_red_up03.png")]
		private var upSkinClass3:Class;
		[Embed(source="assets/gloves/gloves_red_up04.png")]
		private var upSkinClass4:Class;
		[Embed(source="assets/gloves/overlays/overlay_red_up01.png")]
		private var upOverlayClass1:Class;
		[Embed(source="assets/gloves/overlays/overlay_red_up02.png")]
		private var upOverlayClass2:Class;
		[Embed(source="assets/gloves/overlays/overlay_red_up03.png")]
		private var upOverlayClass3:Class;
		[Embed(source="assets/gloves/dudes/dudeup.png")]
		private var upDudeClass:Class;
		
		[Embed(source="assets/gloves/gloves_blue_down01.png")]
		private var downSkinClass1:Class;
		[Embed(source="assets/gloves/gloves_blue_down02.png")]
		private var downSkinClass2:Class;
		[Embed(source="assets/gloves/overlays/overlay_blue_down01.png")]
		private var downOverlayClass1:Class;
		[Embed(source="assets/gloves/overlays/overlay_blue_down02.png")]
		private var downOverlayClass2:Class;
		[Embed(source="assets/gloves/overlays/overlay_blue_down03.png")]
		private var downOverlayClass3:Class;
		[Embed(source="assets/gloves/dudes/dudedown.png")]
		private var downDudeClass:Class;
		
		[Embed(source="assets/gloves/gloves_green_left01.png")]
		private var leftSkinClass1:Class;
		[Embed(source="assets/gloves/gloves_green_left02.png")]
		private var leftSkinClass2:Class;
		[Embed(source="assets/gloves/gloves_green_left03.png")]
		private var leftSkinClass3:Class;
		[Embed(source="assets/gloves/overlays/overlay_green_left.png")]
		private var leftOverlayClass:Class;
		[Embed(source="assets/gloves/dudes/dudeleft.png")]
		private var leftDudeClass:Class;
		
		[Embed(source="assets/gloves/gloves_yellow_right01.png")]
		private var rightSkinClass1:Class;
		[Embed(source="assets/gloves/gloves_yellow_right02.png")]
		private var rightSkinClass2:Class;
		[Embed(source="assets/gloves/gloves_yellow_right03.png")]
		private var rightSkinClass3:Class;
		[Embed(source="assets/gloves/gloves_yellow_right04.png")]
		private var rightSkinClass4:Class;
		[Embed(source="assets/gloves/gloves_yellow_right05.png")]
		private var rightSkinClass5:Class;
		[Embed(source="assets/gloves/overlays/overlay_yellow_right.png")]
		private var rightOverlayClass:Class;
		[Embed(source="assets/gloves/dudes/duderight.png")]
		private var rightDudeClass:Class;
		
		[Embed(source="assets/gloves/gloves_white_stop.png")]
		private var noneSkinClass:Class;
		
		
		[Embed(source="assets/sounds/UpFist.mp3")]
		private var upEngineClass:Class;
		[Embed(source="assets/sounds/Drill.mp3")]
		private var downEngineClass:Class;
		[Embed(source="assets/sounds/Saw.mp3")]
		private var rightEngineClass:Class;
		[Embed(source="assets/sounds/Turbine.mp3")]
		private var leftEngineClass:Class;
		
		/*private var upEngineSource:String = "assets/sounds/UpFist.mp3";
		private var downEngineSource:String = "assets/sounds/Drill.mp3";
		private var rightEngineSource:String = "assets/sounds/Saw.mp3";
		private var leftEngineSource:String = "assets/sounds/Turbine.mp3";*/
		
		[Embed(source="assets/sounds/GainT01.mp3")]
		private var gain1Class:Class;
		
		[Embed(source="assets/sounds/DrainT01.mp3")]
		private var drain1Class:Class;
		[Embed(source="assets/sounds/DrainT02.mp3")]
		private var drain2Class:Class;
		[Embed(source="assets/sounds/DrainT03.mp3")]
		private var drain3Class:Class;
		[Embed(source="assets/sounds/DrainT04.mp3")]
		private var drain4Class:Class;
		
		[Embed(source="assets/sounds/DownT01.mp3")]
		private var down1Class:Class;
		[Embed(source="assets/sounds/DownT02.mp3")]
		private var down2Class:Class;
		[Embed(source="assets/sounds/DownT03.mp3")]
		private var down3Class:Class;
		
		[Embed(source="assets/sounds/LeftT02.mp3")]
		private var left2Class:Class;
		
		[Embed(source="assets/sounds/RightT01.mp3")]
		private var right1Class:Class;
		
		[Embed(source="assets/sounds/UpT01.mp3")]
		private var up1Class:Class;
		[Embed(source="assets/sounds/UpT02.mp3")]
		private var up2Class:Class;
		
		[Embed(source="assets/sounds/TestT01.mp3")]
		private var test1Class:Class;
		
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
			
			animateMovement();
			
			if(direction != NONE)
			{
				energy -= 0.5;
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
					try{
						yellChannel = yell.play(0,0,new SoundTransform(1.0));
					}catch(e:Error)
					{
						
					}
					
					var engine:Sound = engineForDirection;
					if(engine != null)
					{
						try{
							engineChannel = engine.play(0,999,sTransform);
						}catch(e:Error)
						{
							
						}
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
					skinClass = upSkinClass1;
					overlayClass = upOverlayClass1;
					dudeClass = upDudeClass;
					break
				
				case DOWN:
					skinClass = downSkinClass1;
					overlayClass = downOverlayClass1;
					dudeClass = downDudeClass;
					break;
				
				case RIGHT:
					skinClass = rightSkinClass1;
					overlayClass = rightOverlayClass;
					dudeClass = rightDudeClass;
					break;
				
				case LEFT:
					skinClass = leftSkinClass1;
					overlayClass = leftOverlayClass;
					dudeClass = leftDudeClass;
					break;
				
				case NONE:
					skinClass = noneSkinClass;
			}
			
			if(overlayClass != null)
			{
				overlay = new overlayClass();
				addChild(overlay);
			}
			if(dudeClass != null)
			{
				dude = new dudeClass();
				addChild(dude);
			}
			
			skin = new skinClass();
			addChild(skin);
		}
		
		private function animateMovement():void
		{
			switch(direction)
			{
				case DOWN:
					if(skin is downSkinClass1)
					{
						swapSkin(downSkinClass2);
					}else{
						swapSkin(downSkinClass1);
					}
					
					if(overlay is downOverlayClass1)
					{
						swapOverlay(downOverlayClass2);
					}else if(overlay is downOverlayClass2){
						swapOverlay(downOverlayClass3);
					}else{
						swapOverlay(downOverlayClass1);
					}
					
					skin.x = 0;
					skin.y = -140;
					overlay.x = 0;
					overlay.y = -140;
					break;
				
				case LEFT:
					if(skin is leftSkinClass1)
					{
						swapSkin(leftSkinClass2);
					}else if(skin is leftSkinClass2)
					{
						swapSkin(leftSkinClass3);
					}else{
						swapSkin(leftSkinClass1);
					}
					skin.x = 0;
					skin.y = 0;
					overlay.x = 0;
					overlay.y = 0;
					break;
				
				case UP:
					if(skin is upSkinClass1)
					{
						swapSkin(upSkinClass2);
					}else if(skin is upSkinClass2)
					{
						swapSkin(upSkinClass3);
					}else{
						swapSkin(upSkinClass1);
					}
					
					if(overlay is upOverlayClass1)
					{
						swapOverlay(upOverlayClass2);
					}else if(overlay is upOverlayClass2){
						swapOverlay(upOverlayClass3);
					}else{
						swapOverlay(upOverlayClass1);
					}
					skin.x = 0;
					skin.y = 0;
					overlay.x = 0;
					overlay.y = 0;
					break;
				
				case RIGHT:
					if(skin is rightSkinClass1)
					{
						swapSkin(rightSkinClass2);
					}else if(skin is rightSkinClass2)
					{
						swapSkin(rightSkinClass3);
					}else if(skin is rightSkinClass3)
					{
						swapSkin(rightSkinClass4);
					}else if(skin is rightSkinClass4)
					{
						swapSkin(rightSkinClass5);
					}else{
						swapSkin(rightSkinClass1);
					}
					skin.x = 0;
					skin.y = 0;
					overlay.x = 0;
					overlay.y = 0;
					break;
			}
		}
		
		private function swapSkin(skinClass:Class):void
		{
			if(skin && contains(skin))
			{
				removeChild(skin);
			}
			
			skin = new skinClass();
			addChild(skin);
		}
		
		private function swapOverlay(overlayClass:Class):void
		{
			if(overlay && contains(overlay))
			{
				removeChild(overlay);
			}
			
			overlay = new overlayClass();
			addChild(overlay);
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
			
			try{
				//"Gains"
			//	var yellReq:URLRequest = new URLRequest(gain1SoundSource);
				yell = new gain1Class();
			//	yell.load(yellReq);
				
				unplayed.push(yell);
				
				//"Drains"
			//	yellReq = new URLRequest(drain1SoundSource);
				yell = new drain1Class();
			//	yell.load(yellReq);
				
				unplayed.push(yell);
				
				//	yellReq = new URLRequest(drain1SoundSource);
				yell = new drain2Class();
				//	yell.load(yellReq);
				
				unplayed.push(yell);
				
				//	yellReq = new URLRequest(drain1SoundSource);
				yell = new drain3Class();
				//	yell.load(yellReq);
				
				unplayed.push(yell);
				
				//	yellReq = new URLRequest(drain1SoundSource);
				yell = new drain4Class();
				//	yell.load(yellReq);
				
				unplayed.push(yell);
				
				//"Ups"
			//	yellReq = new URLRequest(up1SoundSource);
				yell = new up1Class();
			//	yell.load(yellReq);
				
				unplayed.push(yell);
				
			//	yellReq = new URLRequest(up2SoundSource);
				yell = new up2Class();
			//	yell.load(yellReq);
				
				unplayed.push(yell);
				
				//"Downs"
			//	yellReq = new URLRequest(down1SoundSource);
				yell = new down1Class();
			//	yell.load(yellReq);
				
				unplayed.push(yell);
				
			//	yellReq = new URLRequest(down2SoundSource);
				yell = new down2Class();
			//	yell.load(yellReq);
				
				unplayed.push(yell);
				
			//	yellReq = new URLRequest(down3SoundSource);
				yell = new down3Class();
			//	yell.load(yellReq);
				
				unplayed.push(yell);
				
				//"Lefts"
			//	yellReq = new URLRequest(left2SoundSource);
				yell = new left2Class();
			//	yell.load(yellReq);
				
				unplayed.push(yell);
				
				//"Rights"
			//	yellReq = new URLRequest(right1SoundSource);
				yell = new right1Class();
			//	yell.load(yellReq);
				
				unplayed.push(yell);
				
				//Test
			//	yellReq = new URLRequest(test1SoundSource);
				yell = new test1Class();
			//	yell.load(yellReq);
				
				unplayed.push(yell);
			}catch(e:Error){
				
			}
		}
		
		private var sTransform:SoundTransform;
		
		protected function get engineForDirection():Sound
		{
			switch(direction)
			{
				case UP:
					sTransform = new SoundTransform(0.8);
					return upEngine;
					
				case DOWN:
					sTransform = new SoundTransform(0.8);
					return downEngine;
					
				case LEFT:
					sTransform = new SoundTransform(0.8);
					return leftEngine;
					
				case RIGHT:
					sTransform = new SoundTransform(0.3);
					return rightEngine;
			}
			
			return null;
		}
		
		private function startYourEngines():void
		{
			var engineReq:URLRequest;
			
			//engineReq = new URLRequest(upEngineSource);
			upEngine = new upEngineClass();
			//upEngine.load(engineReq);
			
			//engineReq = new URLRequest(downEngineSource);
			downEngine = new downEngineClass();
			//downEngine.load(engineReq);
			
			
			//engineReq = new URLRequest(leftEngineSource);
			leftEngine = new leftEngineClass();
			//leftEngine.load(engineReq);
			
			
			//engineReq = new URLRequest(rightEngineSource);
			rightEngine = new rightEngineClass();
			//rightEngine.load(engineReq);
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