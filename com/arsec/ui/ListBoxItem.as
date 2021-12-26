package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	public class ListBoxItem extends Gadget
	{
		private var holder:Sprite;
		private var label:TextLabel;
		private var value:String;
		private var _osd:Osd; //for child objects

		private var w:Number;
		private var h:Number = TextInput.LINE_HEIGHT;
		
		private var reciever:ListBox;
		private var itemid:int;
		
		public function ListBoxItem(rc:ListBox, id:int, x:Number, y:Number, s:String, w:Number, r:int, d:int, m:int)
		{
			reciever = rc;
			itemid = id;
			
			h = rc.h;
			this.w = w;
			value = s;
			holder = new RoundRect(x, y, w, h, 0, r, Osd.COLOR_WINDOW);
			addChild(holder);
			
			_osd = new Osd(this);
			label = _osd.addLabel(5, h/8, value);
			label.setPos(new Point(5 + x, y + (h * m / 6) * m - d));
			setValue(value); //to auto-set maxwidth for label text
			
			actor = this;
			super();
		}
		
		private function setColor(s:Sprite, c:uint)
		{
			var ct:ColorTransform = new ColorTransform();
			ct.color = c;
			s.transform.colorTransform = ct;
		}
		
		public function setValue(str:String)
		{
			label.setText(str);
			label.setWidth(w*0.95);
		}
		
		public function update(st:int)
		{
			switch(st)
			{
				case(Gadget.STATE_DEFAULT):
					setColor(holder, Osd.COLOR_WINDOW);
					label.setColor(Osd.COLOR_DEFAULT);
					break;
					
				case(Gadget.STATE_HOVER):
					setColor(holder, Osd.COLOR_SELECTED);
					label.setColor(Osd.COLOR_INVERTED);
					break;
					
				case(Gadget.STATE_HOLD):
					setColor(holder, Osd.COLOR_SELECTED);
					label.setColor(Osd.COLOR_INVERTED);
					break;
					
				case(Gadget.STATE_PRESSED):
					setColor(holder, Osd.COLOR_WINDOW);
					label.setColor(Osd.COLOR_DEFAULT);
					break;
			}
		}
		
		public override function press()
		{
			update(Gadget.STATE_DEFAULT);
			update(Gadget.STATE_HOVER);
			
			reciever.selectItem(itemid);
			super.press();
		}
		
		public override function hover()
		{
			update(Gadget.STATE_HOVER);
			reciever.focusItem(itemid);
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
		
		public override function finalize()
		{
			super.finalize();
		}
	}
}