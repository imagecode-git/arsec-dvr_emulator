package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class YesNoDialog extends Window
	{
		private static const CMD_OK:int		= 0;
		private static const CMD_CANCEL:int	= 1;
		
		private var backupWnd:Window;
		private var exec:int;
		private var message:String = "Message";
	
		public function YesNoDialog(ow:Object, o:Osd, c:Object, msg:String, e:int)
		{
			super(ow, o, defX, defY, 400, 140, 2, 52, false, true);
			caller = c;
			message = msg;
			exec = e;
			
			body.blendMode = BlendMode.LAYER;
			
			_osd.setHandler(body);
			
			gadX = defX-166;
			gadY = defY-32;
			_osd.addLabel(gadX, gadY, message).setMultiline(); gadY += sepLbl*2;
			
			gadX = defX-68;
			_osd.addTextButton(gadX, gadY, "Да", CMD_OK);
			
			gadX = defX+38;
			_osd.addTextButton(gadX, gadY, "Нет", CMD_CANCEL);
			
			_osd.setHandler(this);
			
			if (System.exclusiveRightClick) backupWnd = System.exclusiveRightClick;
			System.exclusiveRightClick = this;
		}
		
		public override function finalize()
		{
			if (backupWnd) System.exclusiveRightClick = backupWnd;
			else System.exclusiveRightClick = null;
			
			super.finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_OK):
					finalize();
					if (caller) caller.osdCommand(exec);
					break;
					
				case(CMD_CANCEL):
					finalize();
					break;
			}
		}
	}
}