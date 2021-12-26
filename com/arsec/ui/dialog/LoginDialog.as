package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class LoginDialog extends Window
	{
		private static const CMD_LOGIN:int = 0;
		
		private var devID:TextInput;
		private var userLBox:ListBox;
		private var passTInput:TextInput;
		private var callback:int = Osd.CMD_INVALID;
		private var userName:String = "admin";
		
		public function LoginDialog(ow:Object, o:Osd, c:int)
		{
			System.manager.showOsd(false);
			
			super(ow, o, defX, defY, 420, 216, 2, 52, true, true);
			callback = c;
			
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			_osd.setHandler(body);
			
			gadX = defX-166;
			gadY = defY-54;
			_osd.addLabel(gadX, gadY, "ID устройства"); gadY += sepLbl;
			_osd.addLabel(gadX, gadY, "Имя"); gadY += sepLbl;
			_osd.addLabel(gadX, gadY, "Пароль");
			
			gadX = defX-32;
			gadY = defY - 58;
			devID = _osd.addTextInput(gadX, gadY, 178, "0", Osd.CMD_INVALID, TextInput.FMT_DIGITAL, 99999999, 8); gadY += sepTInput;
			
			var scr:int;
			if (System.users.length > 5) scr = 5;
			
			var names:Array = new Array();
			for (var i:int = 0; i < System.users.length; i++) names.push(System.users[i].getName());
			
			userLBox = _osd.addListBox(gadX, gadY, 178, names, scr);
			gadY += sepTInput;
			
			passTInput = _osd.addTextInput(gadX, gadY, 178, " ", Osd.CMD_INVALID, TextInput.FMT_PASSWORD); gadY += sepTInput*1.2;
			_osd.addTextButton(gadX + 103, gadY, "Вход", CMD_LOGIN);
			
			_osd.setHandler(this);
		}
		
		public override function finalize()
		{
			if(!System.userLoggedIn) System.manager.showOsd(true); //login canceled by user
			super.finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_LOGIN):
					var did:int = new int(devID.getValue());
					var str:String = new String();
					
					if (did != 0) str = "ID устройства введено неверно!";
					else
					{
						if (passTInput.getValue() != System.users[userLBox.getValue()].getPassword()) str = "Имя или пароль неверны!";
					}
					
					if(!str.length)
					{
						System.curUserID = userLBox.getValue();
						System.userLogin(true);
						caller.activate(callback);
						finalize();
					}
					else
					{
						new MessageDialog(body, _osd, str);
						System.userName = null;
						System.userLoggedIn = false;
					}
					break;
			}
		}
	}
}