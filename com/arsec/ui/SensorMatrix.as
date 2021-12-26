package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class SensorMatrix extends MovieClip
	{
		private const MTX_W:int = 15;
		private const MTX_H:int = 12;

		public static const SEG_SEP:int = 2;
		
		private var owner:Object;
		private var caller:Object;
		private var segments:Array;
		
		private var pivot:Array;
		
		private var watching:Boolean = false;
		private var selected:Boolean = false;
		
		private var retChannel:int;
		
		public function SensorMatrix(ow:Object, ch:int)
		{
			retChannel = System.actChannel;
			System.manager.selectChannel(ch);
			
			owner = ow;
			segments = new Array();
			for (var k:int; k < MTX_H; k++) segments.push(new Array());
			
			var w:Number = (System.SCREEN_X-SEG_SEP*(MTX_W+SEG_SEP))/MTX_W;
			var h:Number = (System.SCREEN_Y-SEG_SEP*(MTX_H+SEG_SEP))/MTX_H;

			var xpos:Number = (SEG_SEP+w-Math.round(w))*1.5;
			var ypos:Number = (SEG_SEP+h-Math.round(h))*1.5;
			var defx:Number = xpos;
			
			for (var i:int = 0; i < MTX_H; i++)
			{
				xpos = defx;
				for (var j:int = 0; j < MTX_W; j++)
				{
					segments[i].push(new SensorSegment(this, this, xpos, ypos, w, h, [i,j]));
					xpos += w+SEG_SEP;
				}
				ypos += h+SEG_SEP;
			}
			
			owner.addChild(this);
			stage.addEventListener(MouseEvent.CONTEXT_MENU, handleRightClick); //if right click is used, gadget must be always finalized in order to remove event listener from stage!
		}
		
		public function beginWatch(id:Array, st:Boolean)
		{
			pivot = id;
			selected = st;
			watching = true;
		}
		
		public function notify(id:Array, factor:Boolean)
		{
			var fromcol:int;
			var tocol:int;
			
			var fromrow:int;
			var torow:int;
			
			if (watching)
			{
				if (id[1] > pivot[1])
				{
					fromcol = pivot[1];
					tocol = id[1];
				}
				else
				{
					fromcol = id[1];
					tocol = pivot[1];
				}
				
				segments[pivot[0]][id[1]].select(!selected);
				for (var i:int = fromcol; i < tocol+1; i++) segments[pivot[0]][i].select(!selected); //single-line processing
				
				if (id[0] != pivot[0])
				{
					if (id[0] > pivot[0])
					{
						fromrow = pivot[0];
						torow = id[0];
					}
					else
					{
						fromrow = id[0];
						torow = pivot[0];
					}
					
					for (i = fromrow; i < torow+1; i++)
					{
						for (var j:int = fromcol; j < tocol+1; j++) segments[i][j].select(!selected); //multi-line processing
					}
				}
			}
		}
		
		public function stopWatch()
		{
			watching = false;
		}
		
		public function setCaller(cl:Object)
		{
			caller = cl;
		}
		
		public function finalize()
		{
			for (var i:int = 0; i < segments.length; i++)
			{
				for (var j:int = 0; j < segments[i].length; j++) segments[i][j].finalize();
			}
			
			System.manager.selectChannel(retChannel);
			if(caller) caller.osdCommand(Osd.CMD_GAD_UPDATE);
			if(owner) owner.removeChild(this);
		}
		
		public function handleRightClick(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.CONTEXT_MENU, handleRightClick);
			finalize();
		}
	}
}