package com.arsec.ui
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.geom.Point;
	import com.arsec.ui.*;
	import com.arsec.system.*;
	
	import flash.events.MouseEvent;
	
	public class Hotspot extends Gadget
	{
		private var debugMode:Boolean = false; //makes area visible
		public var area:MovieClip;
		
		public var w:Number;
		public var h:Number;
		private var pos:Point;
		
		private var con:Gadget;
		
		private var cmdHover:int = Osd.CMD_INVALID;
		private var cmdLeave:int = Osd.CMD_INVALID;
		
		public function Hotspot(ow:Object, o:Osd, c:int)
		{
			area = new Area();
			owner = ow;
			osd = o;
			
			var alpha:Number;
			if (debugMode) alpha = 0.5;
			else alpha = 0;
			
			w = area.width;
			h = area.height;
			setAlpha(alpha)
			owner.addChild(area);
			
			actor = area;
			super();
			cmd = c;
			
			owner = ow;
		}
		
		public override function hide()
		{
			area.visible = false;
			super.hide();
		}
		
		public override function show()
		{
			area.visible = true;
			super.hide();
		}
		
		//activates hover/leave osd commands
		public function activate(c0:int, c1:int)
		{
			cmdHover = c0;
			cmdLeave = c1;
		}
		
		public function setAlpha(a:Number)
		{
			area.alpha = a;
		}
		
		public function setPos(xy:Point)
		{
			area.x = xy.x;
			area.y = xy.y;
			pos = xy;
			if (!globalPos) globalPos = xy;
		}
		
		public function getPos():Point
		{
			return pos;
		}
	
		public function setSize(wh:Point)
		{
			w = wh.x;
			h = wh.y;
			area.width = w;
			area.height = h;
		}
		
		public function attach(g:Gadget)
		{
			con = g;
		}
		
		public override function focus()
		{
			if (con) con.focus();
			super.focus();
		}
	
		public override function unfocus()
		{
			//action at leaving the gadget, if assigned
			if (cmdLeave > Osd.CMD_INVALID)
			{
				cmd = cmdLeave;
				sendMessage();
			}

			if (con) con.unfocus();
			super.unfocus();
		}
		
		public override function hover()
		{
			//hover action, if assigned
			if (cmdHover > Osd.CMD_INVALID)
			{
				cmd = cmdHover;
				sendMessage();
			}
			
			if (con) con.hover();
			super.hover();
		}
		
		public override function press()
		{
			if (con) con.press();
			super.press();
		}
		
		public override function pressRight()
		{
			if (con) con.pressRight();
			super.pressRight();
		}
		
		public override function hold()
		{
			if (con) con.hold();
			super.hold()
		}
		
		public override function unhold()
		{
			if (con) con.unhold();
			super.unhold();
		}
		
		public override function drag()
		{
			if (con) con.drag();
			super.drag()
		}
		
		public override function dragBegin()
		{
			if (con) con.dragBegin();
			super.dragBegin();
		}
		
		public override function dragEnd()
		{
			if (con) con.dragEnd();
			super.dragEnd()
		}
		
		public override function finalize()
		{
			if(owner) owner.removeChild(area);
			super.finalize();
		}
	}
}