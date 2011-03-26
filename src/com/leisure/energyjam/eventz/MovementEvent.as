package com.leisure.energyjam.eventz
{
	import flash.events.Event;
	
	public class MovementEvent extends Event
	{
		public static const MOVE:String = "MOVE DAMN IT!";
		
		public function MovementEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}