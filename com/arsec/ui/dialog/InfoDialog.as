package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.geom.Point;
	
	public class InfoDialog extends Window
	{
		private static const CMD_EXIT:int	= 0;
		private static const CMD_TAB:int	= 10;
		
		private var navButt:MovieClip;
		private var tabs:Array; //each tab is a local array of objects inside the global group
		private var actTab:int;
	
		public function InfoDialog(ow:Object, o:Osd)
		{
			System.manager.showOsd(false);
			
			super(ow, o, defX, defY, 664, 560, 2, 80, true, true);
			
			tabs = new Array();
			var ttl:Array = new Array("Устройство", "LAN", "3G", "Подключение", "Запись", "HDD");
			
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			addNavButtons();
			
			var tab:TabBar = new TabBar(body, _osd, 500, 0, TabBar.TYPE_TEXT, 0, 61);
			for (var i:int = 0; i < ttl.length; i++)
			{
				tab.addButton(50, ttl[i], CMD_TAB + i);
				tabs.push(new MovieClip());
				body.addChild(tabs[i]);
				
				if (i != 0) tabs[i].visible = false;
			}
			tab.setPos(new Point(defX - 305, defY - 214));
			actTab = 0;
			
			_osd.setHandler(tabs[0]);
			//----------------------------------------------------------------------------------------------------------------------------------------------TAB 0
			var data:Array = new Array("Имя DVR", "DVR", "ID устройства", "0", "Серийный номер", "Версия прошивки", "MAC", "Версия MCU", "Версия оборудования");
			gadX = defX - 220;
			gadY = defY - 160;
			for (i = 0; i < data.length; i++)
			{
				_osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT);
				if (i == 0 || i == 2) gadX += 227;
				else
				{
					if (i == 1 || i == 3) gadX -= 227;
					gadY += sepLbl + 1;
				}
			}
			
			_osd.setHandler(tabs[1]);
			//----------------------------------------------------------------------------------------------------------------------------------------------TAB 1
			data = new Array("Статус сети", "IP адрес (LAN)", "Маска", "Шлюз", "Первичный DNS сервер", "Альтернативный DNS сервер", "Конфликт IP адреса", "Нет конфликта IP", "IP адрес (WWAN)", "Медиа порт", "Web порт");
			gadX = defX - 231;
			gadY = defY - 160;
			for (i = 0; i < data.length; i++)
			{
				_osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT);
				if (i == 6) gadX += 271;
				else
				{
					if (i == 7) gadX -= 271;
					gadY += sepLbl;
				}
			}
			
			_osd.setHandler(tabs[2]);
			//----------------------------------------------------------------------------------------------------------------------------------------------TAB 2
			data = new Array("Состояние 3G", "Выкл", "Статус модема", "Статус SIM карты", "Статус сети", "Сигнал", "IP адрес");
			gadX = defX - 172;
			gadY = defY - 160;
			for (i = 0; i < data.length; i++)
			{
				_osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT);
				if (i == 0) gadX += 200;
				else
				{
					if (i == 1) gadX -= 200;
					gadY += sepLbl;
				}
			}
			
			_osd.setHandler(tabs[3]);
			//----------------------------------------------------------------------------------------------------------------------------------------------TAB 3
			gadX = defX - 264;
			gadY = defY - 160;
			_osd.addLabel(gadX, gadY, "Имя", Osd.COLOR_TEXT);			gadX += 118;
			_osd.addLabel(gadX, gadY, "IP адрес", Osd.COLOR_TEXT);		gadX += 154;
			_osd.addLabel(gadX, gadY, "Время входа", Osd.COLOR_TEXT);	gadX += 181;
			_osd.addLabel(gadX, gadY, "Отключен", Osd.COLOR_TEXT);
			
			_osd.setHandler(tabs[4]);
			//----------------------------------------------------------------------------------------------------------------------------------------------TAB 4
			gadX = defX - 264;
			gadY = defY - 160;
			_osd.addLabel(gadX, gadY, "Канал", Osd.COLOR_TEXT);			gadX += 65;
			_osd.addLabel(gadX, gadY, "Разрешение", Osd.COLOR_TEXT);	gadX += 121;
			_osd.addLabel(gadX, gadY, "Скорость", Osd.COLOR_TEXT);		gadX += 112;
			_osd.addLabel(gadX, gadY, "Качество", Osd.COLOR_TEXT);		gadX += 128;
			_osd.addLabel(gadX, gadY, "Объем/час", Osd.COLOR_TEXT);
			
			gadX = defX - 246;
			for (i = 0; i < System.CHANNELS; i++)
			{
				gadY += sepLbl;
				_osd.addLabel(gadX, gadY, new String(i+1), Osd.COLOR_TEXT);
			}
			
			_osd.setHandler(tabs[5]);
			//----------------------------------------------------------------------------------------------------------------------------------------------TAB 5
			gadX = defX - 137;
			gadY = defY - 160;
			_osd.addLabel(gadX, gadY, "ID", Osd.COLOR_TEXT);				gadX += 77;
			_osd.addLabel(gadX, gadY, "Емкость", Osd.COLOR_TEXT);			gadX += 74;
			_osd.addLabel(gadX, gadY, "Всего/Свободно", Osd.COLOR_TEXT);
			
			_osd.setHandler(this);
		}
		
		public function addNavButtons() //navigate buttons - always visible elements
		{
			navButt = new MovieClip();
			body.addChild(navButt);
			_osd.setHandler(navButt);
			
			gadX = defX+233;
			gadY = defY+220;
			_osd.addTextButton(gadX, gadY, "Выход", CMD_EXIT, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);
		}
		
		public override function finalize()
		{
			System.manager.showOsd(true);
			super.finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_EXIT):
					caller.activate();
					finalize();
					break;
			}
			
			if (cmd >= CMD_TAB && cmd <= CMD_TAB + tabs.length-1)
			{
				var t:int = cmd - CMD_TAB;
				tabs[actTab].visible = false;
				tabs[t].visible = true;
				actTab = t;
			}
		}
	}
}