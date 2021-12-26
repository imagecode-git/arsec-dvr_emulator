package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.geom.Point;
	
	public class ArchiveEventsDialog extends Window
	{
		private static const CMD_ARCHIVE	= 0;
		private static const CMD_PLAY		= 1;
		private static const CMD_EXIT		= 2;
		
		private var calendar:Calendar;
		
		public function ArchiveEventsDialog(ow:Object, o:Osd)
		{
			System.exclusiveRightClick = this;
			
			super(ow, o, defX, defY, 800, 468, 2, 80, true, true);
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			_osd.setHandler(body);

			var data:Array = new Array("Канал", "Начало", "Окончание", "Тип");
			var xdlt:Array = new Array(0, 104, 112, 156);
			gadX = defX - 84;
			gadY = defY - 204;
			for (var i:int = 0; i < data.length; i++)
			{
				gadX += xdlt[i];
				_osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT);
			}
			
			gadX = defX - 100;
			gadY = defY - 176;
			sep = 38;
			
			for (i = 0; i < System.eventStack.length; i++)
			{
				var e:EventEntry = System.eventStack[i];
				_osd.addTextLine(gadX, gadY, 470, [new String(e.channel), e.getBeginTime(), e.getEndTime(), e.getType()], Osd.CMD_INVALID, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT, [38, 109, 125, 130]);
				gadY += sep;
			}
			
			data = new Array("Поиск", "Первый", "Пред.", "След.", "Посл.", "Архив", "Воспр.", "Выход");
			xdlt = new Array(0, 166, 81, 74, 77, 70, 72, 75);
			gadX = defX - 296;
			gadY = defY + 191;
			for (i = 0; i < data.length; i++)
			{
				gadX += xdlt[i];
				var c:int = Osd.CMD_INVALID;
				switch(i)
				{
					case(5): c = CMD_ARCHIVE; break;
					case(6): c = CMD_PLAY; break;
					case(7): c = CMD_EXIT; break;
				}
				_osd.addTextButton(gadX, gadY, data[i], c, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
			}
			
			var sep:int = 30;
			data = new Array("Начало", "Окончание", "Тип записи", "Кан.");
			gadX = defX - 381;
			gadY = defY + 18;
			for (i = 0; i < 4; i++)
			{
				_osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT);
				if (i < 3) gadY += sep;
				if (i == 2) gadY -= 2;
			}
			
			gadX += 47;
			gadY += 12;
			_osd.addCheckBox(gadX, gadY, Osd.CMD_INVALID).uncheck(); gadX += 22;
			for (i = 0; i < 4; i++)
			{
				_osd.addCheckBox(gadX, gadY, Osd.CMD_INVALID, new String(i+1)).uncheck(); gadX += 42;
			}
			
			System.textLine = System.TEXTLINE_SHORT; //'short' text lines ON
			gadX = defX - 255;
			gadY -= (sep-1)*3+15;
			_osd.addTextInput(gadX, gadY, 93, "00:00:00", Osd.CMD_INVALID, TextInput.FMT_TIME);	gadY += 30;
			_osd.addTextInput(gadX, gadY, 93, "23:59:59", Osd.CMD_INVALID, TextInput.FMT_TIME);	gadY += 30;
			_osd.addListBox(gadX, gadY, 93, new Array("Все", "Норм.", "Тревога"));
			System.textLine = System.TEXTLINE_NORMAL;  //'short' text lines OFF
			
			calendar = new Calendar(body, _osd);
			calendar.setPos(new Point(defX-380, defY-210));

			_osd.setHandler(this);
		}
		
		public override function finalize()
		{
			System.exclusiveRightClick = null;
			caller.activate(); //this will show up archive main window
			super.finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_ARCHIVE):
					new MessageDialog(body, _osd, "Выберите файлы для архивации!");
					break;
					
				case(CMD_PLAY):
					new MessageDialog(body, _osd, "Выберите файлы!");
					break;
				
				case(CMD_EXIT):
					finalize();
					break;
			}
		}
	}
}