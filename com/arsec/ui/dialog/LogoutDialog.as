package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class LogoutDialog extends Window
	{
		private static const CMD_OK:int = 0;
		private static const CMD_CANCEL:int = 1;
	
		public function LogoutDialog(ow:Object, o:Osd)
		{
			super(ow, o, defX, defY, 400, 140, 2, 52, false, true);
			
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			_osd.setHandler(body);
			
			gadX = defX-150;
			gadY = defY-28;
			_osd.addLabel(gadX, gadY, "Действительно выйти?"); gadY += sepLbl*2;
			
			gadX = defX - 68;
			gadY = defY + 36;
			_osd.addTextButton(gadX, gadY, "Да", CMD_OK); gadX += 106;
			_osd.addTextButton(gadX, gadY, "Нет", CMD_CANCEL);
			
			_osd.setHandler(this);
		}
		
		public override function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_OK):
					System.curUserID = 0;
					System.userLogin(false);
					
					caller.activate();
					caller.hide();
					finalize();
					break;
					
				case(CMD_CANCEL):
					caller.activate();
					finalize();
					break;
			}
		}
	}
}