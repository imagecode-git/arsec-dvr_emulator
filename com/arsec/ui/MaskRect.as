package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class MaskRect extends MovieClip
	{
		internal var owner:Object;
		internal var target:MovieClip;
		internal var rect:RoundRect;

		internal var facing:int;
		internal var pos:Point;
		internal var pivotPos:Point;
		
		public var inverseX:Boolean = false;
		public var inverseY:Boolean = false;
		
		public var id:int;
		
		public function MaskRect(ow:Object, x:Number, y:Number, fc:int, id:int, ...args)
		{
			owner = ow;
			facing = fc;
			
			blendMode = BlendMode.LAYER;
			
			target = new MovieClip();
			
			var a:Number = 1.0; //alpha of 'inside' rectangle
			var c:uint = Osd.COLOR_CHMASKBRD;
			if (args && args.length)
			{
				if (args[0] != undefined || !isNaN(args[0])) a = args[0];
				if (args[1] != undefined || !isNaN(args[1])) c = args[1];
			}
			rect = new RoundRect(0, 0, 100, 100, fc, 0, Osd.COLOR_CHMASKHLD, c, a);
			target.addChild(rect);
			
			addChild(target);
			owner.addChild(this);
			
			setPos(new Point(x, y));
			update(0, 0);
			
			this.id = id;
		}
		
		public function setPivot(p:Point)
		{
			pivotPos = p;
		}
		
		public function getArea():RoundRect
		{
			return rect;
		}
		
		public function update(dx:Number, dy:Number)
		{
			//this will reverse rectangle if scaling is negative
			if (dx < 0)
			{
				inverseX = true;
				scaleX = -1;
			}
			else
			{
				inverseX = false;
				scaleX = 1;
			}
			
			if (dy < 0)
			{
				inverseY = true;
				scaleY = -1;
			}
			else
			{
				inverseY = false;
				scaleY = 1;
			}
			
			dx = Math.abs(dx);
			dy = Math.abs(dy);
			
			if (dx < facing*2) dx = 0;
			if (dy < facing*2) dy = 0;
			
			rect.width = dx;
			rect.height = dy;
		}
		
		public function endDraw()
		{
			if (getWidth() < facing*2 || getHeight() < facing*2)
			{
				finalize(); //this prevents conflicts with double-click in mask manager
				return 0;
			}
			return 1;
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
		
		public function getWidth():Number
		{
			return rect.width;
		}
		
		public function getHeight():Number
		{
			return rect.height;
		}
		
		public function setWidth(wd:Number)
		{
			rect.width = wd;
		}
		
		public function setHeight(wh:Number)
		{
			rect.height = wh;
		}
		
		public function finalize()
		{
			owner.removeChild(this);
		}
	}
}