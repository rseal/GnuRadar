// Copyright (c) 2010 Ryan Seal <rlseal -at- gmail.com>
//
// This file is part of GnuRadar Software.
//
// GnuRadar is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// GnuRadar is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GnuRadar.  If not, see <http://www.gnu.org/licenses/>.
package com.gnuradar.run;

import java.util.Map;

import javax.swing.event.EventListenerList;

import org.zeromq.ZMQ;

import com.gnuradar.proto.Status.StatusMessage;
import com.google.protobuf.Descriptors.FieldDescriptor;
import com.google.protobuf.InvalidProtocolBufferException;

public class StatusThread implements Runnable {

	private boolean running = false;
	protected EventListenerList eventListeners;
	private StatusMessage statusMsg;
	
	ZMQ.Context context;
	ZMQ.Socket socket;

	public void addStatusListener( StatusListener listener ){
		eventListeners.add(StatusListener.class, listener);
	}

	public void removeStatusListener( StatusListener listener){
		eventListeners.remove(StatusListener.class, listener);
	}

	public void processEvent( StatusEvent evt ){    	
		StatusListener[] listeners = eventListeners.getListeners(StatusListener.class);    	
		for( int i=0; i<listeners.length; ++i){
			listeners[i].eventOccurred(evt);
		}    	
	}

	public Map<FieldDescriptor, Object> getResponse()
	{
		return this.statusMsg.getAllFields();
	}
	
	public StatusThread ( String ipAddress)
	{    	    	
		eventListeners = new EventListenerList();
	}

	public void run()
	{
		running = true;
  
		// SETUP SUBSCRIBER
		this.context = ZMQ.context(1);
		this.socket = this.context.socket(ZMQ.SUB);
		
		while ( running ) 
		{
			this.statusMsg = null;
			
			byte[] status = socket.recv(0);
			try {
				this.statusMsg = StatusMessage.parseFrom(status);
			} catch (InvalidProtocolBufferException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			if ( this.statusMsg != null )
			{				
				processEvent( new StatusEvent(this) );
			}
			else
			{
				System.out.println("Status receive timed out. You are not receiving status from the server!");
			}
		}
	}

	public void stopStatus()
	{
		running = false;
		socket.close();
		System.out.println ( "Stop status called" );
	}
}


