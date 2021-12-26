package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class ArchiveTimeDialog extends Window
	{
		private static const CMD_SEARCH:int		= 0;
		private static const CMD_ARCHIVE:int	= 1;
		private static const CMD_EXIT:int		= 2;
		
		private var playback:Playback;
		
		public function ArchiveTimeDialog(ow:Object, o:Osd)
		{
			System.exclusiveRightClick = this;
			
			super(ow, o, defX, defY, 490, 396, 2, 55, true, true);
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			_osd.setHandler(body);

			var data:Array = new Array("Начало", "Окончание", "Канал", "Общее время", "Общий размер", "USB Storage", "Полный размер", "Свободное место");
			var sep:int = 35;
			gadX = defX - 215;
			gadY = defY - 165;
			for (var i:int = 0; i < data.length; i++)
			{
				_osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT); gadY += sep;
			}
			
			gadX = defX + 128;
			gadY = defY - 165;
			for (i = 0; i < 2; i++)
			{
				_osd.addTextButton(gadX, gadY, "Поиск", CMD_SEARCH, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT); gadY += sep;
			}
			 gadY += sep;
			 _osd.addLabel(gadX, gadY, "Час:мин:сек", Osd.COLOR_TEXT);	gadY += sep;
			 _osd.addLabel(gadX, gadY, "Mb", Osd.COLOR_TEXT);			gadY += sep;
			 gadY += sep;
			for (i = 0; i < 2; i++)
			{
				_osd.addLabel(gadX, gadY, "Mb", Osd.COLOR_TEXT); gadY += sep;
			}
			
			gadX = defX - 76;
			gadY = defY - 168;
			_osd.addTextInput(gadX, gadY, 107, " ", Osd.CMD_INVALID, TextInput.FMT_DATE).disable();			gadX += 115;
			_osd.addTextInput(gadX, gadY, 78, "00:00:00", Osd.CMD_INVALID, TextInput.FMT_TIME).disable();	gadY += sep; gadX -= 115;
			_osd.addTextInput(gadX, gadY, 107, " ", Osd.CMD_INVALID, TextInput.FMT_DATE).disable();			gadX += 115;
			_osd.addTextInput(gadX, gadY, 78, "23:59:59", Osd.CMD_INVALID, TextInput.FMT_TIME).disable();	gadY += sep; gadX -= 115;
			
			for (i = 0; i < 4; i++)
			{
				_osd.addCheckBox(gadX+8, gadY+13, Osd.CMD_INVALID, new String(i+1)); gadX += 45;
			}
			gadX -= 4*45;
			gadY += sep;
			
			_osd.addTextInput(gadX, gadY, 193, "00:00:00", Osd.CMD_INVALID, TextInput.FMT_TIME).disable();	gadY += sep;
			_osd.addTextInput(gadX, gadY, 193, "0", Osd.CMD_INVALID, TextInput.FMT_DIGITAL).disable();		gadY += sep;
			_osd.addTextInput(gadX, gadY, 193, "Неизвестный", Osd.CMD_INVALID).disable();					gadY += sep;
			_osd.addTextInput(gadX, gadY, 193, "0", Osd.CMD_INVALID, TextInput.FMT_DIGITAL).disable();		gadY += sep;
			_osd.addTextInput(gadX, gadY, 193, "0", Osd.CMD_INVALID, TextInput.FMT_DIGITAL).disable();		gadY += sep;
			
			gadX = defX - 78;
			gadY = defY + 145;
			_osd.addTextButton(gadX, gadY, "Архив", CMD_ARCHIVE, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT); gadX += 98;
			_osd.addTextButton(gadX, gadY, "Выход", CMD_EXIT, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);
			
			if (System.guideEnabled)
			{
				var pop:Popup = new Popup(System.top, System.osd, System.guide, UserGuide.ID_ARCHIVE_TIME, 644, 85, 400, 100, "Удобно реализован поиск по времени. Нажав на 'Поиск' вы можете легко установить, пользуясь наглядной шкалой времени, начало и окончание интересующего вас отрезка записанного видео.");
				System.guide.extend([pop]);
			}
			
			_osd.setHandler(this);
		}
		
		public override function finalize()
		{
			System.exclusiveRightClick = null;
			caller.activate(); //this will show up archive main window
			super.finalize();
		}
		
		public override function activate(...args):void
		{
			if (!body.visible) body.visible = true;
			super.activate();
		}
		
		public override function deactivate(...args):void
		{
			if (body.visible) body.visible = false;
			super.deactivate();
		}
		
		public override function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_SEARCH):
					deactivate();
					playback = new Playback(System.top, System.osd);
					playback.setCaller(this);
					playback.y += 20;
					break;
					
				case(CMD_ARCHIVE):
					new MessageDialog(body, _osd, "Не найдено внешнее устройство!");
					break;

				case(CMD_EXIT):
					finalize();
					break;
			}
		}
	}
}