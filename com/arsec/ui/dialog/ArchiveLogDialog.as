package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.geom.Point;
	
	public class ArchiveLogDialog extends Window
	{
		private static const CMD_LINKED		= 1; //hovering above text lines
		private static const CMD_ARCHIVE	= 200;
		private static const CMD_ASKCLEAR	= 201;
		private static const CMD_PURGELOG	= 202;
		
		private var logHolder:MovieClip;
		private var detLbl:TextLabel;
		private var logLines:Array;
		private var maxLines:int = 9;
		
		public function ArchiveLogDialog(ow:Object, o:Osd)
		{
			System.exclusiveRightClick = this;
			
			super(ow, o, defX, defY, 800, 468, 2, 80, true, true);
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			_osd.setHandler(body);

			var data:Array = new Array("Дата/Время", "Содержимое", "Просмотр");
			var xdlt:Array = new Array(0, 212, 181);
			gadX = defX - 334;
			gadY = defY - 197;
			for (var i:int = 0; i < data.length; i++)
			{
				gadX += xdlt[i];
				_osd.addLabel(gadX, gadY, data[i], Osd.COLOR_TEXT);
			}
			
			data = new Array("Первый", "Пред.", "След.", "Посл.");
			gadX = defX - 364;
			gadY = defY + 189;
			for (i = 0; i < data.length; i++)
			{
				_osd.addTextButton(gadX, gadY, data[i], Osd.CMD_INVALID, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
				gadX += 105;
			}
			
			System.textLine = System.TEXTLINE_LONG; //'long' text lines ON
			
			if (System.logStack.length)
			{
				logHolder = new MovieClip();
				body.addChild(logHolder);
				
				_osd.setHandler(logHolder);
				
				logLines = new Array();
				
				var lbPos:Point = new Point(defX-361, defY-156);
				var tlPos:Point = new Point(defX-190, defY-159);
				var sep:int = 38;
				
				for (i = 0; i < System.logStack.length; i++)
				{
					if (i < maxLines)
					{
						var e:LogEntry = System.logStack[i];

						logLines.push(_osd.addLabel(lbPos.x, lbPos.y, e.dateToString() + " " + e.timeToString(), Osd.COLOR_TEXT));
						
						var tl:TextLine = _osd.addTextLine(tlPos.x, tlPos.y, 240, [e.getDetails()], CMD_LINKED+i);
						tl.getHotspot().setLinkage(linkedHover);
						logLines.push(tl);
						
						lbPos.y += sep;
						tlPos.y += sep;
					}
					else i = System.logStack.length-1;
				}
			}
			
			_osd.setHandler(body);
			
			sep = 36;
			var dlt:int = 110;
			gadX = defX + 122;
			gadY = defY - 170;
			_osd.addLabel(gadX, gadY, "Тип", Osd.COLOR_TEXT);																			gadX += dlt;
			_osd.addListBox(gadX, gadY-3, 126, new Array("Все",  "Тревога", "Управление"));												gadY += sep; gadX -= dlt;
			_osd.addLabel(gadX, gadY, "Начало", Osd.COLOR_TEXT);																		gadX += dlt;
			_osd.addTextInput(gadX, gadY-3, 126, " ", Osd.CMD_INVALID, TextInput.FMT_DATE).setDateFormat(TextInput.DATE_YMD, false);	gadY += sep;
			_osd.addTextInput(gadX, gadY-3, 126, "00:00:00", Osd.CMD_INVALID, TextInput.FMT_TIME);										gadY += sep; gadX -= dlt;
			_osd.addLabel(gadX, gadY, "Окончание", Osd.COLOR_TEXT);																		gadX += dlt;
			_osd.addTextInput(gadX, gadY-3, 126, " ", Osd.CMD_INVALID, TextInput.FMT_DATE).setDateFormat(TextInput.DATE_YMD, false);	gadY += sep;
			_osd.addTextInput(gadX, gadY-3, 126, "23:59:59", Osd.CMD_INVALID, TextInput.FMT_TIME);

			System.textLine = System.TEXTLINE_NORMAL;  //'long' text lines OFF
			
			data = new Array("Поиск", "Архив", "Сброс");
			gadX = defX + 122;
			gadY = defY + 16;
			for (i = 0; i < data.length; i++)
			{
				var c:int = Osd.CMD_INVALID;
				if (i == 1) c = CMD_ARCHIVE;
				if (i == 2) c = CMD_ASKCLEAR;
				
				_osd.addTextButton(gadX, gadY, data[i], c, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT); gadX += 85;
			}
			
			gadX = defX + 122;
			gadY = defY + 58;
			_osd.addLabel(gadX, gadY, "Детали", Osd.COLOR_TEXT);

			gadY += 45;
			detLbl = _osd.addLabel(gadX, gadY, " ", Osd.COLOR_TEXT);
			
			_osd.setHandler(this);
		}
		
		public function linkedHover(foc:Boolean, c:int)
		{
			if (!foc)
			{
				if(detLbl) detLbl.setText(System.logStack[c-1].getFullDetails());
				detLbl.setWidth(233);
				detLbl.setMultiline();
			}
			else detLbl.setText(" ");
		}
		
		public override function finalize()
		{
			System.exclusiveRightClick = null;
			caller.activate(); //this will show up archive main window
			super.finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_ARCHIVE):
					new MessageDialog(body, _osd, "Выберите файлы для архивации!");
					break;
					
				case(CMD_ASKCLEAR):
					new YesNoDialog(body, _osd, this, "Вы уверены, что хотите очистить лог?", CMD_PURGELOG);
					break;
					
				case(CMD_PURGELOG):
					System.logStack = new Array();
					body.removeChild(logHolder);
					break;
			}
		}
	}
}