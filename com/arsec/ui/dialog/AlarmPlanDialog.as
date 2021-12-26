package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class AlarmPlanDialog extends Window
	{
		private static const CMD_NAV:int	= 0;
		private static const CMD_PTZ:int	= 10;
		
		public static const MODE_MOVEMENT:int	= 0;
		public static const MODE_SENSOR:int		= 1;
		public static const MODE_VIDEOLOST:int	= 2;
		public static const MODE_CAMCLOSE:int	= 3;
		public static const MODE_MISC:int		= 4;
		
		private var mode:int;
		
		private var ptzLBox:Array;
		private var presetLBox:Array;
		private var cruiseLBox:Array;
		
		public function AlarmPlanDialog(ow:Object, o:Osd, m:int)
		{
			mode = m;
			
			System.exclusiveRightClick = this;
			super(ow, o, defX, defY, 637, 402, 2, 55, true, true);
			
			body.blendMode = BlendMode.LAYER;
			
			_osd.setHandler(body);
			
			addNavElements();
			
			ptzLBox = new Array();
			presetLBox = new Array();
			cruiseLBox = new Array();
			
			var data:Array = ["Запись", "Снимок", "Отправка E-mail", "Реле", "Push", "Задержка трев. выхода", "Динамик", "Всплыв экран", "Предзапись", "Постзапись", "PTZ"];
			for (var i:int = 0; i < System.CHANNELS; i++) data.push("Кан" + new String(i+1));

			scrollPageSize = 9;
			scrollLines = new Array();
			for (i = 0; i < data.length; i++)
			{
				scrollLines.push(new MovieClip());
				body.addChildAt(scrollLines[i], 6);
			}
			
			var lineIdx:int = 0;
			
			//----------------------------------------LABELS
			gadX = defX-305;
			gadY = defY-159;
			for (i = 0; i < data.length; i++)
			{
				_osd.setHandler(scrollLines[i]);
				_osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT);
			}
			
			//----------------------------------------LINES {0,1}
			var xpos:Number = defX-106;
			for (var j:int = 0; j < 2; j++)
			{
				gadX = xpos+13;
				for (i = 0; i < System.CHANNELS; i++)
				{
					_osd.setHandler(scrollLines[lineIdx+j]);
					
					var cb:CheckBox = _osd.addCheckBox(gadX-4, gadY+13, Osd.CMD_INVALID, new String(i+1));
					if (mode != MODE_SENSOR) cb.uncheck();
					if (mode == MODE_MISC) cb.disable();
					
					gadX += 49;
				}
			}
			lineIdx+=2;
			
			//----------------------------------------LINES {2,3,4}
			gadX = xpos+13;
			for (i = 0; i < 3; i++)
			{
				_osd.setHandler(scrollLines[lineIdx+i]);
				cb = _osd.addCheckBox(gadX-4, gadY+13, Osd.CMD_INVALID);
				
				switch(i)
				{
					case(0):
						if (mode != MODE_SENSOR) cb.uncheck();
						break;
					
					case(1):
						if (mode == MODE_SENSOR || mode == MODE_MISC) cb.check();
						else cb.uncheck();
						break;
						
					case(2):
						cb.uncheck();
						break;
				}
			}
			lineIdx+=3;
			
			//----------------------------------------LINE 5
			_osd.setHandler(scrollLines[lineIdx]);
			var times:Array = ["10с", "30с", "1мин", "3мин", "5мин", "10мин", "15мин", "30мин"];
			
			gadX = xpos;
			_osd.addListBox(gadX, gadY, 177, times, 3);
			lineIdx++;
			
			//----------------------------------------LINE 6
			_osd.setHandler(scrollLines[lineIdx]);
			var arr:Array = times;
			arr.unshift("Нет");
			
			_osd.addListBox(gadX, gadY, 177, arr, 3).selectItem(1);
			lineIdx++;
			
			//----------------------------------------LINE 7
			_osd.setHandler(scrollLines[lineIdx]);
			data = ["Нет"];
			for (i = 0; i < System.CHANNELS; i++) data.push("Кан" + new String(i+1));
			
			var lb:ListBox = _osd.addListBox(gadX, gadY, 177, data, 3);
			lb.selectItem(1);
			if (mode == MODE_MISC) lb.disable();
			lineIdx++;
			
			//----------------------------------------LINE 8
			_osd.setHandler(scrollLines[lineIdx]);
			lb = _osd.addListBox(gadX, gadY, 177, ["Нет", "5с", "10с"]);
			lb.selectItem(1);
			if (mode == MODE_MISC) lb.disable();
			lineIdx++;
			
			//----------------------------------------LINE 9
			_osd.setHandler(scrollLines[lineIdx]);
			lb = _osd.addListBox(gadX, gadY, 177, times, 3);
			lb.selectItem(1);
			if (mode == MODE_MISC) lb.disable();
			lineIdx+=2;
			
			//----------------------------------------LINES {11,12,13,14}
			arr = ["Точка пресета", "Маршрут", "Нет"];
			
			var presets:Array = new Array();
			for (i = 0; i < 255; i++) presets.push(new String(i+1));
			
			var cruises:Array = new Array();
			for (i = 0; i < System.CHANNELS; i++) cruises.push("Cruise" + new String(i+1));

			for (i = 0; i < System.CHANNELS; i++)
			{
				_osd.setHandler(scrollLines[lineIdx+i]);
				
				ptzLBox.push(_osd.addListBox(gadX, gadY, 177, arr, 0, false, CMD_PTZ+i));	gadX += 184;
				presetLBox.push(_osd.addListBox(gadX, gadY, 169, presets, 3));
				cruiseLBox.push(_osd.addListBox(gadX, gadY, 169, cruises, 3));				gadX -= 184;
			
				if (mode == MODE_SENSOR)
				{
					ptzLBox[i].selectItem(2);
					osdCommand(CMD_PTZ+i);
				}
				
				cruiseLBox[i].visible = false;
			}
			//----------------------------------------EOF LINES
			
			scrollPivot = scrollLines[0].y;
			scrollTo(0);
			
			_osd.setHandler(this);
		}
		
		public function addNavElements()
		{
			var dlt:Array = [-3, 159, 64];
			var data:Array = ["По умолчанию", "ОК", "Выход"];
			
			gadX = defX;
			gadY = defY+146;
			for (var i:int = 0; i < data.length; i++)
			{
				gadX += dlt[i];
				_osd.addTextButton(gadX, gadY, data[i], CMD_NAV+i, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);
			}
			
			wndScroller = _osd.addScroller(defX+293, defY-151, 4, 260, 9, 16); //handled by superclass
		}
		
		public override function finalize()
		{
			System.exclusiveRightClick = null;
			super.finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			if (cmd >= CMD_NAV && cmd <= CMD_NAV+3)
			{
				var t:int = cmd-CMD_NAV;
				if(t>0) finalize();
			}
			
			if (cmd >= CMD_PTZ && cmd <= CMD_PTZ+System.CHANNELS)
			{
				t = cmd-CMD_PTZ;
				switch(ptzLBox[t].getValue())
				{
					case(0):
						presetLBox[t].visible = true;
						presetLBox[t].enable();
						
						cruiseLBox[t].visible = false;
						cruiseLBox[t].enable();
						break;
						
					case(1):
						presetLBox[t].visible = false;
						presetLBox[t].enable();
						
						cruiseLBox[t].visible = true;
						cruiseLBox[t].enable();
						break;
						
					case(2):
						presetLBox[t].disable();
						cruiseLBox[t].disable();
						break;
				}
			}
			
			super.osdCommand(cmd); //forces scroller to work
		}
	}
}