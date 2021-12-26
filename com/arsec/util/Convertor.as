package com.arsec.util
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	
	//toDo: move here convertors from text input and fix links to them in other classes
	public class Convertor
	{
		//int to 2-digital string
		public static function getDouble(val:int):String
		{
			var result:String = new String();
			if (val < 10) result = "0" + val;
			else result = new String(val);
			
			return result;
		}
		
		public static function dateToString(input:Date):String
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
			
			switch(System.dateFormat)
			{
				case(TextInput.DATE_MDY):
					result = ds[1] + "/" + ds[2] + "/" + ds[0];
					break;
					
				case(TextInput.DATE_YMD):
					result = ds[0] + "-" + ds[1] + "-" + ds[2];
					break;
					
				default: //DATE_DMY
					result = ds[2] + "/" + ds[1] + "/" + ds[0];
					break;
			}
			
			return result;
		}
		
		//time string with BIOS time zone offset
		public static function timeToString(input:Date):String
		{
			var result:String = new String();
			var d:Array = new Array();
			
			d.push(input.getHours());
			d.push(input.getMinutes());
			d.push(input.getSeconds());
			
			for (var i:int; i < d.length; i++)
			{
				result += getDouble(d[i]);
				if (i != d.length - 1) result += ":";
			}
			
			return result;
		}
	}
}