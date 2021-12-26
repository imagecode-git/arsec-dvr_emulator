package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	
	public class SchedulerTable extends Window
	{
		private static const CMD_ADD_LINE:int = 1;
		private static const CMD_DEL_LINE:int = 2;
		
		private static const CMD_OK:int = 500;
		
		public static const TYPE_DUAL:int	= 0;
		public static const TYPE_SINGLE:int	= 1;
		
		public var type:int = TYPE_DUAL;
		
		private var scheduler:Scheduler;
		private var day:int;
		private var gpos:Array;
		private var days:Array = new Array("Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота");
		private var pattern:Array;
		private var lines:Array;
		
		public function SchedulerTable(sc:Scheduler, o:Osd, t:int, d:int, p:Array)
		{
			scheduler = sc;
			owner = sc;
			osd = o;
			
			gpos = new Array();
			type = t;
			day = d;
			pattern = p;
			
			if(type == TYPE_DUAL)
			{
				w = 512;
				h = 386;
				
				gpos.push(new Point(-150, -142));
				gpos.push(new Point(-25, -142));
				gpos.push(new Point(141, -142));
				gpos.push(new Point(-215, -99));
				gpos.push(new Point(-37, 150));
				gpos.push(new Point(40, 150));
				gpos.push(new Point(155, 150));
			}
			else
			{
				w = 377;
				h = 396;
				
				gpos.push(new Point(-81, -137));
				gpos.push(new Point(39, -137));
				gpos.push(new Point(0, 0));
				gpos.push(new Point(-140, -95));
				gpos.push(new Point(-76, 156));
				gpos.push(new Point(3, 156));
				gpos.push(new Point(119, 156));
			}
			
			super(sc, o, 0, 0, w, h, 2, 52, true, true);
			
			_osd.setHandler(body);
			
			var lbl:TextLabel = _osd.addLabel(0, 0, days[day], Osd.COLOR_TEXT);
			lbl.setPos(new Point(-lbl.getWidth()/2, -172));
			
			_osd.addLabel(gpos[0].x, gpos[0].y, "Начало", Osd.COLOR_TEXT);
			_osd.addLabel(gpos[1].x, gpos[1].y, "Окончание", Osd.COLOR_TEXT);
			if (type == TYPE_DUAL) _osd.addLabel(gpos[2].x, gpos[2].y, "Тип", Osd.COLOR_TEXT);
			
			buildTable();
			
			_osd.addTextButton(gpos[4].x, gpos[4].y, "Доб.", CMD_ADD_LINE, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
			_osd.addTextButton(gpos[5].x, gpos[5].y, "Удалить", CMD_DEL_LINE, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
			_osd.addTextButton(gpos[6].x, gpos[6].y, "OK", CMD_OK, TextLabel.TYPE_NORMAL, Osd.COLOR_TEXT);
			
			_osd.setHandler(this);
			
			System.exclusiveRightClick = this;
			locker.setPos(new Point(defX-System.SCREEN_X/2, defY-System.SCREEN_Y/2));
		}
		
		private function buildTable()
		{
			var vsep:int = 32;
			var wbox:int = 118;
			var hsep:Array = [26, 165];
			
			if (type == TYPE_DUAL) hsep = [32, 170, 308];
			
			lines = new Array();
			for (var i:int = 0; i < 8; i++)
			{
				var loc:Array = new Array();
				
				var cb:CheckBox = _osd.addCheckBox(gpos[3].x, gpos[3].y + vsep * i, Osd.CMD_INVALID);
				cb.uncheck();
				
				var ti0:TextInput = _osd.addTextInput(gpos[3].x + hsep[0], gpos[3].y - 14 + vsep * i, wbox, "00:00:00", Osd.CMD_INVALID, TextInput.FMT_TIME);
				var ti1:TextInput = _osd.addTextInput(gpos[3].x + hsep[1], gpos[3].y - 14 + vsep * i, wbox, "23:59:59", Osd.CMD_INVALID, TextInput.FMT_TIME);
			
				var lb:ListBox;
				if (type == TYPE_DUAL) lb = _osd.addListBox(gpos[3].x + hsep[2], gpos[3].y - 14 + vsep * i, wbox, new Array("Тревога", "Норм."));
				
				loc.push(cb);
				loc.push(ti0);
				loc.push(ti1);
				if(lb) loc.push(lb);
				
				lines.push(loc);
				deleteLine(i);
			}
			
			fillTable();
		}
		
		private function fillTable()
		{
			var t0:String = new String();
			var t1:String = new String();
			var m:int = 0;
			
			var valid:Boolean = false;
			
			for (var i:int = 0; i < pattern.length-2; i++)
			{
				if (i == 0)
				{
					t0 = pattern[0];
					t1 = pattern[2];
					m =  pattern[1];
					
					if(m != SchedulerSegment.MODE_ERASE) valid = true;
				}
				else
				{
					if (pattern[i+1] != SchedulerSegment.MODE_ERASE)
					{
						t0 = pattern[i];
						t1 = pattern[i+2];
						m =  pattern[i+1];
						
						valid = true;
					}
					else valid = false;
				}
				
				if (valid)
				{
					var ln:int = addLine();
					lines[ln][1].setValue(t0);
					lines[ln][2].setValue(t1);
					if (type == TYPE_DUAL)
					{
						var sel:int = 1;
						if (m == SchedulerSegment.MODE_ALARM) sel = 0;
						
						lines[ln][3].selectItem(sel);
					}
				}
				
				i++;
			}
		}
		
		private function busyLine(id:int):Boolean
		{
			var arr:Array = lines[id];
			for (var i:int = 0; i < arr.length; i++)
			{
				if (arr[i].visible == true) return true;
			}
			
			return false;
		}
		
		private function deleteLine(id:int)
		{
			var arr:Array = lines[id];
			for (var i:int = 0; i < arr.length; i++) arr[i].visible = false;

			arr[0].uncheck();
			arr[1].setValue("00:00:00");
			arr[2].setValue("23:59:59");
			if (type == TYPE_DUAL) arr[3].selectItem(1);
		}
		
		private function addLine():int
		{
			var idx:int = getLastLine();
			var arr:Array = lines[idx];

			for (var j:int = 0; j < arr.length; j++) arr[j].visible = true;
			
			return idx;
		}
		
		public function getLastLine():int
		{
			for (var i:int = 0; i < lines.length-1; i++)
			{
				if (!busyLine(i)) return i;
			}
			
			return lines.length-1;
		}
		
		public function moveLine(id:int, trg:int)
		{
			var a0:Array = lines[id];
			var a1:Array = lines[trg];
			
			a1[0].uncheck();
			a1[1].setValue(a0[1].getValue());
			a1[2].setValue(a0[2].getValue());
			if (type == TYPE_DUAL) a1[3].selectItem(a0[3].getValue());
			
			for (var i:int = 0; i < a1.length; i++) a1[i].visible = true;
			
			deleteLine(id);
		}
		
		public function generatePattern():Array
		{
			var result:Array = new Array();
			
			for (var i:int = 0; i < getLastLine(); i++)
			{
				var arr:Array = lines[i];
				var from:String = arr[1].getValue();
				var to:String = arr[2].getValue();
				var mode:Boolean = false;
				if (type == TYPE_DUAL) mode = new Boolean(arr[3].getValue());
				
				result.push(from, to, new int(!mode));
			}
			
			return result;
		}
		
		public override function pressRight()
		{
			if (!caller) System.exclusiveRightClick = null;
			else System.exclusiveRightClick = caller as Window;
			
			finalize();
		}
		
		public override function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_OK):
					scheduler.readPattern(generatePattern(), day);
					pressRight();
					break;
					
				case(CMD_ADD_LINE):
					addLine();
					break;
					
				case(CMD_DEL_LINE):
					var arr:Array;
					var selection:Array = new Array();
					
					for (var i:int = 0; i < lines.length; i++)
					{
						if (lines[i][0].checked) selection.push(i);
					}
					
					if (selection.length)
					{
						for (i = 0; i < selection.length; i++) deleteLine(selection[i]);
					}
					
					for (i = 0; i < lines.length; i++)
					{
						if (!busyLine(i))
						{
							for (var j:int = i; j < lines.length; j++)
							{
								if (busyLine(j))
								{
									moveLine(j, i);
									break;
								}
							}
						}
					}

					break;
			}
		}
	}
}