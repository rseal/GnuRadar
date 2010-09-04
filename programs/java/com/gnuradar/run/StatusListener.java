package com.gnuradar.run;

import java.util.EventListener;

public interface StatusListener extends EventListener
{
	public void eventOccurred( StatusEvent event );	
}