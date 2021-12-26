package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	public class UserGuide extends MovieClip
	{
		//default guide ID's
		public static const ID_INVALID:int			= -1;
		public static const ID_CUSTOM:int			= 1000;
		
		//preset guide ID's
		public static const ID_WELCOME:int			= 0;
		public static const ID_WIZARD:int			= 1;
		public static const ID_GUIDEBTN:int			= 2;
		public static const ID_MAIN_DESIGN:int		= 3;
		public static const ID_MAIN_TOOLBAR:int		= 4;
		public static const ID_MAIN_STARTUP:int		= 5;
		public static const ID_SETTINGS_MAIN:int	= 6;
		public static const ID_SETTINGS_REC:int		= 7;
		public static const ID_SETTINGS_ALARM:int	= 8;
		public static const ID_SETTINGS_NET:int		= 9;
		public static const ID_SETTINGS_PTZ:int		=10;
		public static const ID_SETTINGS_HDD:int		=11;
		public static const ID_SETTINGS_MTNC:int	=12;
		public static const ID_SETTINGS_NSTR:int	=13; //net stream tab
		public static const ID_SETTINGS_3G:int		=14;
		public static const ID_ARCHIVE_TIME:int		=15;
		
		private static const ST_IDLE:int	= -1;
		private static const ST_DEFAULT:int	=  0;
		private static const ST_SHOW:int	=  1;
		private static const ST_HIDE:int	=  2;
		
		private var owner:Object;
		private var osd:Osd;
		
		private var pop:Popup;
		private var tint:MovieClip;
		
		private var guideList:Array;
		
		private var status:int = ST_DEFAULT;
		
		public function UserGuide(ow:Object, o:Osd)
		{
			owner = ow;
			osd = o;
			
			tint = new Tint();
			tint.blendMode = BlendMode.DARKEN;
			addChild(tint);
		
			status = ST_IDLE;
			visible = false;
			owner.addChild(this);
		}
		
		//collects popups, filters them and shows up guide, if valid popups found
		public function extend(arr:Array)
		{
			var bList:Array = System.guideBanList;
			
			if (System.guideEnabled)
			{
				guideList = new Array();
				for (var i:int = 0; i < arr.length; i++)
				{
					var add:Boolean = true;
					if (bList.length)
					{
						for (var j:int = 0; j < bList.length; j++)
						{
							if (arr[i].guideID == bList[j]) add = false;
						}
					}
					if (add) guideList.push(arr[i]);
					else arr[i].forceDestroy(); //auto-kill guide popup has been already displayed before
				}
				if (guideList.length) show();
			}
			else arr[i].forceDestroy(); //additional self-protection
		}
		
		//popups notify guide about destruction, caused by user
		public function notify(id:int)
		{
			var kill:Array = new Array(); //splice must always go after scanning, so we make kill array for that
			
			for (var i:int = 0; i < guideList.length; i++)
			{
				if (guideList[i] && guideList[i].guideID == id)
				{
					System.guideBanList.push(id);
					kill.push(i);
				}
			}
			
			if (kill.length)
			{
				for (i = 0; i < kill.length; i++) guideList.splice(kill[i], 1);
			}
			
			if (!guideList.length) hide();
			else guideList[0].show(); //if there are any more guide popups to show, next one is being displayed
		}
		
		//guide has no self-destruction methods, so it will keep itself in background until external class kills it
		public function hide()
		{
			status = ST_HIDE;
			addEventListener(Event.ENTER_FRAME, handleEvent);
		}
		
		public function show()
		{
			visible = true;
			tint.alpha = 0;
			status = ST_SHOW;
			
			addEventListener(Event.ENTER_FRAME, handleEvent);
		}
		
		public function handleEvent(e:Event)
		{
			if (e.type == Event.ENTER_FRAME)
			{
				if (status == ST_SHOW)
				{
					if (tint.alpha < 1.0) tint.alpha += 0.2;
					else
					{
						guideList[0].show();
						removeEventListener(Event.ENTER_FRAME, handleEvent);
						status = ST_IDLE;
					}
				}
				else
				{
					if (status ==  ST_HIDE)
					{
						if (tint.alpha > 0) tint.alpha -= 0.2;
						else
						{
							removeEventListener(Event.ENTER_FRAME, handleEvent);
							visible = false;
							status = ST_IDLE;
						}
					}
				}
			}
		}
	}
}