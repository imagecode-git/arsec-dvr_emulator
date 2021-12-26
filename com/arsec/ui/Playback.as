package com.arsec.ui
{
	import com.arsec.ui.dialog.ArchiveTimeDialog;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import com.arsec.ui.*;
	import com.arsec.util.*;
	import com.arsec.system.*;
	
	public class Playback extends Gadget implements IEventHandler
	{
		private static const CMD_MUTE:int		= 0;
		private static const CMD_VOLUME:int		= 1;
		private static const CMD_ZOOM_IN:int	= 2;
		private static const CMD_ZOOM_OUT:int	= 3;
		private static const CMD_PLAYBACK:int	= 4;
		
		//playback simulation states
		private static const PS_PLAY:int		= 0;
		private static const PS_PAUSE:int		= 1;
		private static const PS_FRAMEPLAY:int	= 2;
		private static const PS_FFWD:int		= 3;
		private static const PS_SFWD:int		= 4;
		private static const PS_RWD:int			= 5;
		
		private static const STATE_IMG:Array = new Array("PlayActive.png", "PauseActive.png", "FramePlayActive.png", "FastPlayActive.png", "SlowPlayActive.png", "FastBackActive.png");
		
		private const IMG_NORMAL:Array = new Array("DlMuteNormal.png", "DlMuteActive.png", "DlMutePreLight.png");
		private const IMG_MUTE:Array = new Array("MuteNormal.png", "MuteActive.png", "MutePreLight.png");
		
		private const ZOOM_INTERVALS:Array = new Array(60, 30, 15, 10, 5, 2, 1); //defines what time value one grid interval equals to
		private const GRID_DELTAS:Array = new Array(40, 40, 39, 54, 54, 42, 39); //distance between grid lines inside the stripe
		private const SCROLLER_DATA:Array = new Array(1,1, 240,482, 240,962, 180,1443, 180,2884, 217,7196, 221,14388); //defines knob aspect and scroller step count
		
		private const MIN_ZOOM:int = 0;
		private const MAX_ZOOM:int = 6;
		private const DEF_ZOOM:int = 2;
		
		private const DEF_GRIDSEG:int = 10;
		private const MIN_GRIDX:int = 311;
		
		private var target:MovieClip;
		private var panel:RoundRect;
		private var _osd:Osd;
		
		private var calendar:Calendar;
		private var scroller:Scroller;
		private var curScrollPage:int = 0;
		
		private var border:RoundRect;
		private var holder:RoundRect;
		
		private var volSld:Slider;
		private var volLbl:TextLabel;
		private var muteBtn:ImageButton;
		private var muted:Boolean = false;
		
		private var gridLines:Array;
		private var gridLabels:Array;
		
		private var gridZoom:int = DEF_ZOOM;
		private var timeLbl:TextLabel;
		
		private var locker:Hotspot;
		
		private var playStateImg:Image;
		private var playStateLbl:TextLabel;
		private var playSpeed:Number = 1;
		private var playState:int = PS_PLAY;
		private var playBtn:ImageButton;
		private var playMarker:RoundRect;
		private var playMask:RoundRect;
		
		private var gridStripe:MovieClip;
		private var gridMarker:Image;
		private var gridHotspot:Hotspot;
		private var gridMask:RoundRect;
		
		private var gridDelta:Number = GRID_DELTAS[gridZoom];
		private var gridSegments:Number = DEF_GRIDSEG;
		
		private var retChannel:int = System.actChannel;
		private var playbackChannel:int = 0;
		
		private var caller:Object;
		
		public function Playback(ow:Object, o:Osd)
		{
			System.manager.selectChannel(System.CHANNELS);
			System.manager.showChannels(false);
			System.manager.showChannel(playbackChannel, true);
			System.manager.stopVideo(playbackChannel);
			System.manager.showOsd(false);
			
			owner = ow;
			osd = o;
			target = new MovieClip();
			_osd = new Osd(target);
			
			panel = new RoundRect(0, 465, System.SCREEN_X, 234, 0, 0, Osd.COLOR_WINDOW);
			target.addChild(panel);
			
			calendar = new Calendar(target, osd);
			calendar.setPos(new Point(10, 470));
			
			var xpos:int = 236;
			var ypos:int = 470;
			var brd:int = 2;
			var rnd:int = 35;
			
			border = new RoundRect(xpos, ypos, 1037, 222, 0, 35, Osd.COLOR_DEFAULT);
			holder = new RoundRect(xpos+brd, ypos+brd, 1037-brd*2, 222-brd*2, 0, rnd-brd, Osd.COLOR_WINDOW);
			
			target.addChild(border);
			target.addChild(holder);
			
			timeLbl = _osd.addLabel(288, 657, "Поиск...", Osd.COLOR_TEXT);
			
			xpos = 464;
			ypos = 654;
			
			_osd.addImageButton(xpos, ypos, "FastBackNormal.png", "FastBackActive.png", "FastBackPreLight.png", CMD_PLAYBACK+5);		xpos += 55;
			playBtn = _osd.addImageButton(xpos, ypos, "PauseNormal.png", "PauseActive.png", "PausePreLight.png", CMD_PLAYBACK);			xpos += 55;
			_osd.addImageButton(xpos, ypos, "FramePlayNormal.png", "FramePlayActive.png", "FramePlayPreLight.png", CMD_PLAYBACK+2);		xpos += 55;
			_osd.addImageButton(xpos, ypos, "SlowPlayNormal.png", "SlowPlayActive.png", "SlowPlayPreLight.png", CMD_PLAYBACK+4);		xpos += 55;
			_osd.addImageButton(xpos, ypos, "FastPlayNormal.png", "FastPlayActive.png", "FastPlayPreLight.png", CMD_PLAYBACK+3);		xpos += 58;
			_osd.addImageButton(xpos, ypos+3, "ZoomIncNormal.png", "ZoomIncActive.png", "ZoomIncPrelight.png", Osd.CMD_INVALID); 		xpos += 50;
			
			muteBtn = _osd.addImageButton(xpos, ypos, IMG_NORMAL[0], IMG_NORMAL[1], IMG_NORMAL[2], CMD_MUTE);		xpos += 36;
			volSld = _osd.addSlider(xpos, ypos + 15, 137, 3, 0, 63, CMD_VOLUME, System.volumeLevel);				xpos += 142; ypos += 4;
			volLbl = _osd.addLabel(xpos, ypos, new String(System.volumeLevel), Osd.COLOR_TEXT);						xpos += 120;
			volSld.setLabel(volLbl);
			
			_osd.addImageButton(xpos, ypos, "MinimizeNormal.png", "MinimizePreLight.png", "MinimizeNormal.png", Osd.CMD_INVALID); xpos += 50;
			_osd.addImageButton(xpos, ypos, "ReduceNormal.png", "ReducePreLight.png", "ReduceNormal.png", Osd.CMD_INVALID);
			
			xpos = 250;
			ypos = 628;
			_osd.addImageButton(xpos, ypos, "ZoomTimeNormal.png", "ZoomTimeActive.png", "ZoomTimePreLight.png", CMD_ZOOM_OUT); xpos += 28;
			_osd.addImageButton(xpos, ypos, "ShrinkTimeNormal.png", "ShrinkTimeActive.png", "ShrinkTimePreLight.png", CMD_ZOOM_IN);
			
			xpos = 240;
			ypos = 513;
			for (var i:int = 0; i < 5; i++)
			{
				var rct:RoundRect = new RoundRect(xpos, ypos, 1026, 2, 0, 0, Osd.COLOR_DEFAULT);
				rct.alpha = System.GRIDLINE_ALPHA;
				target.addChild(rct);
				
				if (i<4) _osd.addLabel(xpos+3, ypos+4, "Кан"+ new String(i+1), Osd.COLOR_TEXT);
				ypos += 28;
			}
			
			var vrct:RoundRect = new RoundRect(MIN_GRIDX, 513, 2, 147, 0, 0, Osd.COLOR_DEFAULT);
			vrct.alpha = System.GRIDLINE_ALPHA;
			target.addChild(vrct);
			
			fillGrid();
			
			_osd.setHandler(target);
			
			playStateImg = _osd.addImage(1165, 118, "PauseActive.png");
			playStateLbl = _osd.addLabel(1200, 120, "x1", Osd.COLOR_SELECTED, TextLabel.TYPE_LARGE);
			playStateImg.visible = false;
			playStateLbl.hide();
			
			_osd.setHandler(this);
			
			addChild(target);
			
			owner.addChild(this);
			rightclick = true;
			setActor(this);
			
			osdCommand(CMD_PLAYBACK);
			
			owner = ow;
		}
		
		//kills old grid and builds new one
		public function resetGrid()
		{
			locker.area.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouse);
			locker.area.removeEventListener(MouseEvent.MOUSE_UP, handleMouse);
			gridHotspot.area.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
			
			gridLines = null;
			gridLabels = null;
			curScrollPage = 0;
			
			target.removeChild(gridStripe);
			target.removeChild(locker);
			
			timeLbl.setText("Поиск...");
			gridDelta = GRID_DELTAS[gridZoom];
			fillGrid();
		}
		
		public function fillGrid()
		{
			gridStripe = new MovieClip();
			gridStripe.blendMode = BlendMode.LAYER;
			_osd.setHandler(gridStripe);
			
			buildGridStripe();
			spawnGridMarker();
			
			scroller = _osd.addScroller(326, 636, 926, 4, SCROLLER_DATA[gridZoom*2], SCROLLER_DATA[gridZoom*2+1], Scroller.STYLE_HORIZONTAL);
			_osd.setHandler(target);
			
			gridMask = new RoundRect(System.SCREEN_X - 12, 470, 100, 231, 0, 0, Osd.COLOR_SELECTED);
			gridMask.blendMode = BlendMode.ERASE;
			gridStripe.addChild(gridMask);
			target.addChild(gridStripe);
			
			locker = new Hotspot(target, osd, Osd.CMD_INVALID);
			locker.setSize(new Point(System.SCREEN_X*2, System.SCREEN_Y*2));
			locker.setPos(new Point(0,0));
			locker.area.addEventListener(MouseEvent.MOUSE_MOVE, handleMouse);
			locker.area.addEventListener(MouseEvent.MOUSE_UP, handleMouse);
			locker.hide();
			target.addChild(locker);

			_osd.setHandler(this);
		}

		public function spawnGridMarker()
		{
			playMarker = new RoundRect(0, 0, (60/ZOOM_INTERVALS[gridZoom])*GRID_DELTAS[gridZoom], 28, 0 , 0, Osd.COLOR_SELECTED);
			playMarker.setPos(MIN_GRIDX, 513);
			playMarker.setGradient(SchedulerSegment.GRAD_NORMAL, [1, 1, 1], [0, 105, 255], Math.PI/2);
			playMarker.blendMode = BlendMode.LAYER;
			
			playMask = new RoundRect(MIN_GRIDX, System.SCREEN_Y/2-133, 955, 383, 0, 0, Osd.COLOR_SELECTED);
			playMarker.mask = playMask;
			playMarker.addChild(playMask);
			gridStripe.addChild(playMarker);
			
			gridMarker = _osd.addImage(0, 0, "TimeTableNoniusShort.png");
			gridMarker.setPos(new Point(MIN_GRIDX-gridMarker.width/2, 498));
			gridHotspot = _osd.addHotspot(gridMarker.getPos().x+477, gridMarker.getPos().y + gridMarker.height/2, 954, gridMarker.height, Osd.CMD_INVALID);
			gridHotspot.area.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
		}
		
		public function buildGridStripe()
		{
			gridLines = new Array();
			gridLabels = new Array();
			
			var xpos:int = MIN_GRIDX;
			var ypos:int = 498;
			
			for (var i:int = 0; i < 24; i++)
			{
				for (var j:int = 0; j < getInvervalCount(); j++)
				{
					var col:uint = Osd.COLOR_DEFAULT;
					var str:String = new String(j*ZOOM_INTERVALS[gridZoom]);
					
					if (j == 0)
					{
						col = Osd.COLOR_SELECTED;
						str = new String(i);
					}
					
					var gr:RoundRect = new RoundRect(0, 0, 2, 147, 0, 0, Osd.COLOR_DEFAULT);
					gr.setPos(xpos, ypos);
					gr.alpha = System.GRIDLINE_ALPHA;
					gridLines.push(gr);
					gridStripe.addChild(gr);
					
					var gl:TextLabel = _osd.addLabel(0, 0, str, col);
					gl.setPos(new Point(xpos - gl.getWidth()/2, ypos-18));
					gridLabels.push(gl);
					
					xpos += gridDelta;
				}
			}
		}
		
		//returns amount of sub-intervals in each hour
		public function getInvervalCount():int
		{
			return 60/ZOOM_INTERVALS[gridZoom];
		}
		
		public function moveGrid(mul:int)
		{
			var step:Number = gridDelta/gridSegments;
			var dist:Number = mul*step;
			
			for (var i:int = 0; i < gridLines.length; i++)
			{
				var p:Point = gridLines[i].getPos();
				
				gridLines[i].setPos(p.x+dist, p.y);
				gridLabels[i].setPos(new Point(p.x-gridLabels[i].getWidth()/2+dist, p.y-18));
				
				var vis:Boolean = true;
				var chk:Boolean = gridLines[i].visible;
				
				if (p.x+dist < MIN_GRIDX-step/getInvervalCount())
				{
					gridLines[i].visible = false;
					gridLabels[i].hide();
				}
				else
				{
					gridLines[i].visible = true;
					gridLabels[i].show();
				}
			}
			
			var tpos:Point = new Point(gridMarker.getPos().x+dist, gridMarker.getPos().y);
			gridMarker.setPos(tpos);
			
			playMarker.setPos(playMarker.getPos().x+dist, playMarker.getPos().y);
			
			if (tpos.x+gridMarker.width/2 < MIN_GRIDX-step/getInvervalCount()) gridMarker.visible = false;
			else gridMarker.visible = true;
		}
		
		public function getMaxGridX():int
		{
			if (gridZoom == 2) return 1241;
			else return MIN_GRIDX+943;
		}
		
		public function updateMuteButton()
		{
			var img:Array = IMG_MUTE;
			if (muted) img = IMG_NORMAL;
			
			muteBtn.setStyle(img[0], img[1], img[2]);
		}
		
		public function updateMarkerPos()
		{
			var tpos:Point = gridMarker.getPos();
			var dx:Number = new Point(gridMarker.mouseX - dragPivot.x, 0).x;
				
			if (tpos.x + dx + gridMarker.width/2 >= MIN_GRIDX && tpos.x + dx < getMaxGridX()) gridMarker.setPos(new Point(tpos.x+dx, tpos.y));
			
			var seg:Number = Math.abs(localToGlobal(gridMarker.getPos()).x-gridLines[0].getPos().x+gridMarker.width/2)/GRID_DELTAS[gridZoom]; //how many segments marker has passed
			var fullTime:Number = seg*ZOOM_INTERVALS[gridZoom]*60;
			
			var t:Array = new Array();
			t.push((Math.floor(fullTime/3600)) as int);
			t.push(Math.floor((fullTime-(t[0]*3600))/60) as int);
			t.push((Math.floor(fullTime-(t[0]*3600 + t[1]*60))) as int);
			if (t[0] == 24) t[0] = 0;
			
			timeLbl.setText(Convertor.getDouble(t[0]) + ":" + Convertor.getDouble(t[1]) + ":" + Convertor.getDouble(t[2]));
		}
		
		public function setCaller(cl:Object)
		{
			caller = cl;
		}
		
		public override function finalize()
		{
			removeChild(target);
			super.finalize();
		}
		
		public override function pressRight()
		{
			System.manager.selectChannel(retChannel);
			System.manager.playVideo(playbackChannel);
			System.manager.showChannels(true);
			System.manager.showOsd(true);
			if (caller) caller.activate();
			finalize();
		}
		
		public function osdCommand(cmd:int):void
		{
			switch(cmd)
			{
				case(CMD_VOLUME):
					System.volumeLevel = volSld.getValue();
					break;
					
				case(CMD_MUTE):
					updateMuteButton();
					muted = !muted;
					break;
					
				case(CMD_ZOOM_IN):
					var compmin:int = gridZoom;
					gridZoom++;
					
					if (gridZoom > MAX_ZOOM) gridZoom = MAX_ZOOM;
					if (compmin != gridZoom) resetGrid();
					break;
					
				case(CMD_ZOOM_OUT):
					var compmax:int = gridZoom;
					gridZoom--;
					
					if (gridZoom < MIN_ZOOM) gridZoom = MIN_ZOOM;
					if (compmax != gridZoom) resetGrid();
					break;
			}
			
			if (cmd >= Osd.CMD_SCROLL)
			{
				var pg:int = cmd - Osd.CMD_SCROLL;
				var mv:int = Math.abs(curScrollPage-pg);
				var sgn:int = -1;
				if (pg < curScrollPage) sgn *= (-1);
				
				moveGrid(mv*sgn);
				curScrollPage = pg;
			}
			
			if (cmd >= CMD_PLAYBACK && cmd < CMD_PLAYBACK + STATE_IMG.length)
			{
				var c:int = cmd - CMD_PLAYBACK;
				if (c == 0)
				{
					if (playState == PS_PLAY)
					{
						System.manager.stopVideo(playbackChannel);
						
						playStateImg.visible = true;
						playStateLbl.hide();
						playState = PS_PAUSE;
						playSpeed = 0;
						
						playBtn.setStyle("PlayNormal.png", "PlayActive.png", "PlayPreLight.png");
						playStateImg.update(STATE_IMG[PS_PAUSE]);
					}
					else
					{
						System.manager.playVideo(playbackChannel);
						
						playStateImg.visible = false;
						playStateLbl.hide();
						playState = PS_PLAY;
						playSpeed = 1;
						
						playBtn.setStyle("PauseNormal.png", "PauseActive.png", "PausePreLight.png");
					}
				}
				else
				{
					playStateImg.visible = true;

					if (c != PS_FRAMEPLAY) playStateLbl.show();
					else playStateLbl.hide();
					
					if (c >= PS_FFWD && c <= PS_RWD)
					{
						if (playSpeed < 8 && playSpeed > 0 && playState == c) playSpeed *= 2;
						else playSpeed = 2;
						
						var prefix:String = "x";
						if (c == PS_SFWD) prefix = "x1/";
						playStateLbl.setText(prefix + new String(playSpeed));
					}
					
					playStateImg.update(STATE_IMG[c]);
					playState = c;
				}
			}
		}
		
		public function handleMouse(e:MouseEvent)
		{
			switch(e.type)
			{
				case(MouseEvent.MOUSE_DOWN):
					var tpos:Point = new Point(mouseX - gridMarker.width/2, gridMarker.getPos().y);
					if (tpos.x < getMaxGridX())
					{
						gridMarker.setPos(tpos);
						dragPivot = new Point(gridMarker.mouseX, gridMarker.mouseY);
						if (!gridMarker.visible) gridMarker.visible = true;
						updateMarkerPos();
						locker.show();
					}
					break;
					
				case(MouseEvent.MOUSE_UP):
					locker.hide();
					break;
				
				case(MouseEvent.MOUSE_MOVE):
					updateMarkerPos();
					break;
			}
		}
	}
}