package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class MessageDialog extends Window
	{
		private static const CMD_OK:int = 0;
		
		private var backupWnd:Window;
		private var message:String = "Message";
	
		public function MessageDialog(ow:Object, o:Osd, msg:String)
		{
			super(ow, o, defX, defY, 400, 140, 2, 52, false, true);
			message = msg;
			
			body.blendMode = BlendMode.LAYER;
			
			_osd.setHandler(body);
			
			gadX = defX-166;
			gadY = defY-32;
			_osd.addLabel(gadX, gadY, message).setMultiline(); gadY += sepLbl*2;
			
			gadX = defX-15;
			_osd.addTextButton(gadX, gadY, "OK", CMD_OK);
			
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
					break;
			}
		}
	}
}