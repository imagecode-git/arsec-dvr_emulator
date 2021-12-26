package com.arsec.ui
{
	import flash.events.Event;
	import com.arsec.ui.*;
	import com.arsec.system.*;
	
	public class GadgetEvent extends Event
	{
		public static const ET_DEFAULT:String = "GAD_DEFAULT";
		public static const ET_CHANGE:String = "GAD_CHANGE";
		public static const ET_KILL:String = "GAD_KILL";
		
		public var cmd:int;
		
		public function GadgetEvent(type:String, c:int, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			cmd = c;
			super(type, bubbles, cancelable);
		}
	}
}