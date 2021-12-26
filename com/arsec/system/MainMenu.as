package com.arsec.system
{
	import com.arsec.util.*;
	import com.arsec.ui.*;
	import com.arsec.ui.dialog.*;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class MainMenu extends MovieClip implements IEventHandler
	{
		private static const CMD_SHOW:int		= 0;
		private static const CMD_HIDE:int		= 1;
		private static const CMD_SETTINGS:int	= 2;
		
		private static const CMD_ARCHIVE:int	= 3;
		private static const CMD_SINGLE:int		= 4;
		private static const CMD_SPLIT:int		= 5;
		private static const CMD_COLOR:int		= 6;
		private static const CMD_ZOOM:int		= 7;
		private static const CMD_VOLUME:int		= 8;
		private static const CMD_PTZ:int		= 9;
		private static const CMD_REC:int		= 10;
		private static const CMD_PLAY:int		= 11;
		private static const CMD_INFO:int		= 12;
		private static const CMD_LOGOUT:int		= 13;
		private static const CMD_GUIDE:int		= 14;
		
		private var owner:Object;
		private var osd:Osd;
		
		private var body:MovieClip;
		private var hoverHandler:MovieClip;
		private var spotUp:Hotspot;
		private var spotDn:Hotspot;
		private var holder:MainFrame;
		
		private var btnPos:Point = new Point(370, 670);
		private var btnDlt:Number = 50;
		
		private var settingsBtn:ImageButton;
		private var guideBtn:ImageButton;
		private var recBtn:ImageButton;
		private var recActive:Boolean = false;
		
		private var topLabel:TextLabel;
		private var dateObject:Date;
		
		private var activated:Boolean = false;
		private var settingsDialog:Window;
		private var loginDialog:LoginDialog;
		private var logoutDialog:LogoutDialog;
		private var colorDialog:ColorDialog;
		private var infoDialog:InfoDialog;
		private var volumeDialog:VolumeDialog;
		private var channelDialog:ChannelDialog;
		private var archiveDialog:ArchiveMainDialog;
		private var ptzDialog:PTZMainDialog;
		private var playback:Playback;
		private var digitalZoom:DigitalZoom;
		
		private var grid:MovieClip;
	
		//toDo: auto-hide timer
		public function MainMenu(ow:Object)
		{
			body = new MovieClip();
			hoverHandler = new MovieClip();
			
			owner = ow;
			osd = new Osd(body);
			dateObject = new Date();
			
			holder = new MainFrame();
			holder.x = System.SCREEN_X/2;
			holder.y = System.SCREEN_Y/2;
			holder.alpha = System.DEF_ALPHA;
			body.addChild(holder);
			addChild(hoverHandler);
			addChild(body);
			
			osd.setHandler(hoverHandler);
			spotUp = osd.addHotspot(System.SCREEN_X/2, 15, System.SCREEN_X, 30, Osd.CMD_INVALID);
			spotUp.activate(CMD_SHOW, Osd.CMD_INVALID);
			
			spotDn = osd.addHotspot(System.SCREEN_X/2, 695, System.SCREEN_X, 50, Osd.CMD_INVALID);
			spotDn.activate(CMD_SHOW, Osd.CMD_INVALID);
			
			osd.setHandler(body);
			
			topLabel = osd.addLabel(System.SCREEN_X/2-100, 5, " ");
		
			addButton("BackupNormal.png", "BackupPrelight.png", CMD_ARCHIVE, "Архив");
			addButton("PreviewOneCh.png", "PreviewOneChPrelight.png", CMD_SINGLE, "Один экран");
			addButton("PreviewFourCh.png", "PreviewFourChPrelight.png", CMD_SPLIT, "4 экрана");
			addButton("PreviewAnalog.png", "PreviewAnalogPrelight.png", CMD_COLOR, "Установки цвета");
			addButton("PreviewZoom.png", "PreviewZoomPrelight.png", CMD_ZOOM, "Цифровое увеличение");
			addButton("PreviewVolume.png", "PreviewVolumePrelight.png", CMD_VOLUME, "Громкость");
			addButton("PreviewPtz.png", "PreviewPtzPrelight.png", CMD_PTZ, "PTZ");
			recBtn = addButton("PreviewRecord.png", "PreviewRecordPrelight.png", CMD_REC, "Старт записи");
			addButton("PreviewPlay.png", "PreviewPlayPrelight.png", CMD_PLAY, "Просмотр");
			addButton("InfoNormal.png", "InfoPrelight.png", CMD_INFO, "Информация");
			addButton("ExitActive.png", "ExitPreLight.png", CMD_LOGOUT, "Выход");
			
			guideBtn = osd.addImageButton(1230, 670, "EnabledUserGuideNormal.png", "EnabledUserGuidePrelight.png", "EnabledUserGuideNormal.png", CMD_GUIDE, "Подсказки вкл.");
			settingsBtn = osd.addImageButton(6, 682, "PreviewStart.png", "PreviewStartPre.png", "PreviewStart.png", CMD_SETTINGS);
			osd.setHandler(this);

			owner.addChild(this);
			
			stage.addEventListener(MouseEvent.CONTEXT_MENU, handleRightClick);
			activate();
			addEventListener(Event.ENTER_FRAME, handleEvent);
		}
		
		public function firstRun()
		{
			if (System.guideEnabled)
			{
				var p0:Popup = new Popup(System.top, System.osd, System.guide, UserGuide.ID_MAIN_TOOLBAR, 533, 543, 425, 100, "Часто используемые функции регистратора: резервное копирование, поиск записей, вызов PTZ пульта, кнопка старта экстренной записи, информация о состоянии устройства.");
				var p1:Popup = new Popup(System.top, System.osd, System.guide, UserGuide.ID_MAIN_DESIGN, 442, 235, 400, 100, "В основу нового интерфейса Safari положен принцип разделения базовых функций регистратора, постоянно используемых в работе и его настроек, которые можно вызвать, нажав кнопку 'Меню'.");
				var p2:Popup = new Popup(System.top, System.osd, System.guide, UserGuide.ID_MAIN_STARTUP, 52, 583, 350, 60, "Нажмите на кнопку, чтобы вызвать меню настроек регистратора.");
				var p3:Popup = new Popup(System.top, System.osd, System.guide, UserGuide.ID_GUIDEBTN, 1240, 583, 325, 60, "Нажмите на кнопку снизу, чтобы скрыть подсказки.");
				System.guide.extend([p0, p1, p2, p3]);
			}
		}
		
		public function launchWizard()
		{
			System.manager.showOsd(false);
			deactivate();
			new WizardDialog(root, osd).setCaller(this);
		}
		
		public function loginCheck(c:int):Boolean
		{
			if (!System.userLoggedIn)
			{
				deactivate();
				loginDialog = new LoginDialog(stage, osd, c);
				loginDialog.setCaller(this);
				return false;
			}
			
			return true;
		}
		
		public function refreshTopLabel()
		{
			dateObject = new Date();

			var result:String = new String();

			result += Convertor.dateToString(dateObject);
			result += " ";
			result = result +  Convertor.getDouble(dateObject.getHours()) + ":" + Convertor.getDouble(dateObject.getMinutes()) + ":" + Convertor.getDouble(dateObject.getSeconds());
			
			topLabel.setText(result);
		}
		
		public function handleRightClick(e:MouseEvent):void
		{
			if (activated)
			{
				if (body.visible) hide();
				else show();
			}
		}
		
		public function handleEvent(e:Event):void
		{
			refreshTopLabel();
		}
		
		public function addButton(s0:String, s1:String, c:int, h:String):ImageButton
		{
			var btn = osd.addImageButton(btnPos.x, btnPos.y, s0, s1, s0, c, h);
			btnPos.x += btnDlt;
			return btn;
		}
		
		public function show()
		{
			if (!body.visible)
			{
				body.visible = true;
				settingsBtn.focus();
				addEventListener(Event.ENTER_FRAME, handleEvent);
			}
		}
		
		public function hide()
		{
			if (body.visible)
			{
				body.visible = false;
				removeEventListener(Event.ENTER_FRAME, handleEvent);
			}
		}
		
		public function activate(...args)
		{
			if (!activated)
			{
				show();
				stage.addEventListener(MouseEvent.CONTEXT_MENU, handleRightClick);
				activated = true;
				
				if (args && args[0]) osdCommand(args[0]); //CMD's coming from login window
			}
		}
		
		public function deactivate(...args)
		{
			if (activated)
			{
				hide();
				stage.removeEventListener(MouseEvent.CONTEXT_MENU, handleRightClick);
				activated = false;
			}
		}
		
		public function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_SHOW):
					if(activated) show();
					break;
					
				case(CMD_HIDE):
					if(activated) hide();
					break;
					
				case(CMD_ARCHIVE):
					if (loginCheck(cmd))
					{
						deactivate();
						archiveDialog = new ArchiveMainDialog(stage, osd);
						archiveDialog.setCaller(this);
					}
					break;
					
				case(CMD_SINGLE):
					if (loginCheck(cmd))
					{
						activate();
						channelDialog = new ChannelDialog(stage, osd);
						channelDialog.setCaller(this);
						channelDialog.setPos(-166, 289);
					}
					break;
					
				case(CMD_SPLIT):
					if (loginCheck(cmd))
					{
						System.manager.showOsd(true);
						activate();
						System.manager.selectChannel(System.CHANNELS);
					}
					break;
					
				case(CMD_VOLUME):
					if (loginCheck(cmd))
					{
						activate();
						volumeDialog = new VolumeDialog(stage, osd);
						volumeDialog.setCaller(this);
						volumeDialog.setPos(24, 289);
					}
					break;
					
				case(CMD_PTZ):
					if (loginCheck(cmd))
					{
						deactivate();
						ptzDialog = new PTZMainDialog(stage, osd);
						ptzDialog.setCaller(this);
						ptzDialog.setPos(0, 215);
					}
					break;

				case(CMD_REC):
					if (loginCheck(cmd))
					{
						System.manager.showOsd(true);
						activate();
						if (!recActive)
						{
							recActive = true;
							recBtn.updateHint("Стоп записи");
						}
						else
						{
							recActive = false;
							recBtn.updateHint("Старт записи");
						}
					}
					break;
					
				case(CMD_PLAY):
					if (loginCheck(cmd))
					{
						deactivate();
						playback = new Playback(stage, osd);
						playback.setCaller(this);
						playback.y += 20;
					}
					break;
					
				case(CMD_SETTINGS):
					if (loginCheck(cmd))
					{
						deactivate();
						settingsDialog = new SettingsDialog(stage, osd);
						settingsDialog.setCaller(this);
					}
					break;
					
				case(CMD_COLOR):
					if (loginCheck(cmd))
					{
						deactivate();
						colorDialog = new ColorDialog(stage, osd, System.actChannel);
						colorDialog.setCaller(this);
					}
					break;
					
				case(CMD_ZOOM):
					if (loginCheck(cmd))
					{
						deactivate();
						digitalZoom = new DigitalZoom(System.top, osd);
						digitalZoom.setCaller(this);
					}
					break;
					
				case(CMD_INFO):
					if (loginCheck(cmd))
					{
						deactivate();
						infoDialog = new InfoDialog(stage, osd);
						infoDialog.setCaller(this);
					}
					break;
					
				case(CMD_LOGOUT):
					if (System.userLoggedIn)
					{
						deactivate();
						logoutDialog = new LogoutDialog(stage, osd);
						logoutDialog.setCaller(this);
						show();
					}
					break;
				
				case(CMD_GUIDE):
					var st:Boolean = !System.guideEnabled;
					System.guideEnabled = st;
					if (!st)
					{
						guideBtn.setStyle("DisabledUserGuideNormal.png", "DisabledUserGuidePrelight.png", "DisabledUserGuideNormal.png");
						guideBtn.updateHint("Подсказки выкл.");
					}
					else
					{
						guideBtn.setStyle("EnabledUserGuideNormal.png", "EnabledUserGuidePrelight.png", "EnabledUserGuideNormal.png");
						guideBtn.updateHint("Подсказки вкл.");
					}
					break;
			}
		}
	}
}