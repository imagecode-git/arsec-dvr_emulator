package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	public class Scroller extends Gadget
	{
		public static const STYLE_VERTICAL = 0;
		public static const STYLE_HORIZONTAL = 1;
		
		private var target:MovieClip;
		private var clickable:MovieClip;
		private var holder:Sprite;
		private var bar:ScrollButton;
		
		private var pos:Point;
		
		internal var w:Number;
		internal var h:Number;
		internal var itemCount:int;
		internal var pageSize:int; //amount of elements on a single page
		internal var scrollStep:int = 1; //defines how many page elements are being scrolled at once
		internal var curPage:int = 0;
		internal var style = STYLE_VERTICAL;
		
		public function Scroller(ow:Object, o:Osd, w:Number, h:Number, ps:int, ic:int, ...args)
		{
			owner = ow;
			osd = o;
			pageSize = ps;
			itemCount = ic;

			this.w = w;
			this.h = h;

			if (args && args.length) style = args[0];
			
			target = new MovieClip();
			clickable = new MovieClip();
			holder = new RoundRect(0, 0, w, h, 0, 0, Osd.COLOR_DEFAULT);
			if (style == STYLE_VERTICAL) bar = new ScrollButton(this, w*2.5, h/(itemCount/pageSize));
			else bar = new ScrollButton(this, w/(itemCount/pageSize), h*2.5);
			
			clickable.addChild(holder);
			target.addChild(clickable);
			target.addChild(bar);
			
			addChild(target);
			owner.addChild(this);
			
			actor = clickable;
			super();
		}
		
		public function setPos(xy:Point)
		{
			if (!globalPos) globalPos = xy;
			pos = xy;
			target.x = pos.x;
			target.y = pos.y;
		}
		
		public function setPage(p:int)
		{
			bar.scrollTo(p-1);
		}
		
		public function pageCount():int
		{
			return itemCount/pageSize;
		}

		public function scrollLength():int
		{
			return itemCount - pageSize;
		}
	
		public function scrollToElement(e:int):int
		{
			var page:int;
			if (e >= pageSize) page = (e - pageSize + 1) * scrollStep;
			setPage(page+1);
			
			return e-page*scrollStep; //position of element on detected page
		}
		
		public function elementOnPage(e:int):int
		{
			var page:int;
			if (e >= pageSize) page = (e - pageSize + 1) * scrollStep;
			
			return e-page * scrollStep;
		}
		
		public function pageUp()
		{
			if (curPage < itemCount/scrollStep) setPage(curPage+1);
		}
		
		public function pageDown()
		{
			if (curPage > 1) setPage(curPage-1);
		}
		
		//scroll by mouse click
		//BUGGY!!
		public override function press()
		{
			var mpos:Number;
			var bpos:Number;
			
			if (style == STYLE_VERTICAL)
			{
				mpos = mouseY-globalPos.y;
				bpos = bar.getPos().y;
			}
			
			if (style == STYLE_HORIZONTAL)
			{
				mpos = mouseY-globalPos.x;
				bpos = bar.getPos().x;
			}
			
			if (mpos < bpos) pageDown();
			else pageUp();
		}
		
		public override function sendMessage()
		{
			super.sendMessage();
		}
	}
}