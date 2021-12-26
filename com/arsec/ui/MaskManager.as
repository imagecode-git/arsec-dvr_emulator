package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class MaskManager extends MovieClip
	{
		private static const MAX_MASKS = 4;
		private static const DEF_FACING = 3;
		
		private var owner:Object;
		private var osd:Osd;
		private var events:Array = new Array(MouseEvent.MOUSE_UP, MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_MOVE);
		private var masks:Array;
		private var drawing:Boolean = false;
		private var curChannel:int = 0;
		
		private var locker:Hotspot;
		private var dragPos:Point;
		
		private var focused:Boolean = false;
		
		public function MaskManager(ow:Object)
		{
			owner = ow;
			osd = new Osd(ow);
			width = System.SCREEN_X;
			height = System.SCREEN_Y;
			
			blendMode = BlendMode.LAYER;
			
			locker = osd.addHotspot(System.SCREEN_X/2, System.SCREEN_Y/2, System.SCREEN_X, System.SCREEN_Y, Osd.CMD_INVALID);
			for (var i:int = 0; i < events.length; i++) owner.stage.addEventListener(events[i], this.handleEvent);
			
			show();
			
			masks = new Array();
			for (var j:int = 0; j < System.CHANNELS; j++) masks.push(new Array());

			owner.addChild(this);
		}
		
		public function show()
		{
			locker.area.addEventListener(MouseEvent.MOUSE_OVER, handleEvent);
			locker.area.addEventListener(MouseEvent.MOUSE_OUT, handleEvent);
			
			visible = true;
			locker.show();
		}
		
		public function hide()
		{
			locker.area.removeEventListener(MouseEvent.MOUSE_OVER, handleEvent);
			locker.area.removeEventListener(MouseEvent.MOUSE_OUT, handleEvent);
			
			visible = false;
			locker.hide();
		}
		
		public function setChannel(ch:int)
		{
			if (curChannel != ch)
			{
				showMasks(false);
				curChannel = ch;
				showMasks(true);
			}
		}
		
		public function reset(ch:int)
		{
			for (var i:int = 0; i < masks[curChannel].length; i++)
			{
				var mr:MaskRect = masks[curChannel][i];

				mr.removeEventListener(MouseEvent.DOUBLE_CLICK, handleEvent);
				mr.finalize();
			}
			
			masks[curChannel] = new Array();
		}
		
		public function showMasks(st:Boolean)
		{
			if (masks[curChannel].length)
			{
				for (var i:int = 0; i < masks[curChannel].length; i++) masks[curChannel][i].visible = st;
			}
		}
		
		public function finalize()
		{
			for (var i:int = 0; i < events.length; i++)  owner.stage.removeEventListener(events[i], this.handleEvent);
			for (i = 0; i < System.CHANNELS; i++) reset(i);
			locker.finalize();
			
			owner.removeChild(this);
		}
		
		public function handleEvent(e:MouseEvent)
		{
			if (focused)
			{
				switch(e.type)
				{
					case(events[0]): //MOUSE_UP
						if (drawing)
						{
							var arr:Array = masks[curChannel];
							if(!arr[arr.length-1].endDraw()) arr.splice(arr.length-1, 1);
							drawing = false;
						}
						break;
					
					case(events[1]): //MOUSE_DOWN
						if (masks[curChannel].length < MAX_MASKS)
						{
							dragPos = new Point(e.stageX, e.stageY);
							var mr:MaskRect = new MaskRect(System.masks, dragPos.x, dragPos.y, DEF_FACING, masks[curChannel].length);

							mr.addEventListener(MouseEvent.DOUBLE_CLICK, this.handleEvent);
							mr.addEventListener(MouseEvent.MOUSE_OVER, this.handleEvent);
							mr.addEventListener(MouseEvent.MOUSE_OUT, this.handleEvent);
							
							mr.doubleClickEnabled = true;
							mr.mouseChildren = false;
							mr.setPivot(dragPos);
							
							masks[curChannel].push(mr);
							drawing = true;
						}
						break;
						
					case(events[2]): //MOUSE_MOVE
						if (drawing) masks[curChannel][masks[curChannel].length-1].update(e.stageX-dragPos.x, e.stageY-dragPos.y); //re-indexing id's for all masks on selected channel
						break;
				}
			}

			switch(e.type)
			{
				case(MouseEvent.DOUBLE_CLICK):
					masks[curChannel].splice(e.target.id, 1);
					for (var i:int = 0; i < masks[curChannel].length; i++) masks[curChannel][i].id = i;
					
					e.target.removeEventListener(MouseEvent.DOUBLE_CLICK, handleEvent);
					e.target.finalize();
					break;
				
				case(MouseEvent.MOUSE_OVER):
					focused = true;
					break;
					
				case(MouseEvent.MOUSE_OUT):
					focused = false;
					break;
			}
		}
	}
}