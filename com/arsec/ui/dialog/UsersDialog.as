package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.geom.Point;
	
	public class UsersDialog extends Window
	{
		private static const CMD_NAV:int			= 0;
		private static const CMD_RGSELECTALL:int	= 2;
		private static const CMD_RGRESET:int		= 3;
		private static const CMD_INPUT:int			= 5;
		private static const CMD_TAB:int			= 10;
		private static const CMD_RIGHTS:int			= 20;
		private static const CMD_RGMASTER:int		= 30;
		
		public static const MODE_EDIT:int	= 0;
		public static const MODE_ADD:int	= 1;
		
		private var tabs:Array;
		private var bar:TabBar;
		
		private var mode:int = MODE_EDIT;
		private var user:User;
		private var userID:int;
		private var userAdded:Boolean;
		
		private var cbx:Array;
		private var macCBox:CheckBox;
		private var textInput:Array;
		private var options:int = 0;
		
		public function UsersDialog(ow:Object, o:Osd, m:int, ...args)
		{
			System.exclusiveRightClick = this;
			super(ow, o, defX, defY, 685, 429, 2, 55, true, true);
			
			mode = m;
			if (args && args.length)
			{
				userID = args[0];
				user = System.users[userID]; //user is not required with MODE_EDIT
			}
			
			tabs = new Array();
			
			body.blendMode = BlendMode.LAYER;
			
			_osd.setHandler(body);
			
			bar = new TabBar(body, _osd, 650, 30, TabBar.TYPE_NORMAL, 0, 2);
			bar.addButton(97, "Основные", CMD_TAB);
			bar.addButton(120, "Права", CMD_TAB+1);
			bar.setPos(new Point(defX-323, defY-145));
			bar.setSelection(0);
			body.addChild(bar);
			
			tabs.push(new MovieClip());
			body.addChild(tabs[0]);
			_osd.setHandler(tabs[0]);
			//----------------------------------------------------TAB 0
			var data:Array = new Array("Имя", "Пароль", "Подтверждение пароля", "Тип пользователя", "Привязка к MAC-адресу", "MAC");
			var sep:int = 32;
			
			gadX = defX-256;
			gadY = defY-99;
			for (var i:int = 0; i < data.length; i++)
			{
				_osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT);
				gadY += sep;
			}
			
			var uname:String = " ";
			var upass:String = " ";
			var ut:String = User.getDefType();
			var umc:String = "00:00:00:00:00:00";
			var uml:Boolean = false;
			
			if (mode != MODE_ADD)
			{
				uname = user.getName();
				upass = user.getPassword();
				ut = user.typeToString();
				umc = user.getMAC();
				uml = user.hasLinkedMAC();
			}
			
			var fmt:int = TextInput.FMT_DEFAULT;
			textInput = new Array();
			
			gadX = defX+7;
			gadY = defY-102;
			for (i = 0; i < 3; i++)
			{	
				if (i > 0) fmt = TextInput.FMT_PASSWORD;
				var str:String = new String();
				switch(i)
				{
					case(0):
						str = uname;
						break;
						
					case(1):
						str = upass;
						break;
						
					case(2):
						str = upass;
						break;
				}
				
				textInput.push(_osd.addTextInput(gadX, gadY, 268, str, CMD_INPUT, fmt));
				gadY += sep;
			}
			
			_osd.addLabel(gadX-3, gadY+3, ut, Osd.COLOR_TEXT);
			gadY += sep;
			
			macCBox = _osd.addCheckBox(gadX+7, gadY+13, Osd.CMD_INVALID);	gadY += sep;
			if (!uml) macCBox.uncheck();
			
			textInput.push(_osd.addTextInput(gadX, gadY, 268, umc, CMD_INPUT, TextInput.FMT_MAC));
			textInput[textInput.length-1].disable(); //enable back when MAC input will be done!
			
			var dlt:Array = new Array(54, 131);
			data = new Array("Применить", "Выход");
			
			gadX = defX;
			gadY = defY+167;
			for (i = 0; i < data.length; i++)
			{
				gadX += dlt[i];
				_osd.addTextButton(gadX, gadY, data[i], CMD_NAV+i, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);
			}

			tabs.push(new MovieClip());
			body.addChild(tabs[1]);
			_osd.setHandler(tabs[1]);
			//----------------------------------------------------TAB 1
			wndScroller = _osd.addScroller(defX+315, defY-110, 4, 228, 8, 17); //handled by superclass
			
			data = new Array("Основные", "", "", "Дополнительно", "", "", "Просмотр", "", "", "Архив", "", "", "Удал. контроль", "", "", "");
			
			scrollPageSize = 8;
			scrollLines = new Array();
			for (i = 0; i <= data.length; i++)
			{
				scrollLines.push(new MovieClip());
				tabs[1].addChild(scrollLines[i]);
			}
			
			//----------------------------------------LABELS
			var clearLn:int = 0;
			
			gadX = defX-58;
			gadY = defY-121;
			for (i = 0; i < data.length; i++)
			{
				if (clearLn == 3) clearLn = 0;
				
				_osd.setHandler(scrollLines[i]);
				if (!clearLn) _osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT, TextLabel.TYPE_LARGE);
				
				clearLn++;
			}
			
			//----------------------------------------CHECKBOXES
			var oplist:Array = new Array();
			options = 6;
			cbx = new Array();
			for (i = 0; i < options; i++)
			{
				oplist.push(new Array());
				cbx.push(new Array());
			}
			
			oplist[0] = ["Система", "Дата/время", "Дисплей", "Запись"];
			oplist[1] = ["Тревога", "Сеть", "COMM", "PTZ"];
			
			for (i = 0; i < System.CHANNELS; i++)
			{
				str = "Кан" + new String(i+1);
				for (var j:int = 0; j < 3; j++) oplist[2+j].push(str);
			}

			oplist[5] = ["Диск", "PTZ контроль", "Лог"];
			
			for (i = 0; i < oplist.length; i++) oplist[i].unshift("Все");
			dlt = [0, 74, 127, 128, 127];
			
			var option:int = 0;
			var xpos:Number = defX-304;
			for (i = 1; i < data.length; i++)
			{
				_osd.setHandler(scrollLines[i]);

				var len:int = oplist[option].length;
				if (i == data.length-1) len--;
				
				gadX = xpos;
				for (j = 0; j < len; j++)
				{
					var c:int = CMD_RIGHTS+option;
					if (j == 0) c = CMD_RGMASTER+option;
					
					cbx[option].push(_osd.addCheckBox(gadX += dlt[j]+7, gadY+13, c, oplist[option][j]));
				}
			
				i+=2;
				option++;
			}
			
			_osd.setHandler(scrollLines[scrollLines.length-2]);
			for (j = 0; j < oplist[5].length; j++)
			{
				if (j == 0) c = CMD_RGMASTER+option;
				else c = CMD_RIGHTS+option;
				
				cbx[5].push(_osd.addCheckBox(xpos += dlt[j]+7, gadY+13, c, oplist[5][j]));
			}
			
			if (mode == MODE_EDIT) setRights(user.getUserRights());
			
			_osd.setHandler(tabs[1]);
			
			dlt = [-23, 98, 71, 118];
			data = new Array("Сброс", "Все", "Применить", "Выход");
			
			var arr:Array = new Array(CMD_RGRESET, CMD_RGSELECTALL, CMD_NAV, CMD_NAV+1);
			
			gadX = defX;
			gadY = defY+167;
			for (i = 0; i < data.length; i++)
			{
				gadX += dlt[i];
				_osd.addTextButton(gadX, gadY, data[i], arr[i], TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);
			}
			
			scrollSeparator = 32;
			scrollPivot = scrollLines[0].y;
			scrollTo(0);
			
			tabs[1].visible = false;
			
			_osd.setHandler(this);
		}
		
		public function getRights():Array
		{
			var result:Array = new Array();
			
			for (var i:int = 0; i < options; i++)
			{
				result.push(new Array());
				for (var j:int = 1; j < cbx[i].length; j++)
				{
					result[i].push(cbx[i][j].checked);
				}
			}
			
			return result;
		}
		
		public function setRights(arr:Array)
		{
			for (var i:int = 0; i < arr.length; i++)
			{
				for (var j:int = 0; j < arr[i].length; j++)
				{
					var bool:Boolean = arr[i][j];
					if (bool) cbx[i][j+1].check();
					else cbx[i][j+1].uncheck();
				}
			}
			
			for (i = 0; i < arr.length; i++) osdCommand(CMD_RIGHTS+i); //this will auto-check master checkboxes
		}
		
		public override function finalize()
		{
			System.exclusiveRightClick = null;
			if (caller) caller.updateUserList();
			super.finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			if (cmd >= CMD_RIGHTS && cmd <= CMD_RIGHTS+options)
			{
				var t:int = cmd-CMD_RIGHTS;
				var chk:int = 0;
				for (i = 1; i < cbx[t].length; i++)
				{
					if (cbx[t][i].checked) chk++;
				}
				
				if (chk == cbx[t].length-1) cbx[t][0].check();
				else cbx[t][0].uncheck();
			}
			
			if (cmd >= CMD_RGMASTER && cmd <= CMD_RGMASTER+options)
			{
				t = cmd - CMD_RGMASTER;
				if (cbx[t][0].checked)
				{
					for (i = 0; i < cbx[t].length; i++) cbx[t][i].check();
				}
				else
				{
					for (i = 0; i < cbx[t].length; i++) cbx[t][i].uncheck();
				}
			}
					
			switch(cmd)
			{
				case(CMD_TAB):
					tabs[0].visible = true;
					tabs[1].visible = false;
					bar.setSelection(0);
					break;
					
				case(CMD_TAB+1):
					tabs[0].visible = false;
					tabs[1].visible = true;
					bar.setSelection(1);
					break;
					
				case(CMD_RGRESET):
					for (var i:int = 0; i < options; i++)
					{
						for (var j:int = 0; j < cbx[i].length; j++) cbx[i][j].uncheck();
					}
					break;
					
				case(CMD_RGSELECTALL):
					for (i = 0; i < options; i++)
					{
						for (j = 0; j < cbx[i].length; j++) cbx[i][j].check();
					}
					break;
						
				case(CMD_NAV): //apply button
					var error:String;
					var vl:Array = new Array();
					for (i = 0; i < textInput.length; i++) vl.push(textInput[i].getValue());
					
					if (vl[0] == " ") error = "Имя неверно, повторите ввод.";
					if (vl[1] != vl[2]) error = "Пароль неверен, повторите ввод.";
					if (vl[1] == " " || vl[2] == " ")
					{
						if (userID > 0 || mode == MODE_ADD) error = "Пароль неверен, повторите ввод.";
					}
					
					if (!error)
					{
						if (mode == MODE_ADD) user = new User(vl[0], vl[1], User.TYPE_NORMAL, vl[3], macCBox.checked, getRights());
						else
						{
							user.updateName(vl[0]);
							user.updatePassword(vl[1]);
							user.updateMAC(vl[3], macCBox.checked);
							user.updateRights(getRights());
						}
						
						if (mode != MODE_ADD) System.users[userID] = user;
						else
						{
							if (!userAdded)
							{
								System.users.push(user);
								userAdded = true;
							}
						}
						
						System.log("Изм. настроек пользователя");
						new MessageDialog(body, _osd, "Сохранение выполнено.");
					}
					else new MessageDialog(body, _osd, error);
					break;
					
				case(CMD_NAV+1): //exit button
					finalize();
					break;
			}
	
			super.osdCommand(cmd); //forces scroller to work
		}
	}
}