package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	
	public class ScrollButton extends Gadget
	{
		private var target:MovieClip;
		private var frame:Sprite;
		
		private var scroller:Scroller;
		
		private var w:Number;
		private var h:Number;
		private var round:Number = 6;
		private var dragStep:Number;
		private var pos:Point;
		
		public function ScrollButton(s:Scroller, w:Number, h:Number)
		{
			scroller = s;
			target = new MovieClip();
			if (scroller.style == Scroller.STYLE_VERTICAL)
			{
				if (h < 8) h = 8;
				frame = new RoundRect(-w * 0.25, 2, w, h, 0, round, Osd.COLOR_SELECTED);
			}
			else
			{
				if (w < 5) w = 5;
				frame = new RoundRect(2, -h * 0.25, w, h, 0, round, Osd.COLOR_SELECTED);
			}
			
			this.w = w;
			this.h = h;
			
			target.addChild(frame);
			addChild(target);
			
			actor = target;
			super();
			
			dragndrop = true;
			var len:int = scroller.scrollLength()-1;
			if (scroller.style == Scroller.STYLE_VERTICAL)
			{
				if (len > 1) dragStep = (scroller.h - h - 4) / len;
				else dragStep = scroller.h-h-4-1;
			}
			else
			{
				if (len > 1) dragStep = (scroller.w - w - 4) / len;
				else dragStep = scroller.w-w-4-1;
			}
			
			setPos(new Point(x, y));
		}
		
		public function getPos():Point
		{
			return pos;
		}
		
		public function setPos(xy:Point)
		{
			pos = xy;
			target.x = pos.x;
			target.y = pos.y;
		}
		
		public function setColor(c:uint)
		{
			var ct:ColorTransform = new ColorTransform();
			ct.color = c;
			frame.transform.colorTransform = ct;
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
			var key:Number;
			var min:Number = 0;
			var max:Number;
			
			if (scroller.style == Scroller.STYLE_VERTICAL)
			{
				key = dragPos.y + (mouseY - dragPivot.y);
				max = scroller.h - h - 4 - 1;
			}
			else
			{
				key = dragPos.x + (mouseX - dragPivot.x);
				max = scroller.w - w - 4 - 1;
			}
			
			if (key > max) key = max;
			if (key < 1) key = min;
			
			var page:int;
			var div:Number = key/dragStep;
			if (div < 1) page = 0;
			else page = Math.round(div);

			if (page != scroller.curPage) scrollTo(page);
		}
		
		public function scrollTo(page:int)
		{
			var key:Number;
			var max:Number;

			if (scroller.style == Scroller.STYLE_VERTICAL) max = scroller.h - h - 4 - 1;
			else max = scroller.w - w - 4 - 1;
			
			scroller.curPage = page;
			key = dragStep * page;
				
			if (scroller.style == Scroller.STYLE_VERTICAL) setPos(new Point(0, key));
			else setPos(new Point(key, 0));

			scroller.cmd = Osd.CMD_SCROLL + scroller.curPage;
			scroller.sendMessage();
		}
		
		public override function focus()
		{
			if (!disabled) setColor(Osd.COLOR_DRAGGED);
			super.focus();
		}
		
		public override function press()
		{
			if (!disabled) super.press();
		}
	
		public override function unfocus()
		{
			if(!disabled) setColor(Osd.COLOR_SELECTED);
			super.unfocus();
		}
		
		public override function hover()
		{
			super.hover();
		}

		public override function hold()
		{
			if(!disabled) setColor(Osd.COLOR_DRAGGED);
			super.hold()
		}
		
		public override function unhold()
		{
			if(!disabled) setColor(Osd.COLOR_DRAGGED);
			super.unhold();
		}
		
		//these events are handled manually, since we need to use entire screen as a hotspot, but without locking other interface elements
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