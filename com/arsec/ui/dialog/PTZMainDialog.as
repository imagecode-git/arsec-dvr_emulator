package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class PTZMainDialog extends Window
	{
		private var sldLabel:TextLabel;
		
		public function PTZMainDialog(ow:Object, o:Osd)
		{
			System.manager.showOsd(false);
			
			super(ow, o, defX, defY, 498, 266, 2, 50, true, true);
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			_osd.setHandler(body);
			
			System.textLine = System.TEXTLINE_LONG; //'long' text lines ON
			
			gadX = defX - 230;
			gadY = defY - 102;
			_osd.addLabel(gadX, gadY, "Канал", Osd.COLOR_TEXT); gadX += 71; gadY -= 2;
			_osd.addListBox(gadX, gadY, 94, new Array("Все", "1", "2", "3", "4"), 0, false, Osd.CMD_INVALID);
			
			_osd.addImage(defX-208, defY-65, "PTZBackground.png");
			_osd.addImageButton(defX - 165, defY - 22, "OKNormal.png", "OKActive.png", "OKPrelight.png", Osd.CMD_INVALID);
			
			gadX = defX - 139;
			gadY = defY - 59;
			_osd.addImageButton(gadX, gadY, "UpNormal.png", "UpActive.png", "UpPrelight.png", Osd.CMD_INVALID); 						gadY += 124;
			_osd.addImageButton(gadX, gadY, "DownNormal.png", "DownActive.png", "DownPrelight.png", Osd.CMD_INVALID);
			
			gadX = defX - 179;
			gadY = defY - 42;
			_osd.addImageButton(gadX, gadY, "LeftUpNormal.png", "LeftUpActive.png", "LeftUpPrelight.png", Osd.CMD_INVALID); 			gadX += 78; gadY += 3;
			_osd.addImageButton(gadX, gadY, "RightUpNormal.png", "RightUpActive.png", "RightUpPrelight.png", Osd.CMD_INVALID); 			gadX += 6; gadY += 79;
			_osd.addImageButton(gadX, gadY, "RightDownNormal.png", "RightDownActive.png", "RightDownPrelight.png", Osd.CMD_INVALID); 	gadX -= 88;
			_osd.addImageButton(gadX, gadY, "LeftDownNormal.png", "LeftDownActive.png", "LeftDownPrelight.png", Osd.CMD_INVALID); 		gadX -= 19; gadY -= 43;
			_osd.addImageButton(gadX, gadY, "LeftNormal.png", "LeftActive.png", "LeftPrelight.png", Osd.CMD_INVALID); 					gadX += 124;
			_osd.addImageButton(gadX, gadY, "RightNormal.png", "RightActive.png", "RightPrelight.png", Osd.CMD_INVALID);
			
			gadX = defX - 224;
			gadY = defY - 52;
			_osd.addImageButton(gadX, gadY, "IrisDecNormal.png", "IrisDecActive.png", "IrisDecPrelight.png", Osd.CMD_INVALID, "диафр-");	gadX += 160;
			_osd.addImageButton(gadX, gadY, "IrisIncNormal.png", "IrisIncActive.png", "IrisIncPrelight.png", Osd.CMD_INVALID, "диафр+");
			
			gadX = defX - 237;
			gadY = defY - 5;
			_osd.addImageButton(gadX, gadY, "FocusDecNormal.png", "FocusDecActive.png", "FocusDecPrelight.png", Osd.CMD_INVALID, "фокус-");	gadX += 183;
			_osd.addImageButton(gadX, gadY, "FocusIncNormal.png", "FocusIncActive.png", "FocusIncPrelight.png", Osd.CMD_INVALID, "фокус+");
			
			gadX = defX - 225;
			gadY = defY + 40;
			_osd.addImageButton(gadX, gadY, "ZoomDecNormal.png", "ZoomDecActive.png", "ZoomDecPrelight.png", Osd.CMD_INVALID, "увелич-");	gadX += 160;
			_osd.addImageButton(gadX, gadY, "ZoomIncNormal.png", "ZoomIncActive.png", "ZoomIncPrelight.png", Osd.CMD_INVALID, "увелич+");
			
			gadX = defX - 38;
			gadY = defY + 97;
			_osd.addImage(gadX, gadY, "SpeedInc.png"); gadX -= 190;
			_osd.addImage(gadX, gadY, "SpeedDec.png");
			
			gadX = defX - 64;
			gadY = defY + 94;
			sldLabel = _osd.addLabel(gadX, gadY, "00", Osd.COLOR_TEXT); gadX -= 141; gadY += 10;
			_osd.addSlider(gadX, gadY, 137, 3, 1, 32, Osd.CMD_INVALID, 16, sldLabel);
			
			var data:Array = new Array();
			for (var i:int = 0; i < 255; i++) data.push(new String(i+1));
			
			gadX = defX + 90;
			gadY = defY - 109;
			_osd.addLabel(gadX, gadY, "Пресет", Osd.COLOR_TEXT); 															gadX -= 69; gadY += 30;
			_osd.addListBox(gadX, gadY, 198, data, 5); 																		gadX -= 6; gadY += 40;
			_osd.addTextButton(gadX, gadY, "Уст", Osd.CMD_INVALID, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT); 					gadX += 69;
			_osd.addTextButton(gadX, gadY, "Сброс", Osd.CMD_INVALID, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT); 				gadX += 80;
			_osd.addTextButton(gadX, gadY, "Вызов", Osd.CMD_INVALID, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT); 				gadX -= 75; gadY += 35;
			_osd.addLabel(gadX, gadY, "Маршрут", Osd.COLOR_TEXT); 															gadX -= 68; gadY += 30;
			_osd.addListBox(gadX, gadY, 198, new Array(" ")).disable();														gadX += 23; gadY += 40;
			_osd.addTextButton(gadX, gadY, "Старт", Osd.CMD_INVALID, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT); 				gadX += 80;
			_osd.addTextButton(gadX, gadY, "Стоп", Osd.CMD_INVALID, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT); 				gadX -= 95; gadY += 35;
			_osd.addTextButton(gadX, gadY, "Установки маршрута", Osd.CMD_INVALID, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
			
			System.textLine = System.TEXTLINE_NORMAL; //'long' text lines OFF

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
		}
	}
}