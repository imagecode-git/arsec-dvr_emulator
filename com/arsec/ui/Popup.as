package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	public class Popup extends Gadget
	{
		private var w:Number;
		private var h:Number;
		private var round:int = 30;
		private var facing:int = 2;
		private var pos:Point;
		
		private var label:TextLabel;
		private var labelMargin:int = 10;
		private var labelText:String;
		private var labelMask:Sprite;
		
		private var border:RoundRect;
		private var holder:RoundRect;
		
		private var borderPin:Sprite;
		private var holderPin:Sprite;
		private var pinSize:int = 25;
		private var pinPos:Point;
		
		private var shadow:DropShadowFilter;
		private var clickable:Hotspot;
		
		private var scrollable:Boolean = false;
		private var scrollDelay:Timer;
		private var scrollDelayTime:int = 3000;
		private var scrollInitTime:int = 1500;
		private var scrollSpeed:Number = 0.3;
		
		private var usePin:Boolean = false;
		private var upside:Boolean = false;
		private var finalizeable:Boolean = true;
		
		private var guide:UserGuide;
		public var guideID:int = -1;
		
		private var scrollState:int = 0
		
		private var _osd:Osd;
		
		//important note about XY positioning: if pin is used, XY must be set to the point where pin top corner is being placed at, otherwise just use left top corner of squared rectangle
		public function Popup(ow:Object, o:Osd, g:UserGuide, id:int, x:Number, y:Number, w:Number, h:Number, str:String, ...args)
		{
			owner = ow;
			osd = o;
			_osd = new Osd(this);
			
			guide = g;
			guideID = id;
			
			if (args && args.length)
			{
				if (args[0]) usePin = args[0];
				if (args[1]) upside = args[1];
				if (args[2]) facing = args[2];
				if (args[3]) round = args[3];
			}
			
			this.w = w;
			this.h = h;
			
			if (!usePin)
			{
				this.x = x;
				this.y = y;
				pinSize = 0;
			}
			else
			{
				this.x = x-w/2;
				if(!upside) this.y = y-h-pinSize;
				else this.y = y+pinSize;
			}
			
			var dlt:Number = 0;
			var xmin:Number = 50;
			var xmax:Number = System.SCREEN_X-xmin;
			
			if (this.x < xmin)
			{
				dlt = xmin+Math.abs(this.x);
				this.x += dlt;
			}
			else
			{
				if (this.x > xmax-w)
				{
					dlt = this.x-xmax+w;
					this.x -= dlt;
					
					dlt = xmax-x-w/2-pinSize/20; //for adjusting pin
				}
			}
			
			labelText = str;
			
			//text holder rectangle
			border = new RoundRect(-facing, -facing, w+facing*2, h+facing*2, 0, round, Osd.COLOR_DEFAULT);
			holder = new RoundRect(0, 0, w, h, 0, round-facing, Osd.COLOR_WINDOW);
			
			//pin border
			var mul:int = 1;
			var ypos:Number = h;
			
			pinPos = new Point(w/2-dlt, ypos);
			
			if (upside)
			{
				mul *= (-1);
				ypos = 0;
				dlt *= mul;
				pinPos = new Point(w/2+dlt, ypos);
			}
			
			addChild(border);
			addChild(holder);
			
			if (usePin)
			{
				//triangle pin
				holderPin = new Sprite();
				borderPin = new Sprite();
				
				borderPin.graphics.beginFill(Osd.COLOR_DEFAULT);
				borderPin.graphics.moveTo(pinPos.x-pinSize/2-facing*1.25, ypos);
				borderPin.graphics.lineTo(pinPos.x, pinPos.y+mul*(pinSize*0.75+facing*2));
				borderPin.graphics.lineTo(pinPos.x+pinSize/2+facing*1.25, ypos);
				
				//pin holder
				holderPin.graphics.beginFill(Osd.COLOR_WINDOW);
				holderPin.graphics.moveTo(pinPos.x-pinSize/2, pinPos.y);
				holderPin.graphics.lineTo(pinPos.x, pinPos.y+mul*(pinSize*0.75));
				holderPin.graphics.lineTo(pinPos.x+pinSize/2, ypos);
				holderPin.graphics.endFill();
				
				addChild(borderPin);
				addChild(holderPin);
			}
			
			label = _osd.addLabel(labelMargin+facing, labelMargin-facing, labelText, Osd.COLOR_TEXT, TextLabel.TYPE_SMALL);
			label.setWidth(w-2.75*labelMargin);
			label.setHeight(h-2*labelMargin);
			label.setAlign(TextLabel.ALIGN_JUSTIFY);
			label.setMultiline();
			
			if (label.getHeight() > h-labelMargin) scrollable = true;
			
			labelMask = new Sprite();
			labelMask.graphics.beginFill(Osd.COLOR_DEFAULT);
			labelMask.graphics.drawRect(labelMargin+facing, labelMargin-facing, w-2.75*labelMargin, h-1.75*labelMargin);
			
			addChild(labelMask);
			label.getLabel().mask = labelMask;
			
			clickable = new Hotspot(this, _osd, Osd.CMD_INVALID);
			clickable.setSize(new Point(w, h));
			clickable.setPos(new Point(w/2, h/2));
			
			shadow = new DropShadowFilter(5, 45, 0, 1.0, 14, 14, 0.45, 2);
			filters = [shadow];
			
			actor = clickable.area;
			
			owner.addChild(this);
			super();
			
			finalizeable = false;
			alpha = 0;
			
			owner = ow;
		}
		
		public override function show()
		{
			addEventListener(Event.ENTER_FRAME, handleEvent);
		}
		
		//immediately kills popup
		public function forceDestroy()
		{
			finalizeable = true;
			finalize();
		}
		
		public override function finalize()
		{
			if (finalizeable)
			{
				removeEventListener(Event.ENTER_FRAME, handleEvent);
				clickable.finalize();
				
				super.finalize();
				guide.notify(guideID);
				owner.removeChild(this);
			}
		}
		
		public function update(st:int)
		{
			switch(st)
			{
				case(Gadget.STATE_DEFAULT):
					setPinColor(Osd.COLOR_WINDOW);
					holder.setColor(Osd.COLOR_WINDOW);
					label.setColor(Osd.COLOR_TEXT);
					break;
					
				case(Gadget.STATE_HOVER):
					setPinColor(Osd.COLOR_SELECTED);
					holder.setColor(Osd.COLOR_SELECTED);
					label.setColor(Osd.COLOR_INVERTED);
					break;
					
				case(Gadget.STATE_HOLD):
					setPinColor(Osd.COLOR_SELECTED);
					holder.setColor(Osd.COLOR_SELECTED);
					label.setColor(Osd.COLOR_DEFAULT);
					break;
			}
		}
		
		public function setPinColor(c:uint)
		{
			if (usePin)
			{
				var ct:ColorTransform = new ColorTransform();
				ct.color = c;
				holderPin.transform.colorTransform = ct;
			}
		}
		
		public override function hover()
		{
			update(Gadget.STATE_HOVER);
			super.hover();
		}
		
		public override function unfocus()
		{
			update(Gadget.STATE_DEFAULT);
			super.unfocus();
		}
		
		public override function hold()
		{
			update(Gadget.STATE_HOLD);
			super.hold();
		}
		
		public override function unhold()
		{
			if (!focused) update(Gadget.STATE_DEFAULT);
			else update(Gadget.STATE_HOVER);
			
			finalize();
			super.hold();
		}
		
		public function setPos(x:Number, y:Number)
		{
			this.x = x;
			this.y = y;
			
			pos = new Point(x,y);
		}
		
		public function addDelay(t:int)
		{
			scrollDelay = new Timer(t);
			scrollDelay.addEventListener(TimerEvent.TIMER, this.handleEvent);
			scrollDelay.start();
		}
		
		public function handleEvent(e:Event)
		{
			if (e.type == TimerEvent.TIMER)
			{
				if (scrollState < 2) scrollState++;
				else scrollState = 0;
				
				label.setPos(new Point(label.getPos().x, labelMargin - facing));
				scrollDelay.removeEventListener(TimerEvent.TIMER, this.handleEvent);
				scrollDelay = null;
			}
			else
			{
				if (e.type == Event.ENTER_FRAME)
				{
					if (alpha < 1.0) alpha += 0.1;
					else
					{
						if(!finalizeable) finalizeable = true;
						
						if (scrollable)
						{
							if (!scrollState)
							{
								addDelay(scrollInitTime); //delay before text field scrolls down from the very top
								scrollState++;
							}
							else
							{
								if (!scrollDelay || (scrollDelay && !scrollDelay.running))
								{
									if (label.getPos().y <= clickable.height + h - labelMargin - label.getHeight() + facing)
									{
										addDelay(scrollDelayTime); //delay when text is completely scrolled to the very bottom
										scrollState++;
									}
									else label.setPos(label.getPos().subtract(new Point(0, scrollSpeed)));
								}
							}
						}
					}
				}
			}
		}
	}
}