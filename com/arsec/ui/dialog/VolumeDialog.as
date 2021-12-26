package com.arsec.ui.dialog
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	
	public class VolumeDialog extends Window
	{
		private static const CMD_MUTE:int	= 0;
		private static const CMD_UPDATE:int	= 1;
		
		private const IMG_NORMAL:String = "DlMuteNormal.png";
		private const IMG_MUTE:String = "MuteNormal.png";
		
		private var volSld:Slider;
		private var volLbl:TextLabel;
		private var muteBtn:ImageButton;
		private var muted:Boolean = false;
		
		public function VolumeDialog(ow:Object, o:Osd)
		{
			System.manager.showOsd(true);
			
			super(ow, o, defX, defY, 206, 33, 2, 15, true, true);
			body.blendMode = BlendMode.LAYER;
			body.alpha = System.DEF_ALPHA;
			
			_osd.setHandler(body);
			muteBtn = _osd.addImageButton(defX - 100, defY - 15, IMG_NORMAL, IMG_NORMAL, IMG_NORMAL, CMD_MUTE);
			volLbl = _osd.addLabel(defX + 75, defY - 10, "00", Osd.COLOR_TEXT);
			volSld = _osd.addSlider(defX - 67, defY, 137, 3, 0, 63, CMD_UPDATE, System.volumeLevel, volLbl);
			
			if (System.manager.getMute(System.actChannel))
			{
				muted = false;
				updateMuteButton();
				muted = true;
			}
			
			_osd.setHandler(this);
		}
		
		public function updateMuteButton()
		{
			var img:String = IMG_MUTE;
			if (muted) img = IMG_NORMAL;
			
			muteBtn.setStyle(img, img, img);
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
			switch(cmd)
			{
				case(CMD_CLOSE):
					finalize();
					break;
				
				case(CMD_UPDATE):
					System.volumeLevel = volSld.getValue();
					break;
					
				case(CMD_MUTE):
					updateMuteButton();
					muted = !muted;
					System.manager.muteChannel(System.actChannel, muted);
					break;
			}
		}
	}
}