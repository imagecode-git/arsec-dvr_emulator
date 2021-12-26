package com.arsec.system
{
	import com.arsec.ui.*;
	import com.arsec.util.*;

	public class LogEntry
	{
		public static const TYPE_UNLIM	= 0;
		public static const TYPE_LTD	= 1;
		
		private var date:Date;
		private var dateEnd:Date;
		private var user:String;
		private var details:String;
		private var ended:Boolean = false;
		
		private var type:int = TYPE_UNLIM;
		
		public function LogEntry(det:String, ...args)
		{
			date = new Date();
			
			if (System.userName) user = System.userName;
			else user = " ";
			
			details = det;
			
			if (args && args.length) type = args[0];
		}
		
		public function end()
		{
			dateEnd = new Date();
			ended = true;
		}
		
		public function dateToString():String
		{
			return Convertor.dateToString(date);
		}
		
		public function timeToString():String
		{
			return Convertor.timeToString(date);
		}
		
		public function getDetails():String
		{
			return details;
		}
		
		public function getFullDetails():String
		{
			var result:String = new String();
			var e:String = new String();
			
			result = "Начало: " + dateToString() + " " + timeToString();
			if (type == TYPE_LTD)
			{
				result += "\nКонец: ";
				
				if (ended) result += Convertor.dateToString(dateEnd) + " " + Convertor.timeToString(dateEnd);
				else result += "Working";
			}
			
			if (getUser() != " ") result += "\nИмя: " + getUser();
			result += "\nСодержимое: " + getDetails();
			return result;
		}
		
		public function getUser():String
		{
			return user;
		}
	}
}