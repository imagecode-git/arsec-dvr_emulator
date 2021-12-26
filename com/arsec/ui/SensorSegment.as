package com.arsec.ui
{
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.geom.Point;
	
	public class SensorSegment extends Gadget
	{
		var sensormatrix:SensorMatrix;
		
		private var border:RoundRect;
		private var holder:RoundRect;
		private var clickable:Hotspot;
		
		private var seekSelection:Boolean = false;
		private var selected:Boolean = true;
		public var id:Array;
		
		private var facing:int = 3;

		public function SensorSegment(sm:SensorMatrix, ow:Object, x:Number, y:Number, w:Number, h:Number, id:Array)
		{
			sensormatrix = sm;
			this.id = id;
			
			owner = ow;
			osd = new Osd(this);
			
			blendMode = BlendMode.LAYER;			
			border = new RoundRect(x, y, w, h, 0, 0, Osd.COLOR_SELECTED);
			addChild(border);
			
			holder = new RoundRect(x+facing, y+facing, w-2*facing, h-2*facing, 0, 0, Osd.COLOR_SENSORDEF);
			holder.blendMode = BlendMode.ERASE;
			addChild(holder);

			//filling gaps between segments, so focus won't stuck in these areas
			w += SensorMatrix.SEG_SEP;
			h += SensorMatrix.SEG_SEP;
			
			clickable = osd.addHotspot(x+w/2, y+h/2, w, h, Osd.CMD_INVALID);
			clickable.attach(this);
			clickable.dragndrop = true;
			
			owner.addChild(this);
		}
		
		public function select(st:Boolean)
		{
			var color:uint = Osd.COLOR_SELECTED;
			if (!st) color = Osd.COLOR_SENSORDEF;
			
			selected = st;
			border.setColor(color);
		}
		
		public override function hover()
		{
			sensormatrix.notify(id, true);
			super.hover();
		}
		
		public override function dragBegin()
		{
			seekSelection = false;
			sensormatrix.notify(id, true);
			super.dragBegin();
		}
		
		public override function unfocus()
		{
			if (seekSelection) seekSelection = false;
			sensormatrix.notify(id, false);
			super.unfocus();
		}
		
		public override function hold()
		{
			if (focused)
			{
				seekSelection = true;
				sensormatrix.beginWatch(id, selected);
			}
			super.hold();
		}
		
		public override function unhold()
		{
			sensormatrix.stopWatch();
			if (seekSelection)
			{
				select(!selected);
				seekSelection = false;
			}
			super.unhold();
		}
		
		public override function finalize()
		{
			clickable.finalize();
			super.finalize();
		}
	}
}