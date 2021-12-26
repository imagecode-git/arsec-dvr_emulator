package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class ColorDialog extends Window
	{
		private static const CMD_OK:int		= 0;
		private static const CMD_SETCH:int	= 1;
		private static const CMD_SLIDER:int	= 2;
		
		private var chList:ListBox;
		private var lbl:Array;
		private var defaults:Array;
		
		private var curChannel:int;
		private var retChannel:int;
		private var vals:Array;
		private var sliders:Array;
		
		private var preserveOsd:Boolean = false;
		
		public function ColorDialog(ow:Object, o:Osd, ch:int, ...args)
		{
			System.manager.showOsd(false);
			
			curChannel = ch;
			retChannel = System.actChannel;
			
			if (args && args.length) preserveOsd = args[0];
			
			super(ow, o, defX, defY, 284, 342, 2, 52, true, true);
			
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			defaults = new Array(30, 37, 32, 29);
			vals = new Array();
			for (var i:int = 0; i < 5; i++)
			{
				var temp:Array = new Array();
				for (var j:int = 0; j < defaults.length; j++) temp.push(new int(defaults[j]));
				vals.push(temp);
			}
			
			_osd.setHandler(body);
			
			gadX = defX-121;
			gadY = defY-125;
			_osd.addLabel(gadX, gadY, "Канал"); gadX += 100;
			
			var val:int = curChannel+1;
			if (curChannel == System.CHANNELS) val = 0;
			
			System.textLine = System.TEXTLINE_LONG; //'long' text lines ON
			chList = _osd.addListBox(gadX, gadY - 3, 94, new Array("Все", "1", "2", "3", "4"), 0, false, CMD_SETCH);
			chList.selectItem(val);
			System.textLine = System.TEXTLINE_NORMAL; //'long' text lines OFF
			
			var ct:Array = new Array("Ярк", "Кон", "Цвет", "Нас");
			var sep:int = 35;
			gadX = defX-101;
			gadY = defY - 84;
			
			for (i = 0; i < ct.length; i++)
			{
				_osd.addLabel(gadX, gadY, ct[i]); gadY += sep;
			}
			
			lbl = new Array();
			gadX = defX + 106;
			gadY = defY - 83;
			for (i = 0; i < 4; i++)
			{
				var lb:TextLabel = _osd.addLabel(gadX, gadY, "00", Osd.COLOR_TEXT);
				lbl.push(lb);
				gadY += sep;
			}
			
			sliders = new Array();
			gadX = defX - 32;
			gadY = defY - 75;
			for (i = 0; i < 4; i++)
			{
				sliders.push(_osd.addSlider(gadX, gadY, 137, 3, 0, 63, CMD_SLIDER + i, defaults[i], lbl[i]));
				gadY += sep+1;
			}
			
			var pc:Array = new Array("BrightnessNormal.png", "ContrastNormal.png", "ColorNormal.png", "SaturationNormal.png");
			gadX = defX - 130;
			gadY = defY - 87;
			for (i = 0; i < 4; i++)
			{
				_osd.addImage(gadX, gadY, pc[i]);
				gadY += sep;
			}
			
			gadX = defX-123;
			gadY = defY+133;
			_osd.addTextButton(gadX, gadY, "По умолчанию", Osd.CMD_INVALID, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);	gadX += 140;
			_osd.addTextButton(gadX, gadY, "Применить", CMD_OK, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);
			
			_osd.setHandler(this);
			
			System.manager.selectChannel(curChannel);
		}
		
		public override function finalize()
		{
			if(System.actChannel != retChannel) System.manager.selectChannel(retChannel);
			if(!preserveOsd) System.manager.showOsd(true);
			if(caller) caller.osdCommand(Osd.CMD_GAD_UPDATE);
			
			super.finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_OK):
					caller.activate();
					finalize();
					break;
					
				case(CMD_SETCH):
					var ch:int = chList.getValue();
					if (ch > 0) curChannel = ch - 1;
					else curChannel = 4;
					
					System.manager.selectChannel(curChannel);
					
					for (var k:int = 0; k < sliders.length; k++)
					{
						sliders[k].setValue(vals[curChannel][k]);
						lbl[k].setText(new String(vals[curChannel][k]));
					}
					break;
			}
			
			if (cmd >= CMD_SLIDER && cmd <= CMD_SLIDER + 4)
			{
				var id:int = cmd - CMD_SLIDER;
				
				if (curChannel < 4) vals[curChannel][id] = sliders[id].getValue();
				else
				{
					for (var i:int = 0; i < 5; i++)
					{
						for (var j:int = 0; j < sliders.length; j++) vals[i][j] = sliders[j].getValue();
					}
				}
			}
		}
	}
}