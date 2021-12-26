package com.arsec.system
{
	import com.arsec.ui.*;
	import com.arsec.ui.dialog.*;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class System extends MovieClip implements IEventHandler, IActivator
	{
		public static const SCREEN_X:int = 1280;
		public static const SCREEN_Y:int = 720;
		
		public static const TEXTLINE_NORMAL:int = 0;
		public static const TEXTLINE_LONG:int = 1;
		public static const TEXTLINE_SHORT:int = 2;
		
		public static const MAX_USERS:int = 9;
		public static const CHANNELS:int = 4;
		public static const NOVIDEO:Boolean = false; //will load images instead of videos into channels
		public static const FONT_ANTIALIAS:Boolean = false; //applies smoothing to all text labels
		
		public static const DEF_ALPHA:Number = 0.75; //for all windows and their childs
		public static const MASK_ALPHA:Number = 0.8; //for rectangular masks in mask manager
		public static const GRIDLINE_ALPHA:Number = 0.4; //alpha value for grid lines
		
		public static var textLine:int = TEXTLINE_NORMAL; //global switch, affects any line further created
		public static var dateFormat:int = TextInput.DATE_MDY;
		public static var timeFormat:int = TextInput.TIME_24;
		public static var timePeriod:int = TextInput.TIME_PM;
		public static var timeZone:int = 33; //time zone idx in getTimeZones() from SettingsDialog, GMT+0 by default
		public static var volumeLevel:int = 50;
		public static var actChannel:int = 4; //{0..4}, last value shows all channel at once
		
		public static var logStack:Array = new Array();
		public static var eventStack:Array = new Array();
		
		private var mainMenu:MainMenu;
		public static var osd:Osd;
		public static var manager:ChannelManager;
		public static var masks:MovieClip; //stores masks produced by mask manager
		public static var top:MovieClip; //master layer, the very top one, use very carefully!
		
		public static var userLoggedIn:Boolean = false;
		public static var userLoginEID:int;
		public static var userName:String;
		
		public static var users:Array;
		public static var curUserID:int = 0;
		
		public static var guideEnabled:Boolean = true;
		public static var guide:UserGuide;
		public static var guideBanList:Array;
		
		public static var exclusiveRightClick:Window; //if defined, only selected window will handle right click events
		
		public function System()
		{
			guideBanList = new Array();
			
			users = new Array();
			users.push(new User("admin", " ", User.TYPE_ADMIN, "11:22:33:44:55:66", false));
			
			log("Включение питания");
			
			osd = new Osd(this);
			
			manager = new ChannelManager(this);

			mainMenu = new MainMenu(this);
			mainMenu.deactivate();
			
			new WizardDialog(this, osd, true).setCaller(mainMenu);
			
			generateEvents();
			
			masks = new MovieClip();
			masks.alpha = DEF_ALPHA;
			masks.blendMode = BlendMode.LAYER;
			addChild(masks);
			
			top = new MovieClip();
			guide = new UserGuide(top, osd);
			addChild(top);
			
			if (guideEnabled)
			{
				var p0:Popup = new Popup(this, osd, guide, UserGuide.ID_WELCOME, 449, 177, 380, 60, "Вас приветствует видеорегистратор Safari! Нажмите, чтобы закрыть сообщение.");
				var p1:Popup = new Popup(this, osd, guide, UserGuide.ID_WIZARD, 196, 75, 400, 100, "Мастер первоначальной настройки позволяет без проблем настроить все основные параметры регистратора без необходимости обращения к руководству пользователя.");
				guide.extend([p0, p1]);
			}
			
			//new LicenceDialog(this, osd);
			
			//trace("init OK");
		}
		
		public static function userLogin(st:Boolean)
		{
			if (st)
			{
				userLoggedIn = true;
				userName = users[curUserID].getName();
				log("Локальный вход", LogEntry.TYPE_LTD);
				userLoginEID = logStack.length-1;
			}
			else
			{
				if(userLoggedIn && logStack[userLoginEID]) logStack[userLoginEID].end();
				userLoggedIn = false;
				userName = null;
			}
		}
		
		public static function generateEvents()
		{
			var bd:Date;
			var ed:Date;
			
			for (var i:int = 0; i < 5; i++)
			{
				bd = new Date();
				ed = new Date();
				
				bd.setHours(Math.random()*12);
				bd.setMinutes(Math.random()*60);
				bd.setSeconds(Math.random()*60);
				
				ed.setHours(12+Math.random()*12);
				ed.setMinutes(Math.random()*60);
				ed.setSeconds(Math.random()*60);
			
				var ch:int = Math.round(Math.random()*5);
				if (ch == 0) ch += 1;
				if (ch == 5) ch -= 1;
				
				var e:EventEntry = new EventEntry(ch, bd, ed, Math.round(Math.random()));
				eventStack.push(e);
			}
		}
		
		public static function log(str:String, ...args)
		{
			var t:int;
			if (args && args.length) t = args[0];
			logStack.push(new LogEntry(str, t));
		}
		
		public static function getGMT():Array
		{
			var gmt = new Array(-12, -11, -11, -10, -9, -8, -8, -7, -7, -7, -6, -6, -6, -6, -5, -5, -5, -4, -4, -4, -4, -4, -4, -3, -3, -3, -3, -3, -3, -2, -2, -1, -1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6, 6, 6, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 12, 12, 12, 13);
			var halfs = new Array(17, 23, 56, 62, 66, 67, 71, 83, 84);
			var mins:int = 0;
			
			if (timeZone == 68) mins = 45;
			else
			{
				for (var i:int = 0; i < halfs.length; i++)
				{
					if (timeZone == halfs[i]) mins = 30;
				}
			}
			
			if (gmt[timeZone] < 0) mins *= (-1);
			
			return new Array(gmt[timeZone], mins);
		}
		
		public static function getTimeZones():Array
		{
			var tz = new Array();
			
			tz.push("(GMT-12: 00) International Date Line West");
			tz.push("(GMT-11: 00) Samoa");
			tz.push("(GMT-11: 00) coordination of the world when -11");
			tz.push("(GMT-10: 00) Hawaii");
			tz.push("(GMT-09: 00) Alaska");
			tz.push("(GMT-08: 00) Pacific Time (U.S. and Canada)");
			tz.push("(GMT-08: 00) under Jiafu Li Asia");
			tz.push("(GMT-07: 00) Chihuahua, La Paz, Mazatlan");
			tz.push("(GMT-07: 00) Mountain Time (U.S. and Canada)");
			tz.push("(GMT-07: 00) Arizona");
			tz.push("(GMT-06: 00) Guadalajara, Mexico City, Monterrey");
			tz.push("(GMT-06: 00) Saskatchewan");
			tz.push("(GMT-06: 00) Central Time (U.S. and Canada)");
			tz.push("(GMT-06: 00) Central America");
			tz.push("(GMT-05: 00) Bogota, Lima, Quito");
			tz.push("(GMT-05: 00) Eastern Time (U.S. and Canada)");
			tz.push("(GMT-05: 00) Indiana (East)");
			tz.push("(GMT-04: 30) Caracas");
			tz.push("(GMT-04: 00) Atlantic Time (Canada)");
			tz.push("(GMT-04: 00) Cuiaba");
			tz.push("(GMT-04: 00) Georgetown, La Paz, Manaus, San Juan");
			tz.push("(GMT-04: 00) Santiago");
			tz.push("(GMT-04: 00) Asuncion");
			tz.push("(GMT-03: 30) Newfoundland");
			tz.push("(GMT-03: 00) Brasilia");
			tz.push("(GMT-03: 00) Buenos Aires");
			tz.push("(GMT-03: 00) Greenland");
			tz.push("(GMT-03: 00) Cayenne, Fortaleza");
			tz.push("(GMT-03: 00) Montevideo");
			tz.push("(GMT-02: 00) coordination time -02");
			tz.push("(GMT-02: 00) Mid-Atlantic");
			tz.push("(GMT-01: 00) Cape Verde Islands");
			tz.push("(GMT-01: 00) Azores");
			tz.push("(GMT) Dublin, Edinburgh, Lisbon, London");
			tz.push("(GMT) Casablanca");
			tz.push("(GMT) Monrovia, Reykjavik");
			tz.push("(GMT) Coordinated Universal Time");
			tz.push("(GMT +01:00) Amsterdam, Berlin, Bernier, Rome, Stockholm, Vienna");
			tz.push("(GMT +01:00) Belgrade, Bratislava, Budapest, Ljubljana");
			tz.push("(GMT +01:00) Brussels, Copenhagen, Madrid, Paris");
			tz.push("(GMT +01:00) Sarajevo, Skopje, Warsaw, Zagreb");
			tz.push("(GMT +01:00) Central Africa west");
			tz.push("(GMT +01:00) Windhoek");
			tz.push("(GMT +02:00) Amman");
			tz.push("(GMT +02:00) Beirut");
			tz.push("(GMT +02:00) Damascus");
			tz.push("(GMT +02:00) Harare, Pretoria");
			tz.push("(GMT +02:00) Helsinki, Kiev, Riga, Sofia, Tallinn, Vilnius");
			tz.push("(GMT +02:00) Cairo");
			tz.push("(GMT +02:00) Minsk");
			tz.push("(GMT +02:00) Athens, Bucharest, Istanbul");
			tz.push("(GMT +02:00) Jerusalem");
			tz.push("(GMT +03:00) Baghdad");
			tz.push("(GMT +03:00) Kuwait, Riyadh");
			tz.push("(GMT +03:00) Moscow, St. Petersburg, Volgograd");
			tz.push("(GMT +03:00) Nairobi");
			tz.push("(GMT +03:30) Tehran");
			tz.push("(GMT +04:00) Abu Dhabi, Muscat");
			tz.push("(GMT +04:00) Yerevan");
			tz.push("(GMT +04:00) Baku");
			tz.push("(GMT +04:00) Tbilisi");
			tz.push("(GMT +04:00) Port Louis");
			tz.push("(GMT +04:30) Kabul");
			tz.push("(GMT +05:00) Tashkent");
			tz.push("(GMT +05:00) Ekaterinburg");
			tz.push("(GMT +05:00) Islamabad, Karachi");
			tz.push("(GMT +05:30) Chennai, Kolkata, Mumbai, New Delhi");
			tz.push("(GMT +05:30) Sri Jayawardenepura");
			tz.push("(GMT +05:45) Kathmandu");
			tz.push("(GMT +06:00) Astana, Dhaka");
			tz.push("(GMT +06:00) Novosibirsk");
			tz.push("(GMT +06:30) Rangoon");
			tz.push("(GMT +07:00) Krasnoyarsk");
			tz.push("(GMT +07:00) Bangkok, Hanoi, Jakarta");
			tz.push("(GMT +08:00) Beijing, Chongqing, Hong Kong, Urumqi");
			tz.push("(GMT +08:00) Kuala Lumpur, Singapore");
			tz.push("(GMT +08:00) Perth");
			tz.push("(GMT +08:00) Taipei");
			tz.push("(GMT +08:00) Ulan Bator");
			tz.push("(GMT +08:00) Irkutsk");
			tz.push("(GMT +09:00) Osaka, Sapporo, Tokyo");
			tz.push("(GMT +09:00) Seoul");
			tz.push("(GMT +09:00) Yakutsk");
			tz.push("(GMT +09:30) Adelaide Ryder");
			tz.push("(GMT +09:30) Darwin");
			tz.push("(GMT +10:00) Brisbane");
			tz.push("(GMT +10:00) Vladivostok");
			tz.push("(GMT +10:00) Guam, Port Moresby");
			tz.push("(GMT +10:00) Hobart");
			tz.push("(GMT +10:00) Canberra, Melbourne, Sydney");
			tz.push("(GMT +11:00) Magadan, Solomon Islands, New Caledonia");
			tz.push("(GMT +12:00) Auckland, Wellington");
			tz.push("(GMT +12:00) Fiji");
			tz.push("(GMT +12:00) coordination of the world when +12");
			tz.push("(GMT +13:00) Nukuanuo France");
			
			return tz;
		}
			
		public function osdCommand(cmd:int):void
		{
		}
		
		public function activate(...args):void
		{
			
		}
		
		public function deactivate(...args):void
		{
		}
	}
}