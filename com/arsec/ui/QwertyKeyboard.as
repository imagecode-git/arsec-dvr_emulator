package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class QwertyKeyboard extends VirtualKeyboard
	{
		private static const CMD_CLOSE:int = 1;
		
		private var group_1:MovieClip;
		private var group_2:MovieClip;
		
		public function QwertyKeyboard(ow:Object, o:Osd, ti:TextInput)
		{
			owner = ow;
			osd = o;
			textInput = ti;
			
			//dimensions are fixed
			w = 432;
			h = 166;
			
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
			var xpos:Number = 9;
			var ypos:Number = 9;
			var dlt = VirtualKeyboard.KEY_DIM + 3;
			
			group_1 = new MovieClip(); //normal set
			group_2 = new MovieClip(); //shifted
			
			for (var i = 1; i < 11; i++)
			{
				var digit:int;
				if (i < 10) digit = i;
				else digit = 0;
				
				group_1.addChild(addKey(xpos, ypos, KeyboardKey.KEY_DIGIT + digit)); xpos += dlt;
			}
			
			target.addChild(addKey(xpos, ypos, KeyboardKey.KEY_BACKSPACE)); xpos += dlt;

			xpos = 10;
			ypos += dlt-1;
			group_1.addChild(addKey(xpos, ypos, kbc("q"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("w"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("e"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("r"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("t"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("y"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("u"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("i"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("o"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("p"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, KeyboardKey.KEY_SQBL)); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, KeyboardKey.KEY_SQBR)); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, KeyboardKey.KEY_SLASHL)); xpos += dlt;
			
			xpos = 10;
			ypos += dlt-1;
			group_1.addChild(addKey(xpos, ypos, kbc("a"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("s"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("d"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("f"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("g"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("h"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("j"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("k"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("l"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, KeyboardKey.KEY_SEMICOLON)); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, KeyboardKey.KEY_APSTR)); xpos += dlt;
			
			target.addChild(addKey(xpos, ypos, KeyboardKey.KEY_ENTER));
			
			xpos = 10;
			ypos += dlt-1;
			group_1.addChild(addKey(xpos, ypos, kbc("z"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("x"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("c"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("v"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("b"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("n"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, kbc("m"))); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, KeyboardKey.KEY_COMMA)); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, KeyboardKey.KEY_DOT)); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, KeyboardKey.KEY_SLASHR)); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, KeyboardKey.KEY_GRACC)); xpos += dlt;
			
			target.addChild(addKey(xpos, ypos, KeyboardKey.KEY_SHIFT));
			xpos = 10;
			ypos += dlt-1;
			target.addChild(addKey(xpos, ypos, KeyboardKey.KEY_LEFT)); xpos += dlt;
			target.addChild(addKey(xpos, ypos, KeyboardKey.KEY_RIGHT)); xpos += dlt;
			target.addChild(addKey(xpos, ypos, KeyboardKey.KEY_SPACE)); xpos += dlt*9;
			group_1.addChild(addKey(xpos, ypos, KeyboardKey.KEY_MINUS)); xpos += dlt;
			group_1.addChild(addKey(xpos, ypos, KeyboardKey.KEY_EQUALS));
			
			target.addChild(group_1);
			group_1.visible = true;

			xpos = 10;
			ypos = 10;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_EXCL)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_AT)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_NUM)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_DOLLAR)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_PERCENT)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_CARET)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_AMP)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_ASTR)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_PARL)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_PARR)); xpos += dlt;
			
			xpos = 10;
			ypos += dlt-1;
			group_2.addChild(addKey(xpos, ypos, kbc("Q"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("W"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("E"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("R"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("T"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("Y"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("U"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("I"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("O"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("P"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_BRL)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_BRL)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_VBAR)); xpos += dlt;
			
			xpos = 10;
			ypos += dlt-1;
			group_2.addChild(addKey(xpos, ypos, kbc("A"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("S"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("D"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("F"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("G"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("H"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("J"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("K"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("L"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_COLON)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_QUOT)); xpos += dlt;
			
			xpos = 10;
			ypos += dlt-1;
			group_2.addChild(addKey(xpos, ypos, kbc("Z"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("X"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("C"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("V"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("B"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("N"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, kbc("M"))); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_ANGL)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_ANGR)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_QUESTN)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_TILDA)); xpos += dlt;
			
			xpos = 10+dlt*11;
			ypos += dlt-1;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_USCORE)); xpos += dlt;
			group_2.addChild(addKey(xpos, ypos, KeyboardKey.KEY_PLUS));
			
			target.addChild(group_2);
			group_2.visible = false;
		}
		
		private function kbc(char:String):int
		{
			return char.charCodeAt(0);
		}
		
		public override function shift()
		{
			super.shift();
			if (shifted)
			{
				group_1.visible = false;
				group_2.visible = true;
			}
			else
			{
				group_1.visible = true;
				group_2.visible = false;
			}
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