package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class DigitalKeyboard extends VirtualKeyboard implements IEventHandler
	{
		private static const CMD_CLOSE:int = 1;
		
		public function DigitalKeyboard(ow:Object, o:Osd, ti:TextInput)
		{
			owner = ow;
			osd = o;
			textInput = ti;
			
			//dimensions are fixed
			w = 106;
			h = 130;
			
			_osd = new Osd(this);
			_osd.addHotspot(0, 0, System.SCREEN_X * 2, System.SCREEN_Y * 2, CMD_CLOSE); //custom lock layer
			
			target = new MovieClip();
			border = new RoundRect(0, 0, w, h, 0, 20, Osd.COLOR_DEFAULT);
			target.addChild(border);
			
			holder = new RoundRect(2, 2, w - 4, h - 4, 0, 18, Osd.COLOR_WINDOW)
			target.addChild(holder);
			addChild(target);
			
			build();
			keys[0].hover();
			
			owner.addChild(this);
		}
		
		private function build()
		{
			var xpos:Number;
			var ypos:Number = 4;
			var dlt = VirtualKeyboard.KEY_DIM + 2;
			
			//build 789 456 123 table
			for (var i:int = 3; i > 0; i--)
			{
				xpos = 7;
				for (var j:int = 0; j < 3; j++)
				{
					var num:int = i * 3 - (2-j);
					target.addChild(addKey(xpos, ypos, KeyboardKey.KEY_DIGIT + num));
					xpos += dlt;
				}
				ypos += dlt;
			}
			
			xpos = 7; //now build backspace, zero and enter
			target.addChild(addKey(xpos, ypos, KeyboardKey.KEY_BACKSPACE, KeyboardKey.TYPE_GRAPHIC)); xpos += dlt;
			target.addChild(addKey(xpos, ypos, KeyboardKey.KEY_DIGIT + 0)); xpos += dlt;
			target.addChild(addKey(xpos, ypos, KeyboardKey.KEY_ENTER, KeyboardKey.TYPE_GRAPHIC));
		}
			
		public override function finalize()
		{
		
		}
		
		public function osdCommand(cmd:int):void
		{
			if (cmd == CMD_CLOSE) textInput.processChar("C_terminate"); //lock layer kills keyboard on press
		}
	}
}