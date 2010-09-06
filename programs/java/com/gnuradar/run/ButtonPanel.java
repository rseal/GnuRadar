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

import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.InetAddress;
import java.net.Socket;
import java.util.HashMap;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JFileChooser;
import javax.swing.JPanel;
import javax.swing.border.Border;
import javax.swing.filechooser.FileNameExtensionFilter;

public class ButtonPanel extends JPanel
            implements ActionListener {

    
    
    public static enum State {
        UNCONFIGURED ( "UNCONFIGURED" ),
        CONFIGURED ( "CONFIGURED" ),
        VERIFIED ( "VERIFIED" ),
        RUNNING ( "RUNNING" ),
        STOPPED ( "STOPPED" ),
        ERROR ( "ERROR" ),
        CONNECTION_ERROR ( "CONNECTION ERROR" );

        private String state;

        private State ( String state ) {
            this.state = state;
        }

        public String getValue() {
            return state;
        }
    }

    private void setState ( State next )
    {
        state = next;
        // probably not the best solution, but it appears
        // to work as long as old and new values are different.
        // thus the 0 and 1.
        firePropertyChange ( "state", 0, 1 );
    }

    private State state = State.UNCONFIGURED;
    private static final long serialVersionUID = 1L;
    private static boolean running = false;
    private JButton loadButton;
    private JButton verifyButton;
    private JButton runButton;
    private File configurationFile = null;
    private String xmlResponsePacket;

    private Dimension buttonSize = new Dimension ( 100, 25 );

    private void setComponentSize ( JComponent obj, Dimension dimension )
    {
        obj.setMinimumSize ( dimension );
        obj.setPreferredSize ( dimension );
        obj.setMaximumSize ( dimension );
    }

    private void WriteToServer ( String packet )
    throws IOException, SecurityException
    {
        xmlResponsePacket = null;
        
        // TODO: IP and port should be read from an
        // xml-based setup file during Construction.

        InetAddress address = InetAddress.getByName ( "localhost" );
        Socket socket = new Socket ( address, 54321 );

        if ( socket.isConnected() ) {
            OutputStreamWriter writer = new OutputStreamWriter (
                socket.getOutputStream()
            );
            BufferedReader reader = new BufferedReader (
                new InputStreamReader ( socket.getInputStream() )
            );

            writer.write ( packet );
            writer.flush();
            
            xmlResponsePacket = reader.readLine();
            writer.close();
            reader.close();
            socket.close();
        }
    }

    public boolean loadFile()
    {
        boolean loaded = false;

        FileNameExtensionFilter fileFilter =
            new FileNameExtensionFilter (
            "USRP Configuration File", "ucf" );

        JFileChooser jf = new JFileChooser();
        jf.setFileFilter ( fileFilter );

        int loadFile = jf.showOpenDialog ( null );

        if ( loadFile == JFileChooser.APPROVE_OPTION ) {
            loaded = true;
            configurationFile = jf.getSelectedFile();
            System.out.println ( "file = " + configurationFile.getAbsolutePath() );
        }

        return loaded;
    }

    public ButtonPanel( )
    {
        this.setLayout ( new BoxLayout ( this, BoxLayout.Y_AXIS ) );

        loadButton = new JButton ( "Load" );
        loadButton.setAlignmentX ( CENTER_ALIGNMENT );

        setComponentSize ( loadButton, buttonSize );
        verifyButton = new JButton ( "Verify" );
        verifyButton.setAlignmentX ( CENTER_ALIGNMENT );
        verifyButton.setEnabled ( false );
        setComponentSize ( verifyButton, buttonSize );
        runButton = new JButton ( "Run" );
        runButton.setAlignmentX ( CENTER_ALIGNMENT );
        runButton.setEnabled ( false );
        setComponentSize ( runButton, buttonSize );

        this.add ( Box.createRigidArea ( new Dimension ( 0, 5 ) ) );
        this.add ( loadButton  );
        this.add ( Box.createRigidArea ( new Dimension ( 0, 5 ) ) );
        this.add ( verifyButton  );
        this.add ( Box.createRigidArea ( new Dimension ( 0, 5 ) ) );
        this.add ( runButton  );
        this.add ( Box.createVerticalGlue() );

        loadButton.addActionListener ( this );
        verifyButton.addActionListener ( this );
        runButton.addActionListener ( this );

        Border border = BorderFactory.createEtchedBorder( );
        this.setBorder ( border );
    }

    @Override
    public void actionPerformed ( ActionEvent e )
    {
        if ( e.getSource() == runButton ) {
        	System.out.println("Run button pressed");
        	
            HashMap<String, String> map = new HashMap<String, String>();
            map.put ( "type", "control" );
            map.put ( "source", "gradar_run_java" );
            map.put ( "destination", "gradar_server" );

            if ( state == State.RUNNING ) {

            	System.out.println("Stop button pressed");
            	
                // create xml packet and send to server
                map.put ( "name", "stop" );
                String xmlPacket = XmlPacket.format ( map );

                try {
                	
                	WriteToServer ( xmlPacket );
                	map.clear();
                	map = XmlPacket.parse(xmlResponsePacket);
                	String response = map.get("value");
                	
                	if( response.contains("OK")){

                    // set button states
                    setState ( State.STOPPED );
                    runButton.setText ( "Run" );
                    loadButton.setEnabled ( true );
                	}
                	else{
                		setState( State.ERROR );
                	}

                } catch ( IOException e2 ) {
                    setState ( State.CONNECTION_ERROR );
                    e2.printStackTrace();
                }
            } else {
            	try {

            		// create xml packet and send to server
                    map.put ( "name", "start" );
                    map.put ( "file_name", configurationFile.getAbsolutePath() );
                    String xmlPacket = XmlPacket.format ( map );

                    WriteToServer ( xmlPacket );

                    map.clear();
                    map = XmlPacket.parse( xmlResponsePacket );
                    String response = map.get("value").replace("\n", "").trim();
                 
                    if( response.contains("OK") )
                    {
                    	System.out.println("Setting state to Run");
                       // set button states
                       setState ( State.RUNNING );
                       runButton.setText ( "Stop" );
                       loadButton.setEnabled ( false );
                    }
                    else
                    {                    	
                    	setState( State.ERROR);                    	
                    }

                } catch ( IOException e1 ) {
                    setState ( State.CONNECTION_ERROR );
                    e1.printStackTrace();
                }
            }
        }

        if ( e.getSource() == loadButton ) {

            verifyButton.setEnabled ( false );
            runButton.setEnabled ( false );
            if ( loadFile() ) {
                setState ( State.CONFIGURED );
                verifyButton.setEnabled ( true );
            }
        }

        if ( e.getSource() == verifyButton ) {

            boolean verified = false;
            // TODO: Send Verification Message and get response
            // if successful set verified = true
            setState ( State.VERIFIED );
            runButton.setEnabled ( verified );
            // TODO: Remove me
            runButton.setEnabled ( true );
        }
    }

    public boolean isRunning()
    {
        return running;
    }
    public File getConfigurationFile()
    {
        return configurationFile;
    }
    public State getState()
    {
        return state;
    }
    public String getServerResponse()
    {
    	return xmlResponsePacket;
    }
    public void clickLoadButton()
    {
        loadButton.doClick();
    }

}
