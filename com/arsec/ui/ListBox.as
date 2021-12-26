package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.events.Event;

	public class ListBox extends Gadget implements IEventHandler
	{
		public static const CMD_CLOSE:int = 0;
		
		private var target:MovieClip;
		private var marker:MovieClip;
		private var holder:Sprite;
		private var mediator:Sprite;
		private var border:Sprite;
		private var dropbox:MovieClip;
		
		private var w:Number;
		internal var h:Number = TextInput.LINE_HEIGHT;
		private var wlist:Number; //width for list items
		private var pos:Point;
		private var state = Gadget.STATE_DEFAULT;
		private var round:int = 14; //def corner round level
		private var facing:int = 2;
		
		private var upside:Boolean = false; //if true, list will drop above the holder
		private var scrollable:Boolean = false;
		private var pageSize:int; //amount of elements on each scroll page
		private var pageIndex:int; //we consider that one page scrolls one element
		private var items:Array;
		private var itemGadgets:Array;
		private var selected:int; //array idx of selected item
		private var defSelection:int = 0;
		
		private var label:TextLabel;
		private var _osd:Osd; //for child objects
		private var sosd:Osd; //for scroller
		private var losd:Osd; //lock layer
		private var scroller:Scroller;
		
		//toDo: fix behaviour of listbox to match Safari's one
		public function ListBox(ow:Object, o:Osd, w:Number, a:Array, ...args)
		{
			owner = ow;
			osd = o;
			items = a;
			
			if (System.textLine == System.TEXTLINE_LONG)
			{
				h = TextInput.DEF_LINE_HEIGHT;
				round = 12;
			}
			
			if (System.textLine == System.TEXTLINE_SHORT)
			{
				h = TextInput.SHORT_LINE_HEIGHT;
				round = 12;
			}
			
			target = new MovieClip();
			marker = new ListBoxMarker();
			
			border = new RoundRect(0, 0, w, h, 0, round+facing+1, Osd.COLOR_DEFAULT); //border is smoother than inset
			target.addChild(border);
			
			holder = new RoundRect(facing, facing, w-2*facing, h-2*facing, 0, round, Osd.COLOR_WINDOW);
			target.addChild(holder);
			
			wlist = w-2*facing-marker.width*1.8;
			mediator = new RoundRect(facing, facing, wlist, h-2*facing, 0, round, Osd.COLOR_WINDOW);
			target.addChild(mediator);
			
			_osd = new Osd(target);
			label = _osd.addLabel(5, h/8, "List box object");
			target.addChild(label);
			
			target.addChild(marker);
			marker.x = w - 10;
			marker.y = h / 2 - 0.5;

			addChild(target);
			
			if (args && args.length)
			{
				if (args[0])
				{
					if (args[0] > 0) setScroll(args[0]);
				}
				if (args[1]) upside = args[1];
			}

			actor = target;
			owner.addChild(this);
			super();
			
			if (args && args.length && args[2]) cmd = args[2];
			owner = ow;
			
			selectItem(defSelection);
			
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemove);
		}
		
		//for situations when input field has been emergency removed (for example, right click in parent window)
		public function handleRemove(e:Event)
		{
			if (dropbox)
			{
				owner.removeChild(dropbox);
				dropbox = null;
			}
			removeEventListener(Event.REMOVED_FROM_STAGE, handleRemove);
		}
		
		public function drop(c:int):MovieClip
		{
			if (scrollable) c = pageSize;
			
			var hoverIdx:int;
			var mul:int = 1;
			var sgn:int = 1;
			var dlt:int = h / 15;
			var dlt2:int = 0;
			var dlt3:int = 0;
			var result:MovieClip = new MovieClip();
			
			var first:int;
			
			if (upside)
			{
				sgn *= ( -1);
				mul = mul * c * sgn;
				dlt = 0;
				dlt2 = facing;
				dlt3 = 1;
			}
			
			var xy:Point = pos;

			var losd = new Osd(result);
			losd.addHotspot(0, 0, System.SCREEN_X * 2, System.SCREEN_Y * 2, CMD_CLOSE); //custom lock layer
			losd.setHandler(this);
			
			xy = new Point(0, h * mul + (facing*(1.5+dlt2))*sgn);
			var br:Sprite = new RoundRect(xy.x, xy.y, wlist, h*c+facing*c/(0.5*c), 0, round+facing+1, Osd.COLOR_DEFAULT); //border
			result.addChild(br);

			xy = new Point(facing, h*mul + (facing*(2.5-dlt3)+dlt2)*sgn);
			var hl:Sprite = new RoundRect(xy.x, xy.y, wlist-facing*2, (h*c+facing*c/2)-(0.5*c)*facing, 0, round, Osd.COLOR_WINDOW); //holder
			result.addChild(hl);
			
			itemGadgets = new Array();
			for (var i:int = 0; i < c; i++)
			{
				xy = new Point(facing, h*mul+(h*i) + (facing*2.5)*sgn);
				var li:ListBoxItem = new ListBoxItem(this, i, xy.x, xy.y, items[i] as String, hl.width, round, dlt, sgn);
				itemGadgets.push(li);
				result.addChild(li);
			}
			
			if (scrollable)
			{
				sosd = new Osd(result);
				xy = new Point(hl.width-facing*3-1, h*mul+(facing*6*(dlt3+sgn)));
				scroller = sosd.addScroller(xy.x, xy.y, 4, h*c-facing*5, pageSize, items.length+1);
				sosd.setHandler(this);
				hoverIdx = scroller.scrollToElement(selected);
				scrollTo(pageIndex);
			}
			else hoverIdx = selected;
			
			result.x = pos.x;
			result.y = pos.y;
			
			itemGadgets[hoverIdx].hover();
			selected = hoverIdx;

			return result;
		}
		
		public function getValue():int
		{
			return selected;
		}
		
		public override function copyFrom(...args)
		{
			var lbx:ListBox = args[0];
			
			if (lbx.scrollable) pageIndex = lbx.pageIndex;
			else pageIndex = 0;
			selectItem(lbx.getValue()-pageIndex);
			
			if (lbx.disabled) disable();
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

		public function setPos(xy:Point)
		{
			pos = xy;
			target.x = pos.x;
			target.y = pos.y;
		}
		
		private function setColor(s:Sprite, c:uint)
		{
			var ct:ColorTransform = new ColorTransform();
			ct.color = c;
			s.transform.colorTransform = ct;
		}
		
		public function selectItem(sel:int)
		{
			var prev = selected;
			selected = sel+pageIndex;
		
			for (var i:int = 0; i < items.length; i++)
			{
				if (itemGadgets && itemGadgets.length)
				{
					var g:Gadget = itemGadgets[i] as Gadget;
					if (g) g.finalize();
				}
			}

			if (dropbox)
			{
				owner.removeChild(dropbox);
				dropbox = null;
				
				if (cmd) sendMessage();
			}
			if(items[selected]) label.setText(items[selected]);
			label.setWidth(holder.width * 0.95); //text must not get out of holder width, so we auto-adjust it
		}
		
		public function focusItem(foc:int)
		{
			if (foc >= 0) selected = foc + pageIndex;
			
			for (var i:int = 0; i < items.length; i++)
			{
				if (itemGadgets && itemGadgets.length)
				{
					var li:ListBoxItem = itemGadgets[i] as ListBoxItem;
					if (li)
					{
						if (i != foc) li.update(Gadget.STATE_DEFAULT); //unfocus previously focused items
						else li.focus();
					}
				}
			}
		}
		
		public function setScroll(area:int)
		{
			scrollable = true;
			pageSize = area;
		}
		
		public function scrollTo(page:int)
		{
			var index:int = pageSize + page;
			pageIndex = page;

			for (var i:int = 0; i < itemGadgets.length; i++) itemGadgets[i].setValue(items[page + i]);
		}
		
		public function update(st:int)
		{
			state = st;

			if (!disabled)
			{
				switch(state)
				{
					case(Gadget.STATE_DEFAULT):
						setColor(border, Osd.COLOR_DEFAULT);
						setColor(mediator, Osd.COLOR_WINDOW);
						label.setColor(Osd.COLOR_DEFAULT);
						break;
						
					case(Gadget.STATE_HOVER):
						setColor(mediator, Osd.COLOR_SELECTED);
						label.setColor(Osd.COLOR_INVERTED);
						break;
						
					case(Gadget.STATE_HOLD):
						setColor(mediator, Osd.COLOR_SELECTED);
						label.setColor(Osd.COLOR_DEFAULT);
						break;
						
					case(Gadget.STATE_PRESSED):
						setColor(mediator, Osd.COLOR_SELECTED);
						label.setColor(Osd.COLOR_DEFAULT);
						break;
				}
			}
			else
			{
				setColor(border, Osd.COLOR_DISABLED);
				setColor(mediator, Osd.COLOR_WINDOW);
				label.setColor(Osd.COLOR_DISABLED);
			}
		}
		
		public override function press()
		{
			update(Gadget.STATE_DEFAULT);
			update(Gadget.STATE_HOVER);
			
			if (!disabled)
			{
				dropbox = drop(items.length);
				owner.addChild(dropbox);
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
			owner.removeChild(this);
			super.finalize();
		}
		
		public function osdCommand(cmd:int):void
		{
			if (cmd == CMD_CLOSE) selectItem(selected);
			if (cmd >= Osd.CMD_SCROLL) scrollTo(cmd-Osd.CMD_SCROLL);
		}
	}
}