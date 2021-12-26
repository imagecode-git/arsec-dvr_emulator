package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class KeyboardKey extends Gadget
	{
		public static const TYPE_TEXT:int = 0;
		public static const TYPE_GRAPHIC:int = 1;
		
		//special keys
		public static const KEY_ENTER:int		= 13;
		public static const KEY_BACKSPACE:int	= 8;
		public static const KEY_SPACE:int		= 32;
		public static const KEY_SHIFT:int		= 16;
		
		//normal keys
		public static const KEY_DIGIT:int = 48; //{+0...9}
		
		public static const KEY_SQBL:int	= 91; // [  left square brackets
		public static const KEY_SQBR:int	= 93; // ] right square brackets
		
		public static const KEY_BRL:int		= 123; // {  left brackets
		public static const KEY_BRR:int		= 125; // } right brackets
		
		public static const KEY_SLASHL:int	= 92; // \ left slash
		public static const KEY_SLASHR:int	= 47; // / right slash
		
		public static const KEY_PARL:int	= 40; // ( left parentheses
		public static const KEY_PARR:int	= 41; // ) right parentheses
		
		public static const KEY_ANGL:int	= 60; // < left angular brackets
		public static const KEY_ANGR:int	= 62; // > right angular brackets
		
		public static const KEY_EXCL:int	= 33; //exclamation sign
		public static const KEY_QUESTN:int	= 63; //question sign
		
		public static const KEY_COLON:int		= 58; // :
		public static const KEY_SEMICOLON:int	= 59; // ;
		public static const KEY_QUOT:int		= 34; // " qutation sign
		public static const KEY_APSTR:int		= 39; // ' apostrophe
		public static const KEY_COMMA:int		= 44; // ,
		public static const KEY_DOT:int			= 46; // .
		public static const KEY_GRACC:int		= 96; // ` grave accent
		public static const KEY_TILDA:int		= 126; // ~ tilda
		public static const KEY_AT:int			= 64; // @ sign
		public static const KEY_PERCENT:int		= 37; // %
		public static const KEY_CARET:int		= 94; // ^ caret sign
		public static const KEY_AMP:int			= 38; // & ampersand
		public static const KEY_NUM:int			= 35; // # number sign
		public static const KEY_ASTR:int		= 42; // * asterisk
		public static const KEY_DOLLAR:int		= 36; // $ dollar sign
		public static const KEY_VBAR:int		= 124; // | vertical bar
		public static const KEY_USCORE:int		= 95; // _ underscore
		
		public static const KEY_MINUS:int		= 45;
		public static const KEY_PLUS:int		= 43;
		public static const KEY_EQUALS:int		= 61;
		
		//non-ascii codes
		public static const KEY_LEFT:int		= 800;
		public static const KEY_RIGHT:int		= 900;
		
		private var type:int;
		private var holder:MovieClip;
		private var label:TextLabel;
		private var image:ImageButton;
		private var output:TextInput;
		
		private var wspec:Number;
		private var w:Number;
		private var h:Number;
		private var pos:Point;
		
		private var ascii:int;
		
		public var keyboard:VirtualKeyboard;
		
		public function KeyboardKey(ascii:int, ...args)
		{
			osd = new Osd(this);
			this.ascii = ascii;
			if (args && args.length) type = args[0];
			
			if (type == TYPE_TEXT)
			{
				//calculate special key width
				switch(ascii)
				{
					case(KEY_BACKSPACE): wspec = 94; break;
					case(KEY_ENTER): wspec = 62; break;
					case(KEY_SHIFT): wspec = 62; break;
					case(KEY_SPACE): wspec = 286; break;
					
					default: wspec = VirtualKeyboard.KEY_DIM;
				}
				
				holder = new MovieClip();
				holder.addChild(new RoundRect(0, 0, wspec, VirtualKeyboard.KEY_DIM, 0, 3, Osd.COLOR_SELECTED));
				addChild(holder);
				
				var str:String;
				switch(ascii)
				{
					case(KEY_BACKSPACE): str = "Backspace"; break;
					case(KEY_ENTER): str = "Enter"; break;
					case(KEY_SHIFT): str = "Shift"; break;
					case(KEY_SPACE): str = "Space"; break;
					case(KEY_LEFT): str = "<-"; break;
					case(KEY_RIGHT): str = "->"; break;
					
					default: str = fromAscii(ascii);
				}
				
				label = new TextLabel(this, osd, TextLabel.TYPE_LARGE);
				label.setText(str);
				label.setColor(Osd.COLOR_TEXT);
				label.setWidth(label.getWidth()+3); //we make it a little bit wider to force all key titles display properly
				addChild(label);
			}
			else
			{
				var s0:String;
				var s1:String;
				var s2:String;
				
				if (ascii == KEY_BACKSPACE)
				{
					s0 = "BackspaceKeyNormal.png";
					s1 = "BackspaceKeyFocus.png";
					s2 = s1;
				}
				
				if (ascii == KEY_ENTER)
				{
					s0 = "EnterKeyNormal.png";
					s1 = "EnterKeyFocus.png";
					s2 = s1;
				}
				
				if(s0 && s1 && s2) image = osd.addImageButton(0, 0, s0, s1, s2, Osd.CMD_INVALID);
			}
			
			update(Gadget.STATE_DEFAULT);
			
			actor = this;
			super();
		}
		
		public function setPos(x:Number, y:Number)
		{
			pos = new Point(x, y);
			if (holder)
			{
				holder.x = pos.x;
				holder.y = pos.y;
			}
			
			if (label) label.setPos(new Point(pos.x + wspec / 2 - label.getWidth() / 2 - 1, pos.y + VirtualKeyboard.KEY_DIM / 2 - label.getHeight() / 2 - 1));
			if (image) image.setPos(new Point(pos.x + VirtualKeyboard.KEY_DIM / 2 - image.getWidth() / 2 - 1, pos.y + VirtualKeyboard.KEY_DIM / 2 - image.getHeight() / 2 - 1));
		}
		
		public function setOutput(ti:TextInput)
		{
			output = ti;
		}
		
		public function toAscii(char:String):int
		{
			return char.charAt(0) as int;
		}
		
		public function fromAscii(val:int):String
		{
			return String.fromCharCode(val);
		}
		
		public function update(st:int)
		{
			if (!disabled && type == TYPE_TEXT)
			{
				switch(st)
				{
					case(Gadget.STATE_DEFAULT):
						holder.alpha = 0;
						label.setColor(Osd.COLOR_TEXT);
						break;
						
					case(Gadget.STATE_HOVER):
						holder.alpha = 1.0;
						label.setColor(Osd.COLOR_INVERTED);
						break;
						
					case(Gadget.STATE_HOLD):
						label.setColor(Osd.COLOR_SELECTED);
						break;
						
					case(Gadget.STATE_PRESSED):
						label.setColor(Osd.COLOR_SELECTED);
						break;
				}
			}
		}
		
		public override function press()
		{
			update(Gadget.STATE_DEFAULT);
			update(Gadget.STATE_HOVER);
		
			super.press();
		}
		
		public override function unfocus()
		{
			update(Gadget.STATE_DEFAULT);
			super.unfocus();
		}
		
		public override function hover()
		{
			output.wakeKeyboard();
			update(Gadget.STATE_HOVER);
			super.hover();
		}
		
		public override function hold()
		{
			update(Gadget.STATE_HOLD);
			super.hold()
		}
		
		public override function unhold()
		{
			switch(ascii)
			{
				case(KEY_SHIFT):
					output.processChar("C_shift");
					break;
					
				case(KEY_ENTER):
					output.processChar("C_terminate");
					break;
					
				case(KEY_LEFT):
					output.processChar("C_left");
					break;
					
				case(KEY_RIGHT):
					output.processChar("C_right");
					break;
					
				default:
					output.processChar(fromAscii(ascii));
					break;
			}
			
			update(Gadget.STATE_PRESSED);
			super.unhold();
		}
	}
}