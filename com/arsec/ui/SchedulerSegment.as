package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class SchedulerSegment extends Gadget
	{
		public static const GRAD_NORMAL:Array	= new Array(0x995C00, 0xFEF700, 0x995C00);
		public static const GRAD_ALARM:Array	= new Array(0x6F0F27, 0xFE321B, 0x6F0F27);
		
		public static const MODE_NORMAL:int	= 0;
		public static const MODE_ALARM:int	= 1;
		public static const MODE_ERASE:int	= 2;
		
		private var rect:RoundRect;
		private var scheduler:Scheduler;
		
		public var defMode:int = -1;
		public var mode:int = MODE_NORMAL;
		public var id:Array;

		//this object is not actor itself, there is a hotspot in scheduler so it translates all events to matrix segment
		public function SchedulerSegment(sc:Scheduler, x:Number, y:Number, m:int, id:Array)
		{
			this.id = id;
			
			rect = new RoundRect(0, 0, 12, 28, 0, 0, Osd.COLOR_SELECTED);
			rect.setPos(x,y);
			
			scheduler = sc;
			setMode(m);

			addChild(rect);
			scheduler.addChild(this);
		}
		
		public override function hover()
		{
			scheduler.notify(id, true);
			super.hover();
		}
		
		public override function unfocus()
		{
			scheduler.notify(id, false);
			super.unfocus();
		}
		
		//this function simulates double click
		public override function pressRight()
		{
			scheduler.getTimeTable(id[0]);
			super.pressRight();
		}
		
		public override function hold()
		{
			scheduler.beginWatch(id);
			super.hold();
		}
		
		public override function unhold()
		{
			scheduler.stopWatch();
			super.unhold();
		}
		
		public function setMode(m:int)
		{
			mode = m;
			if (defMode < 0) defMode = m;
			
			switch(mode)
			{
				case(MODE_NORMAL):
					rect.setGradient(GRAD_NORMAL, [1, 1, 1], [0, 105, 255], Math.PI/2);
					alpha = 1.0;
					break;
					
				case(MODE_ALARM):
					rect.setGradient(GRAD_ALARM, [1, 1, 1], [0, 105, 255], Math.PI/2);
					alpha = 1.0;
					break;
					
				case(MODE_ERASE):
					alpha = 0;
					break;
			}
		}
	}
}