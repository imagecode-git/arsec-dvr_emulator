package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	
	public class Slider extends Gadget
	{
		private var target:MovieClip;
		private var clickable:MovieClip;
		private var hotspot:Hotspot;
		private var holder:Sprite;
		private var knob:SliderKnob;
		private var label:TextLabel; //if set, slider will affect values of this label
		private var pos:Point;
		
		private var value:Number = 50;
		private var min:Number = 0;
		private var max:Number = 100;
		
		internal var step:Number;
		internal var w:Number;
		internal var h:Number;
		
		public function Slider(ow:Object, o:Osd, w:Number, h:Number, mn:Number, mx:Number, c:int, ...args)
		{
			owner = ow;
			osd = o;
			
			this.w = w;
			this.h = h;
			
			min = mn;
			max = mx;
			
			if (args && args.length)
			{
				if (args[0]) value = args[0];
				if (args[1]) label = args[1];
			}
			
			target = new MovieClip();
			clickable = new MovieClip();
			
			holder = new RoundRect(0, 0, w, h, 0, 0, Osd.COLOR_DEFAULT);
			clickable.addChild(holder);
			hotspot = new Hotspot(clickable, osd, cmd);
			hotspot.setSize(new Point(w, h * 10));
			hotspot.setPos(new Point(w/2, 0));
			target.addChild(clickable);

			knob = new SliderKnob(this);
			knob.setPos(new Point((w - w / 15 - knob.w / 2) / 2, h * (h + h / 6) - knob.h));
			target.addChild(knob);
			
			step = (w-knob.w) / (max - min);

			addChild(target);
			owner.addChild(this);
			
			actor = clickable;
			super();
			
			cmd = c;
			if (label) setLabel(label);
			setValue(value);
		}
		
		public function setPos(xy:Point)
		{
			if (!globalPos) globalPos = xy;
			pos = xy;
			target.x = pos.x;
			target.y = pos.y;
		}
		
		public function setLabel(lb:TextLabel)
		{
			label = lb;
			setValue(value);
		}
		
		public function updateLabelText(val:Number)
		{
			if (label) label.setText(value.toString());
		}
		
		public function updateValue(factor:Number)
		{
			var len:Number = w - knob.w;
			var curStep = (len-factor)/step;
			
			value = max-Math.round(curStep);
			updateLabelText(value);
			
			if(cmd) sendMessage();
		}
		
		public function getValue():Number
		{
			return value;
		}
		
		public function setValue(val:Number)
		{
			updateLabelText(val);
			knob.setDirect(val);
		}
		
		public override function unfocus()
		{
			super.unfocus();
		}
		
		public override function hold()
		{
			knob.setDirect();
			knob.dragBegin();
			knob.drag();
			super.hold();
		}
		
		public override function unhold()
		{
			knob.dragEnd();
			super.unhold();
		}
		
		public override function sendMessage()
		{
			super.sendMessage();
		}
	}
}