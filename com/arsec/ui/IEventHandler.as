package com.arsec.ui
{
	//basic interface for objects dispatching OSD events
	public interface IEventHandler
	{
		function osdCommand(cmd:int):void;
	}
}