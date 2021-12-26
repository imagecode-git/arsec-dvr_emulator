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
	
	public class OSDSetDialog extends Window
	{
		private static const CMD_OK:int		= 0;
		private static const CMD_SETCH:int	= 1;
		private static const CMD_OPTION:int	= 2;
		
		private var chList:ListBox;
		private var opCBox:Array;
		
		private var curChannel:int;
		private var retChannel:int;
		
		private var topLabel:TextLabel;
		
		public function OSDSetDialog(ow:Object, o:Osd, ch:int)
		{
			System.manager.showOsd(true);
			
			retChannel = System.actChannel;
			curChannel = ch;
			
			super(ow, o, defX, defY, 249, 239, 2, 50, true, true);
			
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;

			_osd.setHandler(System.manager); //we place label inside the object outside the gadget to prevent sync movement when attepmting to drag window
			topLabel = _osd.addLabel(defX-97, 15, " ", Osd.COLOR_SELECTED, TextLabel.TYPE_LARGE);
			_osd.setHandler(body);

			var sep:int = 51;
			var data:Array = new Array("Канал", "OSD время", "OSD имя камеры");
			
			opCBox = new Array();
			gadX = defX-107;
			gadY = defY-76;
			
			for (var i:int = 0; i <data.length; i++)
			{
				_osd.addLabel(gadX, gadY, data[i]);

				if (i == 0)
				{
					System.textLine = System.TEXTLINE_LONG; //'long' text lines ON
					
					var val:int = curChannel+1;
					if (curChannel == System.CHANNELS) val = 0;
			
					chList = _osd.addListBox(gadX+105, gadY-3, 94, new Array("Все", "1", "2", "3", "4"), 0, false, CMD_SETCH);
					chList.selectItem(val);
					
					System.textLine = System.TEXTLINE_NORMAL; //'long' text lines OFF
				}
				else opCBox.push(_osd.addCheckBox(gadX+165, gadY+10, CMD_OPTION+i-1));
				
				gadY += sep;
			}
			
			gadX = defX-118;
			gadY = defY+82;
			_osd.addTextButton(gadX, gadY, "По умолчанию", Osd.CMD_INVALID, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);	gadX += 135;
			_osd.addTextButton(gadX, gadY, "Применить", CMD_OK, TextLabel.TYPE_LARGE, Osd.COLOR_TEXT);
			
			_osd.setHandler(this);
			
			osdCommand(CMD_OPTION); //activate time/date label update
			System.manager.muteChannel(curChannel, true);
			System.manager.selectChannel(curChannel);
		}
		
		public function refreshTopLabel()
		{
			if (topLabel.visible)
			{
				var dateObject:Date = new Date();

				var result:String = new String();

				result += Convertor.dateToString(dateObject);
				result += " ";
				result = result +  Convertor.getDouble(dateObject.getHours()) + ":" + Convertor.getDouble(dateObject.getMinutes()) + ":" + Convertor.getDouble(dateObject.getSeconds());
				
				topLabel.setText(result);
			}
		}
		
		public override function finalize()
		{
			if (opCBox[0].checked) removeEventListener(Event.ENTER_FRAME, handleEvent);
			topLabel.finalize();
			
			if(System.actChannel != retChannel) System.manager.selectChannel(retChannel);
			System.manager.showOsd(false);
			System.manager.muteChannel(retChannel, false);
			
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
					if (ch != curChannel) System.manager.muteChannel(curChannel, false);
					if (ch > 0) curChannel = ch-1;
					else curChannel = 4;
					
					System.manager.selectChannel(curChannel);
					System.manager.muteChannel(curChannel, true);
					
					break;
				
				case(CMD_OPTION):
					if (opCBox[0].checked)
					{
						topLabel.show();
						addEventListener(Event.ENTER_FRAME, handleEvent);
					}
					else
					{
						topLabel.hide();
						removeEventListener(Event.ENTER_FRAME, handleEvent);
					}
					
					break;
					
				case(CMD_OPTION+1):
					System.manager.showOsd(opCBox[1].checked);
					break;
			}
		}
		
		public function handleEvent(e:Event):void
		{
			refreshTopLabel();
		}
	}
}