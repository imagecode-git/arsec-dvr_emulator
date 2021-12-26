package com.arsec.ui
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.BlendMode;
	import flash.display.Stage;
	import flash.geom.Point;
	import com.arsec.ui.*;
	import com.arsec.system.*;
	
	public class TabBar extends Gadget
	{
		public static const TYPE_NORMAL	= 0; //frame + text
		public static const TYPE_TEXT	= 1; //text only
		public static const TYPE_FRAME	= 2; //frame only, but no hotspot, so it only supports external control
		
		internal var type:int = TYPE_NORMAL;
		
		private var target:MovieClip;
		private var border:Sprite;
		private var holder:Sprite;
		private var bottom:Sprite;
		
		private var thickness:int = 2;
		private var margin:int = 17; //left margin, an initial point where the first button is being set
		private var interval:int = 10; //distance between all buttons since the first one
		private var round:int = 10; //for buttons
		private var w:Number;
		private var h:Number;
		private var relX:Number = 0; //relative X, defines where to place next button
		private var pos:Point;
		
		private var selectedID = -1;
		private var buttons:Array;
		
		public function TabBar(ow:Object, o:Osd, w:Number, h:Number, t:int, ...args) //this object has no osd constructor - ext classes must build it themselves
		{
			owner = ow;
			osd = o;
			type = t;
			
			this.w = w;
			this.h = h;
			
			if (args && args.length)
			{
				if (args[0]) margin = args[0];
				if (args[1]) interval = args[1];
				if (args[2]) round = args[2];
			}

			buttons = new Array();
			
			if (type != TYPE_TEXT)
			{
				bottom = new Sprite();
				bottom.graphics.beginFill(Osd.COLOR_DEFAULT);
				bottom.graphics.drawRect(0, 0, w, thickness);
				bottom.graphics.endFill();
				addChild(bottom);
			}
			
			setPos(new Point(0,0));
		
			this.blendMode = BlendMode.LAYER;
			owner.addChild(this);
			actor = this;
		}
		
		public function addButton(bw:Number, str:String, c:int)
		{
			if (!buttons.length) relX += margin;
			else relX += interval;
			
			var ypos:Number = -h;
			if (type == TYPE_TEXT) h = 0;
			
			var btn:TabButton = new TabButton(this, bw, h, str, c, round);
			btn.setPos(new Point(relX, -h));
			buttons.push(btn);
			btn.id = buttons.length-1;
			
			addChild(btn);
			relX += bw;
			
			if (buttons.length == 1) setSelection(0);
		}
		
		public function setSelection(id:int)
		{
			if (id != selectedID)
			{
				if (selectedID < 0)
				{
					selectedID = 0;
					cmd = Osd.CMD_INVALID;
				}
				else cmd = buttons[id].getCommand();
				
				buttons[selectedID].select(false);
				buttons[id].select(true);
				selectedID = id;
				
				sendMessage(); //emerge osdCommand in handler
			}
		}
		
		public function setPos(xy:Point)
		{
			if (!globalPos) globalPos = xy;
			relX -= x;
			
			pos = xy;
			x = pos.x;
			y = pos.y;
			
			relX += x;
		}
	}
}