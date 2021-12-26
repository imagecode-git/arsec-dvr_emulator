package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class SchedulerDialog extends Window implements IEventHandler
	{
		private static const CMD_MODE:int	= 0;
		private static const CMD_COPY:int	= 2;
		private static const CMD_OK:int		= 3;
		private static const CMD_EXIT:int	= 4;
		
		private var scheduler:Scheduler;
		
		private var modeCBox:Array;
		private var copyLBox:Array;
		private var weekDays:Array = ["Вс.", "Пон.", "Вт.", "Ср.", "Чт.", "Птн.", "Сб."];
		
		public function SchedulerDialog(ow:Object, o:Osd, alarm:Boolean)
		{
			System.exclusiveRightClick = this;
			
			super(ow, o, defX, defY, 636, 426, 2, 52, true, true);
			
			body.blendMode = BlendMode.LAYER;
			
			modeCBox = new Array();
			copyLBox = new Array();
			
			_osd.setHandler(body);
			
			gadX = defX-125;
			gadY = defY-180;
			
			var cb:CheckBox = _osd.addCheckBox(gadX, gadY+13, CMD_MODE, "Нет", true);	gadX += 189;
			cb.uncheck();
			modeCBox.push(cb);
			
			cb = _osd.addCheckBox(gadX, gadY+13, CMD_MODE+1, "Тревога", true);
			cb.check();
			modeCBox.push(cb);
			
			System.textLine = System.TEXTLINE_LONG; //'long' text lines ON
			
			gadX = defX-266;
			gadY = defY+102;
			_osd.addLabel(gadX, gadY, "Скопировать", Osd.COLOR_TEXT); gadX += 102;
			copyLBox.push(_osd.addListBox(gadX, gadY-3, 118, weekDays, 3, true)); gadX += 133;

			_osd.addLabel(gadX, gadY, "для", Osd.COLOR_TEXT); gadX += 45;
			
			var data:Array = new Array();
			for (var i:int = 0; i <= weekDays.length; i++)
			{
				if (i == 0) data.push("Все");
				else data.push(weekDays[i-1]);
			}
			
			copyLBox.push(_osd.addListBox(gadX, gadY-3, 118, data, 3, true)); gadX += 140;
			_osd.addTextButton(gadX, gadY, "Скопировать", CMD_COPY, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
			
			System.textLine = System.TEXTLINE_NORMAL; //'long' text lines OFF
			
			data = ["По умолчанию", "ОК", "Выход"];
			var comm:Array = [Osd.CMD_INVALID, CMD_OK, CMD_EXIT];
			var dlt:Array = [0, 164, 62];
			
			gadX = defX-4;
			gadY = defY+163;
			for (i = 0; i < data.length; i++)
			{
				gadX += dlt[i];
				_osd.addTextButton(gadX, gadY, data[i], comm[i], TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);
			}
			
			scheduler = new Scheduler(body, Scheduler.MODE_SINGLE);
			scheduler.setCaller(this);
			scheduler.setPos(defX, defY);
			
			if (alarm) scheduler.unifyMatrix(SchedulerSegment.MODE_ALARM);
			
			_osd.setHandler(this);
		}
		
		public override function finalize()
		{
			System.exclusiveRightClick = null;
			scheduler.finalize();
			super.finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			if(cmd>=CMD_MODE && cmd<CMD_MODE+2)
			{
				var t:int = cmd-CMD_MODE;
				if (t == 0) modeCBox[1].uncheck(); //alarm
				else modeCBox[0].uncheck(); //'normal' mode
				
				scheduler.swapDrawMode();
			}
			
			switch(cmd)
			{
				case(CMD_COPY):
					var from:int = copyLBox[0].getValue();
					var to:int;
					var toall:Boolean = false;
					var pat:Array = scheduler.getOptimizedPattern(from);
					
					if (copyLBox[1].getValue()) to = copyLBox[1].getValue()-1;
					else
					{
						to = 0;
						toall = true;
					}
					
					if (from != to || toall)
					{
						for (var i:int = 0; i < weekDays.length; i++)
						{
							if (toall) to = i;
							
							scheduler.readPattern(pat, to);
							
							if (!toall) i = weekDays.length;
						}
					}
					break;
					
				case(CMD_OK):
					osdCommand(CMD_EXIT);
					break;
					
				case(CMD_EXIT):
					finalize();
					break;
			}
		}
	}
}