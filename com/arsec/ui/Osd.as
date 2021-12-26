package com.arsec.ui
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import com.arsec.ui.*;
	import com.arsec.system.*;
	
	public class Osd extends EventDispatcher
	{
		public static const CMD_INVALID:int		= -1;
		public static const CMD_SLD_UPDATE:int	= 500; //updating slider value
		public static const CMD_GAD_UPDATE:int	= 40000;
		public static const CMD_SCROLL:int		= 50000; //subtract this from scroller cmd to obtain current page index
		
		public static const ALPHA_DEFAULT:Number	= 1.0;
		public static const ALPHA_DISABLED:Number	= 0.5;
		
		//text/rect colors
		public static const COLOR_DEFAULT:uint		= 0xFFFFFF;
		public static const COLOR_CARET:uint		= 0x000000;
		public static const COLOR_DARKEN:uint		= 0x000000;
		public static const COLOR_DISABLED:uint 	= 0x696969; //light-grey
		public static const COLOR_SELECTED:uint 	= 0xFFA500;
		public static const COLOR_DRAGGED:uint		= 0x9E7C00; //pressed scroller bar
		public static const COLOR_INVERTED:uint 	= 0x0C0F18; //kinda "black"
		public static const COLOR_TEXT:uint			= 0xC0C0C0; //ultra light-grey
		public static const COLOR_WINDOWMASK:uint 	= 0x181818; //dark color for masked window stripes
		
		public static const COLOR_SENSORDEF:uint 	= 0x6C6C6C; //sensor disabled segment
		
		//mask rect
		public static const COLOR_CHMASKBRD:uint 	= 0xFA2737; //border
		public static const COLOR_CHMASKHLD:uint 	= 0x181818; //holder
		
		public static const COLOR_WINDOW:uint 		= 0x202020; //window, hints, bars, etc.
		
		internal var handler:Object;
		
		public function Osd(h:Object)
		{
			handler = h;
		}
		
		public function setHandler(h:Object)
		{
			handler = h;
		}
		
		public function addLabel(x:Number, y:Number, t:String, ...args):TextLabel
		{
			var s:int;
			var c:uint = COLOR_DEFAULT;
			if (args && args.length)
			{
				if (args[0]) c = args[0]; //text color
				if (args[1]) s = args[1]; //size
			}
			
			var lbl:TextLabel = new TextLabel(handler, this, s);
			lbl.setPos(new Point(x,y));
			lbl.setText(t);
			
			lbl.setColor(c);
			
			return lbl;
		}
		
		public function addImage(x:Number, y:Number, p:String):Image
		{
			var img:Image = new Image(handler, this, p);
			img.setPos(new Point(x,y));
			
			return img;
		}
		
		public function addImageButton(x:Number, y:Number, s0:String, s1:String, s2:String, c:int, ...args):ImageButton
		{
			var hint:String;
			if (args && args[0]) hint = args[0];
			
			var btn:ImageButton = new ImageButton(handler, this, c, s0, s1, s2, hint);
			btn.setPos(new Point(x, y));
			
			return btn;
		}
		
		public function addTextButton(x:Number, y:Number, t:String, c:int, ...args):TextButton
		{
			var type = TextLabel.TYPE_NORMAL;
			var defColor = Osd.COLOR_DEFAULT;
			
			if (args && args.length)
			{
				if (args[0]) type = args[0];
				if (args[1]) defColor = args[1];
			}
			
			var tb = new TextButton(handler, this, c, type, defColor);
			
			tb.setPos(new Point(x, y));
			tb.setText(t);
			
			return tb;
		}
		
		public function addHotspot(x:Number, y:Number, w:Number, h:Number, c:int):Hotspot
		{
			var hs:Hotspot = new Hotspot(handler, this, c);
			
			hs.setPos(new Point(x, y));
			hs.setSize(new Point(w, h));
			
			return hs;
		}
		
		public function addCheckBox(x:Number, y:Number, c:int, ...args):CheckBox
		{
			var str:String;
			var mono:Boolean;
			if (args && args.length)
			{
				if (args[0]) str = args[0];
				if (args[1]) mono = args[1];
			}

			var cb:CheckBox = new CheckBox(handler, this, c, str, mono);
			cb.setPos(new Point(x, y));
			
			return cb;
		}
		
		public function addListBox(x:Number, y:Number, w:Number, a:Array, ...args):ListBox
		{
			var scrollable:int;
			var upside:Boolean;
			var command:int;
			
			if (args && args.length)
			{
				if (args[0]) scrollable = args[0];
				if (args[1]) upside = args[1];
				if (args[2]) command = args[2];
			}
			
			var lb:ListBox = new ListBox(handler, this, w, a, scrollable, upside, command);
			lb.setPos(new Point(x, y));

			return lb;
		}
		
		public function addTextInput(x:Number, y:Number, w:Number, s:String, c:int, ...args):TextInput
		{
			var ti:TextInput;

			if (args && args.length)
			{
				var type:int;
				var maxValue:int;
				var maxChar:int;
				
				if (args[0]) type = args[0];
				if (args[1]) maxValue = args[1];
				if (args[2]) maxChar = args[2];
				
				ti = new TextInput(handler, this, w, s, c, type, maxValue, maxChar);
			}
			else ti = new TextInput(handler, this, w, s, c);
			ti.setPos(new Point(x,y));
			
			return ti;
		}
		
		public function addTextLine(x:Number, y:Number, w:Number, val:Array, ...args):TextLine
		{
			var tl:TextLine;
			var c:int = CMD_INVALID;
			var sz:int = TextLabel.TYPE_NORMAL;
			var cl:uint = Osd.COLOR_TEXT;
			var dlt:Array;
			
			if (args && args.length)
			{
				if (args[0]) c = args[0]; //cmd
				if (args[1]) sz = args[1]; //text size
				if (args[2]) cl = args[2]; //text color
				if (args[3]) dlt = args[3]; //deltas (if more than one text is defined)
			}
			
			tl = new TextLine(handler, this, w, val, c, cl, sz, dlt);
			tl.setPos(new Point(x,y));
			
			return tl;
		}
		
		public function addScroller(x:Number, y:Number, w:Number, h:Number, pageSize:int, itemCount:int, ...args):Scroller
		{
			var sc:Scroller;

			if (args && args.length) sc = new Scroller(handler, this, w, h, pageSize, itemCount, args[0]);
			else sc = new Scroller(handler, this, w, h, pageSize, itemCount);
			sc.setPos(new Point(x,y));
			
			return sc;
		}
		
		public function addSlider(x:Number, y:Number, w:Number, h:Number, mn:Number, mx:Number, c:int, ...args):Slider
		{
			var sl:Slider;
			var val:Number;
			var lb:TextLabel;

			if (args && args.length)
			{
				if (args[0]) val = args[0];
				if (args[1]) lb = args[1];
				sl = new Slider(handler, this, w, h, mn, mx, c, val, lb);
			}
			else sl = new Slider(handler, this, w, h, mn, mx, c);
			sl.setPos(new Point(x, y));

			return sl;
		}
		
		public function calcCenter(w:Number, h:Number):Point
		{
			return new Point(System.SCREEN_X / 2 - w / 2, System.SCREEN_Y / 2 - h / 2);
		}

		public function handleEvent(e:GadgetEvent):void
		{
			if (handler) handler.osdCommand(e.cmd); //correspodning message back to handler with a given event ID
		}
	}
}