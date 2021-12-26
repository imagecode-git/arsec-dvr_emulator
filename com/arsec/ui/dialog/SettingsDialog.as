package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.system.fscommand;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.display.BlendMode;
	
	public class SettingsDialog extends Window
	{
		private static const CMD_GROUP:int			= 0;
		private static const CMD_TAB:int			= 10;
		
		private static const CMD_WIZARD:int			= 600;
		private static const CMD_EXIT:int			= 601;
		private static const CMD_APPLY:int			= 602;
		private static const CMD_DISPLAY_SET:int	= 603;
		private static const CMD_COPY:int			= 604;
		private static const CMD_TIMEFORMAT:int		= 605;
		private static const CMD_TIMEPERIOD:int		= 606;
		private static const CMD_TIMEINPUT:int		= 607;
		private static const CMD_TIMEZONE:int		= 608;
		private static const CMD_DATEFORMAT:int		= 609;
		private static const CMD_CHANNELNAME:int	= 610;
		private static const CMD_SCHEDCHANNEL:int	= 611;
		private static const CMD_SCHEDMODE:int		= 612;
		private static const CMD_ENABLE3G:int		= 617;
		private static const CMD_ENABLEDDNS:int		= 618;
		private static const CMD_ENABLEEMAIL:int	= 619;
		private static const CMD_TESTEMAIL:int		= 620;
		private static const CMD_HDDOVERWRITE:int	= 621;
		private static const CMD_HDDFORMAT:int		= 622;
		private static const CMD_AUTOREBOOT:int		= 623;
		private static const CMD_USERADD:int		= 624;
		private static const CMD_USERDEL:int		= 625;
		private static const CMD_STGEXPORT:int		= 626;
		private static const CMD_STGIMPORT:int		= 627;
		private static const CMD_STGDEFAULTS:int	= 628;
		private static const CMD_FIRMWAREUPD:int	= 629;
		private static const CMD_FINDFIRMWARE:int	= 630;
		private static const CMD_ASKTURNOFF:int		= 631;
		private static const CMD_TURNOFFDVR:int		= 632;
		private static const CMD_ASKREBOOT:int		= 633;
		private static const CMD_REBOOTDVR:int		= 634;
		
		private static const CMD_MASK:int			= 650;
		private static const CMD_COLOR:int			= 660;
		private static const CMD_OSDSETUP:int		= 670;
		private static const CMD_SENSORSETUP:int	= 680;
		
		private static const CMD_MOVEAREA:int		= 690;
		private static const CMD_MOVEALSCHD:int		= 700;
		private static const CMD_MOVEALPLAN:int		= 710;
		
		private static const CMD_SENSALSCHD:int		= 720;
		private static const CMD_SENSALPLAN:int		= 730;
		
		private static const CMD_CCLOSESCHD:int		= 740;
		private static const CMD_CCLOSEPLAN:int		= 750;
		
		private static const CMD_MISCALPLAN:int		= 760;
		private static const CMD_VLOSTALPLAN:int	= 770;
		
		private static const CMD_USEREDIT:int		= 780;
		private static const CMD_CONFUSERDEL:int	= 800;
		
		private static const CMD_NETIP:int			= 910;
		private static const CMD_NETDNS:int			= 920;
		
		private var defaultsDialog:DefaultsDialog;
		
		private var bnor:Array;
		private var bact:Array;
		private var bpre:Array;
		private var butt:Array;
		private var bttl:Array;
		
		private var title:TextLabel;
		private var frame:TabBar;
		
		private var groups:Array; //each group represents one of 7 settings sections
		private var tabs:Array; //each tab is a local array of objects inside the group
		private var tabPatterns:Array; //describes how much tabs there are in each group
		private var bars:Array; //tab bars
		
		private var guide:UserGuide;
		private var guideLayer:MovieClip; //where user guide placed in
		
		private var actGroup:int;
		private var actTab:int;

		private var navButt:MovieClip;
		
		private var copyLBox:Array;
		
		private var timeInput:TextInput;
		private var tfLBox:ListBox;
		private var tpLBox:ListBox;
		private var tzLBox:ListBox;
		
		private var dateFormatLBox:ListBox;
		private var dateInput:TextInput;
		
		private var chNameinput:Array;
		
		private var recMainLBox:Array;
		private var recMainOnOffCBox:Array;
		private var recMainAudioCBox:Array;
		
		private var recQualMainResLBox:Array;
		private var recQualMainSpdLBox:Array;
		private var recQualMainQltLBox:Array;
		
		private var scheduler:Scheduler;
		private var scdPatterns:Array;
		private var scdModeCBox:Array;
		private var scdChannel:int;
		private var scdChLBox:ListBox;
		
		private var alarmMoveOnOffCBox:Array;
		private var alarmMoveSensLBox:Array;
		
		private var alarmSensOnOffCBox:Array;
		private var alarmSensTypeLBox:Array;
		private var alarmSensNameTInput:Array;
		
		private var vidLostOnOffCBox:Array;
		
		private var camCloseOnOffCBox:Array;
		private var camSensOnOffLBox:Array;
		
		private var netIPCBox:Array;
		private var netDNSCBox:Array;
		private var netTInput:Array;
		
		private var net3GOnOffLBox:ListBox;
		private var net3GTInput:Array;
		
		private var netStrOnOffCBox:Array;
		private var netStrResLBox:Array;
		private var netStrSpdLBox:Array;
		private var netStrQltLBox:Array;
		
		private var netDDNSOnOffLBox:ListBox;
		private var netDDNSSrvLBox:ListBox;
		private var netDDNSDefsCBox:CheckBox;
		
		private var netEmailOnOffLBox:ListBox;
		private var netEmailSetLBox:Array;
		private var netEmailTInput:Array;
		private var netEmailTestTBtn:TextButton;
		
		private var ptzOnOffCBox:Array;
		private var ptzProtoLBox:Array;
		private var ptzSpdLBox:Array;
		private var ptzAddrTInput:Array;
		
		private var hddOvwrLBox:ListBox;
		private var hddDayLbl:TextLabel;
		private var hddDayTInput:TextInput;
		
		private var mtnRbtLBox:ListBox;
		private var mtnRbtMonthLBox:ListBox;
		private var mtnRbtDayLBox:ListBox;
		private var mtnRbtTInput:TextInput;
		
		private var usersTLine:Array;
		private var usersCBox:Array;
	
		public function SettingsDialog(ow:Object, o:Osd)
		{
			System.manager.showOsd(false);
			
			super(ow, o, defX, defY, 684, 620, 5, 125, true, false);
			
			copyLBox = new Array();//to copy from one gadget to another
			
			chNameinput = new Array();
			
			recMainOnOffCBox = new Array();
			recMainAudioCBox = new Array();
			
			recQualMainResLBox = new Array();
			recQualMainSpdLBox = new Array();
			recQualMainQltLBox = new Array();
			
			scdModeCBox = new Array();
			
			alarmMoveOnOffCBox = new Array();
			alarmMoveSensLBox = new Array();
			
			alarmSensOnOffCBox = new Array();
			alarmSensTypeLBox = new Array();
			alarmSensNameTInput = new Array();
			
			vidLostOnOffCBox = new Array();
			
			camCloseOnOffCBox = new Array();
			camSensOnOffLBox = new Array();
			
			netIPCBox = new Array();
			netDNSCBox = new Array();
			netTInput = new Array();
			
			net3GTInput = new Array();
			
			netStrOnOffCBox = new Array();
			netStrResLBox = new Array();
			netStrSpdLBox = new Array();
			netStrQltLBox = new Array();
			
			netEmailSetLBox = new Array();
			netEmailTInput = new Array();
			
			ptzOnOffCBox = new Array();
			ptzProtoLBox = new Array();
			ptzSpdLBox = new Array();
			ptzAddrTInput = new Array();
			
			usersTLine = new Array();
			usersCBox = new Array();
			
			bttl = new Array("Основные", "Запись", "Тревога", "Сеть", "PTZ", "Управление HDD", "Обслуживание");
			bnor = new Array("BasicNormal.png", "RecordNormal.png", "AdvanceNormal.png", "NetWorkNormal.png", "PTZNormal.png", "HddNormal.png", "MaintenanceNormal.png");
			bact = new Array("BasicActive.png", "RecordActive.png", "AdvanceActive.png", "NetWorkActive.png", "PTZActive.png", "HddActive.png", "MaintenanceActive.png");
			bpre = new Array("BasicPreLight.png", "RecordPreLight.png", "AdvancePreLight.png", "NetWorkPreLight.png", "PTZPreLight.png", "HddPreLight.png", "MaintenancePreLight.png");

			butt = new Array();
			groups = new Array();
			tabs = new Array();
			bars = new Array();
			tabPatterns = new Array(4, 3, 5, 5, 1, 2, 2);
			
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			frame = new TabBar(body, _osd, 647, 75, TabBar.TYPE_FRAME, 22, 18, 16);
			for (var k:int = 0; k < bttl.length; k++)
			{
				frame.addButton(72, " ", Osd.CMD_INVALID); //automatically building 7 tabs for this frame
				groups.push(new MovieClip());
				body.addChild(groups[k]);
				
				if (k != 0) groups[k].visible = false;
			}
			frame.setPos(new Point(defX - 326, defY - 195));
			
			for (var l:int = 0; l < groups.length; l++)
			{
				for (var m:int = 0; m < tabPatterns[l]; m++) //at this place tab local groups are not only generated, but also placed inside the hierarchy of each group
				{
					tabs.push(new MovieClip());
					tabs[tabs.length - 1].visible = false;
					groups[l].addChild(tabs[tabs.length - 1]);
				}
			}
			
			addNavButtons();
			
			//--------------------------------------------------------------------GROUP 0
			var tab_0:TabBar = new TabBar(body, _osd, 500, 0, TabBar.TYPE_TEXT, 0, 93);
			tab_0.addButton(50, "Общие", CMD_TAB);
			tab_0.addButton(50, "Дата/Время", CMD_TAB+1);
			tab_0.addButton(50, "Дисплей", CMD_TAB+2);
			tab_0.addButton(50, "Пользователи", CMD_TAB+3);
			tab_0.setPos(new Point(defX - 257, defY - 160));
			bars.push(tab_0);
			groups[0].addChildAt(tab_0,0);
			
			_osd.setHandler(tabs[0]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 0 TAB 0
			gadX = defX - 263;
			gadY = defY - 90;
			var lsep:Number = 37; //'long' Y separator
			
			_osd.addLabel(gadX, gadY, "Имя DVR", Osd.COLOR_TEXT);			gadY += lsep;
			_osd.addLabel(gadX, gadY, "ID устройства", Osd.COLOR_TEXT);		gadY += lsep;
			_osd.addLabel(gadX, gadY, "Формат видео", Osd.COLOR_TEXT);		gadY += lsep;
			_osd.addLabel(gadX, gadY, "Разрешение VGA", Osd.COLOR_TEXT);	gadY += lsep;
			_osd.addLabel(gadX, gadY, "Язык", Osd.COLOR_TEXT);				gadY += lsep;
			_osd.addLabel(gadX, gadY, "Выход из системы", Osd.COLOR_TEXT);	gadY += lsep;
			_osd.addLabel(gadX, gadY, "Мастер настроек", Osd.COLOR_TEXT);
			
			gadX += 210;
			gadY -= 228;
			var tw:Number = 320;
			var data:Array;
			System.textLine = System.TEXTLINE_LONG; //'long' text lines ON
			
			_osd.addTextInput(gadX, gadY, tw, "DVR", Osd.CMD_INVALID);											gadY += lsep;
			_osd.addTextInput(gadX, gadY, tw, "0", Osd.CMD_INVALID, TextInput.FMT_DIGITAL, 127, 3);				gadY += lsep;
			_osd.addListBox(gadX, gadY, tw, new Array("PAL", "NTSC"), 0, false);								gadY += lsep;
			
			data = new Array("1024 x 768", "1280 x 1024", "1366 x 768", "1440 x 900");
			_osd.addListBox(gadX, gadY, tw, data, 0, false).selectItem(1);										gadY += lsep;
			_osd.addListBox(gadX, gadY, tw, new Array("English", "Русский"), 0, false).selectItem(1);			gadY += lsep;
			
			data = new Array("Через 30с", "Через 1мин", "Через 3мин", "Через 5мин", "Через 10мин", "Никогда");
			_osd.addListBox(gadX, gadY, tw, data, 4, false);													gadY += lsep;
			_osd.addListBox(gadX, gadY, tw, new Array("Выкл", "Вкл"), 0, false).selectItem(1);					gadY += sepLbl*1.6;
			
			var tb0:TextButton = _osd.addTextButton(gadX, gadY, "Запустить мастер настроек", CMD_WIZARD, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
			
			_osd.setHandler(tabs[1]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 0 TAB 1
			gadX = defX - 253;
			gadY = defY - 90;
			_osd.addLabel(gadX, gadY, "Дата/Время", Osd.COLOR_TEXT);		gadY += lsep;
			_osd.addLabel(gadX, gadY, "Формат даты", Osd.COLOR_TEXT);		gadY += lsep;
			_osd.addLabel(gadX, gadY, "Формат времени", Osd.COLOR_TEXT);	gadY += lsep;
			_osd.addLabel(gadX, gadY, "Часовой пояс", Osd.COLOR_TEXT);		gadY += lsep;
			_osd.addLabel(gadX, gadY, "Синхронизация", Osd.COLOR_TEXT);		gadY += lsep;
			_osd.addLabel(gadX, gadY, "NTP сервер", Osd.COLOR_TEXT);
			
			gadX += 190;
			gadY -= 191;
			dateInput = _osd.addTextInput(gadX, gadY, 138, " ", Osd.CMD_INVALID, TextInput.FMT_DATE);												gadX += 146;
			timeInput = _osd.addTextInput(gadX, gadY, 94, " ", CMD_TIMEINPUT, TextInput.FMT_TIME);													gadX += 102;
			
			tpLBox = _osd.addListBox(gadX, gadY, 72, new Array("AM", "PM"), 0, false, CMD_TIMEPERIOD);												gadX = defX - 63; gadY += lsep;
			tpLBox.selectItem(System.timePeriod);
			if (System.timeFormat == TextInput.TIME_24) tpLBox.visible = false;
			else tpLBox.visible = true;
			
			timeInput.setTimeLinkage(tpLBox);
			
			var tmp:int = System.timeZone;
			timeInput.updateTimeZone(0);
			timeInput.updateTimeZone(tmp);
			
			dateFormatLBox = _osd.addListBox(gadX, gadY, tw, new Array("MM/DD/YYYY", "YYYY-MM-DD", "DD/MM/YYYY"), 0, false, CMD_DATEFORMAT);		gadY += lsep;
			dateFormatLBox.selectItem(System.dateFormat);
			
			tfLBox = _osd.addListBox(gadX, gadY, tw, new Array("24 часа", "12 часов"), 0, false, CMD_TIMEFORMAT);									gadY += lsep;
			tfLBox.selectItem(System.timeFormat);
			
			tzLBox = _osd.addListBox(gadX, gadY, tw, System.getTimeZones(), 6, false, CMD_TIMEZONE);												gadX += offsetCBox; gadY += sepCBox;
			tzLBox.selectItem(System.timeZone);
			
			_osd.addCheckBox(gadX, gadY, Osd.CMD_INVALID).uncheck();																				gadX -= offsetCBox; gadY += (sepCBox-lsep+4);
			
			data = new Array("time.windows.com", "time.nist.gov", "time-nw.nist.gov", "time-a.nist.gov", "time-b.nist.gov");
			_osd.addListBox(gadX, gadY, tw, data, 4, false);
			
			System.textLine = System.TEXTLINE_NORMAL; //'long' text lines OFF
			
			_osd.setHandler(tabs[2]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 0 TAB 2
			gadX = defX - 285;
			gadY = defY - 130;
			_osd.addLabel(gadX, gadY, "Канал", Osd.COLOR_TEXT);	gadX += 132;
			_osd.addLabel(gadX, gadY, "Имя", Osd.COLOR_TEXT);	gadX += 132;
			_osd.addLabel(gadX, gadY, "Маска", Osd.COLOR_TEXT);	gadX += 128;
			_osd.addLabel(gadX, gadY, "Цвет", Osd.COLOR_TEXT);	gadX += 105;
			_osd.addLabel(gadX, gadY, "OSD текст", Osd.COLOR_TEXT);
			
			data = [CMD_MASK, CMD_COLOR, CMD_OSDSETUP];
			
			gadY = defY - 100;
			for (var i:int = 0; i < System.CHANNELS; i++)
			{
				gadX = defX - 270;
				
				_osd.addLabel(gadX, gadY+2, new String(i+1), Osd.COLOR_TEXT);											gadX += 62;
				chNameinput.push(_osd.addTextInput(gadX, gadY, 148, System.manager.getTitle(i), CMD_CHANNELNAME+i));	gadX += 175;
				
				for (var n:int = 0; n < 3; n++)
				{
					_osd.addTextButton(gadX, gadY, "Установка", data[n]+i, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);	gadX += 123;
				}
				
				gadY += sepTInput-2;
			}
			
			addCopyBar();
			
			_osd.setHandler(tabs[3]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 0 TAB 3
			gadX = defX - 220;
			gadY = defY - 130;
			_osd.addLabel(gadX, gadY, "Имя", Osd.COLOR_TEXT);	gadX += 127;
			_osd.addLabel(gadX, gadY, "Тип пользователя", Osd.COLOR_TEXT);	gadX += 182;
			_osd.addLabel(gadX, gadY, "Привязка к MAC-адресу", Osd.COLOR_TEXT);

			gadX = defX-266;
			gadY = defY-101;
			for (i = 0; i < System.MAX_USERS; i++)
			{
				var tl:TextLine = _osd.addTextLine(gadX, gadY, 557, ["admin", "Администратор", "Не ограниченный"], CMD_USEREDIT+i, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT, [63, 175, 206]);
				usersTLine.push(tl);
				
				if (i > 0) usersCBox.push(_osd.addCheckBox(gadX - 18, gadY + 15, Osd.CMD_INVALID));
				gadY += 38;
			}
			
			updateUserList();
				
			gadX = defX-35;
			gadY = defY+267;
			_osd.addTextButton(gadX, gadY, "Добавить", CMD_USERADD, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);			gadX += 147;
			_osd.addTextButton(gadX, gadY, "Удалить", CMD_USERDEL, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);			gadX += 112;
			_osd.addTextButton(gadX, gadY, "Выход", CMD_EXIT, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);
			
			//--------------------------------------------------------------------GROUP 1
			var tab_1:TabBar = new TabBar(body, _osd, 500, 0, TabBar.TYPE_TEXT, 0, 93);
			tab_1.addButton(50, "Основные", CMD_TAB+4);
			tab_1.addButton(50, "Качество", CMD_TAB+5);
			tab_1.addButton(50, "Расписание", CMD_TAB+6);
			tab_1.setPos(new Point(defX - 197, defY - 160));
			bars.push(tab_1);
			groups[1].addChildAt(tab_1,0);
			
			_osd.setHandler(tabs[4]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 1 TAB 0
			gadX = defX - 205;
			gadY = defY - 130;
			_osd.addLabel(gadX, gadY, "Канал", Osd.COLOR_TEXT);	gadX += 72;
			_osd.addLabel(gadX, gadY, "Вкл", Osd.COLOR_TEXT);	gadX += 68;
			_osd.addLabel(gadX, gadY, "Аудио", Osd.COLOR_TEXT);	gadX += 118;
			_osd.addLabel(gadX, gadY, "Режим", Osd.COLOR_TEXT);
			
			gadY = defY - 100;
			recMainLBox = new Array();
			for (i = 0; i < System.CHANNELS; i++)
			{
				gadX = defX - 190;
				
				_osd.addLabel(gadX, gadY + 2, new String(i+1), Osd.COLOR_TEXT);					gadX += 72;
				recMainOnOffCBox.push(_osd.addCheckBox(gadX, gadY+13, Osd.CMD_INVALID));		gadX += 77;
				var cb:CheckBox = _osd.addCheckBox(gadX, gadY+13, Osd.CMD_INVALID);				gadX += 37;
				cb.uncheck();
				recMainAudioCBox.push(cb);
				
				recMainLBox.push(_osd.addListBox(gadX, gadY, 156, new Array("Всегда", "Расписание"), 0, false));
				
				gadY += sepTInput-2;
			}
			
			addCopyBar();
			
			_osd.setHandler(tabs[5]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 1 TAB 1
			gadX = defX - 205;
			gadY = defY - 130;
			_osd.addLabel(gadX, gadY, "Канал", Osd.COLOR_TEXT);			gadX += 72;
			_osd.addLabel(gadX, gadY, "Разрешение", Osd.COLOR_TEXT);	gadX += 118;
			_osd.addLabel(gadX, gadY, "Скорость", Osd.COLOR_TEXT);		gadX += 118;
			_osd.addLabel(gadX, gadY, "Качество", Osd.COLOR_TEXT);
			
			var spd:Array = new Array();
			for (i = 0; i < 30; i++) spd.push(new String(i+1));
			
			gadY = defY - 100;
			for (i = 0; i < System.CHANNELS; i++)
			{
				gadX = defX - 190;
				
				_osd.addLabel(gadX, gadY + 2, new String(i + 1), Osd.COLOR_TEXT);							gadX += 61;
				
				var lbx:ListBox = _osd.addListBox(gadX, gadY, 86, new Array("C1F", "HD1", "D1"), 0, false);	gadX += 105;
				lbx.selectItem(2)
				recQualMainResLBox.push(lbx);
				
				lbx = _osd.addListBox(gadX, gadY, 86, spd, 8, false);										gadX += 105;
				lbx.selectItem(24);
				recQualMainSpdLBox.push(lbx);
				
				lbx = _osd.addListBox(gadX, gadY, 124, new Array("Наилучшее", "Высокое", "Хорошее", "Нормальное"), 0, false);
				lbx.selectItem(2);
				recQualMainQltLBox.push(lbx);
				
				gadY += sepTInput-2;
			}
			
			addCopyBar();
			
			_osd.setHandler(tabs[6]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 1 TAB 2
			gadX = defX - 230;
			gadY = defY - 130;
			_osd.addLabel(gadX, gadY, "Канал", Osd.COLOR_TEXT);												gadX += 85;
			
			scdChLBox = _osd.addListBox(gadX, gadY, 92, getChannels(), 0, false, CMD_SCHEDCHANNEL);			gadX += 146;
			
			cb = _osd.addCheckBox(gadX, gadY+13, CMD_SCHEDMODE, "Тревога", true);							gadX += 128;
			cb.check();
			scdModeCBox.push(cb);
			
			cb = _osd.addCheckBox(gadX, gadY+13, CMD_SCHEDMODE+1, "Норм.", true);
			cb.uncheck();
			scdModeCBox.push(cb);
			
			gadX = defX + 20;
			gadY = defY - 98;
			_osd.addImage(gadX, gadY, "ColoralarmRec.png"); gadX += 127;
			_osd.addImage(gadX, gadY, "ColornormalRec.png");
			
			addCopyBar(1); //with special params
			
			scheduler = new Scheduler(tabs[6], Scheduler.MODE_DUAL);
			scheduler.setPos(defX+7, defY+55);
			
			//generating default scheduler patterns
			scdPatterns = new Array();
			var pat:Array;
			for (i = 0; i < System.CHANNELS; i++)
			{
				pat = new Array();
				for (var j:int = 0; j < 7; j++) pat.push(scheduler.getOptimizedPattern(j));
				scdPatterns.push(pat);
			}
			
			//--------------------------------------------------------------------GROUP 2
			var tab_2:TabBar = new TabBar(body, _osd, 500, 0, TabBar.TYPE_TEXT, 0, 80);
			tab_2.addButton(50, "Движение", CMD_TAB+7);
			tab_2.addButton(50, "Датчик", CMD_TAB+8);
			tab_2.addButton(50, "Потеря видео", CMD_TAB+9);
			tab_2.addButton(50, "Закрытие камеры", CMD_TAB+10);
			tab_2.addButton(50, "Прочее", CMD_TAB+11);
			tab_2.setPos(new Point(defX - 299, defY - 160));
			bars.push(tab_2);
			groups[2].addChildAt(tab_2,0);
			
			_osd.setHandler(tabs[7]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 2 TAB 0
			gadX = defX - 295;
			gadY = defY - 130;
			_osd.addLabel(gadX, gadY, "Канал", Osd.COLOR_TEXT);				gadX += 68;
			_osd.addLabel(gadX, gadY, "Вкл", Osd.COLOR_TEXT);				gadX += 62;
			_osd.addLabel(gadX, gadY, "Чувствительность", Osd.COLOR_TEXT);	gadX += 168;
			_osd.addLabel(gadX, gadY, "Зона", Osd.COLOR_TEXT);				gadX += 86;
			_osd.addLabel(gadX, gadY, "Расписание", Osd.COLOR_TEXT);		gadX += 105;
			_osd.addLabel(gadX, gadY, "План тревоги", Osd.COLOR_TEXT);
			
			var arr:Array = new Array(CMD_MOVEAREA, CMD_MOVEALSCHD, CMD_MOVEALPLAN);
			
			data = new Array("1(Макс)", "2", "3", "4", "5", "6", "7", "8(Мин)");
			gadY = defY - 98;
			for (i = 0; i < System.CHANNELS; i++)
			{
				gadX = defX - 276;
				_osd.addLabel(gadX, gadY + 2, new String(i+1), Osd.COLOR_TEXT);			gadX += 64;
				
				cb = _osd.addCheckBox(gadX, gadY + 13, Osd.CMD_INVALID);				gadX += 50;
				cb.uncheck();
				alarmMoveOnOffCBox.push(cb);
				
				alarmMoveSensLBox.push(_osd.addListBox(gadX, gadY, 124, data, 0, false));	gadX += 148;
				
				for (n = 0; n < 3; n++)
				{
					_osd.addTextButton(gadX, gadY, "Установка", arr[n]+i, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);	gadX += 108;
				}
				
				gadY += sepTInput-2;
			}
			
			addCopyBar();
			
			_osd.setHandler(tabs[8]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 2 TAB 1
			gadX = defX - 292;
			gadY = defY - 130;
			_osd.addLabel(gadX, gadY, "ID", Osd.COLOR_TEXT);				gadX += 50;
			_osd.addLabel(gadX, gadY, "Вкл", Osd.COLOR_TEXT);				gadX += 92;
			_osd.addLabel(gadX, gadY, "Тип", Osd.COLOR_TEXT);				gadX += 123;
			_osd.addLabel(gadX, gadY, "Имя", Osd.COLOR_TEXT);				gadX += 100;
			_osd.addLabel(gadX, gadY, "Расписание", Osd.COLOR_TEXT);		gadX += 105;
			_osd.addLabel(gadX, gadY, "План тревоги", Osd.COLOR_TEXT);
			
			data = [CMD_SENSALSCHD, CMD_SENSALPLAN];
			
			gadY = defY - 98;
			for (i = 0; i < System.CHANNELS; i++)
			{
				gadX = defX - 288;
				_osd.addLabel(gadX, gadY+2, new String(i+1), Osd.COLOR_TEXT);						gadX += 62;
				
				cb = _osd.addCheckBox(gadX, gadY+13, Osd.CMD_INVALID);								gadX += 56;				
				cb.uncheck();
				alarmSensOnOffCBox.push(cb);
				
				lbx = _osd.addListBox(gadX, gadY, 80, new Array("Н.О.", "Н.З."), 0, false);			gadX += 85;
				lbx.selectItem(1);
				alarmSensTypeLBox.push(lbx);
				
				alarmSensNameTInput.push(_osd.addTextInput(gadX, gadY, 144, "Sensor" + new String(i+1), Osd.CMD_INVALID));		gadX += 163;
				
				for (n = 0; n < 2; n++)
				{
					_osd.addTextButton(gadX, gadY, "Установка", data[n]+i, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);	gadX += 108;
				}
				
				gadY += sepTInput-2;
			}
			
			addCopyBar();
			
			_osd.setHandler(tabs[9]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 2 TAB 2
			gadX = defX - 140;
			gadY = defY - 130;
			_osd.addLabel(gadX, gadY, "Канал", Osd.COLOR_TEXT);				gadX += 64;
			_osd.addLabel(gadX, gadY, "Вкл", Osd.COLOR_TEXT);				gadX += 62;
			_osd.addLabel(gadX, gadY, "План тревоги", Osd.COLOR_TEXT);
			
			gadY = defY - 98;
			for (i = 0; i < System.CHANNELS; i++)
			{
				gadX = defX - 121;
				_osd.addLabel(gadX, gadY + 2, new String(i+1), Osd.COLOR_TEXT);		gadX += 60;
				
				cb = _osd.addCheckBox(gadX, gadY + 13, Osd.CMD_INVALID);			gadX += 60;
				cb.uncheck();
				vidLostOnOffCBox.push(cb);
				
				_osd.addTextButton(gadX, gadY, "Установка", CMD_VLOSTALPLAN+i, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
				
				gadY += sepTInput-2;
			}
			
			addCopyBar();
			
			_osd.setHandler(tabs[10]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 2 TAB 3
			gadX = defX - 278;
			gadY = defY - 130;
			_osd.addLabel(gadX, gadY, "Канал", Osd.COLOR_TEXT);				gadX += 68;
			_osd.addLabel(gadX, gadY, "Вкл", Osd.COLOR_TEXT);				gadX += 65;
			_osd.addLabel(gadX, gadY, "Чувствительность", Osd.COLOR_TEXT);	gadX += 154;
			_osd.addLabel(gadX, gadY, "Расписание", Osd.COLOR_TEXT);		gadX += 128;
			_osd.addLabel(gadX, gadY, "План тревоги", Osd.COLOR_TEXT);
			
			data = [CMD_CCLOSESCHD, CMD_CCLOSEPLAN];
			
			gadY = defY - 98;
			for (i = 0; i < System.CHANNELS; i++)
			{
				gadX = defX - 258;
				_osd.addLabel(gadX, gadY + 2, new String(i+1), Osd.COLOR_TEXT);		gadX += 64;
				
				cb = _osd.addCheckBox(gadX, gadY + 13, Osd.CMD_INVALID);			gadX += 50;
				cb.uncheck();
				camCloseOnOffCBox.push(cb);
				
				camSensOnOffLBox.push(_osd.addListBox(gadX, gadY, 136, new Array("1(Макс)", "2", "3(Мин)"), 0, false));	gadX += 158;
				
				for (n = 0; n < 2; n++)
				{
					_osd.addTextButton(gadX, gadY, "Установка", data[n]+i, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);	gadX += 135;
				}
				
				gadY += sepTInput-2;
			}
			
			addCopyBar();
			
			_osd.setHandler(tabs[11]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 2 TAB 4
			gadX = defX - 150;
			gadY = defY - 70;
			var ssep = lsep + 5;
			_osd.addLabel(gadX, gadY, "Ошибка HDD", Osd.COLOR_TEXT);			gadY += ssep;
			_osd.addLabel(gadX, gadY, "HDD заполнен", Osd.COLOR_TEXT);			gadY += ssep;
			_osd.addLabel(gadX, gadY, "План тревоги", Osd.COLOR_TEXT);			gadY += ssep;
			_osd.addLabel(gadX, gadY, "Конфликт IP адреса", Osd.COLOR_TEXT);	gadY += ssep;
			_osd.addLabel(gadX, gadY, "План тревоги", Osd.COLOR_TEXT);
			
			gadX = defX + 29;
			gadY = defY - 74;
			ssep += 1;
			var onoff:Array = new Array("Выкл", "Вкл");
			_osd.addListBox(gadX, gadY, 98, onoff, 0, false).selectItem(1);											gadY += ssep;
			_osd.addListBox(gadX, gadY, 98, onoff, 0, false).selectItem(1);											gadY += ssep+2;
			_osd.addTextButton(gadX, gadY, "Установка", CMD_MISCALPLAN, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);		gadY += ssep-3;
			_osd.addListBox(gadX, gadY, 98, onoff, 0, false);														gadY += ssep+3;
			_osd.addTextButton(gadX, gadY, "Установка", CMD_MISCALPLAN+1, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
			
			//--------------------------------------------------------------------GROUP 3
			var tab_3:TabBar = new TabBar(body, _osd, 500, 0, TabBar.TYPE_TEXT, 0, 80);
			tab_3.addButton(50, "LAN", CMD_TAB+12);
			tab_3.addButton(50, "3G", CMD_TAB+13);
			tab_3.addButton(50, "Сетевой поток", CMD_TAB+14);
			tab_3.addButton(50, "DDNS", CMD_TAB+15);
			tab_3.addButton(50, "E-MAIL", CMD_TAB+16);
			tab_3.setPos(new Point(defX - 309, defY - 160));
			bars.push(tab_3);
			groups[3].addChildAt(tab_3,0);
			
			_osd.setHandler(tabs[12]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 3 TAB 0
			gadX = defX - 274;
			gadY = defY - 130;
			
			cb = _osd.addCheckBox(gadX, gadY + 13, CMD_NETIP, "Получить IP адрес автоматически", true);					gadY += lsep - 7;
			cb.uncheck();
			netIPCBox.push(cb);
			
			cb = _osd.addCheckBox(gadX, gadY + 13, CMD_NETIP+1, "Статический IP адрес", true);							gadY += lsep; gadX -= 10;
			netIPCBox.push(cb);
			
			_osd.addLabel(gadX, gadY, "IP адрес", Osd.COLOR_TEXT);														gadY += lsep;
			_osd.addLabel(gadX, gadY, "Маска", Osd.COLOR_TEXT);															gadY += lsep;
			_osd.addLabel(gadX, gadY, "Шлюз", Osd.COLOR_TEXT);															gadY += lsep; gadX += 10;
			
			cb = _osd.addCheckBox(gadX, gadY + 13, CMD_NETDNS, "Получить адрес DNS сервера автоматически", true);		gadY += lsep - 7;
			cb.uncheck();
			cb.disable();
			netDNSCBox.push(cb);
			
			cb = _osd.addCheckBox(gadX, gadY + 13, CMD_NETDNS+1, "Исп. следующие адреса DNS серверов", true);			gadY += lsep; gadX -= 10;
			netDNSCBox.push(cb);
			
			_osd.addLabel(gadX, gadY, "Первичный DNS сервер", Osd.COLOR_TEXT);											gadY += lsep;
			_osd.addLabel(gadX, gadY, "Альтернативный DNS сервер", Osd.COLOR_TEXT);										gadY += lsep+7;
			_osd.addLabel(gadX, gadY, "Медиа порт", Osd.COLOR_TEXT);													gadX += 290;
			_osd.addLabel(gadX, gadY, "Web порт", Osd.COLOR_TEXT);														gadY += lsep; gadX -= 290;
			_osd.addLabel(gadX, gadY, "UPnP", Osd.COLOR_TEXT);															gadY += lsep;
			
			System.textLine = System.TEXTLINE_LONG;
			
			netTInput = new Array();
			var netData:Array = new Array("192.168.002.234", "255.255.255.000", "192.168.002.001", "0", "0", "008.008.008.008", "202.096.134.133");
			
			gadX = defX - 34;
			gadY = defY - 67;
			for (i = 0; i < 7; i++)
			{
				if (i != 3 && i != 4) netTInput.push(_osd.addTextInput(gadX, gadY, 318, netData[i], Osd.CMD_INVALID, TextInput.FMT_IP));
				gadY += lsep;
				if (i == 4) gadY -= 7;
			}
			
			gadX = defX - 145;
			gadY = defY + 193;
			_osd.addTextInput(gadX, gadY, 98, "9000", Osd.CMD_INVALID, TextInput.FMT_DIGITAL, 65535, 5);	gadX += 280;
			_osd.addTextInput(gadX, gadY, 78, "85", Osd.CMD_INVALID, TextInput.FMT_DIGITAL, 65535, 5);	gadX -= 280; gadY += lsep;
			_osd.addListBox(gadX, gadY, 98, onoff, 0, true).selectItem(1);
			
			_osd.setHandler(tabs[13]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 3 TAB 1
			gadX = defX - 223;
			gadY = defY - 90;
			_osd.addLabel(gadX, gadY, "3G модем", Osd.COLOR_TEXT);				gadY += ssep;
			_osd.addLabel(gadX, gadY, "APN", Osd.COLOR_TEXT);					gadY += ssep;
			_osd.addLabel(gadX, gadY, "Имя", Osd.COLOR_TEXT);					gadY += ssep;
			_osd.addLabel(gadX, gadY, "Пароль", Osd.COLOR_TEXT);				gadY += ssep;
			_osd.addLabel(gadX, gadY, "Номер доступа", Osd.COLOR_TEXT);
			
			gadX = defX - 55;
			gadY = defY - 95;
			net3GOnOffLBox = _osd.addListBox(gadX, gadY, 319, onoff, 0, false, CMD_ENABLE3G);	gadY += ssep;
			
			var type:int = 0;
			for (i = 0; i < 4; i++)
			{
				if (i == 2) type = TextInput.FMT_PASSWORD;
				else type = TextInput.FMT_DEFAULT;
				
				var ti:TextInput = _osd.addTextInput(gadX, gadY, 319, " ", Osd.CMD_INVALID, type);	gadY += ssep;
				ti.disable();
				net3GTInput.push(ti);
			}
			
			System.textLine = System.TEXTLINE_NORMAL;
			
			_osd.setHandler(tabs[14]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 3 TAB 2
			gadX = defX - 252;
			gadY = defY - 130;
			_osd.addLabel(gadX, gadY, "Канал", Osd.COLOR_TEXT);			gadX += 73;
			_osd.addLabel(gadX, gadY, "Вкл", Osd.COLOR_TEXT);			gadX += 54;
			_osd.addLabel(gadX, gadY, "Разрешение", Osd.COLOR_TEXT);	gadX += 121;
			_osd.addLabel(gadX, gadY, "Скорость", Osd.COLOR_TEXT);		gadX += 125;
			_osd.addLabel(gadX, gadY, "Качество", Osd.COLOR_TEXT);
			
			spd = new Array();
			for (i = 0; i < 25; i++) spd.push(new String(i+1));
			
			gadY = defY - 98;
			for (i = 0; i < System.CHANNELS; i++)
			{
				gadX = defX - 236;
				_osd.addLabel(gadX, gadY + 2, new String(i+1), Osd.COLOR_TEXT);												gadX += 70;
				
				netStrOnOffCBox.push(_osd.addCheckBox(gadX, gadY + 13, Osd.CMD_INVALID));									gadX += 41;
				
				lbx = _osd.addListBox(gadX, gadY, 88, new Array("QCIF", "CIF", "WQCIF", "WCIF", "WHD1", "WD1"), 4, false);	gadX += 108;
				lbx.selectItem(1);
				netStrResLBox.push(lbx);
				
				lbx = _osd.addListBox(gadX, gadY, 88, spd, 8, false);														gadX += 108;
				lbx.selectItem(2);
				netStrSpdLBox.push(lbx);
				
				lbx = _osd.addListBox(gadX, gadY, 136, new Array("Наилучшее", "Высокое", "Хорошее", "Нормальное"), 0, false);
				lbx.selectItem(2);
				netStrQltLBox.push(lbx);
				
				gadY += sepTInput-2;
			}
			
			addCopyBar();
			
			_osd.setHandler(tabs[15]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 3 TAB 2
			gadX = defX - 229;
			gadY = defY - 87;
			_osd.addLabel(gadX, gadY, "DDNS", Osd.COLOR_TEXT);			gadY += ssep;
			_osd.addLabel(gadX, gadY, "Сервер", Osd.COLOR_TEXT);		gadY += ssep;
			_osd.addLabel(gadX, gadY, "По умолчанию", Osd.COLOR_TEXT);	gadY += ssep;
			_osd.addLabel(gadX, gadY, "Адрес сервера", Osd.COLOR_TEXT);	gadY += ssep;
			_osd.addLabel(gadX, gadY, "Порт", Osd.COLOR_TEXT);
			
			System.textLine = System.TEXTLINE_LONG;
			
			var srv:Array = new Array("REELINK", "88110", "3322", "DYNDNS", "DNSEXIT", "NO-IP", "CHANGEIP");
			
			gadX = defX - 61;
			gadY = defY - 95;
			netDDNSOnOffLBox = _osd.addListBox(gadX, gadY, 318, onoff, 0, false, CMD_ENABLEDDNS);		gadY += ssep;
			
			netDDNSSrvLBox = _osd.addListBox(gadX, gadY, 318, srv, 6, false);							gadY += ssep;
			netDDNSSrvLBox.selectItem(1);
			netDDNSSrvLBox.disable();
			
			netDDNSDefsCBox = _osd.addCheckBox(gadX+10, gadY+19, Osd.CMD_INVALID);						gadY += ssep+4;
			netDDNSDefsCBox.check();
			netDDNSDefsCBox.disable();
			
			_osd.addTextInput(gadX, gadY, 318, " ", Osd.CMD_INVALID).disable();							gadY += ssep;
			_osd.addTextInput(gadX, gadY, 318, "0", Osd.CMD_INVALID, TextInput.FMT_DIGITAL).disable();
			
			_osd.setHandler(tabs[16]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 3 TAB 3
			gadX = defX - 303;
			gadY = defY - 117;
			_osd.addLabel(gadX, gadY, "E-mail", Osd.COLOR_TEXT);					gadX += 290;
			_osd.addLabel(gadX, gadY, "Период отправки", Osd.COLOR_TEXT);			gadY += lsep; gadX -= 290;
			_osd.addLabel(gadX, gadY, "Порт", Osd.COLOR_TEXT);						gadX += 290;
			_osd.addLabel(gadX, gadY, "SSL подключение", Osd.COLOR_TEXT);			gadY += lsep; gadX -= 290;
			_osd.addLabel(gadX, gadY, "Почтовый сервер (SMTP)", Osd.COLOR_TEXT);	gadY += lsep;
			_osd.addLabel(gadX, gadY, "Имя", Osd.COLOR_TEXT);						gadY += lsep;
			_osd.addLabel(gadX, gadY, "Пароль", Osd.COLOR_TEXT);					gadY += lsep;
			_osd.addLabel(gadX, gadY, "Кому", Osd.COLOR_TEXT);						gadY += lsep;
			
			for (i = 0; i < 3; i++)
			{
				_osd.addLabel(gadX, gadY, "Копия", Osd.COLOR_TEXT);					gadY += lsep;
			}
			
			data = new Array("Немедленно", "30с", "1мин", "3мин", "5мин", "10мин");
			
			gadX = defX - 205;
			gadY = defY - 121;
			netEmailOnOffLBox = _osd.addListBox(gadX, gadY, 148, onoff, 0, false, CMD_ENABLEEMAIL);									gadX += 360;
			
			lbx = _osd.addListBox(gadX, gadY, 148, new Array("Немедленно", "30с", "1мин", "3мин", "5мин", "10мин"), 0, false);		gadY += lsep; gadX -= 360;
			lbx.selectItem(4);
			lbx.disable();
			netEmailSetLBox.push(lbx);
			
			ti = _osd.addTextInput(gadX, gadY, 148, "25", Osd.CMD_INVALID, TextInput.FMT_DIGITAL, 65535, 5);	gadX += 360;
			ti.disable();
			netEmailTInput.push(ti);
			
			lbx = _osd.addListBox(gadX, gadY, 148, new Array("Нет", "SSL/TLS"), 0, false);						gadY += lsep; gadX -= 190;
			lbx.disable();
			netEmailSetLBox.push(lbx);
			
			for (i = 0; i < 7; i++)
			{
				var tp:int = TextInput.FMT_DEFAULT;
				if (i==2) tp = TextInput.FMT_PASSWORD;
				ti = _osd.addTextInput(gadX, gadY, 338, " ", Osd.CMD_INVALID, tp);	gadY += lsep;
				ti.disable();
				netEmailTInput.push(ti);
			}
			
			var tb:TextButton = _osd.addTextButton(gadX, gadY, "Тест", CMD_TESTEMAIL, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
			tb.disable();
			netEmailTestTBtn = tb;
			
			System.textLine = System.TEXTLINE_NORMAL;
			
			//--------------------------------------------------------------------GROUP 4
			_osd.setHandler(tabs[17]);
			bars.push(new String(undefined)); //dummy empty object! fills the gap in array
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 4 TAB 0
			gadX = defX - 222;
			gadY = defY - 127;
			_osd.addLabel(gadX, gadY, "Канал", Osd.COLOR_TEXT);			gadX += 69;
			_osd.addLabel(gadX, gadY, "Вкл", Osd.COLOR_TEXT);			gadX += 88;
			_osd.addLabel(gadX, gadY, "Протокол", Osd.COLOR_TEXT);		gadX += 111;
			_osd.addLabel(gadX, gadY, "Скорость", Osd.COLOR_TEXT);		gadX += 100;
			_osd.addLabel(gadX, gadY, "Адрес", Osd.COLOR_TEXT);
			
			spd = new Array("1200", "2400", "4800", "9600");
			data = new Array("Pelco-D", "Pelco-P", "PelcoD1", "PelcoD2", "PelcoD3", "PelcoD4", "PelcoD_JEC", "PelcoD_WJ", "ABK2001", "ABK2007", "ACES-HN", "DRAGON", "EE", "HT600", "HY", "SAMSUNG", "Yaan", "Philips", "Lilin", "SAE", "YLDVR", "GRX2000", "JabscoD", "Kallaite", "B01", "Panasonic", "SONY", "SYYT", "V1200", "Visdom", "KonyM800", "KonyMTR500");
			
			gadY = defY - 96;
			for (i = 0; i < System.CHANNELS; i++)
			{
				gadX = defX - 203;
				_osd.addLabel(gadX, gadY + 2, new String(i+1), Osd.COLOR_TEXT);			gadX += 64;
				
				cb = _osd.addCheckBox(gadX, gadY + 13, Osd.CMD_INVALID);				gadX += 41;
				cb.uncheck();
				ptzOnOffCBox.push(cb);
				
				ptzProtoLBox.push(_osd.addListBox(gadX, gadY, 130, data, 8, false));	gadX += 140;
				
				lbx = _osd.addListBox(gadX, gadY, 83, spd, 0, false);					gadX += 98;
				lbx.selectItem(1);
				ptzSpdLBox.push(lbx);
				
				ptzAddrTInput.push(_osd.addTextInput(gadX, gadY, 58, new String(i+1), Osd.CMD_INVALID, TextInput.FMT_DIGITAL, 255, 3));
				
				gadY += sepTInput-2;
			}
			
			addCopyBar();
			
			//--------------------------------------------------------------------GROUP 5
			var tab_5:TabBar = new TabBar(body, _osd, 500, 0, TabBar.TYPE_TEXT, 0, 136);
			tab_5.addButton(50, "Хранилище", CMD_TAB+18);
			tab_5.addButton(50, "e-SATA", CMD_TAB+19);
			tab_5.setPos(new Point(defX - 140, defY - 160));
			bars.push(tab_5);
			groups[5].addChildAt(tab_5,0);
			
			_osd.setHandler(tabs[18]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 5 TAB 0
			gadX = defX - 254;
			gadY = defY - 127;
			_osd.addLabel(gadX, gadY, "ID", Osd.COLOR_TEXT);				gadX += 89;
			_osd.addLabel(gadX, gadY, "Статус", Osd.COLOR_TEXT);			gadX += 123;
			_osd.addLabel(gadX, gadY, "Емкость", Osd.COLOR_TEXT);			gadX += 74;
			_osd.addLabel(gadX, gadY, "Всего/Свободно", Osd.COLOR_TEXT);	gadX += 166;
			_osd.addLabel(gadX, gadY, "Формат", Osd.COLOR_TEXT);
			
			gadX = defX - 250;
			gadY = defY + 43;
			_osd.addLabel(gadX, gadY, "Доступное время записи", Osd.COLOR_TEXT);										gadX += 213;
			_osd.addLabel(gadX, gadY, "18:56:43", Osd.COLOR_TEXT);														gadX += 169;
			_osd.addTextButton(gadX, gadY, "Форматировать", CMD_DISPLAY_SET, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);	gadY += ssep;
			
			gadX = defX - 250;
			_osd.addLabel(gadX, gadY, "Перезапись", Osd.COLOR_TEXT);																		gadX += 110;
			
			lbx = _osd.addListBox(gadX, gadY - 3, 128, new Array("по дням", "при заполн.", "никогда"), 0, false, CMD_HDDOVERWRITE);			gadX += 157;
			lbx.selectItem(1);
			hddOvwrLBox = lbx;
			
			hddDayLbl = _osd.addLabel(gadX, gadY, "Макс. резерв. дней", Osd.COLOR_TEXT);													gadX += 188;
			hddDayLbl.hide();
			
			ti = _osd.addTextInput(gadX, gadY-3, 33, " ", Osd.CMD_INVALID, TextInput.FMT_DIGITAL, 99, 2);
			ti.visible = false;
			hddDayTInput = ti;
			
			_osd.setHandler(tabs[19]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 5 TAB 1
			gadX = defX - 219;
			gadY = defY - 127;
			_osd.addLabel(gadX, gadY, "Статус", Osd.COLOR_TEXT);			gadX += 109;
			_osd.addLabel(gadX, gadY, "Емкость", Osd.COLOR_TEXT);			gadX += 74;
			_osd.addLabel(gadX, gadY, "Всего/Свободно", Osd.COLOR_TEXT);	gadX += 194;
			_osd.addLabel(gadX, gadY, "Формат", Osd.COLOR_TEXT);			gadY += sepLbl;
			
			gadX = defX - 235;
			_osd.addLabel(gadX, gadY, "Получение", Osd.COLOR_TEXT);	gadX += 393;
			_osd.addLabel(gadX, gadY, "Формат", Osd.COLOR_DISABLED);
			
			gadX = defX+220;
			gadY = defY+267;
			_osd.addTextButton(gadX, gadY, "Выход", CMD_EXIT, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);
			
			//--------------------------------------------------------------------GROUP 6
			var tab_6:TabBar = new TabBar(body, _osd, 500, 0, TabBar.TYPE_TEXT, 0, 85);
			tab_6.addButton(50, "Основной", CMD_TAB+20);
			tab_6.addButton(50, "Установки", CMD_TAB+21);
			tab_6.setPos(new Point(defX - 113, defY - 160));
			bars.push(tab_6);
			groups[6].addChildAt(tab_6,0);
			
			_osd.setHandler(tabs[20]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 6 TAB 0
			gadX = defX - 244;
			gadY = defY - 76;
			_osd.addLabel(gadX, gadY, "Автоперезагрузка", Osd.COLOR_TEXT);																				gadX += 189;
			mtnRbtLBox = _osd.addListBox(gadX, gadY-3, 178, new Array("Никогда", "Ежемесячно", "Еженедельно", "Ежедневно"), 0, false, CMD_AUTOREBOOT);	gadX += 190;
			
			var warr:Array = new Array("Вс.", "Пон.", "Вт.", "Ср.", "Чт.", "Птн.", "Сб.");
			var marr:Array = new Array();
			for (i = 0; i < 31; i++) marr.push(new String(i+1) + "-й");
			
			lbx = _osd.addListBox(gadX, gadY - 3, 88, warr, 0, false);
			lbx.visible = false;
			mtnRbtDayLBox = lbx;
			
			lbx = _osd.addListBox(gadX, gadY - 3, 88, marr, 8, false);
			lbx.visible = false;
			mtnRbtMonthLBox = lbx;
			
			gadX = defX - 244;
			gadY += lsep;
			_osd.addLabel(gadX, gadY, "Время", Osd.COLOR_TEXT);																gadX += 189;
			
			ti = _osd.addTextInput(gadX, gadY-3, 178, "00:00:00", Osd.CMD_INVALID, TextInput.FMT_TIME);
			ti.disable();
			mtnRbtTInput = ti;
			
			gadX = defX - 269;
			gadY += ssep+16;
			_osd.addTextButton(gadX, gadY, "Обновление прошивки", CMD_FIRMWAREUPD, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);	gadX += 253;
			_osd.addTextButton(gadX, gadY, "Выключение", CMD_ASKTURNOFF, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);			gadX += 174;
			_osd.addTextButton(gadX, gadY, "Перезагрузка", CMD_ASKREBOOT, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
			
			_osd.setHandler(tabs[21]);
			//----------------------------------------------------------------------------------------------------------------------------------------------GROUP 6 TAB 1
			gadX = defX - 158;
			gadY = defY - 76;
			_osd.addLabel(gadX, gadY, "Экспорт установок", Osd.COLOR_TEXT);											gadX += 192;
			_osd.addTextButton(gadX, gadY, "Экспорт", CMD_STGEXPORT, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);		gadY += lsep+3; gadX -= 192;
			_osd.addLabel(gadX, gadY, "Импорт установок", Osd.COLOR_TEXT);											gadX += 192;
			_osd.addTextButton(gadX, gadY, "Импорт", CMD_STGIMPORT, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);		gadY += lsep+3; gadX -= 192;
			_osd.addLabel(gadX, gadY, "По умолчанию", Osd.COLOR_TEXT);												gadX += 192;
			_osd.addTextButton(gadX, gadY, "Установка", CMD_STGDEFAULTS, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
			
			_osd.setHandler(wnd); //wnd has lower layer, so we use it for placing large objects
			
			title = _osd.addLabel(defX, defY - 295, " ", Osd.COLOR_DEFAULT);
			
			gadX = defX - 305;
			gadY = defY - 270;
			for (i = 0; i < bnor.length; i++)
			{
				var btn:ImageButton = _osd.addImageButton(gadX, gadY, bnor[i], bpre[i], bact[i], CMD_GROUP + i);
				btn.setLinkage(linkedHover);
				butt.push(btn);
				gadX += 90;
			}
			
			_osd.setHandler(this);
			osdCommand(CMD_GROUP); //show up first group and first tab
			
			System.manager.showThinGrid(true);
			spawnGrid();
			
			guideLayer = new MovieClip();
			ow.addChild(guideLayer);
			guide = new UserGuide(guideLayer, _osd);
			
			if (System.guideEnabled)
			{
				var p0:Popup = new Popup(guideLayer, _osd, guide, UserGuide.ID_SETTINGS_MAIN, 448, 218, 400, 100, "Разделы меню настроек логически объединены в 7 групп: общие настройки, настройки записи, настройки тревог, настройки PTZ, установки сети, параметры жесткого диска, обслуживание системы.");
				guide.extend([p0]);
			}
		}
		
		public function addCopyBar(...args)
		{
			System.textLine = System.TEXTLINE_LONG; //'long' text lines ON
			
			var xval:Array;
			var yval:int = 45;
			if (!args.length) xval = new Array(267, 129, 126, 47, 125);
			else
			{
				xval = new Array(257, 129, 150, 56, 113);
				yval = 149;
			}
			
			gadX = defX-xval[0];
			gadY = defY + yval;
			_osd.addLabel(gadX, gadY+3, "Копировать", Osd.COLOR_TEXT);											gadX += xval[1];
			copyLBox.push(_osd.addListBox(gadX, gadY, 92, getChannels(), 0, false));							gadX += xval[2];
			_osd.addLabel(gadX, gadY+3, "в", Osd.COLOR_TEXT);													gadX += xval[3];
			copyLBox.push(_osd.addListBox(gadX, gadY, 92, new Array("Все", "1", "2", "3", "4"), 0, false));		gadX += xval[4];
			_osd.addTextButton(gadX, gadY+3, "Скопировать", CMD_COPY, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
			
			System.textLine = System.TEXTLINE_NORMAL; //'long' text lines OFF
		}
		
		public function addNavButtons() //navigate buttons - always visible elements
		{
			navButt = new MovieClip();
			wnd.addChild(navButt);
			_osd.setHandler(navButt);
			
			gadX = defX-45;
			gadY = defY+267;
			_osd.addTextButton(gadX, gadY, "По умолчанию", Osd.CMD_INVALID, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);		gadX += 147;
			_osd.addTextButton(gadX, gadY, "Применить", CMD_APPLY, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);				gadX += 118;
			_osd.addTextButton(gadX, gadY, "Выход", CMD_EXIT, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);
		}
		
		public function linkedHover(foc:Boolean, c:int)
		{
			if (!foc) updateTitle(bttl[c]);
			else updateTitle(" ");
		}
		
		public function updateTitle(str:String)
		{
			title.setText(str);
			title.setPos(new Point(defX-title.getWidth()/2, defY-295));
		}
		
		public function updateUserList()
		{
			for (var i:int = 0; i < System.MAX_USERS; i++)
			{
				if (System.users[i])
				{
					usersTLine[i].setValue(0, System.users[i].getName());
					usersTLine[i].setValue(1, System.users[i].typeToString());
					usersTLine[i].setValue(2, System.users[i].macToString());
					usersTLine[i].visible = true;
					
					if (i > 0)
					{
						usersCBox[i-1].visible = true;
						usersCBox[i-1].uncheck();
					}
				}
				else
				{
					usersTLine[i].visible = false;
					if (i > 0)
					{
						usersCBox[i-1].visible = false;
						usersCBox[i-1].uncheck();
					}
				}
			}
		}
		
		public function getChannels():Array
		{
			var chlst:Array = new Array();
			
			for (var chidx:int = 0; chidx < System.CHANNELS; chidx++) chlst.push(new String(chidx+1));
			return chlst;
		}
		
		public override function finalize()
		{
			System.manager.showThinGrid(false);
			System.manager.showOsd(true);
			scheduler.finalize();
			
			guideLayer.parent.removeChild(guideLayer);
			
			super.finalize();
		}
		
		public override function pressRight()
		{
			if (!haltRightClick) super.pressRight();
		}
		
		public override function osdCommand(cmd:int):void
		{
			if (cmd >= CMD_GROUP && cmd <= CMD_GROUP+groups.length)
			{
				var b:int = cmd;
				for (var i:int = 0; i < butt.length; i++) butt[i].setStyle(bnor[i], bpre[i], bact[i]); //revert old style
				butt[b].setStyle(bact[b], bpre[b], bact[b]); //set new style
				if (frame) frame.setSelection(b); //updates large tabs on the top
				
				groups[actGroup].visible = false;
				groups[b].visible = true;
				actGroup = b;
				
				if (bars[b] && bars[b] is TabBar) bars[b].setSelection(0); //group 4 contains dummy object, so we additionally check its type
				
				var tidx:int = 0; //calculates tab index to jump
				if (b > 0)
				{
					for (var j:int = 0; j < b; j++)
					tidx += tabPatterns[j];
				}
				
				osdCommand(CMD_TAB + tidx);
			}
			
			if (cmd >= CMD_TAB && cmd <= CMD_TAB + tabs.length-1)
			{
				var t:int = cmd-CMD_TAB;
				tabs[actTab].visible = false;
				tabs[t].visible = true;
				actTab = t;
				
				if (t == 3 || t == 19) navButt.visible = false;
				else navButt.visible = true;
				
				if (System.guideEnabled)
				{
					var pop:Popup;
					var params:Array = new Array();
					switch(t)
					{
						case(4):
							params = [UserGuide.ID_SETTINGS_REC, 291, 190, 350, 80, "Настройки записи позволяют задать скорость, качество, разрешение и расписание записи индивидуально для каждого канала."];
							break;
							
						case(7):
							params = [UserGuide.ID_SETTINGS_ALARM, 360, 190, 375, 100, "Регистратор способен распознавать следующие типы тревог: движение, тревожный датчик, потеря видео, закрытие камеры, заполнение диска, сбой диска."];
							break;
							
						case(12):
							params = [UserGuide.ID_SETTINGS_NET, 442, 190, 400, 100, "Регистраторы Safari позволяют передавать в сеть 2 потока видео: с высоким и пониженным качеством, это может быть полезно, если ваша сеть не позволяет передавать большие объемы видео."];
							break;
							
						case(13):
							params = [UserGuide.ID_SETTINGS_3G, 300, 230, 400, 125, "Во всех регистраторах Safari реализована возможность работы в 3G сетях. Настроив эту функцию, вы можете получить доступ к регистратору через мобильный телефон или компьютер и удалённо управлять его функциями."];
							break;
							
						case(14):
							params = [UserGuide.ID_SETTINGS_NSTR, 428, 230, 400, 125, "Настройки сетевого потока позволяют снизить разрешение и частоту кадров передаваемого изображения в сеть. Эта функция будет полезной для загруженных сетей и для сетей с низкой пропускной способностью."];
							break;
							
						case(17):
							params = [UserGuide.ID_SETTINGS_PTZ, 544, 190, 375, 80, "Раздел PTZ содержит широкий выбор поддерживаемых протоколов передачи данных. Среди них: Philips, Samsung, Panasonic, Sony."];
							break;
							
						case(18):
							params = [UserGuide.ID_SETTINGS_HDD, 650, 190, 350, 80, "Кроме внутренних HDD HD-SDI модели регистраторов поддерживают подключение внешних e-SATA массивов."];
							break;
							
						case(20):
							params = [UserGuide.ID_SETTINGS_MTNC, 687, 190, 450, 125, "В регистраторах Safari реализована возможность резервного копирования всех настроек на flash-накопитель и их сброс на заводские установки. Таким образом, вы всегда сможете вернуть регистратор в исходное состояние, если возникнут какие-либо сбои при его неправильной настройке."];
							break;
					}
				}
				if (params && params.length > 0)
				{
					pop = new Popup(guideLayer, _osd, guide, params[0], params[1], params[2], params[3], params[4], params[5]);
					guide.extend([pop]);
				}
			}
			
			if (cmd >= CMD_CHANNELNAME && cmd < CMD_CHANNELNAME + System.CHANNELS)
			{
				t = cmd-CMD_CHANNELNAME;
				System.manager.setTitle(t, chNameinput[t].getValue());
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
			
			if (cmd >= CMD_MASK && cmd < CMD_MASK + System.CHANNELS)
			{
				t = cmd-CMD_MASK;
				haltRightClick = true;
				body.visible = false;
				new MaskSetDialog(System.top, _osd, t).setCaller(this);
			}
			
			if (cmd >= CMD_COLOR && cmd < CMD_COLOR + System.CHANNELS)
			{
				t = cmd-CMD_COLOR;
				haltRightClick = true;
				body.visible = false;
				System.manager.showThinGrid(false);
				new ColorDialog(caller, _osd, t, true).setCaller(this);
			}
			
			if (cmd >= CMD_OSDSETUP && cmd < CMD_OSDSETUP + System.CHANNELS)
			{
				t = cmd-CMD_OSDSETUP;
				haltRightClick = true;
				body.visible = false;
				System.manager.showThinGrid(false);
				new OSDSetDialog(caller, _osd, t).setCaller(this);
			}
			
			if (cmd >= CMD_MOVEAREA && cmd <= CMD_MOVEAREA+System.CHANNELS)
			{
				t = cmd-CMD_MOVEAREA;
				haltRightClick = true;
				body.visible = false;
				System.manager.showOsd(false);
				new SensorMatrix(System.top, t).setCaller(this);
			}
			
			if (cmd >= CMD_MOVEALSCHD && cmd <= CMD_MOVEALSCHD+System.CHANNELS)
			{
				new SchedulerDialog(body, _osd, false);
			}
			
			if (cmd >= CMD_MOVEALPLAN && cmd <= CMD_MOVEALPLAN+System.CHANNELS)
			{
				new AlarmPlanDialog(body, _osd, AlarmPlanDialog.MODE_MOVEMENT);
			}
			
			if (cmd >= CMD_SENSALSCHD && cmd <= CMD_SENSALSCHD+System.CHANNELS)
			{
				new SchedulerDialog(body, _osd, true);
			}
			
			if (cmd >= CMD_SENSALPLAN && cmd <= CMD_SENSALPLAN+System.CHANNELS)
			{
				new AlarmPlanDialog(body, _osd, AlarmPlanDialog.MODE_SENSOR);
			}
			
			if (cmd >= CMD_VLOSTALPLAN && cmd <= CMD_VLOSTALPLAN+System.CHANNELS)
			{
				new AlarmPlanDialog(body, _osd, AlarmPlanDialog.MODE_CAMCLOSE);
			}
			
			if (cmd >= CMD_CCLOSESCHD && cmd <= CMD_CCLOSESCHD+System.CHANNELS)
			{
				new SchedulerDialog(body, _osd, false);
			}
			
			if (cmd >= CMD_CCLOSEPLAN && cmd <= CMD_CCLOSEPLAN+System.CHANNELS)
			{
				new AlarmPlanDialog(body, _osd, AlarmPlanDialog.MODE_CAMCLOSE);
			}
			
			if (cmd >= CMD_MISCALPLAN && cmd <= CMD_MISCALPLAN+1)
			{
				new AlarmPlanDialog(body, _osd, AlarmPlanDialog.MODE_MISC);
			}
			
			if (cmd >= CMD_USEREDIT && cmd <= CMD_USEREDIT+System.MAX_USERS)
			{
				t = cmd-CMD_USEREDIT;
				new UsersDialog(body, _osd, UsersDialog.MODE_EDIT, t).setCaller(this);
			}
			
			switch(cmd)
			{
				case(CMD_WIZARD):
					caller.launchWizard();
					super.finalize();
					break;
				
				case(CMD_EXIT):
					caller.activate();
					finalize();
					break;
				
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
					
				case(CMD_ENABLE3G):
					var st:int = net3GOnOffLBox.getValue();
					for (i = 0; i < net3GTInput.length; i++)
					{
						if (st == 1) net3GTInput[i].enable();
						else net3GTInput[i].disable();
					}
					break;
					
				case(CMD_ENABLEDDNS):
					st = netDDNSOnOffLBox.getValue();
					if (st == 0)
					{
						netDDNSSrvLBox.disable();
						netDDNSDefsCBox.disable();
					}
					else
					{
						netDDNSSrvLBox.enable();
						netDDNSDefsCBox.enable();
					}
					break;
					
				case(CMD_ENABLEEMAIL):
					st = netEmailOnOffLBox.getValue();
					
					if (st == 0)
					{
						for (i = 0; i < netEmailSetLBox.length; i++) netEmailSetLBox[i].disable();
						for (i = 0; i < netEmailTInput.length; i++) netEmailTInput[i].disable();
						netEmailTestTBtn.disable();
					}
					else
					{
						for (i = 0; i < netEmailSetLBox.length; i++) netEmailSetLBox[i].enable();
						for (i = 0; i < netEmailTInput.length; i++) netEmailTInput[i].enable();
						netEmailTestTBtn.enable();
					}
					
				case(CMD_HDDOVERWRITE):
					st = hddOvwrLBox.getValue();
					if (st == 0)
					{
						hddDayTInput.visible = true;
						hddDayLbl.show();
					}
					else
					{
						hddDayTInput.visible = false;
						hddDayLbl.hide();
					}
					
					break;
					
				case(CMD_HDDFORMAT):
					new MessageDialog(body, _osd, "Не найдено внешнее устройство!");
					break;
					
				case(CMD_TESTEMAIL):
					new MessageDialog(body, _osd, "Проверьте введенные данные.");
					break;
					
				case(CMD_AUTOREBOOT):
					st = mtnRbtLBox.getValue();
					
					if (st == 0) mtnRbtTInput.disable();
					else mtnRbtTInput.enable();
					
					if (st == 1) mtnRbtMonthLBox.visible = true;
					else mtnRbtMonthLBox.visible = false;
						
					if (st == 2) mtnRbtDayLBox.visible = true;
					else mtnRbtDayLBox.visible = false;
					
					break;
					
				case(CMD_USERADD):
					if (System.users.length < System.MAX_USERS) new UsersDialog(body, _osd, UsersDialog.MODE_ADD).setCaller(this);
					else new MessageDialog(body, _osd, "Достигнут лимит пользователей!");
					break;
					
				case(CMD_USERDEL):
					var chk:Boolean = false;
					for (i = 0; i < usersCBox.length; i++)
					{
						if (usersCBox[i].checked) chk = true;
					}
					
					if (!chk) new MessageDialog(body, _osd, "Выберите пользователя!");
					else new YesNoDialog(body, _osd, this, "Удалить пользователя?", CMD_CONFUSERDEL);
					break;
				
				case(CMD_CONFUSERDEL):
					var del:Boolean = false;
					for (i = 0; i < usersCBox.length; i++)
					{
						if (usersCBox[i].checked)
						{
							if (i+1 == System.curUserID) new MessageDialog(body, _osd, "Невозможно удалить " + System.users[i+1].getName() + "!");
							else
							{
								System.users[i+1] = null;
								del = true;
							}
						}
					}
					
					if (del)
					{
						var ta:Array = new Array();
						for (i = 0; i < System.users.length; i++)
						{
							if (System.users[i] != null)
							{
								ta.push(System.users[i]);
								if (i == System.curUserID) System.curUserID = ta.length-1; //users array was updated, so we need to refresh current user ID, since it's relative to users array structure
							}
						}
						System.users = ta;
						
						updateUserList();
						System.log("Удаление пользователя");
					}
					break;
					
				case(CMD_STGEXPORT):
					new MessageDialog(body, _osd, "Не найдено внешнее устройство!");
					break;
					
				case(CMD_STGIMPORT):
					new MessageDialog(body, _osd, "Не найдено внешнее устройство!");
					break;
					
				case(CMD_STGDEFAULTS):
					haltRightClick = true;
					body.visible = false;
					defaultsDialog = new DefaultsDialog(caller, _osd);
					defaultsDialog.setCaller(this);
					break;
					
				case(CMD_FIRMWAREUPD):
					new YesNoDialog(body, _osd, this, "Выполнить обновление?", CMD_FINDFIRMWARE);
					break;
					
				case(CMD_FINDFIRMWARE):
					new MessageDialog(body, _osd, "Не найдено внешнее устройство!");
					break;
					
				case(CMD_ASKTURNOFF):
					new YesNoDialog(body, _osd, this, "Выключить DVR?", CMD_TURNOFFDVR);
					break;
					
				case(CMD_TURNOFFDVR):
					fscommand("quit");
					break;
					
				case(CMD_ASKREBOOT):
					new YesNoDialog(body, _osd, this, "Выполнить перезагрузку?", CMD_REBOOTDVR);
					break;
					
				case(CMD_REBOOTDVR):
					System.log("Перезагрузка DVR");
					System.userLogin(false);
					System.manager.selectChannel(System.CHANNELS);
					osdCommand(CMD_WIZARD);
					break;
					
				case(CMD_APPLY):
					new MessageDialog(body, _osd, "Сохранение выполнено.");
					break;
					
				case(CMD_COPY):
					var from:int = 0;
					var to:int = 0;
					var toall:Boolean = false;
					
					switch(actTab)
					{
						case(2):
							from = copyLBox[0].getValue();
							if (copyLBox[1].getValue()) to = copyLBox[1].getValue() - 1;
							else
							{
								to = 0;
								toall = true;
							}
							
							for (i = 0; i < chNameinput.length; i++)
							{
								if (toall) to = i;
								
								chNameinput[to].copyFrom(chNameinput[from]);
								System.manager.setTitle(to, chNameinput[to].getValue());
								
								if (!toall) i = chNameinput.length;
							}
							break;
							
						case(4):
							from = copyLBox[2].getValue();
							if (copyLBox[3].getValue()) to = copyLBox[3].getValue() - 1;
							else
							{
								to = 0;
								toall = true;
							}
							
							for (i = 0; i < recMainLBox.length; i++)
							{
								if (toall) to = i;
								
								recMainLBox[to].copyFrom(recMainLBox[from]);
								recMainOnOffCBox[to].copyFrom(recMainOnOffCBox[from]);
								recMainAudioCBox[to].copyFrom(recMainAudioCBox[from]);
								
								if (!toall) i = recMainLBox.length;
							}
							break;
							
						case(5):
							from = copyLBox[4].getValue();
							if (copyLBox[5].getValue()) to = copyLBox[5].getValue() - 1;
							else
							{
								to = 0;
								toall = true;
							}
							
							for (i = 0; i < recQualMainResLBox.length; i++)
							{
								if (toall) to = i;
								
								recQualMainResLBox[to].copyFrom(recQualMainResLBox[from]);
								recQualMainSpdLBox[to].copyFrom(recQualMainSpdLBox[from]);
								recQualMainQltLBox[to].copyFrom(recQualMainQltLBox[from]);
								
								if (!toall) i = recQualMainResLBox.length;
							}
							break;
							
						case(6):
							from = copyLBox[6].getValue();
							if (copyLBox[7].getValue()) to = copyLBox[7].getValue() - 1;
							else
							{
								to = 0;
								toall = true;
							}
							
							if (scdChannel == from) //current channel is not updated yet, so we take its pattern right here
							{
								var tp:Array = new Array();
								for (j = 0; j < 7; j++) tp.push(scheduler.getOptimizedPattern(j));
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
							
						case(7):
							from = copyLBox[8].getValue();
							if (copyLBox[9].getValue()) to = copyLBox[9].getValue() - 1;
							else
							{
								to = 0;
								toall = true;
							}
							
							for (i = 0; i < alarmMoveOnOffCBox.length; i++)
							{
								if (toall) to = i;
								
								alarmMoveOnOffCBox[to].copyFrom(alarmMoveOnOffCBox[from]);
								alarmMoveSensLBox[to].copyFrom(alarmMoveSensLBox[from]);
								
								if (!toall) i = alarmMoveOnOffCBox.length;
							}
							break;
							
						case(8):
							from = copyLBox[10].getValue();
							if (copyLBox[11].getValue()) to = copyLBox[11].getValue() - 1;
							else
							{
								to = 0;
								toall = true;
							}
							
							for (i = 0; i < alarmSensOnOffCBox.length; i++)
							{
								if (toall) to = i;
								
								alarmSensOnOffCBox[to].copyFrom(alarmSensOnOffCBox[from]);
								alarmSensTypeLBox[to].copyFrom(alarmSensTypeLBox[from]);
								alarmSensNameTInput[to].copyFrom(alarmSensNameTInput[from]);
								
								if (!toall) i = alarmSensOnOffCBox.length;
							}
							break;
							
						case(9):
							from = copyLBox[12].getValue();
							if (copyLBox[13].getValue()) to = copyLBox[13].getValue() - 1;
							else
							{
								to = 0;
								toall = true;
							}
							
							for (i = 0; i < vidLostOnOffCBox.length; i++)
							{
								if (toall) to = i;

								vidLostOnOffCBox[to].copyFrom(vidLostOnOffCBox[from]);
								
								if (!toall) i = vidLostOnOffCBox.length;
							}
							break;
							
						case(10):
							from = copyLBox[14].getValue();
							if (copyLBox[15].getValue()) to = copyLBox[15].getValue() - 1;
							else
							{
								to = 0;
								toall = true;
							}
							
							for (i = 0; i < camCloseOnOffCBox.length; i++)
							{
								if (toall) to = i;

								camCloseOnOffCBox[to].copyFrom(camCloseOnOffCBox[from]);
								camSensOnOffLBox[to].copyFrom(camSensOnOffLBox[from]);
								
								if (!toall) i = camCloseOnOffCBox.length;
							}
							break;
							
						case(14):
							from = copyLBox[16].getValue();
							if (copyLBox[17].getValue()) to = copyLBox[17].getValue() - 1;
							else
							{
								to = 0;
								toall = true;
							}
							
							for (i = 0; i < netStrOnOffCBox.length; i++)
							{
								if (toall) to = i;

								netStrOnOffCBox[to].copyFrom(netStrOnOffCBox[from]);
								netStrResLBox[to].copyFrom(netStrResLBox[from]);
								netStrSpdLBox[to].copyFrom(netStrSpdLBox[from]);
								netStrQltLBox[to].copyFrom(netStrQltLBox[from]);
								
								if (!toall) i = netStrOnOffCBox.length;
							}
							break;
							
						case(17):
							from = copyLBox[18].getValue();
							if (copyLBox[19].getValue()) to = copyLBox[19].getValue() - 1;
							else
							{
								to = 0;
								toall = true;
							}
							
							for (i = 0; i < ptzOnOffCBox.length; i++)
							{
								if (toall) to = i;

								ptzOnOffCBox[to].copyFrom(ptzOnOffCBox[from]);
								ptzProtoLBox[to].copyFrom(ptzProtoLBox[from]);
								ptzSpdLBox[to].copyFrom(ptzSpdLBox[from]);
								ptzAddrTInput[to].copyFrom(ptzAddrTInput[from]);
								
								if (!toall) i = ptzOnOffCBox.length;
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
					
				case(Osd.CMD_GAD_UPDATE):
					haltRightClick = false;
					body.visible = true;
					System.manager.showThinGrid(true);
					break;
			}
		}
	}
}