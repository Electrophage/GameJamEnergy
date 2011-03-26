package
{
	import com.leisure.energyjam.blocks.Block;
	import com.leisure.energyjam.eventz.MovementEvent;
	import com.leisure.energyjam.person.TestSubject;
	import com.leisure.energyjam.room.TestChamber;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	[SWF(width="500", height="500", backgroundColor='#000000', frameRate='30')]
	public class GameJamEnergy extends Sprite
	{
		public static const HEIGHT:int = 500;
		public static const WIDTH:int = 500;
		private var chamber:TestChamber;
		private var subject:TestSubject;
		
		public function GameJamEnergy()
		{
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
			subject.x = WIDTH/2.0 - subject.width/2.0;
			subject.y = HEIGHT/2.0 - subject.height/2.0;
			subject.addEventListener(MovementEvent.MOVE, handleMove);
			
			var block:Block = new Block(Block.RED);
			chamber.addChild(block);
			block.x = chamber.width/2.0 + 20;
			block.y = chamber.height/2.0 + 20;
			
			
			addChild(chamber);
			addChild(subject);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressHandler);
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(e:Event):void
		{
			subject.step();
		}
		
		private function keyPressHandler(e:KeyboardEvent):void
		{
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
			moveField(subject.direction, subject.speed);
		}
		
		private function moveField(direction:String, speed:Number):void
		{
			/*if(chamber.level.bitmapData.hitTest(new Point(chamber.x, chamber.y),255,
						subject.getBounds(this), new Point(subject.x, subject.y), 255))
			{
				return;
			}*/
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