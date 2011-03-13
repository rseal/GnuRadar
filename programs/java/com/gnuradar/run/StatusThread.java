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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.Socket;
import java.util.HashMap;

import javax.swing.event.EventListenerList;

public class StatusThread implements Runnable {

	private static final long serialVersionUID = 1L;

	private static final int MAX_PACKET_SIZE_BYTES = 512;

	private final InetAddress SERVER_IP;
	private final int SERVER_PORT;
	private boolean running = false;

	protected EventListenerList eventListeners;

	private HashMap<String, String> map = null;
	private String xmlStatusPacket;
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

	private String createRegistrationPacket()
	{
		// create an xml status packet on construction.
		map = new HashMap<String, String>();
		map.put ( "type", "register" );
		map.put ( "source", "gradar_run_java" );
		map.put ( "destination", "gradar_server" );
		map.put ( "name", "status" );

		return XmlPacket.format(map);		
	}
	
	private String createUnregistrationPacket()
	{		
		map = new HashMap<String, String>();
		map.put ( "type", "unregister" );
		map.put ( "source", "gradar_run_java" );
		map.put ( "destination", "gradar_server" );
		map.put ( "name", "status" );
		
		return XmlPacket.format( map );
	}
	
	public StatusThread ( InetAddress ip, int port )
	{    	    	
		SERVER_IP = ip;
		SERVER_PORT = port;
		eventListeners = new EventListenerList();
	}

	public void run()
	{
		Socket socket = null;
		PrintWriter writer = null;
		BufferedReader reader = null;
		DatagramPacket packet = null;
		DatagramSocket dSocket = null;
		running = true;

		xmlStatusPacket = createRegistrationPacket();

		try
		{
			socket = new Socket ( SERVER_IP, SERVER_PORT );
			writer = new PrintWriter( socket.getOutputStream() );
			reader = new BufferedReader( 
					new InputStreamReader( socket.getInputStream() )
			);
			
			// register to receive status packets, flush, and close stream.
			writer.write( xmlStatusPacket );
			writer.close();
			
			// read response and parse into HashMap
			HashMap<String, String> map = XmlPacket.parse( reader.readLine() );
			
			reader.close();			
			socket.close();
			
			if( map.get("response") != "success")
			{
				// TODO: throw exception if registration fails.
			}
			
			byte[] buffer = new byte[MAX_PACKET_SIZE_BYTES];
			packet = new DatagramPacket(
					buffer,
					buffer.length,
					SERVER_IP,
					SERVER_PORT);
			dSocket = new DatagramSocket();
		}
		catch ( IOException e ) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			running = false;
		} 

		
		
		while ( running ) 
		{
			try 
			{
				// receive udp packet and assign.
				dSocket.receive(packet);
				xmlResponsePacket = packet.getData().toString();
				System.out.println ( "status response = " + xmlResponsePacket );
			} catch (IOException e)
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

			if ( xmlResponsePacket != null )
			{
				processEvent( new StatusEvent(this) );
				//this.processEvent ( action );
			}
		}
		
		dSocket.close();
	}

	public void stopStatus()
	{
		Socket socket = null;
		PrintWriter writer = null;
		BufferedReader reader = null;
		
		// unregister with the server to properly shutdown status packet stream.
		xmlStatusPacket = createUnregistrationPacket();
		
		try
		{
			socket = new Socket ( SERVER_IP, SERVER_PORT );
			writer = new PrintWriter( socket.getOutputStream() );
			reader = new BufferedReader( 
					new InputStreamReader( socket.getInputStream() )
			);
			
			// register to receive status packets, flush, and close stream.
			writer.write( xmlStatusPacket );
			writer.close();
			
			// read response and parse into HashMap
			HashMap<String, String> map = XmlPacket.parse( reader.readLine() );
			
			reader.close();			
			socket.close();
			
			if( map.get("response") != "success")
			{
				// TODO: throw exception if unregistration fails.
			}
		}
		catch ( IOException e ) {
			// TODO Auto-generated catch block
			e.printStackTrace();			
		} 
		
		System.out.println ( "Stop status called" );
		running = false;
	}

}


