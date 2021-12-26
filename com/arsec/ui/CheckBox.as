package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	public class CheckBox extends Gadget
	{
		private var target:MovieClip;
		private var holder:Sprite;
		private var core:Sprite;
		private var border:Sprite;
		
		private var labelText:String;
		private var label:TextLabel;
		private var hotspot:Hotspot;
		private var _osd:Osd; //for child objects
		
		internal var spacing:Number = 15; //distance between checkbox and label
		internal var radius:Number = 8.3; //default checkbox radius
		
		private var pos:Point;
		private var state:int;

		public var checked:Boolean = true;
		public var mono:Boolean = false; //defines if external object is used for unchecking this checkbox

		public function CheckBox(ow:Object, o:Osd, c:int, ...args)
		{
			target = new MovieClip();
			
			border = addCircle(radius, Osd.COLOR_DEFAULT);
			target.addChild(border);
			
			holder = addCircle(radius*0.73, Osd.COLOR_INVERTED);
			target.addChild(holder);

			core = addCircle(radius*0.37, Osd.COLOR_SELECTED);
			target.addChild(core);
			
			addChild(target);
			owner = ow;
			osd = o;
			
			if (args && args.length)
			{
				labelText = args[0];
				mono = args[1];
			}
			if (labelText)
			{
				_osd = new Osd(target);
				label = _osd.addLabel(spacing, -11, labelText, Osd.COLOR_TEXT);
				label.setText(labelText); //this will update label width
				hotspot = _osd.addHotspot(label.getWidth() / 2, 0, label.getWidth() + spacing + radius, label.getHeight(), Osd.CMD_INVALID);
				actor = hotspot;
				hotspot.attach(this as Gadget);
			}
			else actor = this;
			
			owner.addChild(this);
			super();
			cmd = c;
		}
		
		private function addCircle(r:Number, c:uint):Sprite
		{
			var result = new Sprite();
			result.graphics.beginFill(c);
			result.graphics.drawCircle(0, 0, r);
			result.graphics.endFill();

			return result;
		}
		
		private function setColor(s:Sprite, c:uint)
		{
			var ct:ColorTransform = new ColorTransform();
			ct.color = c;
			s.transform.colorTransform = ct;
		}
		
		public override function copyFrom(...args)
		{
			var cbx:CheckBox = args[0];
			if (cbx.checked != checked)
			{
				if (cbx.checked) check();
				else uncheck();
			}
			
			if (cbx.disabled) disable();
			else
			{
				if(disabled) enable();
			}
		}
		
		public override function disable()
		{
			super.disable();
			update(Gadget.STATE_DEFAULT);
		}
		
		public override function enable()
		{
			super.enable();
			update(Gadget.STATE_DEFAULT);
		}
		
		public function check()
		{
			checked = true;
			update(Gadget.STATE_DEFAULT);
		}
		
		public function uncheck()
		{
			checked = false;
			update(Gadget.STATE_DEFAULT);
		}
		
		public function update(st:int)
		{
			state = st;
	
			if (!disabled)
			{
				switch(state)
				{
					case(Gadget.STATE_DEFAULT):
						setColor(core, Osd.COLOR_SELECTED);
						setColor(holder, Osd.COLOR_INVERTED);
						setColor(border, Osd.COLOR_DEFAULT);
						if (label) label.setColor(Osd.COLOR_TEXT);
						
						if (checked) core.alpha = 1.0;
						else core.alpha = 0;

						break;
							
					case(Gadget.STATE_HOVER):
						setColor(holder, Osd.COLOR_WINDOW);
						setColor(border, Osd.COLOR_DEFAULT);
						if (label) label.setColor(Osd.COLOR_SELECTED);

						break;
						
					case(Gadget.STATE_HOLD):
						setColor(holder, Osd.COLOR_INVERTED);
						if (checked) setColor(core, Osd.COLOR_DEFAULT);
						if (label) label.setColor(Osd.COLOR_SELECTED);

						break;
							
					case(Gadget.STATE_PRESSED):
						setColor(holder, Osd.COLOR_INVERTED);
						if (label) label.setColor(Osd.COLOR_SELECTED);

						if (!checked)
						{
							core.alpha = 1.0;
							setColor(core, Osd.COLOR_DEFAULT);
						}
						else core.alpha = 0.0;

						break;
				}
			}
			else
			{
				setColor(border, Osd.COLOR_DISABLED);
				setColor(holder, Osd.COLOR_WINDOW);
				if (label) label.setColor(Osd.COLOR_DISABLED);
				
				if (checked)
				{
					core.alpha = 1.0;
					setColor(core, Osd.COLOR_DISABLED);
				}
				else core.alpha = 0.0;
			}
		}
		
		public function setPos(xy:Point)
		{
			pos = xy;
			target.x = pos.x;
			target.y = pos.y;
		}
		
		public override function press()
		{
			if (!disabled)
			{
				var prev:Boolean = checked;
				if (!checked) checked = true;
				else
				{
					if(!mono) checked = false;
				}
					
				update(Gadget.STATE_DEFAULT);
				update(Gadget.STATE_HOVER);
				
				if (checked != prev) super.press();
			}
		}
		
		public override function unfocus()
		{
			update(Gadget.STATE_DEFAULT);
			super.unfocus();
		}
		
		public override function hover()
		{
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
			update(Gadget.STATE_PRESSED);
			super.unhold();
		}
		
		public override function finalize()
		{
			if (label)
			{
				label.finalize();
				hotspot.finalize();
			}
			owner.removeChild(this);
		}
	}
}