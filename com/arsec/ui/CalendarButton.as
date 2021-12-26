package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	public class CalendarButton extends Gadget
	{
		public static const TYPE_PAST = 0;
		public static const TYPE_PRESENT = 1;
		public static const TYPE_FUTURE = 2;
		
		private var pos:Point;
		private var bck:Image;
		private var label:TextLabel;
		private var defColor:TextLabel;
		private var calendar:Calendar;
		
		public var picked:Boolean = false;
		public var actual:Boolean = false; //defines if calendar button describes day from present month
		public var type:int = TYPE_PRESENT;
		
		public function CalendarButton(x:Number, y:Number, str:String, act:Boolean, t:int, c:int, cl:Calendar)
		{
			osd = new Osd(this);
			
			bck = osd.addImage(0, 0, "DayFocusBack.png");
			label = osd.addLabel(0, 0, str, Osd.COLOR_TEXT, TextLabel.TYPE_SMALL);
			setTitle(str);
			setPos(new Point(x, y));

			bck.visible = false;
			
			actual = act;
			type = t;
			calendar = cl;
			update(Gadget.STATE_DEFAULT);
			
			actor = this;
			super();
			cmd = c;
		}
		
		public function setPos(xy:Point)
		{
			pos = xy;
			x = xy.x;
			y = xy.y;
		}
		
		public function pick(state:Boolean)
		{
			picked = state;
			update(Gadget.STATE_DEFAULT);
		}
		
		public function setTitle(str:String)
		{
			label.setText(str);
			label.setPos(new Point(bck.width / 2 - label.getWidth() / 2 - 2, bck.height / 2 - label.getHeight() / 2));
			label.setWidth(label.getWidth()+3);
		}
		
		public function getTitle():String
		{
			return label.text;
		}
		
		public function update(st:int)
		{
			var defColor:int;

			switch(st)
			{
				case(Gadget.STATE_DEFAULT):
					if (actual) defColor = Osd.COLOR_TEXT;
					else defColor = Osd.COLOR_DISABLED;
					
					label.setColor(defColor);
					if (!picked) bck.visible = false;
					else bck.visible = true;
					break;
					
				case(Gadget.STATE_HOVER):
					if (actual)
					{
						defColor = Osd.COLOR_INVERTED;
						bck.visible = true;
					}
					else defColor = Osd.COLOR_SELECTED;
					
					label.setColor(defColor);
					break;
					
				case(Gadget.STATE_HOLD):
					label.setColor(Osd.COLOR_SELECTED);
					break;
					
				case(Gadget.STATE_PRESSED):
					label.setColor(Osd.COLOR_SELECTED);
					break;
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
			update(Gadget.STATE_HOVER);
			if (calendar) calendar.wakeUp();
			super.hover();
		}
		
		public override function hold()
		{
			update(Gadget.STATE_HOLD);
			super.hold()
		}
		
		public override function unhold()
		{
			update(Gadget.STATE_PRESSED);
			super.unhold();
		}
		
		public function osdCommand(cmd:int):void
		{
			calendar.osdCommand(Calendar.CMD_DATE_PICK + cmd);
		}
	}
}