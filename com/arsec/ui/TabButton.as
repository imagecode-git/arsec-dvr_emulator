package com.arsec.ui
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.BlendMode;
	import flash.display.Stage;
	import flash.geom.Point;
	import com.arsec.ui.*;
	import com.arsec.system.*;
	
	public class TabButton extends Gadget
	{
		private var target:MovieClip;
		private var holder:Sprite;
		private var body:Sprite;
		
		private var label:TextLabel;
		private var labelText:String = "Tab button";
	
		private var border:Number = 2;
		private var round:Number = 10;
		
		private var bar:TabBar;
		private var pos:Point;
		private var w:Number;
		private var h:Number;
		
		public var selected:Boolean = false;
		public var id:int = -1;
		public var linkCmd:int = Osd.CMD_INVALID;
		
		public function TabButton(tb:TabBar, w:Number, h:Number, str:String, c:int, ...args)
		{
			target = new MovieClip();
			osd = new Osd(this);
			bar = tb;
			linkCmd = c;
			
			this.w = w;
			this.h = h;
			
			if (args && args.length)
			{
				if (args[0]) round = args[0];
				if (args[1]) border = args[1];
			}
			
			if (bar.type != TabBar.TYPE_TEXT)
			{
				holder = new Sprite();
				holder.graphics.beginFill(Osd.COLOR_DEFAULT);
				holder.graphics.drawRoundRectComplex(0, 0, w, h, round, round, 0, 0);
				holder.graphics.endFill();
				target.addChild(holder);
				
				body = new Sprite();
				body.graphics.beginFill(Osd.COLOR_WINDOW);
				body.graphics.drawRoundRectComplex(border, border, w-2*border, h+border, round-border, round-border, 0, 0);
				body.graphics.endFill();
				target.addChild(body);
				
				this.blendMode = BlendMode.NORMAL;
				body.blendMode = BlendMode.ERASE;
			}
			
			if (bar.type != TabBar.TYPE_FRAME)
			{
				osd.setHandler(target); //switching to target to place text inside right layer
				
				var color:uint = Osd.COLOR_DISABLED;
				if (bar.type == TabBar.TYPE_NORMAL) color = Osd.COLOR_SELECTED;
				
				label = osd.addLabel(0, 0, str, color);
				label.blendMode = BlendMode.LAYER;
				setText(str);
				
				osd.setHandler(this);
			}
			
			update(Gadget.STATE_DEFAULT);
			addChild(target);
			if(bar.type != TabBar.TYPE_FRAME) actor = this;
			
			super();
		}
		
		public function getCommand():int
		{
			return linkCmd;
		}
		
		public function setText(txt:String)
		{
			labelText = txt;
			label.setText(txt);
			label.setPos(new Point(x+w/2-border-label.getWidth()/2, y+h/2+border-label.getHeight()/2));
		}
		
		public function setPos(xy:Point)
		{
			if (!globalPos) globalPos = xy;
			pos = xy;
			x = pos.x;
			y = pos.y;
		}
		
		public function update(st:int)
		{
			var color:uint = Osd.COLOR_SELECTED;
			
			switch(st)
			{
				case(Gadget.STATE_DEFAULT):
					if (selected)
					{
						if (bar.type == TabBar.TYPE_TEXT) color = Osd.COLOR_DEFAULT;
						else
						{
							holder.visible = true;
							body.visible = true;
						}
					}
					else
					{
						color = Osd.COLOR_DISABLED;
						if (bar.type != TabBar.TYPE_TEXT)
						{
							holder.visible = false;
							body.visible = false;
						}
					}
					
					if(label) label.setColor(color);
					break;
					
				case(Gadget.STATE_HOVER):
					if(label) label.setColor(color);
					break;
					
				case(Gadget.STATE_HOLD):
					if (bar.type == TabBar.TYPE_TEXT) color = Osd.COLOR_DEFAULT;
					if(label) label.setColor(color);
					break;
			}
		}
		
		public function select(st:Boolean)
		{
			if(selected != st)
			{
				selected = st;
				update(Gadget.STATE_DEFAULT);
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
			bar.setSelection(id);
			
			if (focused) update(Gadget.STATE_HOVER);
			else update(Gadget.STATE_DEFAULT);
			
			super.unhold();
		}
	}
}