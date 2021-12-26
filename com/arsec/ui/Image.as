package com.arsec.ui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import com.arsec.ui.*;
	import com.arsec.system.*;
	
	//toDo: ability to replace bitmap data
	public class Image extends Gadget
	{
		internal var interactive:Boolean;
		internal var path:String;
		internal var pos:Point;

		private var data:BitmapData;
		internal var bitmap:Bitmap;
		private var cDef:Class;
			
		public function Image(ow:Object, o:Osd, p:String)
		{
			owner = ow;
			osd = o;
			build(p);
			owner.addChild(this);
			if (interactive) actor = this;

			super();
		}
		
		//generates new bitmap
		public function build(p:String)
		{
			path = p;
			cDef = getDefinitionByName(path) as Class;
			data = new cDef(0,0);
			bitmap = new Bitmap(data);
			bitmap.smoothing = true;
			addChild(bitmap);
		}
		
		//generates new bitmap and _updates_ current one
		public function update(p:String)
		{
			removeChild(bitmap);
			build(p);
		}
		
		public function setPos(p:Point)
		{
			pos = p;
			this.x = p.x;
			this.y = p.y;
			if (!globalPos) globalPos = p;
		}
		
		public function getPos():Point
		{
			return pos;
		}
		
		public override function disable()
		{
			this.alpha = Osd.ALPHA_DISABLED;
			super.disable();
		}
		
		public override function enable()
		{
			this.alpha = Osd.ALPHA_DEFAULT;
			super.enable();
		}

		public override function focus()
		{
			super.focus();
		}
	
		public override function unfocus()
		{
			super.unfocus();
		}
		
		public override function hover()
		{
			super.hover();
		}
		
		public override function press()
		{
			super.press();
		}
		
		public override function hold()
		{
			super.hold()
		}
		
		public override function unhold()
		{
			super.unhold();
		}
		
		public override function finalize()
		{
			owner.removeChild(this);
		}
	}
}