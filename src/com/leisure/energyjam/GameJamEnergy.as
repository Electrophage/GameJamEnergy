package com.leisure.energyjam
{
	import com.leisure.energyjam.blocks.Block;
	import com.leisure.energyjam.eventz.EnergyChangeEvent;
	import com.leisure.energyjam.eventz.MovementEvent;
	import com.leisure.energyjam.gui.EnergyGuage;
	import com.leisure.energyjam.person.TestSubject;
	import com.leisure.energyjam.room.TestChamber;
	
	import flash.display.Bitmap;
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
	
	import flashx.textLayout.factory.TruncationOptions;
	import flashx.textLayout.formats.Direction;
	
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
		
		[Embed(source="assets/start.png")]
		private var startScreenSource:Class;
		
		[Embed(source="assets/startButton.png")]
		private var startButtonSource:Class;
		
		private var chamber:TestChamber;
		private var subject:TestSubject;
		private var gauge:EnergyGuage;
		private var startButton:Sprite;
		private var startScreen:Bitmap;
		private var credits:Credits;
		
		
		[Embed(source="assets/music/idle1.mp3")]
		private var idleClass:Class;
		
		[Embed(source="assets/music/NRG_1.mp3")]
		private var playMusicClass:Class;
		
		[Embed(source="assets/music/EndSong.mp3")]
		private var endMusicClass:Class;
		
		[Embed(source="assets/sounds/Powerup.mp3")]
		private var powerUpClass:Class;
		
		[Embed(source="assets/sounds/PowerDown.mp3")]
		private var powerDownClass:Class;
		
		private var playMusicSource:String = "assets/music/NRG_1.mp3";
		private var idleMusicSource:String = "assets/music/idle1.mp3";
		private var endMusicSource:String = "assets/music/EndSong.mp3";
		private var powerUpSource:String = "assets/sounds/Powerup.mp3";
		private var powerDownSource:String = "assets/sounds/PowerDown.mp3";
		private var playMusic:Sound;
		private var idleMusic:Sound;
		private var endMusic:Sound;
		private var powerUp:Sound;
		private var powerDown:Sound;
		
		private var musicChannel:SoundChannel;
		
		private var breakingBlocks:Array;
		
		public function GameJamEnergy()
		{
			gameState = STATE_START;
			
			try{
				//var musicReq:URLRequest = new URLRequest(playMusicSource);
				playMusic = new playMusicClass();
				//playMusic.load(musicReq);
			}catch(e:Error)
			{
			}
			
			try{
				//var idleMusicReq:URLRequest = new URLRequest(idleMusicSource);
				idleMusic = new idleClass();
				//idleMusic.load(idleMusicReq);
			}catch(e:Error)
			{
			}
			try{
				//var endMusicReq:URLRequest = new URLRequest(endMusicSource);
				endMusic = new endMusicClass();
//				endMusic.load(endMusicReq);
			}catch(e:Error)
			{
			}
			
			try{
				//var powerUpReq:URLRequest = new URLRequest(powerUpSource);
				powerUp = new powerUpClass();
				//powerUp.load(powerUpReq);
			}catch(e:Error)
			{
			}
			
			try{
				//var powerDownReq:URLRequest = new URLRequest(powerDownSource);
				powerDown = new powerDownClass();
				//powerDown.load(powerDownReq);
			}catch(e:Error)
			{
			}
			
			breakingBlocks = new Array();
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		private function handleAddedToStage(e:Event):void
		{
			stage.align = "topLeft";
			stage.scaleMode = "noScale";

			setUp();
			initLevel();
			
			credits = new Credits();
			credits.width = WIDTH;
			credits.height = HEIGHT+100;
			credits.nextButton.addEventListener(MouseEvent.CLICK, newGame);
			
			startScreen = new startScreenSource();
			startScreen.width = WIDTH;
			startScreen.height = HEIGHT;
			
			startButton = new Sprite()
			startButton.addChild(new startButtonSource());
			startButton.width = 260;
			startButton.height = 44;
			startButton.x = 118;
			startButton.y = 334;
			
			addChild(startScreen);
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
			try{
				musicChannel = idleMusic.play(0,999, new SoundTransform(0.1));
			}catch(e:Error)
			{
				trace(e.name);
			}
			removeChild(startButton);
			removeChild(startScreen);
		}
		
		private function newGame(e:MouseEvent):void
		{
			gameState = STATE_START;
			removeChild(credits);
			removeChild(subject);
			removeChild(chamber);
			removeChild(gauge);
			musicChannel.stop();
			setUp();
			initLevel();
			addChild(startScreen);
			addChild(startButton);
			credits.winText.visible = false;
		}
		
		private function setUp():void
		{
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
			
			addChild(chamber);
			addChild(subject);
			addChild(gauge);
			
			gauge.width = 20;
			gauge.height = TestSubject.MAX_ENERGY;
			
			gameMusicRunning = false;
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
		
		private var gameMusicRunning:Boolean = false;
		
		private function keyPressHandler(e:KeyboardEvent):void
		{
			if(gameState != STATE_RUNNING)
				return;
			
			if(gameMusicRunning == false && (
				e.keyCode == Keyboard.UP ||
				e.keyCode == Keyboard.LEFT ||
				e.keyCode == Keyboard.RIGHT ||
				e.keyCode == Keyboard.DOWN))
			{
				try{
					powerUp.play();
					musicChannel.stop();
					musicChannel = playMusic.play(0,999,new SoundTransform(0.3));
				}catch(e:Error)
				{
					
				}
				gameMusicRunning = true;
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
			if(doIntersections(true))
			{
				moveField(subject.direction, subject.speed);
				doIntersections(false);
			}
			gauge.energy = subject.energy;
		}
		
		private function handleOutOfEnergy(e:EnergyChangeEvent):void
		{
			subject.removeEventListener(EnergyChangeEvent.OUT_OF_POWER,handleOutOfEnergy);
			gameState = STATE_GAME_OVER;
			musicChannel.stop();
			musicChannel = endMusic.play(0,999);
			powerDown.play();
			addChild(credits);
			setChildIndex(subject,0);
		}
		
		/**
		 * 
		 * @return Whether or not to continue on to moving after this is called 
		 * 
		 */		
		private function doIntersections(firstCall:Boolean):Boolean
		{
			var blocks:Array = chamber.blocksInArea(new Point(0,0), WIDTH, HEIGHT);
			var block:Block;
			var blockBounds:Rectangle;
			var blockOrigin:Point;
			var subjectOrigin:Point = new Point(subject.x,subject.y+subject.skin.y);
			
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
							if(block.type == Block.RAINBOW)
							{
								credits.winText.visible = true;
								handleOutOfEnergy(new EnergyChangeEvent(EnergyChangeEvent.OUT_OF_POWER));
								return false;
							}
							subject.energy += block.energyChange;
							breakingBlocks.push(block);
							chamber.removeBlock(block);
							continue;
						}else/* if(!firstCall)*/
						{
							return subjectEvenWithBlock(block);
						}
					}
				}
			}
			
			return true;
		}
		
		private function subjectEvenWithBlock(block:Block):Boolean
		{
			/*if(!blockImportant(block))
				return true;*/
			
			var subjectOrigin:Point = new Point(subject.x+subject.skin.x, subject.y+subject.skin.y);
			var chamberOffset:Point = new Point(0,0);
			var blockOrigin:Point = block.getBounds(this).topLeft;
			var dist:int = 0;
			
			switch(subject.direction)
			{
				//Seems to work okay
				case TestSubject.DOWN:
					/*if(blockOrigin.y >= subjectOrigin.y + 50)
					{
						return true;
					}*/
					//chamberOrigin.y++;
					//chamberOrigin.y = chamberOrigin.y >= chamberMaxY ? chamberMaxY : chamberOrigin.y + 1;
					while(subject.skin.bitmapData.hitTest(subjectOrigin,255,block.skin.bitmapData,blockOrigin,255) 
						&& dist <= subject.speed)
					{
						//chamberOrigin.y++;
						chamberOffset.y = chamberOffset.y >= chamberMaxY ? chamberMaxY : chamberOffset.y + 1;
						++dist;
						blockOrigin = block.getBounds(this).topLeft.add(chamberOffset);
						
					}
					chamber.y += chamberOffset.y;
					
					break;
				
				//Doesn't seem to do the backwards thing, but edge behavior is weird, that happens in moveField
				case TestSubject.UP:
					/*if(blockOrigin.y <= subjectOrigin.y + (subject.height - subject.skin.y - 50))
					{
						return true;
					}*/
					//chamberOrigin.y--;
					//chamberOrigin.y = chamberOrigin.y <= chamberMinY ? chamberMinY : chamberOrigin.y - 1;
					while(subject.skin.bitmapData.hitTest(subjectOrigin,255,block.skin.bitmapData,blockOrigin,255)
						&& dist <= subject.speed)
					{
						//chamberOrigin.y--;
						chamberOffset.y = chamberOffset.y <= chamberMinY ? chamberMinY : chamberOffset.y - 1;
						++dist;
						blockOrigin = block.getBounds(this).topLeft.add(chamberOffset);;
					}
					chamber.y += chamberOffset.y;
					
					break;
				
				//Need to test moveField, still seems wrong
				//Backwards bug happens plenty
				case TestSubject.LEFT:
					//chamberOrigin.x--;
					//chamberOrigin.x = chamberOrigin.x <= chamberMinX ? chamberMinX : chamberOrigin.x - 1;
					while(subject.skin.bitmapData.hitTest(subjectOrigin,255,block.skin.bitmapData,blockOrigin,255)
						&& dist <= subject.speed)
					{
						//chamberOrigin.x--;
						chamberOffset.x = chamberOffset.x <= chamberMinX ? chamberMinX : chamberOffset.x - 1;
						++dist;
						blockOrigin = block.getBounds(this).topLeft.add(chamberOffset);
					}
					chamber.x += chamberOffset.x;
					
					break;
				
				//Backwards bug happens occasionally
				case TestSubject.RIGHT:
					//chamberOrigin.x++;
					//chamberOrigin.x = chamberOrigin.x >= chamberMaxX ? chamberMaxX : chamberOrigin.x + 1;
					while(subject.skin.bitmapData.hitTest(subjectOrigin,255,block.skin.bitmapData,blockOrigin,255)
						&& dist <= subject.speed)
					{
						//chamberOrigin.x++;
						chamberOffset.x = chamberOffset.x >= chamberMaxX ? chamberMaxX : chamberOffset.x + 1;
						++dist;
						blockOrigin = block.getBounds(this).topLeft.add(chamberOffset);
					}
					chamber.x += chamberOffset.x;
					
					break
			}
			
			return false;
		}
		
		private function blockImportant(block:Block):Boolean
		{
			var importantRect:Rectangle = subject.skin.getBounds(this);
			switch(subject.direction)
			{
				case TestSubject.UP:
					importantRect.height = 70;
					importantRect.x += 25;
					importantRect.width -= 50;
					break;
				
				case TestSubject.DOWN:
					importantRect.y = importantRect.height - 70;
					importantRect.height = 70;
					importantRect.x += 25;
					importantRect.width -= 50;
					break;
				
				case TestSubject.RIGHT:
					importantRect.x = importantRect.width - 70;
					importantRect.width = 70;
					importantRect.y += 25;
					importantRect.height -= 50;
					break;
				
				case TestSubject.LEFT:
					importantRect.width = 70;
					importantRect.y += 25;
					importantRect.height -= 50;
					break;
			}
			
			return importantRect.intersects(block.getBounds(this));
		}
		
		private function moveField(direction:String, speed:Number):void
		{
			switch(direction)
			{
				case TestSubject.UP:
					if(chamber.y < chamberMaxY && subjectCenteredVert)
					{
						if( chamber.y + speed < chamberMaxY)
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
							if(subject.y + speed > subjectMinY)
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
							chamber.y = chamberMinY;
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
							if(subject.y + speed <= subjectMaxY)
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
							chamber.x = chamberMinX;
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
							if(subject.x + speed > subjectMaxX)
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
			
			loc = new Point(8,22);
			chamber.createBlockOfBlocks(loc,Block.RAINBOW);
			
			loc = new Point(2,16);
			chamber.createBlockOfBlocks(loc,Block.RAINBOW);
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
			return WIDTH - subject.skin.width - subject.skin.x;
		}
		
		protected function get subjectMinX():Number
		{
			return 0;
		}
		
		protected function get subjectMaxY():Number
		{
			return HEIGHT - subject.skin.height - subject.skin.y;
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