package com.arsec.system
{
	import com.arsec.ui.*;
	import com.arsec.util.*;

	public class EventEntry
	{
		public static const TYPE_NORMAL	= 0;
		public static const TYPE_ALARM	= 1;
		
		private var dateBegin:Date;
		private var dateEnd:Date;
		
		public var channel:int = 0;
		public var type:int = TYPE_NORMAL;
		
		public function EventEntry(ch:int, db:Date, de:Date, t:int)
		{
			channel = ch;
			type = t;
			dateBegin = db;
			dateEnd = de;
		}
		
		public function getBeginDate():String
		{
			return Convertor.dateToString(dateBegin);
		}
		
		public function getEndDate():String
		{
			return Convertor.dateToString(dateEnd);
		}
		
		public function getBeginTime():String
		{
			return Convertor.timeToString(dateBegin);
		}
		
		public function getEndTime():String
		{
			return Convertor.timeToString(dateEnd);
		}
		
		public function getType():String
		{
			if (type == TYPE_ALARM) return "Тревога";
			else return "Норм.";
		}
	}
}