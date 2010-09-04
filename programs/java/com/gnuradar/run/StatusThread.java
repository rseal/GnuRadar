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
import java.net.InetAddress;
import java.net.Socket;
import java.util.HashMap;

import javax.swing.event.EventListenerList;

public class StatusThread implements Runnable {

    private static final long serialVersionUID = 1L;
	
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

    public StatusThread ( InetAddress ip, int port )
    {    	    	
        SERVER_IP = ip;
        SERVER_PORT = port;

        // create an xml status packet on construction.
        map = new HashMap<String, String>();
        map.put ( "type", "status" );
        map.put ( "source", "gradar_run_java" );
        map.put ( "destination", "gradar_server" );
        map.put ( "name", "status" );

        xmlStatusPacket = XmlPacket.format ( map );
        map = null;
        
        eventListeners = new EventListenerList();
    }

    public void run()
    {
        Socket socket = null;
        PrintWriter writer = null;
        BufferedReader reader = null;
        running = true;

        while ( running ) {
            // form request, send, wait for response
            try {
                socket = new Socket ( SERVER_IP, SERVER_PORT );
                writer = new PrintWriter ( socket.getOutputStream() );
                reader = new BufferedReader (
                    new InputStreamReader ( socket.getInputStream() )
                );
                writer.write ( xmlStatusPacket );
                writer.flush();
                //writer.close();

                xmlResponsePacket = reader.readLine();
                System.out.println ( "status response = " + xmlResponsePacket );

                Thread.sleep ( 1000 );

                System.out.println ( "running status thread " + xmlStatusPacket
                                     + " " + socket.isConnected() );

                if ( xmlResponsePacket != null ) {
                    //this.processEvent ( action );
                    
                }
            } catch ( IOException e ) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            } catch ( InterruptedException e ) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    }

    public void stopStatus()
    {
        System.out.println ( "Stop status called" );
        running = false;
    }
	
}


