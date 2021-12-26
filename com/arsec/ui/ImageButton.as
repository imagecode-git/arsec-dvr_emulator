package com.arsec.ui
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.geom.Point;
	
	public class ImageButton extends Image
	{
		private var nodeName:String; //name in database
		private var states:Array; //image names for different button states (normal/hover/pressed)
		private var hintObject:Hint;
		private var hint:String;
	
		public function ImageButton(ow:Object, o:Osd, c:int, ...args)
		{
			interactive = true;
			states = new Array();
			for (var i:int = 0; i < 3; i++) states[i] = args[i];
			super(ow, o, states[Gadget.STATE_DEFAULT]);
			cmd = c;
			
			if (args[3]) hint = args[3];
		}
		
		//to create button manually (or change its style at runtime)
		public function setStyle(s0:String, s1:String, s2:String)
		{
			states[Gadget.STATE_DEFAULT] = s0;
			states[Gadget.STATE_HOVER] = s1;
			states[Gadget.STATE_PRESSED] = s2;
			
			if (!focused) update(states[Gadget.STATE_DEFAULT]);
			else update(states[Gadget.STATE_HOVER]);
		}
		
		public function updateHint(str:String)
		{
			hint = str;
			if (focused)
			{
				unfocus();
				hover();
			}
		}
		
		public function getWidth():Number
		{
			return bitmap.width;
		}
		
		public function getHeight():Number
		{
			return bitmap.height;
		}
		
		public override function focus()
		{
			if (!disabled) update(states[Gadget.STATE_HOVER]);
			super.focus();
		}
		
		public override function press()
		{
			if (!disabled) super.press();
		}
	
		public override function unfocus()
		{
			if (!disabled)
			{
				update(states[Gadget.STATE_DEFAULT]);
				if (hintObject) removeChild(hintObject);
			}
			super.unfocus();
		}
		
		public override function hover()
		{
			if (!disabled)
			{
				if (hint)
				{
					hintObject = new Hint(getWidth(), getHeight(), hint);
					addChild(hintObject);

					if (localToGlobal(new Point(hintObject.x, hintObject.y)).x + hintObject.width > System.SCREEN_X - 100) hintObject.x -= Math.abs(hintObject.width-getWidth());
				}
			}
			super.hover();
		}

		public override function hold()
		{
			if(!disabled) update(states[Gadget.STATE_PRESSED]);
			super.hold()
		}
		
		public override function unhold()
		{
			if(!disabled) update(states[Gadget.STATE_HOVER]);
			super.unhold();
		}
	}
}