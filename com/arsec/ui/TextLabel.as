package com.arsec.ui
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.text.AntiAliasType;
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.text.TextFormat;
	
	public class TextLabel extends Gadget
	{
		public static const TYPE_NORMAL:int	= 0;
		public static const TYPE_LARGE:int	= 1;
		public static const TYPE_SMALL:int	= 2;
		
		public static const ALIGN_LEFT:int		= 0;
		public static const ALIGN_RIGHT:int		= 1;
		public static const ALIGN_CENTER:int	= 2;
		public static const ALIGN_JUSTIFY:int	= 3;
		
		internal var label:MovieClip;
		internal var interactive:Boolean;
		internal var type:int = TYPE_NORMAL;
		private var color:uint;
		private var pos:Point;
		
		private var antialias:BlurFilter;

		public var text:String;
		
		public function TextLabel(ow:Object, o:Osd, ...args)
		{
			if (args && args.length) type = args[0];
			
			switch(type)
			{
				case(TYPE_LARGE): label = new LargeLabelObject(); break;
				case(TYPE_SMALL): label = new SmallLabelObject(); break;
				default: label = new LabelObject(); break;
			}

			owner = ow;
			osd = o;
			setText("undefined");

			if (System.FONT_ANTIALIAS)
			{
				antialias = new BlurFilter(1.1, 1.1, 2);
				label.filters = [antialias];
			}
			
			//more precise rendering for small-sized fonts
			if (type == TYPE_SMALL)
			{
				label.Text.antiAliasType = AntiAliasType.ADVANCED;
				label.Text.sharpness = 50;
				label.Text.thickness = 50;
			}
			
			owner.addChild(label);
			if (interactive) actor = label; //if it's a text button
			super();
			
			owner = ow;
		}
		
		public function setAlign(a:int)
		{
			var fmt:TextFormat = new TextFormat();
			switch(a)
			{
				case(ALIGN_CENTER):		fmt.align = TextFormatAlign.CENTER;		break;
				case(ALIGN_RIGHT):		fmt.align = TextFormatAlign.RIGHT;		break;
				case(ALIGN_JUSTIFY):	fmt.align = TextFormatAlign.JUSTIFY;	break;
				
				default:				fmt.align = TextFormatAlign.LEFT;		break;
			}
			
			label.Text.setTextFormat(fmt);
		}
		
		public function setMultiline()
		{
			label.Text.multiline = true;
			label.Text.wordWrap = true;
			label.Text.autoSize = TextFieldAutoSize.LEFT;
		}
		
		public override function hide()
		{
			label.visible = false;
			super.hide();
		}
		
		public override function show()
		{
			label.visible = true;
			super.show();
		}
		
		public override function disable()
		{
			setColor(Osd.COLOR_DISABLED);
			super.disable();
		}
		
		public override function enable()
		{
			setColor(Osd.COLOR_DEFAULT);
			super.enable();
		}
		
		public override function finalize()
		{
			owner.removeChild(label);
		}
		
		public function setText(txt:String)
		{
			text = txt;
			label.Text.text = text;
			label.Text.width = getWidth()+2; //updates hotspot width
		}
		
		public function getLabel() //returns movie clip
		{
			return label;
		}
		
		public function getCharWidth(idx:int):Number
		{
			return label.Text.getCharBoundaries(idx).width;
		}
		
		public function getCharPos(idx:int):Point
		{
			return new Point(label.Text.getCharBoundaries(idx).x, label.Text.getCharBoundaries(idx).y);
		}
		
		public function appendText(char:String)
		{
			var temp:String;
			var txt:String = label.Text.text;
			if (char.charCodeAt(0) != KeyboardKey.KEY_BACKSPACE)
			{
				if (txt == " ") temp = char;
				else temp = txt.concat(char);
			}
			else
			{
				if (txt.length > 0) temp = txt.slice(0, txt.length-1);
			}
			
			if (temp.length > 0) setText(temp);
			else setText(" "); //'empty' string if there's nothing to add
		}
		
		//returns caret pos for clicked char
		public function getCaret():int
		{
			var min:Number;
			var max:Number;
			
			if (mouseX > getCharPos(0).x + getWidth()) return text.length;
			
			for (var i:int = 0; i < text.length; i++)
			{
				if (i != text.length-1)
				{
					min = getCharPos(i).x;
					max = min + getCharWidth(i+1);
				}
				else
				{
					if (i > text.length - 2)
					{
						min = getCharPos(text.length-2).x + (text.length-i)*getCharWidth(0);
						max = getCharPos(text.length-2).x + (text.length-i+1)*getCharWidth(0);
					}
					else
					{
						min = getCharPos(i-1).x;
						max = min + getCharWidth(i);
					}
				}
				
				if (mouseX > min && mouseX <= max+0.3) return i; //additional 0.3 makes caret placement a little bit easier
			}
			
			return 0;
		}
		
		public function setWidth(input:Number)
		{
			label.Text.width = input;
		}
		
		public function setHeight(input:Number)
		{
			label.Text.height = input;
		}
			
		public function setPos(xy:Point)
		{
			label.x = xy.x;
			label.y = xy.y;
			pos = xy;
			if (!globalPos) globalPos = xy;
		}
		
		public function getPos():Point
		{
			return pos;
		}
		
		public function setColor(c:uint)
		{
			color = c;
			label.Text.textColor = c;
		}
		
		public function getWidth():Number
		{
			return label.Text.textWidth*1.05;
		}
		
		public function getHeight():Number
		{
			return label.Text.textHeight;
		}
		
		public function getLength():int
		{
			return label.Text.text.length;
		}
		
		public override function focus()
		{
			super.focus();
		}
	
		public override function unfocus()
		{
			super.unfocus();
		}
		
		public override function hover()
		{
			super.hover();
		}
		
		public override function press()
		{
			super.press();
		}
		
		public override function hold()
		{
			super.hold()
		}
		
		public override function unhold()
		{
			super.unhold();
		}
	}
}