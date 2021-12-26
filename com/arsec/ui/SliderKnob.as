package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	
	public class SliderKnob extends Gadget
	{
		public var w:Number;
		public var h:Number;
		
		private var target:MovieClip;
		private var slider:Slider;
		private var knob:ImageButton;
		private var pos:Point;
		
		public function SliderKnob(s:Slider)
		{
			target = new MovieClip;
			osd = new Osd(target);
			slider = s;
			
			knob = osd.addImageButton(0, 0, "blockv.png", "blockvfocus.png", "blockvfocus.png", Osd.CMD_INVALID);
			w = knob.getWidth();
			h = knob.getHeight();
			addChild(target);

			actor = this;
			super();
			
			dragndrop = true;
			
			setPos(new Point(x, w));
		}
		
		public function setPos(xy:Point)
		{
			if (!globalPos) globalPos = xy;
			pos = xy;
			target.x = pos.x;
			target.y = pos.y;
		}
		
		public function setDirect(...args)
		{
			if (args && args.length) setPos(new Point(args[0] * slider.step, pos.y));
			else
			{
				var p:Number = mouseX-w/2;
				setPos(new Point(p, pos.y));
			}
		}
		
		public override function dragBegin()
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouse);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouse);
			
			dragPos = new Point(target.x, target.y);
			super.dragBegin();
			dragPivot = new Point(mouseX, mouseY);
		}
		
		public override function dragEnd()
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouse);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouse);
			
			super.dragEnd();
		}
		
		public override function drag()
		{
			var p:Number = dragPos.x + (mouseX - dragPivot.x);
			if (p < 0) p = 0;
			if (p > slider.w - w) p = slider.w - w;

			if (slider.focused || this.focused)
			{
				setPos(new Point(p, pos.y)); //drag is active only if knob or hotspot are focused
				slider.updateValue(p);
			}
		}
		
		public function handleMouse(e:MouseEvent)
		{
			if (e.type == MouseEvent.MOUSE_MOVE) drag();
			if (e.type == MouseEvent.MOUSE_UP)
			{
				if (drg)
				{
					dragEnd();
					unhold();
					unfocus();
				}
			}
		}
	}
}