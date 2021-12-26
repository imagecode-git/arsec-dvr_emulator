package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	public class Calendar extends Gadget implements IEventHandler
	{
		public static const CMD_PREV_MONTH:int = 0;
		public static const CMD_NEXT_MONTH:int = 1;
		public static const CMD_NEXT_YEAR:int = 2;
		public static const CMD_PREV_YEAR:int = 3;
		public static const CMD_CLOSE:int = 4;
		public static const CMD_DATE_PICK:int = 100;
			
		internal var target:MovieClip;
		internal var border:Sprite;
		internal var holder:Sprite;
		internal var _osd:Osd; //for child objects
		internal var textInput:TextInput;
		
		internal var pos:Point;
		internal var w:Number;
		internal var h:Number;
		
		private var prevMonth:ImageButton;
		private var nextMonth:ImageButton;
		private var prevYear:ImageButton;
		private var nextYear:ImageButton;
		
		private var dayButtons:Array;
		
		private var labelMonth:TextLabel;
		private var labelYear:TextLabel;
		
		private var dayTitles = new Array("Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб");
		private var monthTitles = new Array("Янв.", "Фев.", "Мар.", "Апр.", "Май", "Июн.", "Июл.", "Авг.", "Сен.", "Окт.", "Ноя.", "Дек.");
		
		private var dateObject:Date;
		private var date:int;
		
		private var weekday:int;
		private var day:int;
		private var month:int;
		private var year:int;
		
		private var pickedIdx:int = -1;
		private var hoverIdx:int = -1; //initial hover on calendar show up
		private var initialState:Boolean = false;
		
		public function Calendar(ow:Object, o:Osd, ...args)
		{
			owner = ow;
			osd = o;
			if (args && args.length)
			{
				textInput = args[0];
				dateObject = textInput.getDate();
			}
			else dateObject = new Date();
			
			month = dateObject.getMonth();
			year = dateObject.getFullYear();
			day = dateObject.getDate();
			weekday = dateObject.getDay();
			
			//dimensions are fixed
			w = 220;
			h = 222;
			
			_osd = new Osd(this);
			if(textInput) _osd.addHotspot(0, 0, System.SCREEN_X * 2, System.SCREEN_Y * 2, CMD_CLOSE); //custom lock layer
			
			target = new MovieClip();
			border = new RoundRect(0, 0, w, h, 0, 35, Osd.COLOR_DEFAULT);
			target.addChild(border);
			
			holder = new RoundRect(2, 2, w - 4, h - 4, 0, 33, Osd.COLOR_WINDOW)
			target.addChild(holder);

			_osd = new Osd(target);
			var s0:String;
			var s1:String;
			
			s0 = "LeftArrow.png";
			s1 = "LeftArrowFocus.png";
			prevMonth = _osd.addImageButton(20, 10, s0, s1, s1, CMD_PREV_MONTH);
			prevYear = _osd.addImageButton(120, 10, s0, s1, s1, CMD_PREV_YEAR);
			labelMonth = _osd.addLabel(39, 7, "Month", Osd.COLOR_TEXT, TextLabel.TYPE_SMALL);
			updateMonthTitle();
			
			s0 = "RightArrow.png";
			s1 = "RightArrowFocus.png";
			nextMonth = _osd.addImageButton(90, 10, s0, s1, s1, CMD_NEXT_MONTH);
			nextYear = _osd.addImageButton(190, 10, s0, s1, s1, CMD_NEXT_YEAR);
			labelYear = _osd.addLabel(145, 7, "Year", Osd.COLOR_TEXT, TextLabel.TYPE_SMALL);
			updateYearTitle();
			
			for (var i:int = 0; i < dayTitles.length; i++)
			{
				_osd.addLabel(17 + i * 27, 46, dayTitles[i], Osd.COLOR_TEXT, TextLabel.TYPE_SMALL);
			}
			
			build();
			
			addChild(target);
			owner.addChild(this);
			_osd.setHandler(this);
		}
		
		public function build()
		{
			if (!dayButtons) dayButtons = new Array();
			else
			{
				for (var l:int = 0; l < dayButtons.length; l++) target.removeChild(dayButtons[l]);
				dayButtons = new Array();
			}
				
			var past:int = 0;
			var present:int = 0;
			var future:int = 0;
			
			var daysPast:int = getDays(getPast().getMonth());
			var daysPresent:int = getDays(month);
			
			var dayNum:int = 0;
			var dlt:int = new Date(year, month, 1).getDay();
			var shift:int;
			
			var procDate:Date;
			var picked:Boolean = false;
			var procIdx:int;
			var btnType:int;
			
			pickedIdx = -1;
			
			for (var j:int = 0; j < 6; j++)
			{
				var act:Boolean = false;
				
				for (var k:int = 0; k < 7; k++)
				{
					if (past < dlt)
					{
						btnType = CalendarButton.TYPE_PAST;
						procDate = new Date(getPast().getFullYear(), getPast().getMonth(), daysPast - past);
						dayNum = daysPast - past -  1;
						past++;
						act = false;
					}
					else
					{
						if (present < daysPresent)
						{
							btnType = CalendarButton.TYPE_PRESENT;
							dayNum = present;
							procDate = new Date(year, month, dayNum+1);
							present++;
							act = true;
							if (hoverIdx < 0) hoverIdx = procIdx;
							
							if (!picked)
							{
								if (procDate.getDate() == day) pickedIdx = procIdx;
								else
								{
									if (day > getDays(procDate.getMonth()))
									{
										day = getDays(procDate.getMonth());
										pickedIdx = procIdx + day - 1;
									}
								}
							}
						}
						else
						{
							btnType = CalendarButton.TYPE_FUTURE;
							procDate = new Date(getFuture().getFullYear(), getFuture().getMonth(), future+1);
							dayNum = future;
							future++;
							act = false;
						}
					}
					
					var title:String = new String(dayNum + 1);
					var btn = new CalendarButton(17 + procDate.getDay() * 27, 70 + j * 25, title, act, btnType, procIdx, this);
					if (pickedIdx >= 0 && procIdx == pickedIdx)
					{
						if (!picked)
						{
							btn.pick(true);
							picked = true;
						}
					}

					target.addChild(btn);
					dayButtons.push(btn);

					procIdx++;
				}
			}
			
			dayButtons[hoverIdx].hover();
			initialState = true;
		}
		
		public function wakeUp()
		{
			if (initialState)
			{
				for (var i:int = 0; i < dayButtons.length; i++) dayButtons[i].unfocus();
				initialState = false;
			}
		}
		
		//returns max days in selected month
		public function getDays(m:int):int
		{
			var result:int;
			
			if (m == 3 || m == 5 || m == 8 || m == 10) return 30;
			else
			{
				if (m == 1)
				{
					if (!(year % 4)) result = 29;
					else result = 28;
				}
				else result = 31;
			}
			
			return result;
		}
		
		public function updateMonthTitle()
		{
			labelMonth.setText(monthTitles[month]);
			labelMonth.setPos(new Point(62-labelMonth.getWidth()/2, 7));
		}
		
		public function updateYearTitle()
		{
			labelYear.setText(new String(year));
			labelYear.setPos(new Point(162-labelYear.getWidth()/2, 7));
		}
		
		public function setPos(xy:Point)
		{
			if (!globalPos) globalPos = xy;
			pos = xy;
			x = pos.x;
			y = pos.y;
		}
		
		//used only to build/rebuild calendar
		public function getPast():Date
		{
			var mpast:int = month;
			var ypast:int = year;

			if (mpast > 0) mpast = mpast - 1;
			else
			{
				mpast = 11;
				ypast = year - 1;
			}
			
			return new Date(ypast, mpast);
		}
		
		//used only to build/rebuild calendar
		public function getFuture():Date
		{
			var mfuture:int = month;
			var yfuture:int = year;
			
			if (mfuture < 12) mfuture = mfuture + 1; 
			else
			{
				mfuture = 0;
				yfuture = year + 1;
			}
			
			return new Date(yfuture, mfuture);
		}
		
		//returns currently active date
		public function getDate():Date
		{
			return new Date(year, month, day);
		}
		
		public function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_PREV_MONTH):
					var tpy:int = year;
					var tpm:int = month;
					
					if (year >= 2000)
					{
						if (month > 0) month--;
						else
						{
							if (year > 2000)
							{
								year--;
								month = 11;
							}
						}
					}
					
					if (tpm != month)
					{
						build();
						updateMonthTitle();
						updateYearTitle();
					}
					break;
					
				case(CMD_NEXT_MONTH):
					var tfy:int = year;
					var tfm:int = month;
					
					if (year <= 2038)
					{
						if (month < 11) month++;
						else
						{
							if (year < 2038)
							{
								year++;
								month = 0;
							}
						}
					}
					
					if (tfm != month)
					{
						build();
						updateMonthTitle();
						updateYearTitle();
					}
					break;
					
				case(CMD_PREV_YEAR):
					if (year > 2000)
					{
						year--;
						build();
						updateYearTitle();
					}
					break;
					
				case(CMD_NEXT_YEAR):
					if (year < 2038)
					{
						year++;
						build();
						updateYearTitle();
					}
					break;
					
				case(CMD_CLOSE):
					if (textInput)
					{
						textInput.setDate(getDate());
						textInput.saveInput();
					}
					break;
			}
			
			if (cmd >= CMD_DATE_PICK) //this cmd comes from calendar buttons
			{
				var newIdx = cmd - CMD_DATE_PICK; //detecting idx of button that has sent cmd
				if (dayButtons)
				{
					dayButtons[pickedIdx].pick(false); //unselecting old date
					dayButtons[newIdx].pick(true); //selecting new one
					pickedIdx = newIdx;
					day = new int(dayButtons[newIdx].getTitle()); //updating current day
					
					var t = dayButtons[pickedIdx].type;
					switch(t)
					{
						case(CalendarButton.TYPE_PAST): //date from past month has been picked
							osdCommand(CMD_PREV_MONTH);
							break;
							
						case(CalendarButton.TYPE_FUTURE): //some date from the future is picked
							osdCommand(CMD_NEXT_MONTH);
							break;
						
						case(CalendarButton.TYPE_PRESENT):
							if(textInput) osdCommand(CMD_CLOSE);
							break;
					}
				}
			}
		}
	}
	
}