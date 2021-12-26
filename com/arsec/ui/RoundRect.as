package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.LineScaleMode;
	import flash.display.GradientType;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class RoundRect extends Sprite
	{
		private var rect:Sprite;
		private var pos:Point;
		private var w:Number;
		private var h:Number;
		private var round:int; //smoothness of round corners
		private var border:int; //border thickness
		private var bodyColor:uint = Osd.COLOR_WINDOW;
		private var borderColor:uint = Osd.COLOR_DEFAULT;
		private var bodyAlpha:Number;
	
		public function RoundRect(x:Number, y:Number, w:Number, h:Number, ...args)
		{
			pos = new Point(x, y);
			this.w = w;
			this.h = h;
			
			bodyAlpha = 1.0;
			
			if (args && args.length)
			{
				if (args[0]) border = args[0];
				if (args[1]) round = args[1];
				if (args[2]) bodyColor = args[2];
				if (args[3]) borderColor = args[3];
				if (args[4] != undefined || !isNaN(args[4])) bodyAlpha = args[4]; //alpha may come up with zero value, so we apply additional checks
			}
			else
			{
				//auto-calculate border thickness and border smoothness
				var min:Number;
				if (w < h) min = w;
				else min = h;
				
				border = Math.round(min/100);
				round = Math.round(min/5.5);
			}
			
			rect = new Sprite();
			if(border) rect.graphics.lineStyle(border, borderColor, 1, false, LineScaleMode.NONE);
			rect.graphics.beginFill(bodyColor, bodyAlpha);
			rect.graphics.drawRoundRect(pos.x, pos.y, w, h, round);
			rect.graphics.endFill();
			
			addChild(rect);
		}
		
		public function setColor(c:uint)
		{
			var ct:ColorTransform = new ColorTransform();
			ct.color = c;
			rect.transform.colorTransform = ct;
		}
		
		public function setGradient(colors:Array, alphas:Array, ratios:Array, ang:Number)
		{
			var mtx:Matrix = new Matrix();
			mtx.createGradientBox(w, h, ang, 0, 0);
			
			rect.graphics.clear();
			rect.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, mtx);
			rect.graphics.drawRoundRect(0, 0, w, h, round);
		}
	
		public function setPos(x:Number, y:Number)
		{
			pos = new Point(x, y);
			rect.x = pos.x;
			rect.y = pos.y;
		}
		
		public function getPos():Point
		{
			return pos;
		}
		
		public function getWidth():Number
		{
			return w;
		}
		
		public function getHeight():Number
		{
			return h;
		}
		
		public function getBorderWidth():int
		{
			return border;
		}
		
		public function finalize()
		{
			removeChild(rect);
		}
	}
}