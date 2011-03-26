package com.leisure.energyjam.gui
{
	import com.leisure.energyjam.person.TestSubject;
	
	import flash.display.Sprite;

	public class EnergyGuage extends Sprite
	{
		private var _energy:Number;

		public function get energy():Number
		{
			return _energy;
		}

		public function set energy(value:Number):void
		{
			_energy = value;
			redraw();
		}
		
		public function EnergyGuage()
		{
			super();
		}
		
		private function redraw():void
		{
			graphics.clear();
			
			graphics.beginFill(0xff0000);
			graphics.drawRect(0,0,20,TestSubject.MAX_ENERGY);
			graphics.endFill();
			
			var topLevel:Number = TestSubject.MAX_ENERGY - energy;
			if( topLevel > TestSubject.MAX_ENERGY)
			{
				topLevel = TestSubject.MAX_ENERGY;
			}
			
			graphics.beginFill(0x00ff00);
			graphics.drawRect(0,topLevel,20,TestSubject.MAX_ENERGY - topLevel);
			graphics.endFill();
		}
	}
}