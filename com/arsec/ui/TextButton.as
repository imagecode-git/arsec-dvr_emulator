package com.arsec.ui
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import com.arsec.ui.*;
	import com.arsec.system.*;
	
	//toDo: kind of style support
	public class TextButton extends TextLabel
	{
		private var defColor:uint = Osd.COLOR_DEFAULT;
		
		public function TextButton(ow:Object, o:Osd, c:int, ...args)
		{
			if (args && args.length)
			{
				if (args[0]) type = args[0];
				if (args[1]) defColor = args[1];
			}
			else type = TYPE_NORMAL;

			interactive = true;
			super(ow, o);
			setColor(defColor);
			cmd = c;
		}
		
		public override function focus()
		{
			if (!disabled) setColor(Osd.COLOR_SELECTED);
			super.focus();
		}
		
		public override function press()
		{
			if (!disabled) super.press();
		}
	
		public override function unfocus()
		{
			if(!disabled) setColor(defColor);
			super.unfocus();
		}
		
		public override function hover()
		{
			super.hover();
		}

		public override function hold()
		{
			if(!disabled) setColor(defColor);
			super.hold()
		}
		
		public override function unhold()
		{
			if(!disabled) setColor(Osd.COLOR_SELECTED);
			super.unhold();
		}
	}
}