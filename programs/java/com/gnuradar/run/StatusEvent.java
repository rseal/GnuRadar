package com.gnuradar.run;

import java.util.EventObject;

public class StatusEvent extends EventObject
{
	private static final long serialVersionUID = 1L;

	public StatusEvent(Object source) {
		super(source);		
	}
	
}