package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import com.arsec.ui.dialog.MessageDialog;
	import com.arsec.ui.dialog.WarningDialog;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	
	public class Scheduler extends MovieClip
	{
		private static const LINE_LENGTH:int = 48; //12 hours * 4 subsegments
		
		//modes of scheduler itself
		public static const MODE_DUAL:int	= 0; //both normal and alarm modes are applied to matrix segments
		public static const MODE_SINGLE:int	= 1; //alarm mode or disabled segments
		
		private var caller:Object;
		private var owner:Object;
		private var osd:Osd;
		private var locker:Hotspot;
		private var lock:Boolean = false;
		
		private var gridLinesH:Array;
		private var gridLinesV:Array;
		private var weekDays:Array;
		
		private var segments:Array;
		private var segmentHotspots:Array;
		private var pivot:Array; //identifier of a matrix segment that is being picked as a basis (something like a drag pivot)
		private var watching:Boolean = false;
		private var update:Boolean = false; //this will force all selected matrix segments to update their current defstates
		
		private var pos:Point;
		
		private var mode:int = MODE_DUAL;

		private var drawModes:Array;
		private var curDrawMode:int;
		
		public function Scheduler(ow:Object, m:int)
		{
			owner = ow;
			osd = new Osd(this);
			mode = m;
			
			if (mode == MODE_SINGLE) drawModes = new Array(SchedulerSegment.MODE_ERASE, SchedulerSegment.MODE_ALARM);
			else drawModes = new Array(SchedulerSegment.MODE_NORMAL, SchedulerSegment.MODE_ALARM);
			
			curDrawMode = 1;
		
			weekDays = new Array("Вс.", "Пон.", "Вт.", "Ср.", "Чт.", "Птн.", "Сб.");
			
			buildGrid();
			owner.addChild(this);
		}
		
		public function buildGrid()
		{
			gridLinesH = new Array();
			gridLinesV = new Array();
			
			segments = new Array();
			segmentHotspots = new Array();
		
			var tx:Number
			var ty:Number = -117;
			var sv:Number = 28; //step V
			var sh:Number = 11; //step H
			
			var defMode:int = drawModes[curDrawMode];
			
			//segment matrix, lies on bottom layer, since there must be a grid created above it further
			for (var i:int = 0; i < weekDays.length; i++)
			{
				var loc:Array = new Array();
				
				tx = -235;
				for (var j:int = 0; j <= LINE_LENGTH; j++)
				{
					var ss:SchedulerSegment = new SchedulerSegment(this, tx, ty, drawModes[0], [i,j]);
					if (j == LINE_LENGTH) ss.visible = false; //fictive, invisible segments!
					loc.push(ss);
					tx += sh;
				}
				ty += sv;
				
				segments.push(loc);
			}
			
			//grid: horizontal lines
			var step:int = 28;
			for (i = 0; i < 8; i++)
			{
				var lh:RoundRect = new RoundRect(0, 0, 588, 2, 0, 0, Osd.COLOR_DEFAULT);
				lh.setPos(-lh.width/2, -118+(i*step));
				lh.alpha = System.GRIDLINE_ALPHA;
				
				addChild(lh);
				gridLinesH.push(lh);
				
				if (i > 0) osd.addLabel(gridLinesH[i-1].getPos().x+3, gridLinesH[i-1].getPos().y+4, weekDays[i-1], Osd.COLOR_TEXT); //week day titles
			}
			
			step = 44;
			var substep:int = 11;
			for (i = 0; i < 12; i++)
			{
				//grid: long vertical lines
				var lv:RoundRect = new RoundRect(0, 0, 2, 203, 0, 0, Osd.COLOR_DEFAULT);
				lv.setPos(-235 + (i*step), -125);
				lv.alpha = System.GRIDLINE_ALPHA;

				addChild(lv);
				gridLinesV.push(lv);
				
				//hour titles
				var lb:TextLabel = osd.addLabel(0, 0, new String(i*2), Osd.COLOR_DEFAULT);
				lb.setPos(new Point(gridLinesV[i].getPos().x-lb.getWidth()/2, gridLinesV[i].getPos().y-lb.getHeight()+1));
				
				//grid: short intermediate vertical lines
				for (j = 0; j < 3; j++)
				{
					var ls:RoundRect = new RoundRect(0, 0, 2, 7, 0, 0, Osd.COLOR_DEFAULT);
					ls.setPos(gridLinesV[i].getPos().x + ((j+1)*substep), -125);
					ls.alpha = System.GRIDLINE_ALPHA;
					
					addChild(ls);
				}
			}
			
			locker = new Hotspot(this, osd, Osd.CMD_INVALID);
			locker.setSize(new Point(System.SCREEN_X*2, System.SCREEN_Y*2));
			locker.setPos(new Point(0, 0));
			locker.area.addEventListener(MouseEvent.MOUSE_MOVE, handleLock);
			locker.area.addEventListener(MouseEvent.MOUSE_OUT, handleLock);
			locker.hide();
			
			//we have to additionally spawn hotspots over grid, since the grid itself does interfere the interaction between matrix and cursor
			ty = -117;
			for (i = 0; i < weekDays.length; i++)
			{
				tx = -235;
				for (j = 0; j <= 12*4; j++)
				{
					var hs:Hotspot = new Hotspot(this, osd, Osd.CMD_INVALID);
					hs.setSize(new Point(segments[i][j].width, segments[i][j].height));
					hs.setPos(new Point(tx + hs.w/2, ty + hs.h/2));
					hs.attach(segments[i][j]);
					
					//we simulate right click in hotspot to prevent conflicts with all left click events matrix segment object
					hs.area.addEventListener(MouseEvent.DOUBLE_CLICK, hs.handleRightClick);
					hs.area.doubleClickEnabled = true;
					hs.area.mouseChildren = false;
					
					segmentHotspots.push(hs);
					
					tx += sh;
				}
				ty += sv;
			}
		}
		
		public function swapDrawMode()
		{
			var bool:Boolean = new Boolean(curDrawMode);
			curDrawMode = new int(!bool);
		}
		
		//returns pattern that can be read by scheduler itself
		public function getOptimizedPattern(day:int):Array
		{
			var result:Array = new Array();
			var input:Array = getPattern(day);
			
			var t0:String = new String();
			var t1:String = new String();
			var m:int = 0;
			
			for (var i:int = 0; i < input.length-2; i++)
			{
				if (i == 0)
				{
					t0 = input[0];
					t1 = input[2];
					m =  input[1];
				}
				else
				{
					if (input[i+1] != SchedulerSegment.MODE_ERASE)
					{
						t0 = input[i];
						t1 = input[i+2];
						m =  input[i+1];
					}
				}
				
				result.push(t0, t1, m);
				i++;
			}

			return result;
		}
		
		//returns pattern that is valid for reading only by scheduler table
		public function getPattern(day:int):Array
		{
			forceUpdate(); //to make sure that all matrix segments have proper defMode set
			
			var pattern:Array = new Array();
			var mark:Boolean = false;
			
			for (var i:int = 0; i < LINE_LENGTH+1; i++)
			{
				if (i == 0) mark = true;
				else
				{
					if (i == LINE_LENGTH)
					{
						pattern.push("23:59:59");
						pattern.push(segments[day][i].defMode);
					}
					else
					{
						if (segments[day][i-1].defMode != segments[day][i].defMode) mark = true;
					}
				}
				
				if (mark)
				{
					var h:int = Math.floor(i/2);
					var m:int = (i-h*2)*30;
					var s:String = "00";
					var d:String = ":";
					
					var hstr:String = new String(h);
					if (h<10) hstr = "0"+hstr;
					
					var mstr:String = new String(m);
					if (m<10) mstr = "0"+mstr;
					
					pattern.push(new String(hstr + d + mstr + d + s));
					pattern.push(segments[day][i].defMode);
					
					mark = false;
				}
			}
			watching = false;
			update = false;
			
			return pattern;
		}
		
		public function getTimeTable(day:int)
		{
			var pattern:Array = getPattern(day);
			var sct:SchedulerTable = new SchedulerTable(this, osd, mode, day, pattern);
			if (caller) sct.setCaller(caller); //will backup exclusive right click if scheduler is placed inside some external window
		}
		
		public function readPattern(pat:Array, d:int)
		{
			for (var i:int = 0; i < LINE_LENGTH + 1; i++) segments[d][i].setMode(SchedulerSegment.MODE_ERASE);
			for (i = 0; i < pat.length-2; i++)
			{
				var from:int = timeToSegment(pat[i]);
				var to:int = timeToSegment(pat[i+1]);

				for (var j:int = from; j < to; j++) segments[d][j].setMode(pat[i+2]);
				i+=2;
			}
			
			forceUpdate();
		}
		
		public function timeToSegment(input:String):int
		{
			var t:Array = new Array();
			var result:int = 0;
			
			t.push(input.slice(0,2));
			t.push(input.slice(3,5));
			
			result =  t[0]*2 + Math.round(t[1]/30);
			
			return result;
		}
		
		//checking if there are not more than 8 segments per each matrix line
		public function checkSegments():Boolean
		{
			var seg:int = 0;
			var curMode:int = -1;
			
			for (var i:int; i < weekDays.length; i++)
			{
				seg = 0;
				for (var j:int = 0; j < LINE_LENGTH+1; j++)
				{
					if (j == 0) curMode = segments[i][j].mode;
					else
					{
						if (segments[i][j-1].mode != segments[i][j].mode || j == LINE_LENGTH)
						{
							if (seg < 8)
							{
								if (curMode != SchedulerSegment.MODE_ERASE) seg++;
								curMode = segments[i][j].mode;
							}
							else return false;
						}
					}
				}
			}
			
			return true;
		}
		
		public function haltUpdate()
		{
			stopWatch();
			flushMatrix();
			
			update = false;
			lock = false;
			
			new WarningDialog(owner, osd, "Максимальное число периодов: 8");
		}
		
		//this message comes in every time we hover the cursor over segment
		public function notify(id:Array, factor:Boolean)
		{
			var newmode:int = drawModes[curDrawMode];
		
			if ((watching || update) && !lock)
			{
				if (id != pivot && pivot[1] != LINE_LENGTH) //fictive line (the last invisible one) never serves as a pivot
				{
					//picking the right order for updating matrix segments, according to pivot
					var fromcol:int;
					var tocol:int;
					if (id[1] < pivot[1])
					{
						fromcol = id[1];
						tocol = pivot[1];
					}
					else
					{
						if (id[1] > pivot[1])
						{
							fromcol = pivot[1];
							tocol = id[1];
						}
					}

					for (var j:int = fromcol; j < tocol; j++)
					{
						if (update) segments[pivot[0]][j].defMode = newmode;
						if (!factor) newmode = segments[pivot[0]][j].defMode;
						
						segments[pivot[0]][j].setMode(newmode); //single-line processing

					}
					
					if (!checkSegments())
					{
						haltUpdate();
						return;
					}
					
					if (id[0] != pivot[0])
					{
						var fromrow:int;
						var torow:int;
						if (id[0] < pivot[0])
						{
							fromrow = id[0];
							torow = pivot[0];
						}
						else
						{
							if (id[0] > pivot[0])
							{
								fromrow = pivot[0];
								torow = id[0]+1;
							}
						}
						for (var i:int = fromrow; i < torow; i++)
						{
							for (j = fromcol; j < tocol; j++)
							{
								if (update) segments[i][j].defMode = newmode;
								if (!factor) newmode = segments[i][j].defMode;
								
								segments[i][j].setMode(newmode); //multi-line processing, if more than one selected
							}
						}
						
						if (!checkSegments())
						{
							haltUpdate();
							return;
						}
					}
				}
				if (update && !watching) update = false;
			}
		}
		
		public function forceUpdate()
		{
			for (var i:int = 0; i < weekDays.length; i++)
			{
				for (var j:int = 0; j < LINE_LENGTH; j++) segments[i][j].defMode = segments[i][j].mode;
			}
		}
		
		public function flushMatrix()
		{
			for (var i:int = 0; i < weekDays.length; i++)
			{
				for (var j:int = 0; j < LINE_LENGTH; j++) segments[i][j].setMode(segments[i][j].defMode);
			}
		}
		
		//set selected mode for all segments
		public function unifyMatrix(m:int)
		{
			for (var i:int = 0; i < weekDays.length; i++)
			{
				for (var j:int = 0; j < LINE_LENGTH; j++) segments[i][j].setMode(m);
			}
		}
		
		//this does initiate interaction with matrix
		public function beginWatch(id:Array)
		{
			if (!watching)
			{
				pivot = id;
				locker.show();
				watching = true;
				
				locker.area.addEventListener(MouseEvent.MOUSE_UP, handleLock);
			}
		}
		
		public function stopWatch()
		{
			if (watching)
			{
				if (!lock) update = true; //normally updating states for all matrix segments if selection was ended inside the matrix itself
				else forceUpdate(); //or forced update if selection was dropped somewhere outside matrix
				
				locker.hide();
				watching = false;
				
				locker.area.removeEventListener(MouseEvent.MOUSE_UP, handleLock);
			}
			
			if (!update && pivot) pivot = null;
		}
		
		public function setPos(x:Number, y:Number)
		{
			pos = new Point(x,y);
			this.x = x;
			this.y = y;
		}
		
		public function handleLock(e:MouseEvent):void
		{
			switch(e.type)
			{
				case(MouseEvent.MOUSE_MOVE):
					lock = true;
					break;
					
				case(MouseEvent.MOUSE_OUT):
					lock = false;
					if (watching) flushMatrix(); //we return to selection in some random position, so we need to revert entire matrix to its original state (i.e. how it was before beginning selection)
					break;
					
				case(MouseEvent.MOUSE_UP):
					stopWatch();
					break;
			}
		}
		
		public function setCaller(clr:Object)
		{
			caller = clr;
		}
		
		public function finalize()
		{
			locker.finalize();
			for (var i:int = 0; i < segmentHotspots.length; i++) segmentHotspots[i].finalize();
			owner.removeChild(this);
		}
	}
}