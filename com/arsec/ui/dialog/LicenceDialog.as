package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	
	public class LicenceDialog extends Window
	{
		private static const CMD_OK:int = 0;
	
		public function LicenceDialog(ow:Object, o:Osd)
		{
			super(ow, o, defX, defY, 860, 150, 2, 52, false, false);
			
			_osd.setHandler(body);
			
			gadX = defX-349;
			gadY = defY-58;
			_osd.addLabel(gadX, gadY, "Приложение предназначено только для внутреннего пользования ГК 'Арсенал Безопасности'.", Osd.COLOR_SELECTED); gadY += 30;
			_osd.addLabel(defX-294, gadY, "Если вы не являетесь сотрудником данной организации, немедленно обратитесь"); gadY += 30;
			_osd.addLabel(defX-378, gadY, "к правообладателю по телефону +7 906 919 8583 и сообщите о факте незаконного распространения ПО."); gadY += 38;
			
			gadX = defX-15;
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