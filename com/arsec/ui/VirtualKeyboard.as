package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class VirtualKeyboard extends Gadget
	{
		public static const KEY_DIM:int = 29;
		
		internal var target:MovieClip;
		internal var border:Sprite;
		internal var holder:Sprite;
		internal var _osd:Osd; //for child objects
		
		internal var pos:Point;
		internal var w:Number;
		internal var h:Number;
		
		internal var textInput:TextInput;
		
		internal var keys:Array;
		internal var initialState:Boolean = true;
		internal var shifted:Boolean = false;
		
		public function VirtualKeyboard()
		{
			keys = new Array();
		}
		
		public function setPos(xy:Point)
		{
			if (!globalPos) globalPos = xy;
			pos = xy;
			x = pos.x;
			y = pos.y;
		}
		
		public function wakeUp()
		{
			if (initialState)
			{
				for (var i:int = 0; i < keys.length; i++) keys[i].unfocus();
				initialState = false;
			}
		}
		
		public function shift()
		{
			if (shifted) shifted = false;
			else shifted = true;
		}
		
		internal function addKey(px:Number, py:Number, ascii:int, ...args):KeyboardKey
		{
			var type:int;
			if (args && args.length) type = args[0];

			var key:KeyboardKey = new KeyboardKey(ascii, type);
			key.setPos(px, py);
			key.setOutput(textInput);
			keys.push(key);
			
			return key;
		}
	}
}