package com.arsec.ui
{
	public interface IActivator
	{
		//in arguments we can define which objects need activation/deactivation
		function activate(...args):void;
		function deactivate(...args):void;
	}
}