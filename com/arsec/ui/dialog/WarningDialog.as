package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class WarningDialog extends Window
	{
		private static const CMD_OK:int = 0;
		
		private var message:String = "Message";
	
		public function WarningDialog(ow:Object, o:Osd, msg:String)
		{
			super(ow, o, defX, defY, 396, 136, 2, 52, false, true);
			message = msg;
			
			body.blendMode = BlendMode.LAYER;
			
			_osd.setHandler(body);
			
			gadX = defX-114;
			gadY = defY-21;
			_osd.addLabel(gadX, gadY, message); gadY += sepLbl * 2;
			
			gadX = defX - 147;
			gadY = defY - 31;
			_osd.addImage(gadX, gadY, "warning.png");
			
			gadX = defX - 15;
			gadY = defY + 33;
			_osd.addTextButton(gadX, gadY, "OK", CMD_OK);
			
			_osd.setHandler(this);
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