package
{
	import com.leisure.energyjam.blocks.Block;
	import com.leisure.energyjam.eventz.EnergyChangeEvent;
	import com.leisure.energyjam.eventz.MovementEvent;
	import com.leisure.energyjam.gui.EnergyGuage;
	import com.leisure.energyjam.person.TestSubject;
	import com.leisure.energyjam.room.TestChamber;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.ui.Keyboard;
	
	[SWF(width="500", height="500", backgroundColor='#000000', frameRate='40')]
	public class GameJamEnergy extends Sprite
	{
		public static const HEIGHT:int = 500;
		public static const WIDTH:int = 500;
		
		public static const STATE_START:String = "startScreen";
		public static const STATE_RUNNING:String = "running";
		public static const STATE_GAME_OVER:String = "gameOver";
		
		private var _gameState:String;

		public function get gameState():String
		{
			return _gameState;
		}

		public function set gameState(value:String):void
		{
			_gameState = value;
		}
		
		private var chamber:TestChamber;
		private var subject:TestSubject;
		private var gauge:EnergyGuage;
		private var startButton:Sprite;
		
		private var musicSource:String = "assets/music/GameJam2.mp3";
		private var powerUpSource:String = "assets/sounds/Powerup.mp3";
		private var powerDownSource:String = "assets/sounds/PowerDown.mp3";
		private var music:Sound;
		private var powerUp:Sound;
		private var powerDown:Sound;
		
		private var musicChannel:SoundChannel;
		
		private var breakingBlocks:Array;
		
		public function GameJamEnergy()
		{
			gameState = STATE_START;
			
			var musicReq:URLRequest = new URLRequest(musicSource);
			music = new Sound();
			music.load(musicReq);
			
			var powerUpReq:URLRequest = new URLRequest(powerUpSource);
			powerUp = new Sound();
			powerUp.load(powerUpReq);
			
			var powerDownReq:URLRequest = new URLRequest(powerDownSource);
			powerDown = new Sound();
			powerDown.load(powerDownReq);
			
			breakingBlocks = new Array();
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		private function handleAddedToStage(e:Event):void
		{
			stage.align = "topLeft";
			stage.scaleMode = "noScale";

			chamber = new TestChamber();
			chamber.height = TestChamber.DESIRED_HEIGHT;
			chamber.width = TestChamber.DESIRED_WIDTH;
			chamber.x = -chamber.width/2.0 + WIDTH/2.0;
			chamber.y = -chamber.height/2.0 + HEIGHT/2.0;
			
			subject = new TestSubject();
			subject.width = TestSubject.DESIRED_WIDTH;
			subject.height = TestSubject.DESIRED_HEIGHT;
			subject.x = subjectCenterX;
			subject.y = subjectCenterY;
			subject.addEventListener(MovementEvent.MOVE, handleMove);
			subject.addEventListener(EnergyChangeEvent.OUT_OF_POWER, handleOutOfEnergy);
			
			gauge = new EnergyGuage();
			gauge.x = 20;
			gauge.y = 20;
			gauge.energy = subject.energy;
			
			initLevel();
			
			addChild(chamber);
			addChild(subject);
			addChild(gauge);
			gauge.width = 20;
			gauge.height = TestSubject.MAX_ENERGY;
			
			startButton = new Sprite();
			startButton.graphics.beginFill(0x0000ff);
			startButton.graphics.drawRoundRect(0,0,100,80,90,90);
			startButton.graphics.endFill();
			startButton.x = WIDTH/2;
			startButton.y = HEIGHT/2;
			startButton.buttonMode = true;
			
			var textElement:TextElement = new TextElement();
			textElement.text = "Volunteer";
			textElement.elementFormat = new ElementFormat();
			
			var textblock:TextBlock = new TextBlock(textElement);
			var buttonLabel:TextLine = textblock.createTextLine();
			
			startButton.addChild(buttonLabel);
			buttonLabel.x = 30;
			buttonLabel.y = 30;
			addChild(startButton);
			
			startButton.addEventListener(MouseEvent.CLICK, onStartClicked);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function onStartClicked(e:MouseEvent):void
		{
			stage.focus = stage;
			gameState = STATE_RUNNING;
			removeChild(startButton);
		}
		
		private function initLevel():void
		{
			var i:int;
			var j:int;
			
			var rect:Rectangle = new Rectangle(3,3,121,121);
			chamber.createBlockOfBlocks(rect,Block.WHITE);
			
			rect = new Rectangle(25,25,25,25);
			chamber.createBlockOfBlocks(rect,Block.RED_UP,1,2);
			
			rect = new Rectangle(75,25,25,25);
			chamber.createBlockOfBlocks(rect,Block.BLUE_DOWN,1,2);
			
			rect = new Rectangle(75,75,25,25);
			chamber.createBlockOfBlocks(rect,Block.GREEN_LEFT,2,1);
			
			rect = new Rectangle(25,75,25,25);
			chamber.createBlockOfBlocks(rect,Block.YELLOW_RIGHT,2,1);
			
			rect = new Rectangle(60,60,5,5);
			chamber.clearBlockOfBlocks(rect);
			
			for(i=0;i<125;++i)
			{
				chamber.addBlockAt(new Block(Block.BLACK), 0, i);
				chamber.addBlockAt(new Block(Block.BLACK), 1, i);
				chamber.addBlockAt(new Block(Block.BLACK), 2, i);
				chamber.addBlockAt(new Block(Block.BLACK), 122, i);
				chamber.addBlockAt(new Block(Block.BLACK), 123, i);
				chamber.addBlockAt(new Block(Block.BLACK), 124, i);
				chamber.addBlockAt(new Block(Block.BLACK), i, 0);
				chamber.addBlockAt(new Block(Block.BLACK), i, 1);
				chamber.addBlockAt(new Block(Block.BLACK), i, 2);
				chamber.addBlockAt(new Block(Block.BLACK), i, 122);
				chamber.addBlockAt(new Block(Block.BLACK), i, 123);
				chamber.addBlockAt(new Block(Block.BLACK), i, 124);
			}
		}
		
		private function enterFrameHandler(e:Event):void
		{
			subject.step();
			breakBlocks();
		}
		
		private function breakBlocks():void
		{
			var block:Block;
			for(var i:int=breakingBlocks.length-1;i>=0;--i)
			{
				block = breakingBlocks[i];
				if(block && block.animateBreaking())
				{
					breakingBlocks = removeArrayItemAt(breakingBlocks, i);
					chamber.removeChild(block);
				}
			}
		}
		
		private function keyPressHandler(e:KeyboardEvent):void
		{
			if(gameState != STATE_RUNNING)
				return;
			
			if(musicChannel == null && (
				e.keyCode == Keyboard.UP ||
				e.keyCode == Keyboard.LEFT ||
				e.keyCode == Keyboard.RIGHT ||
				e.keyCode == Keyboard.DOWN))
			{
				musicChannel = music.play(0,999,new SoundTransform(0.3));
				powerUp.play();
			}
			
			switch(e.keyCode)
			{
				case Keyboard.UP:
					subject.direction = TestSubject.UP;
					break;
				
				case Keyboard.DOWN:
					subject.direction = TestSubject.DOWN;
					break;
				
				case Keyboard.RIGHT:
					subject.direction = TestSubject.RIGHT;
					break;
				
				case Keyboard.LEFT:
					subject.direction = TestSubject.LEFT;
					break;
			}
		}
		
		private function handleMove(e:MovementEvent):void
		{
			if(doIntersections())
			{
				moveField(subject.direction, subject.speed);
				doIntersections();
			}
			gauge.energy = subject.energy;
		}
		
		private function handleOutOfEnergy(e:EnergyChangeEvent):void
		{
			gameState = STATE_GAME_OVER;
			musicChannel.stop();
			musicChannel = null;
			powerDown.play();
		}
		
		/**
		 * 
		 * @return Whether or not to continue on to moving after this is called 
		 * 
		 */		
		private function doIntersections():Boolean
		{
			var blocks:Array = chamber.blocksInArea(new Point(0,0), WIDTH, HEIGHT);
			var block:Block;
			var blockBounds:Rectangle;
			var blockOrigin:Point;
			var subjectOrigin:Point = new Point(subject.x,subject.y);
			
			for(var i:int=0; i<blocks.length; ++i)
			{
				block = blocks[i];
				if(subject.overlapsBlock(block))
				{
					blockBounds = block.getBounds(this);
					blockOrigin = blockBounds.topLeft;
					if(subject.skin.bitmapData.hitTest(subjectOrigin,255,block.skin.bitmapData,blockOrigin,255))
					{
						if(block.brokenByDirection(subject.direction))
						{
							subject.energy += block.energyChange;
							breakingBlocks.push(block);
							chamber.removeBlock(block);
							continue;
						}else{
							subjectEvenWithBlock(block);
							return false;
						}
					}
				}
			}
			
			return true;
		}
		
		private function subjectEvenWithBlock(block:Block):void
		{
			var subjectOrigin:Point = new Point(subject.x,subject.y);
			var blockOrigin:Point = block.getBounds(this).topLeft;
			
			switch(subject.direction)
			{
				case TestSubject.UP:
					subjectOrigin.y++;
					while(subject.skin.bitmapData.hitTest(subjectOrigin,255,block.skin.bitmapData,blockOrigin,255))
					{
						subjectOrigin.y++;
					}
					subject.y = subjectOrigin.y;
					
					break;
				
				case TestSubject.DOWN:
					subjectOrigin.y--;
					while(subject.skin.bitmapData.hitTest(subjectOrigin,255,block.skin.bitmapData,blockOrigin,255))
					{
						subjectOrigin.y--;
					}
					subject.y = subjectOrigin.y;
					
					break;
				
				case TestSubject.RIGHT:
					subjectOrigin.x--;
					while(subject.skin.bitmapData.hitTest(subjectOrigin,255,block.skin.bitmapData,blockOrigin,255))
					{
						subjectOrigin.x--;
					}
					subject.x = subjectOrigin.x;
					
					break;
				
				case TestSubject.LEFT:
					subjectOrigin.x++;
					while(subject.skin.bitmapData.hitTest(subjectOrigin,255,block.skin.bitmapData,blockOrigin,255))
					{
						subjectOrigin.x++;
					}
					subject.x = subjectOrigin.x;
					
					break
			}
		}
		
		private function moveField(direction:String, speed:Number):void
		{
			switch(direction)
			{
				case TestSubject.UP:
					if(chamber.y < chamberMaxY && subjectCenteredVert)
					{
						if( chamber.y + speed <= chamberMaxY)
						{
							chamber.y += speed;
						}else{
							chamber.y = chamberMaxY;
						}
					}else if(subject.y != subjectMinY)
					{
						if(!subjectCenteredVert && chamber.y < chamberMaxY)
						{
							if(subject.y > subjectCenterY)
							{
								if(subject.y - subjectCenterY >= speed)
								{
									subject.y -= speed;
								}else{
									subject.y = subjectCenterY;
								}
							}else{
								if(subjectCenterY - subject.y >= speed)
								{
									subject.y += speed;
								}else{
									subject.y = subjectCenterY;
								}
							}
						}else{
							if(subject.y >= speed)
							{
								subject.y -= speed;
							}else{
								subject.y = subjectMinY;
							}
						}
					}
					break;
				
				case TestSubject.DOWN:
					if(chamber.y > chamberMinY && subjectCenteredVert)
					{
						if(chamber.y - speed >= chamberMinY)
						{
							chamber.y -= speed;
						}else{
							chamber.y = -(chamber.height - HEIGHT);
						}
					}else if(subject.y != subjectMaxY)
					{
						if(!subjectCenteredVert && chamber.y > chamberMinY)
						{
							if(subject.y > subjectCenterY)
							{
								if(subject.y - subjectCenterY >= speed)
								{
									subject.y -= speed;
								}else{
									subject.y = subjectCenterY;
								}
							}else{
								if(subjectCenterY - subject.y >= speed)
								{
									subject.y += speed;
								}else{
									subject.y = subjectCenterY;
								}
							}
						}else{
							if(HEIGHT - subject.y >= speed)
							{
								subject.y += speed;
							}else{
								subject.y = subjectMaxY;
							}
						}
					}
					break;
				
				case TestSubject.RIGHT:
					if(chamber.x > chamberMinX && subjectCenteredHoriz)
					{
						if(chamber.x - speed >= chamberMinX)
						{
							chamber.x -= speed;
						}else{
							chamber.x = -(chamber.height - HEIGHT);
						}
					}else if(subject.x != subjectMaxX)
					{
						if(!subjectCenteredHoriz && chamber.x > chamberMinX)
						{
							if(subject.x > subjectCenterX)
							{
								if(subject.x - subjectCenterX >= speed)
								{
									subject.x -= speed;
								}else{
									subject.x = subjectCenterX;
								}
							}else{
								if(subjectCenterX - subject.x >= speed)
								{
									subject.x += speed;
								}else{
									subject.x = subjectCenterX;
								}
							}
						}else{
							if(WIDTH - subject.x >= speed)
							{
								subject.x += speed;
							}else{
								subject.x = subjectMaxX;
							}
						}
					}
					
					break;
				
				case TestSubject.LEFT:
					if(chamber.x < chamberMaxX && subjectCenteredHoriz)
					{
						if( chamber.x + speed <= chamberMaxX)
						{
							chamber.x += speed;
						}else{
							chamber.x = chamberMaxX;
						}
					}else if(subject.x != subjectMinX)
					{
						if(!subjectCenteredHoriz && chamber.x < chamberMaxX)
						{
							if(subject.x > subjectCenterX)
							{
								if(subject.x - subjectCenterX >= speed)
								{
									subject.x -= speed;
								}else{
									subject.x = subjectCenterX;
								}
							}else{
								if(subjectCenterX - subject.x >= speed)
								{
									subject.x += speed;
								}else{
									subject.x = subjectCenterX;
								}
							}
						}else{
							if(subject.x >= speed)
							{
								subject.x -= speed;
							}else{
								subject.x = subjectMinX;
							}
						}
					}
					break;
				
				case TestSubject.NONE:
					break;
			}
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
		
		protected function get subjectCenteredVert():Boolean
		{
			return subject.y ==  subjectCenterY;
		}
		
		protected function get subjectCenteredHoriz():Boolean
		{
			return subject.x == subjectCenterX;
		}
		
		protected function get subjectCenterX():Number
		{
			return WIDTH/2.0 - subject.width/2.0;
		}
		
		protected function get subjectCenterY():Number
		{
			return HEIGHT/2.0 - subject.height/2.0;
		}
		
		protected function get subjectMaxX():Number
		{
			return WIDTH - subject.width;
		}
		
		protected function get subjectMinX():Number
		{
			return 0;
		}
		
		protected function get subjectMaxY():Number
		{
			return HEIGHT - subject.height;
		}
		
		protected function get subjectMinY():Number
		{
			return 0;
		}
		
		protected function get chamberMinX():Number
		{
			return -(chamber.width - WIDTH);
		}
		
		protected function get chamberMaxX():Number
		{
			return 0;
		}
		
		protected function get chamberMinY():Number
		{
			return -(chamber.height - HEIGHT);
		}
		
		protected function get chamberMaxY():Number
		{
			return 0;
		}
	}
}