package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class ArchiveMainDialog extends Window
	{
		private static const CMD_TIME	= 0;
		private static const CMD_EVENTS	= 1;
		private static const CMD_LOG	= 2;
		private static const CMD_EXIT	= 3;
		
		public function ArchiveMainDialog(ow:Object, o:Osd)
		{
			System.manager.showOsd(false);
			
			super(ow, o, defX, defY, 198, 176, 2, 50, true, true);
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			_osd.setHandler(body);

			var sep:int = 35;
			gadX = defX - 67;
			gadY = defY - 65;
			_osd.addTextButton(gadX, gadY, "Поиск по времени", CMD_TIME, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);	gadX -= 2;	gadY += sep;
			_osd.addTextButton(gadX, gadY, "Поиск по событию", CMD_EVENTS, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);	gadX += 17;	gadY += sep;
			_osd.addTextButton(gadX, gadY, "Поиск по логу", CMD_LOG, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);		gadX += 24;	gadY += 48;
			_osd.addTextButton(gadX, gadY, "Выход", CMD_EXIT, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);
			
			_osd.setHandler(this);
		}
		
		public override function finalize()
		{
			System.manager.showOsd(true);
			super.finalize();
		}
		
		public override function pressRight()
		{
			if (body.visible) super.pressRight(); //implementing standard action for right click, if there is no window above
		}
		
		public override function activate(...args):void
		{
			if (!body.visible) body.visible = true;
			super.activate();
		}
		
		public override function deactivate(...args):void
		{
			if (body.visible) body.visible = false;
			super.deactivate();
		}
		
		public override function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_TIME):
					deactivate();
					new ArchiveTimeDialog(caller, _osd).setCaller(this);
					break;
					
				case(CMD_EVENTS):
					deactivate();
					new ArchiveEventsDialog(caller, _osd).setCaller(this);
					break;
					
				case(CMD_LOG):
					deactivate();
					new ArchiveLogDialog(caller, _osd).setCaller(this);
					break;
					
				case(CMD_EXIT):
					caller.activate();
					finalize();
					break;
			}
		}
	}
}