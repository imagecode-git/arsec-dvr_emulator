package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class DefaultsDialog extends Window
	{
		private static const CMD_BTN:int = 0;
		
		private var cbx:Array;
		
		public function DefaultsDialog(ow:Object, o:Osd)
		{
			super(ow, o, defX, defY, 638, 476, 2, 55, true, false);
			
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			_osd.setHandler(body);
			
			var data:Array = new Array("Система", "Дисплей", "Обслуживание", "Тревога", "COMM", "Управление HDD", "Дата/время", "Запись", "Пользователи", "Сеть", "PTZ");
			var sep:int = 42;
			
			gadX = defX-169;
			gadY = defY-148;
			
			cbx = new Array();
			for (var i:int = 0; i < 11; i++)
			{
				cbx.push(_osd.addCheckBox(gadX, gadY, Osd.CMD_INVALID, data[i]));
				cbx[i].check();
				
				if (i != 5) gadY += sep;
				else
				{
					gadX = defX+98;
					gadY = defY-148;
				}
			}
			
			var dlt:Array = new Array(126, 75, 116, 0);
			data = new Array("Выбрать все", "Сброс", "Применить", "Выход");
			
			gadX = defX-119;
			gadY = defY+183;
			
			for (i = 0; i < data.length; i++)
			{
				_osd.addTextButton(gadX, gadY, data[i], CMD_BTN+i, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);		gadX += dlt[i];
			}
			
			_osd.setHandler(this);
			
			spawnGrid();
		}
		
		public override function finalize()
		{
			caller.osdCommand(Osd.CMD_GAD_UPDATE);
			super.finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			if (cmd >= CMD_BTN && cmd < CMD_BTN + cbx.length)
			{
				var c:int = cmd-CMD_BTN;
				switch(c)
				{
					case 0:
						for (var i:int = 0; i < cbx.length; i++) cbx[i].check();
						break;
						
					case 1:
						for (i = 0; i < cbx.length; i++) cbx[i].uncheck();
						break;
						
					case 2:
						new MessageDialog(body, _osd, "Изменения сохранены.");
						break;
						
					case 3:
						caller.osdCommand(Osd.CMD_GAD_UPDATE);
						finalize();
						break;
				}
			}
		}
	}
}