package
{
	import com.leisure.energyjam.Credits;
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
		private var credits:Credits;
		
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
			
			gauge = new EnergyGuage();
			gauge.x = 20;
			gauge.y = 20;
			gauge.energy = subject.energy;
			
			initLevel();
			
			credits = new Credits();
			credits.width = WIDTH;
			credits.height = HEIGHT+100;
			
			addChild(chamber);
			addChild(subject);
			addChild(gauge);
			gauge.width = 20;
			gauge.height = TestSubject.MAX_ENERGY;
			
			startButton = new Sprite();
			startButton.graphics.beginFill(0x0000ff);
			startButton.graphics.drawRoundRect(0,0,100,80,90,90);
			startButton.graphics.endFill();
			startButton.x = WIDTH/2 - 50;
			startButton.y = HEIGHT/2 - 40;
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
			subject.addEventListener(EnergyChangeEvent.OUT_OF_POWER, handleOutOfEnergy);
			stage.focus = stage;
			gameState = STATE_RUNNING;
			removeChild(startButton);
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
				powerUp.play();
				musicChannel = music.play(0,999,new SoundTransform(0.3));
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
			subject.removeEventListener(EnergyChangeEvent.OUT_OF_POWER,handleOutOfEnergy);
			gameState = STATE_GAME_OVER;
			musicChannel.stop();
			musicChannel = null;
			powerDown.play();
			addChild(credits);
			setChildIndex(subject,0);
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
		private function initLevel():void
		{
			var loc:Point;
			//Zero
			loc= new Point(0,1);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(0,3);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(0,5);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(0,7);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(0,9);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(0,11);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(0,13);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(0,15);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(0,17);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(0,19);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(0,21);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(0,23);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			//One
			loc = new Point(1,0);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(1,2);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(1,4);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(1,6);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(1,8);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(1,10);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(1,12);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(1,14);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(1,16);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(1,18);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(1,20);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(1,22);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(1,24);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			//Two
			loc= new Point(2,1);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(2,3);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(2,5);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(2,7);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(2,9);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(2,11);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(2,13);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(2,15);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(2,17);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(2,19);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(2,21);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc = new Point(2,23);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			//Three
			loc= new Point(3,0);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(3,2);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(3,4);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(3,6);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(3,8);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(3,10);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(3,12);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(3,14);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(3,16);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(3,18);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(3,20);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(3,22);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(3,24);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			//Four
			loc= new Point(4,1);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(4,3);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(4,5);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(4,7);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(4,9);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(4,11);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(4,13);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(4,15);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(4,17);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(4,19);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(4,21);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(4,23);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			//Five
			loc= new Point(5,0);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(5,2);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(5,4);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(5,6);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(5,8);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(5,10);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(5,12);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(5,14);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(5,16);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(5,18);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(5,20);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(5,22);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(5,24);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			//Six
			loc= new Point(6,1);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(6,3);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(6,5);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(6,7);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(6,9);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(6,11);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(6,13);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(6,15);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(6,17);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(6,19);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(6,21);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(6,23);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			//Seven
			loc= new Point(7,0);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(7,2);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(7,4);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(7,6);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(7,8);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(7,10);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(7,12);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(7,14);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(7,16);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(7,18);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(7,20);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(7,22);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(7,24);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			//EIGHT
			loc= new Point(8,1);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(8,3);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(8,5);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(8,7);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(8,9);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(8,11);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(8,13);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(8,15);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(8,17);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(8,19);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(8,21);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			//KEY in between
			loc= new Point(8,23);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			//Nine
			loc= new Point(9,0);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(9,2);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(9,4);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(9,6);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(9,8);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(9,10);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(9,12);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(9,14);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(9,16);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(9,18);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(9,20);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(9,22);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(9,24);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			//Ten
			loc= new Point(10,1);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(10,3);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(10,5);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(10,7);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(10,9);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(10,11);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(10,13);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(10,15);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(10,17);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(10,19);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(10,21);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(10,23);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			//Eleven
			loc= new Point(11,0);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(11,2);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(11,4);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(11,6);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(11,8);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(11,10);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(11,12);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(11,14);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(11,16);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(11,18);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(11,20);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(11,22);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(11,24);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			//Twelve
			loc= new Point(12,1);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(12,3);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(12,5);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(12,7);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(12,9);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(12,11);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(12,13);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(12,15);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(12,17);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(12,19);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(12,21);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(12,23);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			//Thirteen
			loc= new Point(13,0);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(13,2);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(13,4);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(13,6);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(13,8);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(13,10);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(13,12);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(13,14);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(13,16);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(13,18);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(13,20);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(13,22);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(13,24);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			//Fourteen
			loc= new Point(14,1);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(14,3);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(14,5);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(14,7);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(14,9);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(14,11);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(14,13);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(14,15);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(14,17);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(14,19);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(14,21);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(14,23);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			//Fifteen
			loc= new Point(15,0);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(15,2);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(15,4);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(15,6);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(15,8);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(15,10);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(15,12);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(15,14);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(15,16);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(15,18);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(15,20);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(15,22);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(15,24);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			//Sixteen
			loc= new Point(16,1);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(16,3);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(16,5);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(16,7);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(16,9);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(16,11);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(16,13);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(16,15);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(16,17);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(16,19);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(16,21);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(16,23);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			//Seventeen
			loc= new Point(17,0);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(17,2);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(17,4);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(17,6);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(17,8);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(17,10);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(17,12);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(17,14);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(17,16);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(17,18);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(17,20);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(17,22);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(17,24);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			//Eightteen
			loc= new Point(18,1);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(18,3);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(18,5);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(18,7);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(18,9);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(18,11);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(18,13);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(18,15);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(18,17);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(18,19);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(18,21);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(18,23);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			//Nineteen
			loc= new Point(19,0);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(19,2);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(19,4);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(19,6);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(19,8);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(19,10);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(19,12);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(19,14);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(19,16);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(19,18);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(19,20);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(19,22);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(19,24);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			//Twenty
			loc= new Point(20,1);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(20,3);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(20,5);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(20,7);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(20,9);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(20,11);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(20,13);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(20,15);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(20,17);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(20,19);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(20,21);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(20,23);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			//Twentyone
			loc= new Point(21,0);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(21,2);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(21,4);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(21,6);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(21,8);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(21,10);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(21,12);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(21,14);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(21,16);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(21,18);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(21,20);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(21,22);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(21,24);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			//TwentyTwo
			loc= new Point(22,1);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(22,3);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(22,5);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(22,7);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(22,9);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(22,11);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(22,13);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(22,15);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(22,17);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(22,19);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(22,21);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(22,23);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			//TwentyThree
			loc= new Point(23,0);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(23,2);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(23,4);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(23,6);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(23,8);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(23,10);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(23,12);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(23,14);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(23,16);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(23,18);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(23,20);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(23,22);
			chamber.createBlockOfBlocks(loc, Block.GREEN_LEFT);
			
			loc= new Point(23,24);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			//TwentyFour
			loc= new Point(24,1);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(24,3);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(24,5);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(24,7);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(24,9);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(24,11);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(24,13);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(24,15);
			chamber.createBlockOfBlocks(loc, Block.YELLOW_RIGHT);
			
			loc= new Point(24,17);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(24,19);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
			
			loc= new Point(24,21);
			chamber.createBlockOfBlocks(loc, Block.BLUE_DOWN);
			
			loc= new Point(24,23);
			chamber.createBlockOfBlocks(loc, Block.RED_UP);
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