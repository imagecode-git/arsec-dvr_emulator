package com.arsec.system
{
	import com.arsec.ui.*;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	
	public class Channel extends MovieClip
	{
		private var manager:ChannelManager;
		private var source:MovieClip;
		private var hud:MovieClip;
		private var osd:Osd;
		private var soundIcon:Image;
		private var title:TextLabel;
		private var pos:Point;
		private var globalPos:Point;
		
		private var alias:String;
		private var id:int;
		private var maximized:Boolean = true;
		public var muted:Boolean = false;
		
		public function Channel(mgr:ChannelManager, id:int)
		{
			manager = mgr;
			this.id = id;
			alias = "CH" + new String(id);
			osd = new Osd(this);

			source = detectSource();
			
			addChild(source);
			
			hud = new MovieClip();
			addChild(hud);
			
			osd.setHandler(hud);
			soundIcon = osd.addImage(50, 100, "AudioIcon.png");
			title = osd.addLabel(50, 620, alias, Osd.COLOR_SELECTED, TextLabel.TYPE_LARGE);
			osd.setHandler(this);
			
			doubleClickEnabled = true; //enables double click for this this object
			mouseChildren = false; //this will force double click to work with objects that have complex structure
			addEventListener(MouseEvent.DOUBLE_CLICK, handleClick);
			
			minimize();
			
			setPos(0,0);
		}
		
		public function detectSource():MovieClip
		{
			var result:MovieClip;
			
			if (System.NOVIDEO) result = new VideoSource(); //default "no signal" image
			else
			{
				switch(this.id)
				{
					case(1):	result = new SourceCH1(); break;
					case(2):	result = new SourceCH2(); break;
					case(3):	result = new SourceCH3(); break;
					case(4):	result = new VideoSource(); break;
				}
			}
			
			return result;
		}
		
		public function setPlayback(st:Boolean, ...args)
		{
			if (st) source.play();
			else source.stop();
		}
		
		public function updateTitle(str:String)
		{
			alias = str;
			title.setText(str);
		}
		
		//returns new instance of source, not the original one!
		public function getSource():MovieClip
		{
			var result:MovieClip = detectSource();
			result.gotoAndPlay(source.currentFrame);
			
			return result;
		}
		
		public function getCurFrame():int
		{
			return source.currentFrame;
		}
		
		public function getAlias():String
		{
			return alias;
		}
		
		public function setPos(x:Number, y:Number)
		{
			pos = new Point(x,y);
			this.x = x;
			this.y = y;
		}
		
		public function setGlobalPos(gx:Number, gy:Number)
		{
			globalPos = new Point(gx,gy);
		}
		
		public function getGlobalPos():Point
		{
			return globalPos;
		}
		
		public function showHud(st:Boolean)
		{
			hud.visible = st;
		}
		
		public function showSource(st:Boolean)
		{
			source.visible = st;
		}
		
		public function mute(st:Boolean)
		{
			soundIcon.visible = !st;
			muted = st;
		}
		
		public function maximize()
		{
			if (!maximized)
			{
				source.width = System.SCREEN_X;
				source.height = System.SCREEN_Y;
				
				soundIcon.setPos(new Point(50, 100));
				title.setPos(new Point(50, 620));
				
				maximized = true;
			}
		}
		
		public function minimize()
		{
			if (maximized)
			{
				source.width = System.SCREEN_X/2;
				source.height = System.SCREEN_Y/2;
				
				soundIcon.setPos(new Point(25, 50));
				title.setPos(new Point(25, 325));
				
				maximized = false;
			}
		}
		
		public function handleClick(e:MouseEvent):void
		{
			if (manager)
			{
				if (maximized) manager.selectChannel(System.CHANNELS);
				else manager.selectChannel(id-1);
			}
		}
	}
}