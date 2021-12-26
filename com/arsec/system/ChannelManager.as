package com.arsec.system
{
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.geom.Point;
	
	public class ChannelManager extends MovieClip
	{
		private var owner:Object;
		private var grid:Grid;
		private var thinGrid:ThinGrid;
		private var channels:Array;
		
		private var useThinGrid = false;
		
		public var lastViewed:int = 0;
		
		public function ChannelManager(ow:Object)
		{
			owner = ow;
			owner.addChild(this);
			channels = new Array();
			
			for (var i:int = 0; i < System.CHANNELS; i++)
			{
				var ch = new Channel(this, i+1);
				addChild(ch);
				channels.push(ch);
				
				var xpos:Number = 0;
				var ypos:Number = 0;
				if (i == 1 || i == 3) xpos = System.SCREEN_X/2;
				if (i > 1) ypos = System.SCREEN_Y/2;

				ch.setPos(xpos, ypos);
				ch.setGlobalPos(xpos, ypos);
			}
			
			thinGrid = new ThinGrid();
			addChild(thinGrid);
			thinGrid.visible = false;
			
			grid = new Grid();
			addChild(grid);
			grid.visible = true;
			grid.x = System.SCREEN_X/2;
			grid.y = System.SCREEN_Y/2;
		}
		
		public function playVideo(ch:int)
		{
			channels[ch].setPlayback(true);
		}
		
		public function stopVideo(ch:int)
		{
			channels[ch].setPlayback(false);
		}
		
		public function showThinGrid(st:Boolean)
		{
			if (System.actChannel == System.CHANNELS)
			{
				useThinGrid = st;
				
				thinGrid.visible = st;
				grid.visible = !st;
			}
		}
		
		public function showOsd(st:Boolean)
		{
			for (var i:int = 0; i < channels.length; i++) channels[i].showHud(st);
		}
		
		public function showChannels(st:Boolean)
		{
			for (var i:int = 0; i < channels.length; i++) showChannel(i, st);
		}
		
		public function showChannel(ch:int, st:Boolean)
		{
			channels[ch].showSource(st);
		}
		
		public function getChannelSource(ch:int):MovieClip
		{
			return channels[ch].getSource();
		}
		
		public function getPlaybackFrame(ch:int):int
		{
			return channels[ch].getCurFrame();
		}
		
		public function getTitle(ch:int):String
		{
			return channels[ch].getAlias();
		}
		
		public function setTitle(ch:int, str:String)
		{
			if (ch == System.CHANNELS)
			{
				for (var i:int = 0; i < System.CHANNELS; i++) channels[i].updateTitle(str);
			}
			else channels[ch].updateTitle(str);
		}
		
		public function muteChannel(ch:int, st:Boolean)
		{
			if (ch == System.CHANNELS)
			{
				for (var i:int = 0; i < System.CHANNELS; i++) channels[i].mute(st);
			}
			else channels[ch].mute(st);
		}
		
		public function getMute(ch:int)
		{
			if (ch != System.CHANNELS)
			{
				if (channels[ch].muted) return true;
				else return false;
			}
			else
			{
				var count:int = 0;
				for (var i:int = 0; i < System.CHANNELS; i++)
				{
					if (channels[i].muted) count++;
				}
				
				if (count == System.CHANNELS) return true;
			}
			return false;
		}
		
		public function minimizeChannel(ch:int)
		{
			var p:Point = channels[ch].getGlobalPos();
			channels[ch].setPos(p.x, p.y);
			channels[ch].minimize();
		}
		
		public function maximizeChannel(ch:int)
		{
			channels[ch].setPos(0,0);
			channels[ch].maximize();
		}
		
		public function selectChannel(ch:int)
		{
			//saving recently viewed single channel
			if (System.actChannel != System.CHANNELS) lastViewed = System.actChannel;
			else
			{
				if (ch != System.CHANNELS) lastViewed = ch;
			}
			
			System.actChannel = ch;
			if (ch != System.CHANNELS)
			{
				grid.visible = false;
				thinGrid.visible = false;
				
				for (var i:int = 0; i < channels.length; i++)
				{
					if (ch == i)
					{
						channels[i].visible = true;
						maximizeChannel(i);
					}
					else
					{
						minimizeChannel(i);
						channels[i].visible = false;
					}
				}
			}
			else
			{
				grid.visible = true;
				showThinGrid(useThinGrid);
				
				for (var j:int = 0; j < channels.length; j++)
				{
					minimizeChannel(j);
					channels[j].visible = true;
				}
			}
		}
	}
}