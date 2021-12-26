package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.geom.Point;
	
	public class WizardDialog extends Window
	{
		//patterns for navigation buttons, uses button id's to define which buttons are visible for user
		private static const PAT_INIT:Array		= [1,2];
		private static const PAT_NORMAL:Array	= [0,1,2];
		private static const PAT_SAVE:Array		= [0,3,2];
		private static const PAT_FINAL:Array	= [4];
		
		private static const PAGES:Array		= [0,1,4,5,6,7,10];
		
		private static const CMD_GROUP:int		= 0;
		private static const CMD_TAB:int		= 10;
		private static const CMD_NAV:int		= 50;
		
		private static const CMD_COPY:int			= 300;
		private static const CMD_TIMEINPUT:int		= 301;
		private static const CMD_TIMEPERIOD:int		= 302;
		private static const CMD_TIMEFORMAT:int		= 303;
		private static const CMD_SCHEDMODE:int		= 304;
		private static const CMD_SCHEDCHANNEL:int	= 306;
		private static const CMD_NETIP:int			= 307;
		private static const CMD_NETDNS:int			= 309;
		private static const CMD_DATEFORMAT:int		= 311;
		private static const CMD_TIMEZONE:int		= 312;
		
		private var spawnFinalMessage:Boolean = false;
		
		private var actPage = 0;
		private var actGroup:int = -1;
		private var groups:Array;
		private var groupTitle:TextLabel;
		private var gttl:Array = new Array(" ", "Запись", "Расписание", "Сеть", "Тест сети", "Основные", "Выполнено");
		
		private var bars:Array;
		private var tabs:Array;
		private var actTab:int = -1;
		
		private var masterLayer:MovieClip;
		private var navBtn:Array;
		private var navPat:Array;
		
		private var copyLBox:Array;
		
		private var recMainLBox:Array;
		private var recMainOnOffCBox:Array;
		private var recMainAudioCBox:Array;
		
		private var qualMainResLBox:Array;
		private var qualMainSpdLBox:Array;
		private var qualMainQltLBox:Array;
		
		private var netIPCBox:Array;
		private var netDNSCBox:Array;
		private var netTInput:Array;
		
		private var topCBox:CheckBox;
		private var tpLBox:ListBox;
		private var tfLBox:ListBox;
		private var tzLBox:ListBox;
		private var timeInput:TextInput;
		
		private var dateFormatLBox:ListBox;
		private var dateInput:TextInput;
		
		private var scheduler:Scheduler;
		private var scdPatterns:Array;
		private var scdModeCBox:Array;
		private var scdChannel:int;
		private var scdChLBox:ListBox;
		
		private var firstRun:Boolean = false;
		
		public function WizardDialog(ow:Object, o:Osd, ...args)
		{
			if (args && args.length)
			{
				firstRun = true;
				
				System.userName = "admin";
				spawnFinalMessage = args[0];
			}
			
			System.log("Запуск мастера настроек");
			if (firstRun) System.userName = null;
			if (firstRun) System.userName = null;
			
			System.manager.showOsd(false);
			
			super(ow, o, defX, defY, 789, 477, 2, 66, false, false, 68);
			
			copyLBox = new Array(); //to copy from one gadget to another
			
			recMainOnOffCBox = new Array();
			recMainAudioCBox = new Array();
			
			qualMainResLBox = new Array();
			qualMainSpdLBox = new Array();
			qualMainQltLBox = new Array();
			
			scdModeCBox = new Array();
			
			netIPCBox = new Array();
			netDNSCBox = new Array();
			
			bars = new Array();
			tabs = new Array();
			groups = new Array();
			for (var i:int = 0; i < 11; i++)
			{
				groups.push(new MovieClip());
				body.addChild(groups[i]);
				
				groups[i].visible = false;
			}
			
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			addMasterLayer();
			
			_osd.setHandler(groups[0]);
			//--------------------------------------------------------------------PAGE 0
			var img:Image = _osd.addImage(defX, defY, "welcome.png");
			img.setPos(new Point(defX - img.width/2 - 4, defY - img.height/2 - 12));
			
			_osd.setHandler(groups[1]);
			//--------------------------------------------------------------------PAGE 1
			var tab_0:TabBar = new TabBar(body, _osd, 767, 30, TabBar.TYPE_NORMAL, 0, 5);
			tab_0.addButton(95, "Основные", CMD_TAB);
			tab_0.addButton(150, "Качество", CMD_TAB+1);
			tab_0.setPos(new Point(defX - 381, defY - 132));
			bars.push(tab_0);
			groups[1].addChild(tab_0);
			
			groups[1].addChild(groups[2]);
			tabs.push(groups[2]);
			_osd.setHandler(groups[2]);
			//----------------------------------------------------------------------------------------------------------------------------------------------PAGE 1 TAB 0
			var data:Array = new Array("Канал", "Вкл", "Аудио", "Режим");
			var dlt:Array = new Array(120, 90, 135);
			
			gadX = defX - 227;
			gadY = defY - 116;
			for (i = 0; i < data.length; i++)
			{
				_osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT);
				gadX += dlt[i];
			}

			gadY = defY - 86;
			recMainLBox = new Array();
			for (i = 0; i < System.CHANNELS ; i++)
			{
				gadX = defX - 207;
				
				_osd.addLabel(gadX, gadY + 2, new String(i+1), Osd.COLOR_TEXT);					gadX += 114;
				recMainOnOffCBox.push(_osd.addCheckBox(gadX, gadY+13, Osd.CMD_INVALID));		gadX += 100;
				
				var cb:CheckBox = _osd.addCheckBox(gadX, gadY + 13, Osd.CMD_INVALID);			gadX += 56;
				cb.uncheck();
				recMainAudioCBox.push(cb);
				
				recMainLBox.push(_osd.addListBox(gadX, gadY, 170, new Array("Всегда", "Расписание"), 0, false));
				
				gadY += sepTInput-2;
			}
			
			addCopyBar(246, 50);
			
			groups[1].addChild(groups[3]);
			tabs.push(groups[3]);
			_osd.setHandler(groups[3]);
			//----------------------------------------------------------------------------------------------------------------------------------------------PAGE 1 TAB 1
			data = new Array("Канал", "Разрешение", "Скорость", "Качество");
			dlt = new Array(85, 120, 126);
			
			gadX = defX - 212;
			gadY = defY - 116;
			for (i = 0; i < data.length; i++)
			{
				_osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT);
				gadX += dlt[i];
			}
			
			var spd:Array = new Array();
			for (i = 0; i < 30; i++) spd.push(new String(i + 1));
			
			gadY = defY - 86;
			for (i = 0; i < System.CHANNELS; i++)
			{
				gadX = defX - 190;
				
				_osd.addLabel(gadX, gadY + 2, new String(i+1), Osd.COLOR_TEXT);								gadX += 65;
				
				var lbx:ListBox = _osd.addListBox(gadX, gadY, 96, new Array("C1F", "HD1", "D1"), 0, false); gadX += 109;
				lbx.selectItem(2);
				qualMainResLBox.push(lbx);
				
				lbx = _osd.addListBox(gadX, gadY, 96, spd, 8, false);										gadX += 112;
				lbx.selectItem(24);
				qualMainSpdLBox.push(lbx);
				
				lbx = _osd.addListBox(gadX, gadY, 124, new Array("Наилучшее", "Высокое", "Хорошее", "Нормальное"), 0, false);
				lbx.selectItem(2);
				qualMainQltLBox.push(lbx);
				
				gadY += sepTInput-2;
			}
			
			addCopyBar(246, 50);
			
			_osd.setHandler(groups[4]);
			//----------------------------------------------------------------------------------------------------------------------------------------------PAGE 2
			gadX = defX - 215;
			gadY = defY - 160;
			_osd.addLabel(gadX, gadY, "Канал", Osd.COLOR_TEXT);											gadX += 82;
			scdChLBox = _osd.addListBox(gadX, gadY, 92, getChannels(), 0, false, CMD_SCHEDCHANNEL);		gadX += 136;
			
			scdModeCBox.push(_osd.addCheckBox(gadX, gadY + 13, CMD_SCHEDMODE, "Тревога", true));		gadX += 130;
			cb = _osd.addCheckBox(gadX, gadY + 13, CMD_SCHEDMODE+1, "Норм.", true);
			cb.uncheck();
			scdModeCBox.push(cb);
			
			gadX = defX + 20;
			gadY = defY - 134;
			_osd.addImage(gadX, gadY, "ColoralarmRec.png"); gadX += 123;
			_osd.addImage(gadX, gadY, "ColornormalRec.png");
			
			addCopyBar(254, 128);
			
			scheduler = new Scheduler(groups[4], Scheduler.MODE_DUAL);
			scheduler.setPos(defX + 7, defY + 30);
			
			//generating default scheduler patterns
			scdPatterns = new Array();
			var pat:Array;
			for (i = 0; i < System.CHANNELS; i++)
			{
				pat = new Array();
				for (var j:int = 0; j < 7; j++) pat.push(scheduler.getOptimizedPattern(j));
				scdPatterns.push(pat);
			}
			
			_osd.setHandler(groups[5]);
			//----------------------------------------------------------------------------------------------------------------------------------------------PAGE 3
			gadX = defX - 296;
			gadY = defY - 164;
			var lsep:Number = 37; //'long' Y separator
			
			cb = _osd.addCheckBox(gadX, gadY + 13, CMD_NETIP, "Получить IP адрес автоматически", true);							gadY += lsep - 7;
			cb.uncheck();
			netIPCBox.push(cb);
			
			cb = _osd.addCheckBox(gadX, gadY + 13, CMD_NETIP + 1, "Статический IP адрес", true);								gadY += lsep + 5; gadX -= 10;
			netIPCBox.push(cb);
			
			_osd.addLabel(gadX, gadY, "IP адрес", Osd.COLOR_TEXT);																gadY += lsep;
			_osd.addLabel(gadX, gadY, "Маска", Osd.COLOR_TEXT);																	gadY += lsep;
			_osd.addLabel(gadX, gadY, "Шлюз", Osd.COLOR_TEXT);																	gadY += lsep; gadX += 10;
			
			cb = _osd.addCheckBox(gadX, gadY + 13, CMD_NETDNS, "Получить адрес DNS сервера автоматически", true);				gadY += lsep - 7;
			cb.uncheck();
			cb.disable();
			netDNSCBox.push(cb);
			
			netDNSCBox.push(_osd.addCheckBox(gadX, gadY + 13, CMD_NETDNS + 1, "Исп. следующие адреса DNS серверов", true));		gadY += lsep + 3; gadX -= 10;
			
			_osd.addLabel(gadX, gadY, "Первичный DNS сервер", Osd.COLOR_TEXT);													gadY += lsep;
			_osd.addLabel(gadX, gadY, "Альтернативный DNS сервер", Osd.COLOR_TEXT);												gadY += lsep + 7;
			
			System.textLine = System.TEXTLINE_LONG;
			
			netTInput = new Array();
			var netData:Array = new Array("192.168.002.234", "255.255.255.000", "192.168.002.001", "0", "0", "008.008.008.008", "202.096.134.133");
			
			gadX = defX + 10;
			gadY = defY - 95;
			for (i = 0; i < 7; i++)
			{
				if (i != 3 && i != 4) netTInput.push(_osd.addTextInput(gadX, gadY, 318, netData[i], Osd.CMD_INVALID, TextInput.FMT_IP));
				gadY += lsep;
				if (i == 4) gadY -= 7;
			}
			
			_osd.setHandler(groups[6]);
			//----------------------------------------------------------------------------------------------------------------------------------------------PAGE 4
			data = new Array("Статус сети", "IP адрес (лок.)", "Маска", "Шлюз", "Первичный DNS сервер", "Альтернативный DNS сервер", "Интернет IP адрес (внеш.)");
			
			gadX = defX - 242;
			gadY = defY - 130;
			for (i = 0; i < data.length; i++)
			{
				_osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT);
				gadY += 32;
			}
			
			gadX = defX + 75;
			gadY = defY - 130;
			for (i = 0; i < data.length-1; i++)
			{
				var str:String = "0.0.0.0";
				if (i == 0) str = "Ethernet разрыв";
				
				_osd.addLabel(gadX, gadY, str, Osd.COLOR_TEXT);
				gadY += 32;
			}
			
			_osd.setHandler(groups[7]);
			//--------------------------------------------------------------------PAGE 5
			var tab_1:TabBar = new TabBar(body, _osd, 767, 30, TabBar.TYPE_NORMAL, 0, 5);
			tab_1.addButton(97, "Система", CMD_TAB+2);
			tab_1.addButton(97, "Время", CMD_TAB+3);
			tab_1.setPos(new Point(defX - 381, defY - 132));
			bars.push(tab_1);
			groups[7].addChild(tab_1);
			
			groups[7].addChild(groups[8]);
			tabs.push(groups[8]);
			_osd.setHandler(groups[8]);
			//----------------------------------------------------------------------------------------------------------------------------------------------PAGE 5 TAB 0
			gadX = defX - 170;
			gadY = defY - 24;
			
			_osd.addLabel(gadX, gadY, "Формат видео", Osd.COLOR_TEXT);						gadX += 202;
			_osd.addListBox(gadX, gadY-7, 147, new Array("PAL", "NTSC"), 0, false);			gadX -= 202; gadY += lsep;
			_osd.addLabel(gadX, gadY+3, "Язык", Osd.COLOR_TEXT);							gadX += 202;
			_osd.addListBox(gadX, gadY, 147, new Array("Русский", "English"), 0, false);
			
			groups[7].addChild(groups[9]);
			tabs.push(groups[9]);
			_osd.setHandler(groups[9]);
			//----------------------------------------------------------------------------------------------------------------------------------------------PAGE 5 TAB 1
			gadX = defX - 280;
			gadY = defY - 86;
			
			var tw:int = 320;
			var ssep:int = 42;
			
			data = new Array("Дата/время", "Формат даты", "Формат времени", "Часовой пояс", "Синхронизация", "NTP сервер");
			for (i = 0; i < data.length; i++)
			{
				_osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT);
				if (i != data.length-1) gadY += ssep;
			}
			
			System.textLine = System.TEXTLINE_LONG; //'long' text lines ON
			
			gadX += 238;
			gadY -= 215;
			dateInput = _osd.addTextInput(gadX, gadY, 138, " ", Osd.CMD_INVALID, TextInput.FMT_DATE);												gadX += 146;
			timeInput = _osd.addTextInput(gadX, gadY, 94, " ", CMD_TIMEINPUT, TextInput.FMT_TIME);													gadX += 102;
			
			tpLBox = _osd.addListBox(gadX, gadY, 72, new Array("AM", "PM"), 0, false, CMD_TIMEPERIOD);												gadX = defX - 42; gadY += ssep;
			tpLBox.selectItem(timeInput.timePeriod);
			if (System.timeFormat == TextInput.TIME_24) tpLBox.visible = false;
			else tpLBox.visible = true;
			
			timeInput.setTimeLinkage(tpLBox);
			
			var tmp:int = System.timeZone;
			timeInput.updateTimeZone(0);
			timeInput.updateTimeZone(tmp);
			
			dateFormatLBox = _osd.addListBox(gadX, gadY, tw, new Array("MM/DD/YYYY", "YYYY-MM-DD", "DD/MM/YYYY"), 0, false, CMD_DATEFORMAT);		gadY += ssep;
			dateFormatLBox.selectItem(System.dateFormat);
			
			tfLBox =  _osd.addListBox(gadX, gadY, tw, new Array("24 часа", "12 часов"), 0, false, CMD_TIMEFORMAT);									gadY += ssep;
			tfLBox.selectItem(System.timeFormat);
			
			tzLBox = _osd.addListBox(gadX, gadY, tw, System.getTimeZones(), 6, false, CMD_TIMEZONE);												gadX += offsetCBox; gadY += sepCBox;
			tzLBox.selectItem(System.timeZone);
			_osd.addCheckBox(gadX, gadY+5, Osd.CMD_INVALID).uncheck();																				gadX -= offsetCBox; gadY += (sepCBox-lsep+4);
			
			data = new Array("time.windows.com", "time.nist.gov", "time-nw.nist.gov", "time-a.nist.gov", "time-b.nist.gov");
			_osd.addListBox(gadX, gadY+9, tw, data, 4, false);
			
			System.textLine = System.TEXTLINE_NORMAL; //'long' text lines OFF
			
			_osd.setHandler(groups[10]);
			//----------------------------------------------------------------------------------------------------------------------------------------------PAGE 6
			var lastImg:Image = _osd.addImage(0, 0, "login.png");
			lastImg.setPos(new Point(defX-lastImg.width/2, defY-lastImg.height/2));
			
			_osd.setHandler(this);
			
			showPage(0);
			
			System.manager.showThinGrid(true);
			spawnGrid();
		}
		
		public function addMasterLayer()
		{
			masterLayer = new MovieClip();
			wnd.addChild(masterLayer);
			_osd.setHandler(masterLayer);
			
			var bttl:Array = new Array("Пред.", "След.", "Отмена", "Сохр.", "Закрыть");
			var dlt:Array = new Array(87, 193, 290, 197, 288);
			navBtn = new Array();
			
			for (var i:int = 0; i < bttl.length; i++)
			{
				navBtn.push(_osd.addTextButton(defX + dlt[i], defY + 194, bttl[i], CMD_NAV+i, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT));
				navBtn[i].hide();
			}
			
			groupTitle = _osd.addLabel(defX - 370, defY - 221, gttl[0], Osd.COLOR_DEFAULT, TextLabel.TYPE_LARGE);

			topCBox = _osd.addCheckBox(defX - 357, defY + 201, Osd.CMD_INVALID, "Не показывать это окно в следующий раз");
			topCBox.uncheck();
		}
		
		public function addCopyBar(xdlt:int, ydlt:int)
		{
			System.textLine = System.TEXTLINE_LONG; //'long' text lines ON
			
			var xval:Array = new Array(xdlt, 129, 126, 47, 125);
			var yval:int = ydlt;
			
			gadX = defX-xval[0];
			gadY = defY + yval;
			_osd.addLabel(gadX, gadY+3, "Копировать", Osd.COLOR_TEXT);											gadX += xval[1];
			copyLBox.push(_osd.addListBox(gadX, gadY, 92, getChannels(), 0, false));							gadX += xval[2];
			_osd.addLabel(gadX, gadY+3, "в", Osd.COLOR_TEXT);													gadX += xval[3];
			copyLBox.push(_osd.addListBox(gadX, gadY, 92, new Array("Все", "1", "2", "3", "4"), 0, false));		gadX += xval[4];
			_osd.addTextButton(gadX, gadY+3, "Скопировать", CMD_COPY, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
			
			System.textLine = System.TEXTLINE_NORMAL; //'long' text lines OFF
		}
		
		public function getChannels():Array
		{
			var chlst:Array = new Array();
			
			for (var chidx:int = 0; chidx < System.CHANNELS; chidx++) chlst.push(new String(chidx+1));
			return chlst;
		}
		
		public function setNavPattern(pat:Array)
		{
			if (navPat != pat)
			{
				for (var i:int = 0; i < navBtn.length; i++) navBtn[i].hide();
				for (i = 0; i < navBtn.length; i++)
				{
					for (var j:int = 0; j < pat.length; j++)
					{
						if (i == pat[j]) navBtn[i].show();
					}
				}
				navPat = pat;
			}
		}
		
		//jump to predefined page group
		public function showPage(pg:int)
		{
			showGroup(PAGES[pg]);
			groupTitle.setText(gttl[pg]);
			
			var p:Array = PAT_NORMAL;
			switch(pg)
			{
				case 0:
					p = PAT_INIT;
					break;
					
				case 5:
					p = PAT_SAVE;
					break;
					
				case 6:
					p = PAT_FINAL;
					if(spawnFinalMessage) new MessageDialog(body, _osd, "Загрузка окончена. Пожалуйста, отключите \nМастер настройки в главном меню.");
					break;
			}
			
			setNavPattern(p);
		}
		
		//direct group set
		public function showGroup(id:int)
		{
			if (id != actGroup)
			{
				if(actGroup >= 0) groups[actGroup].visible = false;
				groups[id].visible = true;
				actGroup = id;
				
				switch(id)
				{
					case(PAGES[1]):
						bars[0].setSelection(0);
						showTab(0);
						break;
						
					case(PAGES[5]):
						bars[1].setSelection(0);
						showTab(2);
						break;
					
					case(PAGES[PAGES.length-1]):
						topCBox.visible = false;
						break;
				}
			}
		}
		
		public function showTab(id:int)
		{
			if (id != actTab)
			{
				if (actTab >= 0) tabs[actTab].visible = false;
				tabs[id].visible = true;
				actTab = id;
			}
		}
		
		public override function finalize()
		{
			System.manager.showThinGrid(false);
			scheduler.finalize();
			
			if (firstRun && caller) caller.firstRun();
			
			super.finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			if (cmd >= CMD_NAV && cmd <= CMD_NAV + navBtn.length)
			{
				var id:int = cmd - CMD_NAV;
				switch(id)
				{
					case(0):
						if (actPage > 0)
						{
							if (actPage != 5) actPage--;
							else actPage -= 2;
							
							showPage(actPage);
						}
						break;
					
					case(1):
						if (actPage < PAGES.length)
						{
							actPage++;
							showPage(actPage);
						}
						break;
						
					case(2): //close window and discard changes
						osdCommand(CMD_NAV+4);
						break;
						
					case(3):
						osdCommand(CMD_NAV+1);
						break;
						
					case(4): //close window
						caller.activate();
						finalize();
						System.manager.showOsd(true);
						break;
				}
			}
			
			if (cmd >= CMD_TAB && cmd <= CMD_TAB + tabs.length)
			{
				var t:int = cmd - CMD_TAB;
				showTab(t);
			}
			
			if(cmd>=CMD_SCHEDMODE && cmd<CMD_SCHEDMODE+2)
			{
				t = cmd-CMD_SCHEDMODE;
				if (t == 0) scdModeCBox[1].uncheck(); //alarm
				else scdModeCBox[0].uncheck(); //normal mode
				
				scheduler.swapDrawMode();
			}
			
			if (cmd >= CMD_NETIP && cmd < CMD_NETIP+2)
			{
				t = cmd - CMD_NETIP;
				if (t == 0)
				{
					netIPCBox[1].uncheck();
					for (var k:int = 0; k < 3; k++) netTInput[k].disable();
					
					netDNSCBox[0].enable();
					netDNSCBox[0].uncheck();
				}
				else
				{
					netIPCBox[0].uncheck();
					for (k = 0; k < 3; k++) netTInput[k].enable();
					
					netDNSCBox[0].disable();
					netDNSCBox[0].uncheck();
					netDNSCBox[1].check();
					
					for (k = 3; k < 5; k++) netTInput[k].enable();
				}
			}
			
			if (cmd >= CMD_NETDNS && cmd < CMD_NETDNS + 2)
			{
				t = cmd - CMD_NETDNS;
				if (t == 0)
				{
					netDNSCBox[1].uncheck();
					for (k = 3; k < 5; k++) netTInput[k].disable();
				}
				else
				{
					netDNSCBox[0].uncheck();
					for (k = 3; k < 5; k++) netTInput[k].enable();
				}
			}
			
			switch(cmd)
			{
				case(CMD_DATEFORMAT):
					var df:int = dateFormatLBox.getValue();
					dateInput.setDateFormat(df, true);
					break;
				
				case(CMD_TIMEFORMAT):
					var tf:int = tfLBox.getValue();
					if (tf == TextInput.TIME_12) tpLBox.visible = true;
					else tpLBox.visible = false;
					
					timeInput.setTimeFormat(tf);
					break;
					
				case(CMD_TIMEPERIOD):
					timeInput.setTimePeriod(tpLBox.getValue());
					break;
					
				case(CMD_TIMEINPUT):
					osdCommand(CMD_TIMEPERIOD);
					break;
					
				case(CMD_TIMEZONE):
					timeInput.updateTimeZone(tzLBox.getValue());
					break;
					
				case(CMD_COPY):
					var from:int = 0;
					var to:int = 0;
					var toall:Boolean = false;
					
					switch(actGroup)
					{
						case(1):
							if (actTab == 0)
							{
								from = copyLBox[0].getValue();
								if (copyLBox[1].getValue()) to = copyLBox[1].getValue() - 1;
								else
								{
									to = 0;
									toall = true;
								}
								
								for (var i:int = 0; i < recMainLBox.length; i++)
								{
									if (toall) to = i;
									
									recMainLBox[to].copyFrom(recMainLBox[from]);
									recMainOnOffCBox[to].copyFrom(recMainOnOffCBox[from]);
									recMainAudioCBox[to].copyFrom(recMainAudioCBox[from]);
									
									if (!toall) i = recMainLBox.length;
								}
							}
							else
							{
								from = copyLBox[2].getValue();
								if (copyLBox[3].getValue()) to = copyLBox[3].getValue() - 1;
								else
								{
									to = 0;
									toall = true;
								}
								
								for (i = 0; i < qualMainResLBox.length; i++)
								{
									if (toall) to = i;
									
									qualMainResLBox[to].copyFrom(qualMainResLBox[from]);
									qualMainSpdLBox[to].copyFrom(qualMainSpdLBox[from]);
									qualMainQltLBox[to].copyFrom(qualMainQltLBox[from]);
									
									if (!toall) i = qualMainResLBox.length;
								}
							}
							break;
							
						case(4):
								from = copyLBox[4].getValue();
								if (copyLBox[5].getValue()) to = copyLBox[5].getValue() - 1;
								else
								{
									to = 0;
									toall = true;
								}
								
								if (scdChannel == from) //current channel is not updated yet, so we take its pattern right here
								{
									var tp:Array = new Array();
									for (var j:int = 0; j < 7; j++) tp.push(scheduler.getOptimizedPattern(j));
								}
								
								for (i = 0; i < scdPatterns.length; i++)
								{
									if (toall) to = i;
									
									if (scdChannel == from) scdPatterns[to] = tp;
									else scdPatterns[to] = scdPatterns[from];

									if (!toall) i = scdPatterns.length;
								}
								
								if (scdChannel == to || toall)
								{
									for (i = 0; i < 7; i++) scheduler.readPattern(scdPatterns[scdChannel][i], i); //updating scheduler matrix
								}
							break;
					}
					break;
					
				case(CMD_SCHEDCHANNEL):
					var pat:Array = new Array();
					for (i = 0; i < 7; i++) pat.push(scheduler.getOptimizedPattern(i)); //reading current scheduler pattern
					
					scdPatterns[scdChannel] = pat;
					scdChannel = scdChLBox.getValue();
					for (i = 0; i < 7; i++) scheduler.readPattern(scdPatterns[scdChannel][i], i); //applying changes to scheduler
					break;
			}
		}
	}
}