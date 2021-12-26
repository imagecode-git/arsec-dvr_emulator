package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	
	public class Hint extends MovieClip
	{
		private var osd:Osd;
		private var holder:Sprite;
		private var label:TextLabel;
		
		public function Hint(w:Number, h:Number, str:String)
		{
			osd = new Osd(this);
			
			holder = new RoundRect(0, 0, 1, 1, 0, 0, Osd.COLOR_WINDOW);
			addChild(holder);
			
			label = osd.addLabel(0, 0, str);
			label.setText(str);
			addChild(label);
			
			holder.width = label.getWidth()*1.2;
			holder.height = label.getHeight() * 1.2;
			
			x = 0;
			y = -holder.height-2.4;
		}
	}
}