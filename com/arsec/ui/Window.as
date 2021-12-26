package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	
	public class Window extends Gadget implements IEventHandler, IActivator
	{
		protected static const CMD_CLOSE:int = 99999;
		
		protected var wndScroller:Scroller;
		protected var scrollLines:Array;
		protected var scrollSeparator:Number = 32;
		protected var scrollPivot:Number; //ypos of line 0
		protected var scrollPageSize:int;
		
		protected var rect:RoundRect;
		protected var body:MovieClip; //parent of the window itself and _all_ objects inside it
		protected var wnd:MovieClip; //only window area (for correct drag&drop)
		protected var grid:MovieClip;
		protected var _osd:Osd; //local OSD to store and handle all child interface objects
		protected var pos:Point;
		protected var w:Number;
		protected var h:Number;
		
		protected var movable:Boolean = true;
		protected var activated:Boolean = false;
		protected var rightlock:Boolean = false; //lock handler for right click
		protected var haltRightClick:Boolean = false; //this allows child gadgets to handle right click without killing parent
		protected var caller:Object;
		protected var locker:Hotspot;
		
		protected var dragHolder:Hotspot;
		protected var dragParent:MovieClip;
		
		//default Y separators
		public var sepLbl:Number = 32;
		public var sepTInput:Number = 34;
		public var sepCBox:Number = 54;
		public var thinMul:Number = 0.89; //multiplier for thinner separator
		
		public var offsetCBox:Number = 8; //X offset for checkbox
		
		//helper vars
		public var gadX:Number;
		public var gadY:Number;
		
		protected static const defX:Number = System.SCREEN_X/2;
		protected static const defY:Number = System.SCREEN_Y/2;
		
		public function Window(ow:Object, o:Osd, x:Number, y:Number, w:Number, h:Number, b:int, r:int, rc:Boolean, mv:Boolean, ...args)
		{
			body = new MovieClip();
			wnd = new MovieClip();
			_osd = new Osd(body);
			locker = _osd.addHotspot(System.SCREEN_X/2, System.SCREEN_Y/2, System.SCREEN_X*2, System.SCREEN_Y*2, CMD_CLOSE);
			
			owner = ow;
			osd = o;
			
			this.w = w;
			this.h = h;
			pos = new Point(x-w/2, y-h/2);
			globalPos = pos;
			
			var col = Osd.COLOR_DEFAULT;
			if (h < 50) col = Osd.COLOR_TEXT;
			
			rect = new RoundRect(pos.x, pos.y, w, h, b, r, Osd.COLOR_WINDOW, col);
			wnd.addChild(rect);
			
			//if top/bottom masked lines defined
			if (args && args.length)
			{
				var topmask = new RoundRect(pos.x+b*0.65, pos.y+b*0.75, w-b, h-b*1.2, b, r-3, Osd.COLOR_WINDOW, col);
				var bottommask = new RoundRect(pos.x+b*0.65, pos.y+b*0.5, w-b, h-b*1.2, b, r-3, Osd.COLOR_WINDOW, col);
				
				var toprect = new RoundRect(pos.x, pos.y, w, args[0], 0, 0, Osd.COLOR_WINDOWMASK);
				toprect.mask = topmask;
				
				var bottomrect = new RoundRect(pos.x, pos.y + h - args[0], w, args[0], 0, 0, Osd.COLOR_WINDOWMASK);
				bottomrect.mask = bottommask;
				
				wnd.addChild(topmask);
				wnd.addChild(bottommask);
				wnd.addChild(toprect);
				wnd.addChild(bottomrect);
			}
			
			body.addChild(wnd);
			owner.addChild(body);
			
			actor = wnd;
			rightclick  = true;
			rightlock = !rc;
			movable = mv;
			
			if (movable) wnd.addEventListener(MouseEvent.MOUSE_DOWN, this.handleMouse);
		
			super();
			pos = new Point(0, 0); //addChild turns actual pos to zero, so we sync it
			_osd.setHandler(this);
			owner = ow; //gadget does reset the owner, reassigning it here
		}
		
		public function spawnGrid()
		{
			grid = new Grid();
			grid.x = System.SCREEN_X/2;
			grid.y = System.SCREEN_Y/2;
			body.addChildAt(grid, 0);
		}
		
		//required to restore its original state
		public function setCaller(clr:Object)
		{
			caller = clr;
		}
		
		public function setPos(x:Number, y:Number)
		{
			pos = new Point(x, y);
			body.x = x;
			body.y = y;
		}
		
		public override function pressRight()
		{
			if (!rightlock)
			{
				if (!haltRightClick)
				{
					if (!System.exclusiveRightClick || System.exclusiveRightClick == this)
					{
						finalize();
						if (caller) caller.activate();
					}
				}
			}
		}
		
		public override function finalize()
		{
			super.finalize();
			owner.removeChild(body);
		}
		
		public function activate(...args):void
		{
			if(!activated) activated = true;
		}
		
		public function deactivate(...args):void
		{
			if(activated) activated = false;
		}
		
		public function scrollTo(pg:int)
		{
			for (var i:int = 0; i < scrollLines.length; i++)
			{
				if (i >= pg && i-pg < scrollPageSize)
				{
					if (!scrollLines[i].visible) scrollLines[i].visible = true;
					scrollLines[i].y = scrollPivot+((i-pg)*scrollSeparator);
				}
				else scrollLines[i].visible = false;
			}
		}
		
		public function handleMouse(e:MouseEvent)
		{
			if (movable)
			{
				switch(e.type)
				{
					case(MouseEvent.MOUSE_DOWN):
						dragParent = new MovieClip();
						body.addChild(dragParent);
						
						dragHolder = new Hotspot(dragParent, osd, Osd.CMD_INVALID);
						dragHolder.setPos(new Point(defX-System.SCREEN_X/2, defY-System.SCREEN_Y/2));
						dragHolder.setSize(new Point(System.SCREEN_X*2, System.SCREEN_Y*2));
						dragHolder.area.addEventListener(MouseEvent.MOUSE_MOVE, handleMouse);
						dragHolder.area.addEventListener(MouseEvent.MOUSE_UP, handleMouse);

						dragPos = new Point(body.x, body.y);
						dragPivot = new Point(mouseX, mouseY);
						
						_osd.setHandler(this);
						break;
						
					case(MouseEvent.MOUSE_UP):
						dragHolder.area.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouse);
						dragHolder.area.removeEventListener(MouseEvent.MOUSE_UP, handleMouse);
						body.removeChild(dragParent);
						break;
						
					case(MouseEvent.MOUSE_MOVE):
						var dx:Number = dragPos.x + (mouseX - dragPivot.x);
						var dy:Number = dragPos.y + (mouseY - dragPivot.y);
						var mx:Number = pos.x;
						var my:Number = pos.y;
						var xmax:Number = System.SCREEN_X - globalPos.x - w;
						var xmin:Number = 0-(System.SCREEN_X - xmax - w);
						var ymax:Number = System.SCREEN_Y - globalPos.y - h;
						var ymin:Number = 0-(System.SCREEN_Y - ymax - h);
						
						if (Math.abs(dx) < Math.abs(xmax)) mx  = dx;
						else
						{
							if (Math.abs(xmax) - Math.abs(dx) < 1.5) //stick window strictly to screen bounds
							{
								if (dx - Math.abs(xmax) > -1) mx = xmax;
								else mx = xmin;
							}
						}

						if (Math.abs(dy) < Math.abs(ymax)) my  = dy;
						else
						{
							if (Math.abs(ymax) - Math.abs(dy) < 1.5) //stick window strictly to screen bounds
							{
								if (dy - Math.abs(ymax) > -1) my = ymax;
								else my = ymin;
							}
						}
						
						setPos(mx, my);
						break;
				}
			}
		}
		
		public function osdCommand(cmd:int):void
		{
			if (wndScroller) //scrollable windows
			{
				if (cmd >= Osd.CMD_SCROLL && cmd <= Osd.CMD_SCROLL+scrollPageSize) scrollTo(cmd-Osd.CMD_SCROLL);
			}
		}
	}
}