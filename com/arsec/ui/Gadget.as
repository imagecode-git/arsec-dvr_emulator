package com.arsec.ui
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import com.arsec.system.*;
	
	public class Gadget extends MovieClip
	{
		public static const STATE_INVALID:int	= -1;
		public static const STATE_DEFAULT:int	= 0;
		public static const STATE_HOVER:int		= 1;
		public static const STATE_PRESSED:int	= 2;
		public static const STATE_HOLD:int 		= 3;
		
		public var focused:Boolean = false;

		internal var dragndrop:Boolean = false;
		internal var rightclick:Boolean = false;
		internal var noclick:Boolean = false; //preserves sending left click gadget events
		internal var disabled:Boolean = false;
		internal var owner:Object;
		internal var osd:Osd;
		internal var stg:Stage;
		internal var actor:MovieClip; //this object is used to interact with mouse
		internal var hld:Boolean; //cursor is being held by user
		internal var drg:Boolean; //drag&drop is active
		internal var cmd:int = Osd.CMD_INVALID; //by default, all gadgets have no press action defined
		internal var dragPos:Point; //object initial pos
		internal var dragPivot:Point; //cursor initial pos
		internal var link:Function; //hover linkage

		public var globalPos:Point; //local pos + placement pos
		
		public function Gadget()
		{
			if (actor) setActor(actor);
		}
		
		public function setActor(act:MovieClip)
		{
			actor = act;
			actor.addEventListener(MouseEvent.CLICK, handleClick); //click itself
			actor.addEventListener(MouseEvent.MOUSE_OVER, handleHover); //cursor is over the gadget
			actor.addEventListener(MouseEvent.MOUSE_OUT, handleRelease); //cursor leaves gadget
			actor.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp); //mouse button is pressed and being held
			actor.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown); //mouse button is unpressed!
			actor.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove); //user is moving the cursor
				
			if (osd) osd.addEventListener(GadgetEvent.ET_DEFAULT, osd.handleEvent);
			if (rightclick && actor && actor.stage) actor.stage.addEventListener(MouseEvent.CONTEXT_MENU, handleRightClick); //if right click is used, gadget must be always finalized in order to remove event listener from stage!
		}
	
		public function disable()
		{
			if (!disabled) disabled = true;
		}
		
		public function enable()
		{
			if(disabled) disabled = false;
		}
		
		public function show()
		{
			
		}
		
		public function hide()
		{
			
		}
		
		//defines function that will be called on hover/leave, see linkedHover() in SettingsDialog to check out how it works and how it should be properly assigned to gadget
		public function setLinkage(f:Function)
		{
			link = f;
		}
		
		public function focus()
		{
			if (!disabled)
			{
				if (!focused) focused = true;
			}
		}
	
		public function unfocus()
		{
			if (focused)
			{
				if (link != null) link(focused, cmd);
				focused = false;
			}
		}
		
		public function hover()
		{
			if (!disabled)
			{
				if (link != null) link(focused, cmd);
				focus();
			}
		}
		
		public function dragBegin()
		{
			if (!drg)
			{
				drg = true;
				dragPivot = new Point(this.mouseX, this.mouseY);
			}
		}
		
		public function dragEnd()
		{
			if (drg)
			{
				drg = false;
				dragPivot = new Point(0,0);
				dragPos = new Point(0,0);
			}
		}
		
		public function finalize()
		{
			if (actor)
			{
				actor.removeEventListener(MouseEvent.CLICK, handleClick);
				actor.removeEventListener(MouseEvent.MOUSE_OVER, handleHover);
				actor.removeEventListener(MouseEvent.MOUSE_OUT, handleRelease);
				actor.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
				actor.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
				actor.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
				
				if (rightclick) actor.stage.removeEventListener(MouseEvent.CONTEXT_MENU, handleRightClick);
				//if (osd) osd.removeEventListener(GadgetEvent.ET_DEFAULT, osd.handleEvent); //this should be locally finalized
			}
		}
		
		//allows to recieve settings from other gadgets
		public function copyFrom(...args)
		{
			
		}
		
		//sends message with gadget event to handler
		public function sendMessage()
		{
			if (cmd != Osd.CMD_INVALID) osd.dispatchEvent(new GadgetEvent(GadgetEvent.ET_DEFAULT, cmd)); //handler must implement IEventHandler to execute these commands
		}
		
		public function press()
		{
			if(!noclick) sendMessage();
		}
		
		public function pressRight()
		{
			
		}
		
		public function drag()
		{
			
		}
		
		public function hold()
		{
			if (!hld) hld = true;
		}
		
		public function unhold()
		{
			if (hld) hld = false;
		}
		
		public function handleHover(e:MouseEvent):void
		{
			hover();
		}
		
		public function handleRelease(e:MouseEvent):void
		{
			unfocus();
		}
		
		public function handleClick(e:MouseEvent):void
		{
			press();
		}
		
		public function handleRightClick(e:MouseEvent):void
		{
			pressRight();
		}
		
		public function handleMouseUp(e:MouseEvent):void
		{
			if (drg) dragEnd();
			unhold();
		}
		
		public function handleMouseDown(e:MouseEvent):void
		{
			hold();
		}
		
		public function handleMouseMove(e:MouseEvent):void
		{
			if (dragndrop)
			{
				if (!drg)
				{
					if (hld) dragBegin();
				}
				else drag();
			}
		}
	}
}