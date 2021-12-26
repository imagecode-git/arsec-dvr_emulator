package com.arsec.system
{
	import com.arsec.ui.*;
	import com.arsec.util.*;

	public class User
	{
		public static const TYPE_NORMAL	= 0;
		public static const TYPE_ADMIN	= 1;
		
		private var name:String;
		private var password:String;
		private var loggedIn:Boolean = false;
		private var loginEID:int;
		
		private var mac:String = "00:00:00:00:00";
		private var macLink:Boolean = false;
		private var rights:Array;
		
		private var type:int = TYPE_NORMAL;
		
		public function User(n:String, p:String, t:int, mac:String, mlink:Boolean, ...args)
		{
			name = n;
			password = p;
			type = t;
			this.mac = mac;
			macLink = mlink;
			
			if (args && args.length) rights = args[0];
			else
			{
				var rg:Boolean = false;
				if (type == TYPE_ADMIN) rg = true;
				
				rights = new Array();
				for (var i:int = 0; i<6; i++)
				{
					var arr:Array = [rg,rg,rg];
					if (i == rights.length - 1) arr.push(rg);
					
					rights.push(arr);
				}
			}
		}
		
		public function getName():String
		{
			return name;
		}
		
		public function getPassword():String
		{
			return password;
		}
		
		public function getMAC():String
		{
			return mac;
		}
		
		public function hasLinkedMAC():Boolean
		{
			return macLink;
		}
		
		public function updateName(str:String)
		{
			if(str.length) name = str;
		}
		
		public function updatePassword(str:String)
		{
			password = str;
		}
		
		public function updateMAC(str:String, ...args)
		{
			mac = str;
			if (args && args.length) macLink = args[0];
		}
		
		public function getUserRights():Array
		{
			return rights;
		}
		
		public function updateRights(arr:Array)
		{
			rights = arr;
		}
		
		public function typeToString():String
		{
			if (type == TYPE_NORMAL) return getDefType();
			else return "Администратор";
		}
		
		public function macToString():String
		{
			if (!hasLinkedMAC()) return "Не ограниченный";
			else return mac;
		}
		
		public static function getDefType():String
		{
			return "Норм.";
		}
	}
}