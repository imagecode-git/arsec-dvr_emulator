package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.util.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class MaskSetDialog extends Window
	{
		private static const CMD_OK:int		= 0;
		private static const CMD_SETCH:int	= 1;
		private static const CMD_RESET:int	= 2;
		
		private var chList:ListBox;
		
		private var curChannel:int;
		private var retChannel:int;
		
		private var maskman:MaskManager;
		
		public function MaskSetDialog(ow:Object, o:Osd, ch:int)
		{
			System.manager.showOsd(false);
			maskman = new MaskManager(System.masks);
			
			retChannel = System.actChannel;
			curChannel = ch;
			
			super(ow, o, defX, defY, 232, 201, 2, 52, true, true);
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;

			_osd.setHandler(body);

			System.textLine = System.TEXTLINE_LONG; //'long' text lines ON
			
			var data:Array = new Array();
			for (var i:int = 0; i < System.CHANNELS; i++) data.push(new String(i+1));
					
			var val:int = curChannel;
			
			gadX = defX-98;
			gadY = defY-57;
			_osd.addLabel(gadX, gadY, "Канал"); gadX += 70;
			
			chList = _osd.addListBox(gadX, gadY-3, 94, data, 0, false, CMD_SETCH);
			chList.selectItem(val);
					
			System.textLine = System.TEXTLINE_NORMAL; //'long' text lines OFF

			gadX = defX-83;
			gadY = defY+64;
			_osd.addTextButton(gadX, gadY, "Сброс", CMD_RESET, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);	gadX += 73;
			_osd.addTextButton(gadX, gadY, "Применить", CMD_OK, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);
			
			_osd.setHandler(this);
			
			locker.hide();
			System.manager.selectChannel(curChannel);
			maskman.setChannel(curChannel);
		}
		
		public override function finalize()
		{
			if(System.actChannel != retChannel) System.manager.selectChannel(retChannel);
			maskman.finalize();
			locker.finalize();
			
			if(caller) caller.osdCommand(Osd.CMD_GAD_UPDATE);
			
			super.finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_OK):
					finalize();
					break;
					
				case(CMD_SETCH):
					var ch:int = chList.getValue();
					curChannel = ch;
					
					System.manager.selectChannel(curChannel);
					maskman.setChannel(curChannel);
					break;
				
				case(CMD_RESET):
					maskman.reset(curChannel);
					break;
			}
		}
	}
}