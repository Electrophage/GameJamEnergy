package com.leisure.energyjam.eventz
{
	import flash.events.Event;
	
	public class EnergyChangeEvent extends Event
	{
		public static const OUT_OF_POWER:String = "outOfPower";
		
		public function EnergyChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}