package com.arsec.ui
{
	import adobe.utils.CustomActions;
	import com.arsec.ui.*;
	import com.arsec.system.*;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class DigitalZoom extends Gadget
	{
		private static const MIN_WIDTH:Number = 160;
		private static const MIN_HEIGHT:Number = 90;
		
		private var retChannel:int;
		
		private var preview:MovieClip;
		private var holder:RoundRect;
		private var pan:RoundRect;
		private var panning:Boolean;
		
		private var facing:int = 6;
		
		private var events:Array = new Array(MouseEvent.MOUSE_UP, MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_MOVE, MouseEvent.CONTEXT_MENU);
		
		private var done:Boolean = false;
		private var drawing:Boolean = false;
		private var selection:MaskRect;
		private var locker:Hotspot;
		
		private var zSource:MovieClip; //object to zoom
		private var zTarget:MovieClip; //stretched source
		private var zMask:RoundRect; //clone of area selected by the cursor
		
		private var caller:Object;
	
		public function DigitalZoom(ow:Object, o:Osd)
		{
			owner = ow;
			osd = o;
			
			retChannel = System.actChannel;
			System.manager.selectChannel(System.manager.lastViewed);
			System.manager.showOsd(false);
			
			var sx:Number = System.SCREEN_X;
			var sy:Number = System.SCREEN_Y;
			
			holder = new RoundRect(0, 0, sx/4, sy/4, facing, 0, 0xFF000000, Osd.COLOR_SELECTED);
			holder.setPos(sx-75-holder.getWidth(), sy-75-holder.getHeight());
			addChild(holder);
			
			preview = new MovieClip();
			preview.addChild(System.manager.getChannelSource(System.manager.lastViewed));
			preview.width = holder.getWidth();
			preview.height = holder.getHeight();
			preview.x = holder.getPos().x;
			preview.y = holder.getPos().y;
			
			holder.addChild(preview);
			holder.visible = false;
			addChild(holder);
			
			osd.setHandler(this);
			locker = osd.addHotspot(System.SCREEN_X/2, System.SCREEN_Y/2, System.SCREEN_X, System.SCREEN_Y, Osd.CMD_INVALID);
			for (var i:int = 0; i < events.length; i++) owner.stage.addEventListener(events[i], this.handleEvent);
			
			owner.addChild(this);
		}
		
		public function reset()
		{
			if (done)
			{
				swapChildren(zTarget, holder);
				
				/*pan.removeEventListener(events[1], this.handlePan);
				owner.stage.removeEventListener(events[0], this.handlePan);
				owner.stage.removeEventListener(events[2], this.handlePan);*/
				
				removeChild(zTarget);
				removeChild(pan);
				
				holder.visible = false;
				
				System.manager.showChannel(System.manager.lastViewed, true);
				
				done = false;
			}
		}
		
		public function setCaller(cl:Object)
		{
			caller = cl;
		}
		
		public function handleEvent(e:MouseEvent)
		{
			if (!done)
			{
				switch(e.type)
				{
					case(events[0]): //MOUSE_UP
						if (drawing) drawing = false;
						if (selection) selection.visible = false;
						
						if (selection.getWidth() < MIN_WIDTH) selection.setWidth(MIN_WIDTH);
						if (selection.getHeight() < MIN_HEIGHT) selection.setHeight(MIN_HEIGHT);

						//fixing mask position if inversed selection axles have been used
						if (selection.inverseX) selection.setPos(new Point(selection.getPos().x-selection.getWidth(), selection.getPos().y));
						if (selection.inverseY) selection.setPos(new Point(selection.getPos().x, selection.getPos().y-selection.getHeight()));
						
						//now spawning zoom mask from area selected by cursor
						zMask = new RoundRect(0, 0, selection.getWidth(), selection.getHeight(), 0, 0, Osd.COLOR_CHMASKBRD);
						zMask.setPos(selection.getPos().x, selection.getPos().y);
						addChild(zMask);
						
						zSource = System.manager.getChannelSource(System.manager.lastViewed); //now cloning channel source
						
						//then creating zoom target, a masked channel source
						zTarget = new MovieClip();
						zTarget.addChild(zSource);
						zTarget.mask = zMask;
						
						zSource.addChild(zMask); //connecting mask with source to sync their movements/scalings
						
						//applying zero pos for zoom target with normal scale
						zTarget.x -= selection.getPos().x;
						zTarget.y -= selection.getPos().y;
						
						var xdlt:Number = zTarget.x;
						var ydlt:Number = zTarget.y;
						
						//calculating XY scale ratios for zoom target
						zTarget.scaleX = System.SCREEN_X/selection.getWidth();
						zTarget.scaleY = System.SCREEN_Y/selection.getHeight();
						
						//rescaling coordinates of zoom target using calculated ratio and additionally adjusting pos
						zTarget.x += xdlt*zTarget.scaleX-xdlt;
						zTarget.y += ydlt*zTarget.scaleY-ydlt;
						
						zTarget.filters = [new BlurFilter(4,4,2)]; //applying additional blur for a better quality of resized output
						
						addChild(zTarget); //finally, adding result to container
						
						System.manager.showChannel(System.manager.lastViewed, false);
						
						//showing up pan controller and bringing to the top
						holder.visible = true;
						swapChildren(holder, zTarget);
						
						//calculating inversed aspect ratio for pan object
						var scx:Number = selection.getWidth()/System.SCREEN_X;
						var scy:Number = selection.getHeight()/System.SCREEN_Y;
						
						//calculating XY deltas for it
						xdlt = holder.getWidth()*(selection.getPos().x/System.SCREEN_X);
						ydlt = holder.getHeight()*(selection.getPos().y/System.SCREEN_Y);
						
						//building new pan to avoid various rescaling issues
						pan = new RoundRect(0, 0, holder.getWidth()*scx, holder. getHeight()*scy, facing-3, 0, 0xFF000000, Osd.COLOR_SELECTED, 0);
						pan.setPos(holder.getPos().x+xdlt, holder.getPos().y+ydlt);
						/*pan.addEventListener(events[1], this.handlePan); //only mouse down for pan, move/release for stage
						owner.stage.addEventListener(events[0], this.handlePan);
						owner.stage.addEventListener(events[2], this.handlePan);*/
						addChild(pan);
						
						removeChild(selection);
						
						done = true;
						break;
					
					case(events[1]): //MOUSE_DOWN
						dragPos = new Point(e.stageX, e.stageY);
						
						var mr:MaskRect = new MaskRect(this, dragPos.x, dragPos.y, 3, 0, 0, Osd.COLOR_SELECTED);
						mr.setPivot(dragPos);
						selection = mr;
						selection.visible = true;
						
						drawing = true;
						break;
						
					case(events[2]): //MOUSE_MOVE
						if (drawing && selection) selection.update(e.stageX-dragPos.x, e.stageY-dragPos.y);
						break;
					
					case(events[3]): //CONTEXT_MENU (right click)
						if(!drawing) finalize();
						break;
				}
			}
			else
			{
				if (e.type == events[3]) reset();
			}
		}
		
		public function handlePan(e:MouseEvent)
		{
			switch(e.type)
			{
				case(events[0]): //MOUSE_UP
					panning = false;
					break;
					
				case(events[1]): //MOUSE_DOWN
					panning = true;
					dragPos = pan.getPos();
					dragPivot = new Point(e.stageX, e.stageY);
					break;
					
				case(events[2]): //MOUSE_MOVE
					if(panning)
					{
						var dlt:Point = new Point(e.stageX, e.stageY).subtract(dragPivot);
						
						var dx:Number = dragPos.add(dlt).x;
						var dy:Number = dragPos.add(dlt).y;
						var mx:Number = pan.getPos().x;
						var my:Number = pan.getPos().y;
						
						var xmax:Number = holder.getPos().x + holder.getWidth() - pan.getWidth();
						var xmin:Number = holder.getPos().x;
						var ymax:Number = holder.getPos().y + holder.getHeight() - pan.getHeight();
						var ymin:Number = holder.getPos().y;
						
						if (Math.abs(dx) < Math.abs(xmax))
						{
							if (dx - Math.abs(xmin) < -1) mx = xmin;
							else mx = dx;
						}
						else
						{
							if (Math.abs(xmax) - Math.abs(dx) < 1.5) //stick strictly to bounds
							{
								if (dx - Math.abs(xmax) > -1) mx = xmax;
							}
						}

						if (Math.abs(dy) < Math.abs(ymax))
						{
							if (dy - Math.abs(ymin) < -1) my  = ymin;
							else my = dy;
						}
						else
						{
							if (Math.abs(ymax) - Math.abs(dy) < 1.5) //stick  strictly to bounds
							{
								if (dy - Math.abs(ymax) > -1) my = ymax;
							}
						}
						
						pan.setPos(mx, my);
					}
					break;					
			}
		}
		
		public override function finalize()
		{
			for (var i:int = 0; i < events.length; i++)  owner.stage.removeEventListener(events[i], this.handleEvent);
			
			System.manager.selectChannel(retChannel);
			System.manager.showOsd(true);
			
			locker.finalize();
			owner.removeChild(this);
			osd.setHandler(caller); //handler was set to owner in the beginning, but osd sender is caller in fact, so we return handler back to it
			if(caller) caller.activate();
		}
	}
}