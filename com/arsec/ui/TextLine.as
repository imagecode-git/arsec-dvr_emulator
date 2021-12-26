package com.arsec.ui
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import com.arsec.ui.*;
	import com.arsec.system.*;
	
	public class TextLine extends Gadget
	{
		private var _osd:Osd;
		private var labels:Array;
		private var values:Array;
		private var deltas:Array;
		
		private var bar:RoundRect;
		private var clickable:Hotspot;
		private var dcmd:int;
		
		private var w:Number;
		private var h:Number;
		private var dy:Number;
		private var pos:Point;
		
		private var textColor:uint;
		private var textSize:int;
		
		public function TextLine(ow:Object, o:Osd, w:Number, str:Array, c:int, cl:uint, sz:int, ...args)
		{
			owner = ow;
			osd = o;
			
			x = 0;
			y = 0;
			this.w = w;
			
			if (args && args.length) deltas = args[0];
			cmd = c;
			
			textColor = cl;
			textSize = sz;
			
			labels = new Array();
			_osd = new Osd(this);
			
			for (var i:int = 0; i < str.length; i++)
			{
				if (str.length == 1) x += w/2;
				else x += deltas[i];
				
				var lbl:TextLabel = _osd.addLabel(0, 0, str[i], textColor, textSize);
				lbl.setPos(new Point(x-lbl.getWidth()/2, y+(lbl.getHeight()/1.5)/4));
				
				labels.push(lbl);
			}
			
			dy = labels[0].getHeight()/1.5;
			
			bar = new RoundRect(0, 0, w, dy*2, 0, 0, Osd.COLOR_SELECTED);
			addChildAt(bar, 0);
			bar.visible = false;
			
			clickable = new Hotspot(this, osd, cmd);
			clickable.setSize(new Point(w, dy*2));
			clickable.setPos(new Point(w/2, dy));
			
			actor = clickable.area;
			addChild(clickable);
			
			values = str;

			clickable.noclick = true;
			clickable.area.doubleClickEnabled = true;
			clickable.area.mouseChildren = false;
			clickable.area.addEventListener(MouseEvent.DOUBLE_CLICK, this.handleMouse);
		
			owner.addChild(this);
			super();
		}
		
		public override function finalize()
		{
			clickable.area.removeEventListener(MouseEvent.DOUBLE_CLICK, this.handleMouse);
			super.finalize();
		}
		
		public function setPos(xy:Point)
		{
			this.x = xy.x;
			this.y = xy.y;
			
			pos = xy;
		}
		
		public function getPos():Point
		{
			return pos;
		}
		
		public function getHotspot():Hotspot
		{
			return clickable;
		}
		
		public function getValue(idx:int):String
		{
			return labels[idx].text;
		}
		
		public function setValue(idx:int, str:String)
		{
			labels[idx].setText(str);
		}
		
		public override function focus()
		{
			bar.visible = true;
			super.focus();
		}
	
		public override function unfocus()
		{
			bar.visible = false;
			super.unfocus();
		}
		
		public override function hover()
		{
			super.hover();
		}
		
		public function handleMouse(e:MouseEvent)
		{
			clickable.sendMessage(); //safely sends message via hotspot on double click
		}
	}
}