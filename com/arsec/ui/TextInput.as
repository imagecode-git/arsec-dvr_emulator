package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.util.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	public class TextInput extends Gadget
	{
		public static const DEF_LINE_HEIGHT:int = 30;
		public static const LINE_HEIGHT:int = 28;
		public static const SHORT_LINE_HEIGHT:int = 24;
		
		//24-hour or 12-hour time switches
		public static const TIME_24:int = 0;
		public static const TIME_12:int = 1;
		
		//for 12-hour time only
		public static const TIME_AM:int = 0;
		public static const TIME_PM:int = 1;
		
		//various date display formats
		public static const DATE_MDY:int = 0;
		public static const DATE_YMD:int = 1;
		public static const DATE_DMY:int = 2;
		
		public static const FMT_DEFAULT:int = 0;
		public static const FMT_DIGITAL:int = 1;
		public static const FMT_PASSWORD:int = 2;
		public static const FMT_DATE:int = 3;
		public static const FMT_TIME:int = 4;
		public static const FMT_IP:int = 5;
		public static const FMT_MAC:int = 6;
		
		private var target:MovieClip;
		private var holder:Sprite;
		private var core:Sprite;
		private var border:Sprite;
		private var caret:Sprite;

		private var w:Number;
		private var h:Number = LINE_HEIGHT;
		private var pos:Point;
		
		private var caretPos:Point;
		private var state = Gadget.STATE_DEFAULT;
		private var maxChar:int = 20;
		private var maxValue:int = 9999;
		private var value:String;
		
		private var password:String;
		private var ip:int;
		private var date:Date;
		private var dateFormat:int = System.dateFormat;
		private var time:int;
		private var timeFormat:int = System.timeFormat;
		public  var timePeriod:int = System.timePeriod;
		private var timeLink:ListBox;
		
		private var round:int = 14; //def corner round level
		private var facing:int = 2;
		
		private var label:TextLabel;
		private var _osd:Osd; //for child objects
		private var kosd:Osd; //for keyboard
		private var labelText:String = "Input text"; //only displayed (visible to user) text!
		
		private var type:int = FMT_DEFAULT;
		private var userInput:Boolean = false;
		private var keyboard:VirtualKeyboard;
		private var calendar:Calendar;
		private var curChar:int; //index of currently processed character inside the input string
		
		//toDo: calendar linkage
		public function TextInput(ow:Object, o:Osd, w:Number, s:String, c:int, ...args)
		{
			labelText = s;
			
			if (args && args.length)
			{
				if (args[0]) type = args[0];
				if (args[1]) maxValue = args[1];
				if (args[2]) maxChar = args[2];
			}
			
			if (System.textLine == System.TEXTLINE_LONG)
			{
				h = DEF_LINE_HEIGHT;
				round = 12;
			}
			
			if (System.textLine == System.TEXTLINE_SHORT)
			{
				h = SHORT_LINE_HEIGHT;
				round = 12;
			}

			switch(type)
			{
				case(FMT_PASSWORD):
					value = labelText;
					labelText = getPassword(labelText);
					break;
					
				case(FMT_TIME):
					if (labelText == " ") labelText = timeToString(getTimeValue()); //only UTC time yet
					time = timeToValue(labelText);
					maxChar = 8;
					value = labelText;
					break;
					
				case(FMT_IP):
					ip = new int(labelText);
					maxChar = 15;
					value = labelText;
					break;
					
				case(FMT_MAC):
					maxChar = 17;
					value = labelText;
					break;
					
				case(FMT_DATE):
					date = new Date();
					labelText = dateToString(date);
					value = labelText;
					break;
					
				default:
					value = labelText;
					break;
			}
			
			curChar = labelText.length;

			this.w = w;
			
			target = new MovieClip();
			
			border = new RoundRect(0, 0, w, h, 0, round+facing+1, Osd.COLOR_DEFAULT); //border is smoother than inset
			target.addChild(border);
			
			holder = new RoundRect(facing, facing, w-2*facing, h-2*facing, 0, round, Osd.COLOR_WINDOW);
			target.addChild(holder);
			
			_osd = new Osd(target);
			label = _osd.addLabel(5, h/8, labelText);
			target.addChild(label);

			addChild(target);
			owner = ow;
			osd = o;
			owner.addChild(this);

			actor = this;
			super();
			cmd = c;
			
			caretPos = new Point(0, (h - h * 0.95) / 2);
			caret = new RoundRect(caretPos.x, caretPos.y, 2, h * 0.95, 0, 0, Osd.COLOR_CARET); //should be invisible at showup
			setCaret(curChar);
			target.addChild(caret);
			caret.visible = false;
			owner = ow;
			
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemove);
		}
		
		//for situations when input field has been emergency removed (for example, right click in parent window)
		public function handleRemove(e:Event)
		{
			//sometimes calendar and keyboard are already built, but not placed on stage, we check userInput to realize where they are and shall we touch them on right click annihilation event
			if (calendar && userInput) owner.removeChild(calendar);
			if (keyboard && userInput) owner.removeChild(keyboard);
			removeEventListener(Event.REMOVED_FROM_STAGE, handleRemove);
		}
		
		public function setCaret(idx:int)
		{
			if (type == FMT_TIME)
			{
				if (idx == 2 || idx == 5)
				{
					idx++;
					curChar++;
				}
			}
			
			if (type == FMT_IP)
			{
				if (idx == 3 || idx == 7|| idx == 11)
				{
					idx++;
					curChar++;
				}
			}
			
			if (type == FMT_MAC)
			{
				if (idx == 2 || idx == 5 || idx == 7 || idx == 9 || idx == 11 || idx == 13)
				{
					idx++;
					curChar++;
				}
			}
			
			if (idx == labelText.length) caretPos.x = 5 + label.getCharPos(labelText.length - 1).x + label.getCharWidth(0); //last index, caret pos can't be calculated over text label, so we pick approx result
			else caretPos.x = 5 + label.getCharPos(idx).x;
			
			caret.x = caretPos.x;
		}
		
		public function setKeyboard(kbd:VirtualKeyboard)
		{
			keyboard = kbd;
		}
		
		public function wakeKeyboard()
		{
			if(keyboard) keyboard.wakeUp();
		}
		
		public function shiftKeyboard()
		{
			if(keyboard) keyboard.shift();
		}
		
		public function append(char:String)
		{
			var result:String;
			var str1:String;
			var str2:String = value.slice(curChar, value.length);
			
			if (char.charCodeAt(0) == KeyboardKey.KEY_BACKSPACE)
			{
				if (type != FMT_TIME && type != FMT_IP && type != FMT_MAC)
				{
					str1 = value.slice(0, curChar - 1);
					if (curChar > 0)
					{
						if (value.length > 1) result = str1 + str2.slice(0, str2.length);
						else result = " ";
						curChar--;
					}
				}
				else processChar("C_left");
			}
			else
			{
				if (curChar < maxChar)
				{
					if (type != FMT_TIME && type != FMT_IP)
					{
						if (value == " ")
						{
							str1 = new String();
							str2 = new String();
						}
						else str1 = value.slice(0, curChar);
						result = str1 + char + str2;
					}
					else
					{
						if (type == FMT_TIME)
						{
							var temp:String = new String();
							str1 = value.slice(0, curChar);
							str2 = value.slice(curChar+1, value.length);
							temp = str1 + char + str2;
							
							//max time values for each component
							var tmax:Array = new Array();
							tmax.push(24);
							tmax.push(60);
							tmax.push(60);
							
							var detect:int = Math.floor(curChar/3); //defines what component we edit: hour, minute or second
							str1 = temp.slice(detect*3, detect*3+2); //we pick 2 digits from detected area
							if (str1 < tmax[detect]) result = temp;
							else
							{
								if (detect == 0 && curChar == 0) //special action for hour counter: day incrementation
								{
									var t:int = new int(str1);
									if(t<30)
									{
										var f1:String = temp.slice(0, detect * 3);
										var f2:String = temp.slice(detect * 3 + 2, temp.length);
										var f3:String = new String(t-tmax[detect]);
										result = f1 + "0" + f3 + f2; //reconstruct result with corrected value
										
										//toDo: sync time change with calendar (change current date)
									}
								}
							}
						}
						else
						{
							if (type == FMT_MAC)
							{/*
								str1 = value.slice(0, curChar);
								str2 = value.slice(curChar+1, value.length);
								result = str1 + char + str2;
								
								var val:int;
								var select:int = Math.floor(curChar/6);
								str1 = result.slice(select*6, select*6+2);
								val = new int(str1);
								if (val > 99)
								{
									var r1:String = result.slice(0, select*6);
									var r2:String = result.slice(select*6+3, result.length);
									var r3:String = new String(99);
									result = r1 + r3 + r2;
								}*/
							}
							else
							{
								if (type == FMT_IP)
								{
									str1 = value.slice(0, curChar);
									str2 = value.slice(curChar + 1, value.length);
									result = str1 + char + str2;
									
									var val:int;
									var select:int = Math.floor(curChar / 4); //pick currently editable segment
									str1 = result.slice(select * 4, select * 4 + 3); //detecting digit triple inside it
									val = new int(str1);
									if (val > 255) //now check if entered value is greater than 255, which is max value for IP string
									{
										var r1:String = result.slice(0, select * 4);
										var r2:String = result.slice(select * 4+3, result.length);
										var r3:String = new String(255);
										result = r1 + r3 + r2; //reconstruct result with corrected value
									}
								}
							}
						}
					}
				}
			}
			
			if (result)
			{
				if (char.charCodeAt(0) != KeyboardKey.KEY_BACKSPACE) curChar++;
				
				if (type == FMT_DIGITAL)
				{
					if (Number(result) > maxValue) result = maxValue.toString();
				}
				
				value = result;
				
				if (type == FMT_PASSWORD) labelText = getPassword(result);
				else
				{
					if (type == FMT_TIME) time = timeToValue(value);
					else
					{
						if (type == FMT_IP) ip = ipToValue(value);
					}
					labelText = result;
				}

				if (type == FMT_TIME) updateTimeString(); //updates labelText only, according to selected time format
				else label.setText(labelText);
				setCaret(curChar);
			}
		}
		
		public function getPassword(input:String):String
		{
			var output:String = "";
			if (value != " ") for (var i:int = 0; i < input.length; i++) output += "*";
			else output = " ";
			
			return output;
		}
		
		//from seconds to string
		public static function timeToString(input:int):String
		{
			var t:Array = new Array();
			var result:String = new String();
			
			t.push((Math.floor(input/3600)) as int);
			t.push(Math.floor((input-(t[0]*3600))/60) as int);
			t.push((input-(t[0]*3600 + t[1]*60)) as int);
			
			for (var i:int = 0; i < t.length; i++)
			{
				var str:String = t[i];
				if (t[i] < 10) str = "0" + str;
				if (i < t.length-1) str += ":";
				
				result += str;
			}
			
			timeToValue(result);
			return result;
		}
		
		//affects only labelText, actual time value stay the same
		public function setTimeFormat(fmt:int)
		{
			if (System.timeFormat != fmt)
			{
				var hour:int = new int(timeToString(time).slice(0,2));
				var rest:String = timeToString(time).slice(3,8);
				
				if (timeFormat == TIME_24 && fmt == TIME_12)
				{
					if (hour > 12)
					{
						hour -= 12;
						timePeriod = TIME_PM;
					}
					else timePeriod = TIME_AM;
				}
				else
				{
					if (timeFormat == TIME_12 && fmt == TIME_24)
					{
						if (timePeriod == TIME_PM)
						{
							hour += 12;
							time = timeToValue(Convertor.getDouble(hour) + ":" + rest);
						}
					}
				}
				
				labelText = Convertor.getDouble(hour) + ":" + rest;
				label.setText(labelText);
				time = timeToValue(labelText);
				value = labelText;

				timeFormat = fmt;
				System.timeFormat = timeFormat;
				System.timePeriod = timePeriod;
				if (timeLink) timeLink.selectItem(System.timePeriod);
			}
		}
		
		public function setTimePeriod(tp:int)
		{
			timePeriod = tp;
		}
		
		public function setTimeLinkage(lbx:ListBox)
		{
			timeLink = lbx;
			timeLink.selectItem(System.timePeriod);
		}
		
		public function updateTimeZone(tz:int)
		{
			if (tz != System.timeZone)
			{
				System.timeZone = tz;
				
				//first of all, we pick current GMT time adjust value
				var data:Array = System.getGMT();
				var hr:int = Math.abs(data[0]);
				var min:int = Math.abs(data[1]);
				var delta:int = timeToValue(new String(Convertor.getDouble(hr) + ":" + Convertor.getDouble(min) + ":00"));
				
				//now define if time adjust is positive or negative
				var sgn:int = 1;
				if (data[0] < 0) sgn *= (-1);

				var dateObject:Date = new Date();
				var utc:Array = new Array();
				
				utc.push(Convertor.getDouble(dateObject.getUTCHours()));
				utc.push(Convertor.getDouble(dateObject.getUTCMinutes()));
				utc.push(Convertor.getDouble(dateObject.getUTCMinutes()));
				
				time = timeToValue(utc[0] + ":" + utc[1] + ":" + utc[2]);
				time += delta*sgn; //adjusting UTC by delta
				
				//converting new time value to compatible time string
				var str:String = timeToString(time);
				hr = new int(str.slice(0,2));
				var rest:String = str.slice(3,8);
				
				if (hr >= 24)
				{
					if (hr == 24) hr = 0;
					else hr -= 24;
				}
				
				str = Convertor.getDouble(hr) + ":" + rest;
				time = timeToValue(str);
				
				updateTimeString(); //finally, updating all time values and printing result to label
			}
		}
		
		//this applies final changes to time string
		public function updateTimeString()
		{
			var hour:String = timeToString(time).slice(0,2);
			var rest:String = timeToString(time).slice(3,8);
			var hr:int = int(hour);

			if(timeFormat == TIME_12)
			{
				if (hr > 12)
				{
					if (timePeriod == TIME_AM) timePeriod = TIME_PM;
					else timePeriod = TIME_AM;
					hr -= 12;
				}
			}

			hour = new String(hr);
			if (hr < 10) hour = "0" + hour;

			labelText = hour + ":" + rest;
			label.setText(labelText);
			
			value = labelText;
			time = timeToValue(value);
			
			if (System.timePeriod != timePeriod)
			{
				System.timePeriod = timePeriod;
				if (timeLink) timeLink.selectItem(System.timePeriod);
			}
		}
		
		//back from string to seconds
		public static function timeToValue(input:String):int
		{
			var t:Array = new Array();
			var result:int = 0;
			
			t.push(input.slice(0,2));
			t.push(input.slice(3,5));
			t.push(input.slice(6,8));
			
			for (var i:int = 0; i < t.length; i++) result += t[i]*Math.pow(60,t.length-i-1);
			return new int(result);
		}
		
		public static function getTimeValue():int
		{
			var result:int;
			var d:Date = new Date();
			
			return d.getUTCHours()*3600 + d.getUTCMinutes()*60 + d.getUTCSeconds();
		}
		
		//from IP adress UINT32 to string
		public static function ipToString(input:uint):String
		{
			var v:Array = new Array();
			var result:String = new String();
			
			v.push(Math.floor(input/16777216));
			v.push(Math.floor((input-v[0]*16777216)/65536));
			v.push(Math.floor((input-v[0]*16777216-v[1]*65536)/256));
			v.push(Math.floor(input-v[0]*16777216-v[1]*65536-v[2]*256));
				
			for (var i:int = 0; i < v.length; i++)
			{
				var str:String = v[i];
				if (v[i] < 10) str = "0" + str;
				if (v[i] < 100) str = "0" + str;
				if (i < v.length - 1) str += ".";
				
				result += str;
			}

			return result;
		}
		
		//back from String to UINT32
		public static function ipToValue(input:String):uint
		{
			var v:Array = new Array();
			var result:uint = 0;
			
			for (var i:int = 0; i < 16; i++)
			{
				v.push(new int(input.slice(i, i + 3)));
				i+=3
			}
			
			for (var j:int = 0; j < v.length; j++)
			{
				result += v[j] * (Math.pow(256, v.length - j));
			}
			
			result = v[0]*16777216 + v[1]*65536 + v[2]*256 + v[3]; //straight calculation should be the most precise
			return new uint(result);
		}
		
		//from labelText to Date object, compatible with calendar
		public function dateToValue(input:String):Date
		{
			var month:int;
			var year:int;
			var day:int;
			
			switch(dateFormat)
			{
				case(DATE_MDY):
					month = new int(input.slice(0,2));
					day = new int(input.slice(3,5));
					year = new int(input.slice(6,10));
					break;
					
				case(DATE_YMD):
					year = new int(input.slice(0,4));
					month = new int(input.slice(5,7));
					day = new int(input.slice(8,10));
					break;
					
				default: //DATE_DMY
					day = new int(input.slice(0,2));
					month = new int(input.slice(3,5));
					year = new int(input.slice(6,10));
					break;
			}
		
			return new Date(new int(year), new int(month-1), new int(day));
		}
		
		//from Date object to string value
		public function dateToString(input:Date):String
		{
			var result:String = new String();
			var d:Array = new Array();
			d.push(input.getFullYear());
			d.push(input.getMonth()+1);
			d.push(input.getDate());
			
			var ds:Array = new Array();
			for (var i:int = 0; i < d.length; i++)
			{
				var add:String = new String(d[i]);
				if (d[i] < 10) add = "0" + add;
				ds.push(add);
			}
			
			switch(dateFormat)
			{
				case(DATE_MDY):
					result = ds[1] + "/" + ds[2] + "/" + ds[0];
					break;
					
				case(DATE_YMD):
					result = ds[0] + "-" + ds[1] + "-" + ds[2];
					break;
					
				default: //DATE_DMY
					result = ds[2] + "/" + ds[1] + "/" + ds[0];
					break;
			}
			
			return result;
		}
		
		public function setDateFormat(fmt:int, chg:Boolean)
		{
			if (fmt != System.dateFormat)
			{
				var temp:Date = dateToValue(value);
				dateFormat = fmt;
				value = dateToString(temp);
				
				labelText = value;
				label.setText(labelText);
				
				if(chg) System.dateFormat = fmt; //additional args define if system date format is preserved from changing
			}
		}
		
		public function setDate(dt:Date)
		{
			date = dt;
			value = dateToString(dt);
			
			labelText = value;
			label.setText(labelText);
			
			userInput = false;
			unfocus();
			if (calendar) owner.removeChild(calendar);
		}
		
		//this is required to initialize the calendar
		public function getDate():Date
		{
			return dateToValue(value);
		}
		
		public function getValue():String
		{
			return value;
		}
		
		public function saveInput()
		{
			if (cmd) sendMessage();
		}
		
		public function processChar(char:String)
		{
			switch(char)
			{
				case("C_terminate"):
					owner.removeChild(keyboard);
					userInput = false;
					caret.visible = false;
					unfocus();
					saveInput();
					break;
					
				case("C_shift"):
					keyboard.shift();
					break;
					
				case("C_left"):
					if (curChar > 0)
					{
						if (type == FMT_TIME)
						{
							if (curChar == 3 || curChar == 6) curChar--;
						}
						
						if (type == FMT_IP)
						{
							if (curChar == 4 || curChar == 8 || curChar == 12) curChar--;
						}
						
						curChar--;
					}
					else curChar = label.getLength();
					
					setCaret(curChar);
					break;
					
				case("C_right"):
					if (curChar < label.getLength()) curChar++;
					else curChar = 0;
					
					setCaret(curChar);
					break;
					
				default:
					if (curChar <= maxChar) append(char);
					break;
			}
		}
		
		public override function disable()
		{
			super.disable();
			update(Gadget.STATE_DEFAULT);
		}
		
		public override function enable()
		{
			super.enable();
			update(Gadget.STATE_DEFAULT);
		}

		public function setPos(xy:Point)
		{
			pos = xy;
			target.x = pos.x;
			target.y = pos.y;
		}
		
		private function setColor(s:Sprite, c:uint)
		{
			var ct:ColorTransform = new ColorTransform();
			ct.color = c;
			s.transform.colorTransform = ct;
		}
		
		public function setValue(str:String)
		{
			value = str;
			labelText = value;
			label.setText(labelText);
		}
		
		public override function copyFrom(...args)
		{
			var ti:TextInput = args[0];
			setValue(ti.getValue()); //only value is being copied
			
			if (ti.disabled) disable();
			else
			{
				if(disabled) enable();
			}
		}
		
		public function update(st:int)
		{
			state = st;
	
			if (!disabled)
			{
				switch(state)
				{
					case(Gadget.STATE_DEFAULT):
						setColor(border, Osd.COLOR_DEFAULT);
						setColor(holder, Osd.COLOR_WINDOW);
						label.setColor(Osd.COLOR_DEFAULT);
						break;
						
					case(Gadget.STATE_HOVER):
						setColor(holder, Osd.COLOR_SELECTED);
						label.setColor(Osd.COLOR_INVERTED);
						break;
						
					case(Gadget.STATE_HOLD):
						setColor(holder, Osd.COLOR_SELECTED);
						label.setColor(Osd.COLOR_DEFAULT);
						break;
						
					case(Gadget.STATE_PRESSED):
						setColor(holder, Osd.COLOR_SELECTED);
						label.setColor(Osd.COLOR_DEFAULT);
						break;
				}
			}
			else
			{
				setColor(holder, Osd.COLOR_WINDOW);
				setColor(border, Osd.COLOR_DISABLED);
				label.setColor(Osd.COLOR_DISABLED);
			}
		}
		
		public override function press()
		{
			update(Gadget.STATE_DEFAULT);
			update(Gadget.STATE_HOVER);
		}
		
		public override function unfocus()
		{
			if(!userInput) update(Gadget.STATE_DEFAULT);
			super.unfocus();
		}
		
		public override function hover()
		{
			update(Gadget.STATE_HOVER);
			super.hover();
		}
		
		public override function hold()
		{
			update(Gadget.STATE_HOLD);
			super.hold()
		}
		
		public override function unhold()
		{
			if (!disabled)
			{
				update(Gadget.STATE_PRESSED);
				userInput = true;
				
				if (type != FMT_DATE)
				{
					if (type != FMT_DEFAULT && type != FMT_PASSWORD) keyboard = new DigitalKeyboard(owner, _osd, this);
					else keyboard = new QwertyKeyboard(owner, _osd, this);

					keyboard.setPos(new Point(pos.x, pos.y+h+facing*2)); //we pick global coords, since object is placed on stage
					setKeyboard(keyboard);

					caret.visible = true;
					if (value != " ") curChar = label.getCaret();
					else curChar = 0;
					setCaret(curChar);
				}
				else
				{
					calendar = new Calendar(owner, _osd, this);
					calendar.setPos(new Point(pos.x, pos.y+h+facing*2)); //we use global coords for calendar as well
				}
				
				super.unhold();
			}
		}
		
		public override function finalize()
		{
			label.finalize();
			owner.removeChild(this);
		}
	}
}