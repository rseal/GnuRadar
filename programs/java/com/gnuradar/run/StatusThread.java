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

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;

import javax.swing.event.EventListenerList;

public class StatusThread implements Runnable {

	private static final long serialVersionUID = 1L;

	// we must use a fixed packet size to avoid problems 
	// with the underlying byte buffer in a datagrampacket.
	private static final int MAX_PACKET_SIZE_BYTES = 512;
	
	private final int SERVER_PORT;
	private boolean running = false;
	
	private DatagramSocket socket = null;
	
	protected EventListenerList eventListeners;
	
	private String xmlResponsePacket;

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

	public String getResponse()
	{
		return xmlResponsePacket;
	}
	
	public StatusThread ( int port )
	{    	    	
		SERVER_PORT = port;
		eventListeners = new EventListenerList();
	}

	public void run()
	{
		byte[] buffer = new byte[MAX_PACKET_SIZE_BYTES];		
		DatagramPacket packet = null;
		running = true;
  
		try
		{				
			packet = new DatagramPacket(buffer, buffer.length);
			socket = new DatagramSocket(SERVER_PORT);
			socket.setBroadcast(true);
			socket.setReceiveBufferSize( MAX_PACKET_SIZE_BYTES );
		}
		catch (SocketException e) {
			e.printStackTrace();
		} 
		
		while ( running ) 
		{
			try 
			{			
				// receive udp packet and assign.
				socket.receive(packet);
                xmlResponsePacket = new String( packet.getData() );
			} catch (IOException e)
			{				
				e.printStackTrace();
			}

			if ( xmlResponsePacket != null )
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
		socket.disconnect();
		socket.close();
		System.out.println ( "Stop status called" );
	}
}


