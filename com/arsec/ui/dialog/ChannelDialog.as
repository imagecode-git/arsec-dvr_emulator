package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class ChannelDialog extends Window
	{
		private static const CMD_CH = 0;
		
		private var switches:Array;
		
		public function ChannelDialog(ow:Object, o:Osd)
		{
			System.manager.showOsd(true);
			
			super(ow, o, defX, defY, 258, 30, 2, 16, true, true);
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			_osd.setHandler(body);
			_osd.addLabel(defX - 127, defY - 11, "Канал", Osd.COLOR_TEXT);
			
			switches = new Array();
			gadX = defX - 62;
			gadY = defY;
			for (var i:int = 0; i < System.CHANNELS; i++)
			{
				var cb:CheckBox = _osd.addCheckBox(gadX, gadY, CMD_CH + i, new String(i + 1)); gadX += 49;
				if (i == System.actChannel) cb.check();
				else cb.uncheck();
				
				switches.push(cb);
			}
			
			_osd.setHandler(this);
		}
		
		public override function finalize()
		{
			if (caller)
			{
				System.manager.showOsd(true);
				caller.deactivate();
				caller.activate(0); //CMD_SHOW in main menu
			}
			super.finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			if (cmd >= CMD_CH && cmd < CMD_CH + System.CHANNELS)
			{
				var id:int = cmd - CMD_CH;
				var checked:int = 0;
				for (var i:int = 0; i < switches.length; i++)
				{
					if (i != id) switches[i].uncheck();
					if (switches[i].checked) checked++;
				}
				
				if (checked > 0) System.manager.selectChannel(id);
				else System.manager.selectChannel(System.CHANNELS); //show all
			}
			
			if(cmd == CMD_CLOSE) finalize();
		}
	}
}