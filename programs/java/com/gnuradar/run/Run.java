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

import java.awt.Color;
import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.Font;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Point;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.io.File;
import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.prefs.Preferences;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextPane;
import javax.swing.border.Border;
import javax.swing.border.TitledBorder;
import javax.swing.text.DefaultStyledDocument;
import javax.swing.text.Document;

import com.corejava.GBC;
import com.gnuradar.common.FixedFrame;
import com.gnuradar.run.ButtonPanel.State;

public class Run implements ActionListener, PropertyChangeListener {

    // define constants
    public static final int DEFAULT_WIDTH = 575;
    public static final int DEFAULT_HEIGHT = 560;
    public static final int LEFT_WIDTH = 420;
    public static final int RIGHT_WIDTH = 200;
    public static final String TITLE = "GnuRadarRun";
    public static final String VERSION = "Version: 1.0.0";
    public static final String BUILD = "Build: September 01, 2010";
    public static final String COPYRIGHT = "Copyright: \u00a9 2009-2010";
    public static final String AUTHOR = "Author: Ryan Seal";
    public final int PORT = 54321;
    
    public static InetAddress INET_ADDRESS;
    private StatusListener statusListener;
    private HashMap<String,String> responseMap = new HashMap<String,String>();    
    
    private JLabel statusLabel;
    private JTextPane statusPane;
    private ProgressPanel progressPanel;
    private Document statusDocument;

    private static ButtonPanel buttonPanel;
    private static FixedFrame frame;
    private static String userNode = "/com/gnuradar/run";

    private Thread thread = null;
    private StatusThread statusThread = null;
    
    private JMenuItem quitAction;
    private JMenuItem loadAction;
    private JMenuItem aboutAction;
    private JMenuItem plotAction;
    private JMenuItem bpgAction;
    private JMenuItem configureAction;

    private void loadPreferences()
    {
    	Preferences preferences = Preferences.userRoot().node(userNode);
    	int x = preferences.getInt("x", 0);
    	int y = preferences.getInt("y", 0);
    	File file = new File( preferences.get("config_dir", "") );
    	buttonPanel.setConfigurationFile( file );
    	frame.setLocation(x,y);
    }
    
    private void savePreferences()
    {    	
    	Point point = frame.getLocation();
    	File file = buttonPanel.getConfigurationFile();
    	
    	Preferences preferences = Preferences.userRoot().node(userNode);
    	
        preferences.put("x", Integer.toString( point.x ));
        preferences.put("y", Integer.toString( point.y ));
        preferences.put("config_dir", file.toString() );
    }
    
    private void updateDisplay(String xmlResponsePacket )
    {
    	//System.out.println("Updating Display");
    	responseMap.clear();
    	responseMap = XmlPacket.parse(xmlResponsePacket);
    	
    	progressPanel.setHead( Integer.valueOf( responseMap.get("head")));
    	progressPanel.setTail( Integer.valueOf( responseMap.get("tail")));
    	progressPanel.setDepth( Integer.valueOf( responseMap.get("depth")));
    	progressPanel.setNumBuffers( Integer.valueOf( responseMap.get("num_buffers")));    	
    }
    
    private static void setComponentSize ( JComponent obj, Dimension dimension )
    {
        obj.setMinimumSize ( dimension );
        obj.setPreferredSize ( dimension );
    }

    // main entry point
    public static void main ( String[] args )
    {    	
        final Run run = new Run();
        
		try {
			  INET_ADDRESS = InetAddress.getByName("localhost");
		} catch (UnknownHostException e1) {
			System.out.println(" Could not contact the specified IP address " + INET_ADDRESS );			
			e1.printStackTrace();
		}    	

        // this is required for proper event-handling
        EventQueue.invokeLater ( new Runnable() {
            public void run() {

                // use the grid bag layout manager
                GridBagLayout gridBagLayout = new GridBagLayout();

                Border border = BorderFactory.createEtchedBorder( );
                TitledBorder tBorder = BorderFactory.createTitledBorder ( border, "Status" );
                tBorder.setTitleJustification ( TitledBorder.CENTER );

                run.statusPane = new JTextPane();
                run.statusDocument = new DefaultStyledDocument();
                run.statusPane.setBorder ( tBorder );
                run.statusPane.setEditable(false);
                run.statusPane.setDocument( run.statusDocument);

                setComponentSize ( run.statusPane, new Dimension ( 400, 390 ) );

                JPanel statusPanel = new JPanel();
                statusPanel.setBorder ( border );

                run.statusLabel = new JLabel ( "UNCONFIGURED", JLabel.CENTER );
                run.statusLabel.setFont ( new Font ( "", Font.BOLD, 16 ) );
                run.statusLabel.setForeground ( Color.WHITE );

                setComponentSize ( statusPanel, new Dimension ( 400, 25 ) );

                statusPanel.setBackground ( Color.BLUE );
                statusPanel.add ( run.statusLabel );

                buttonPanel = new ButtonPanel();
                setComponentSize ( buttonPanel, new Dimension ( 100, 400 ) );

                run.progressPanel = new ProgressPanel();
                setComponentSize ( run.progressPanel, new Dimension ( 400, 50 ) );

                // create menu bar and menu items
                JMenuBar menuBar = new JMenuBar();

                run.loadAction = new JMenuItem ( "Load", 'L' );
                run.loadAction.addActionListener ( run );
                run.quitAction = new JMenuItem ( "Quit", 'Q' );
                run.quitAction.addActionListener ( run );
                run.plotAction = new JMenuItem ( "Plotter", 'P' );
                run.plotAction.addActionListener ( run );
                run.bpgAction = new JMenuItem ( "BitPatternGenerator", 'B' );
                run.bpgAction.addActionListener ( run );
                run.aboutAction = new JMenuItem ( "About", 'A' );
                run.aboutAction.addActionListener ( run );
                run.configureAction = new JMenuItem( "GnuRadar Configure", 'C');
                run.configureAction.addActionListener(run );

                JMenu fileMenu = new JMenu ( "File" );
                fileMenu.add ( run.loadAction );
                fileMenu.addSeparator();
                fileMenu.add ( run.quitAction );

                JMenu toolMenu = new JMenu ( "Tools" );
                toolMenu.add ( run.plotAction );
                toolMenu.add ( run.bpgAction );
                toolMenu.add ( run.configureAction);

                JMenu helpMenu = new JMenu ( "Help" );
                helpMenu.add ( run.aboutAction );

                //TODO: Enable these when ready
                run.plotAction.setEnabled ( false );
                run.bpgAction.setEnabled ( false );

                menuBar.add ( fileMenu );
                menuBar.add ( toolMenu );
                menuBar.add ( Box.createHorizontalGlue() );
                menuBar.add ( helpMenu );

                // create main window frame and set properties.
                frame = new FixedFrame (
                    DEFAULT_WIDTH, DEFAULT_HEIGHT, TITLE + " " + VERSION );
                frame.setLayout ( gridBagLayout );
                frame.setJMenuBar ( menuBar );
                frame.setDefaultCloseOperation ( JFrame.DO_NOTHING_ON_CLOSE );

                // make sure that a click to 'x' out the window passes through
                // the quit function to ensure proper shutdown.
                frame.addWindowListener (
                new WindowAdapter() {
                    public void windowClosing ( WindowEvent e ) {
                        run.quit();
                    }
                } );

                frame.add ( buttonPanel,
                            new GBC ( 0, 1, 10, 100 ).setIpad ( 5, 5 ).
                            setSpan ( 1, 4 ).setFill (
                                GridBagConstraints.VERTICAL )
                          );
                frame.add ( statusPanel,
                            new GBC ( 0, 0, 10, 10 ).setIpad ( 5, 5 ).
                            setSpan ( 4, 1 ).setFill (
                                GridBagConstraints.HORIZONTAL )
                          );
                frame.add ( run.statusPane,
                            new GBC ( 1, 1, 100, 100 ).setIpad ( 5, 5 ).
                            setSpan ( 3, 3 ).setFill (
                                GridBagConstraints.HORIZONTAL )
                          );
                frame.add ( run.progressPanel,
                            new GBC ( 1, 4, 100, 100 ).setIpad ( 5, 5 ).
                            setSpan ( 3, 1 ).setFill (
                                GridBagConstraints.HORIZONTAL )
                          );
                
                run.loadPreferences();

                buttonPanel.addPropertyChangeListener ( run );
                frame.setVisible ( true );
            }
        } );
    }

    @Override
    public void actionPerformed ( ActionEvent e )
    {
        Object source = e.getSource();

        if ( source == configureAction ){
        	
        	ProcessBuilder pBuilder = new ProcessBuilder("gradar-configure");
        	try {
				Process process = pBuilder.start();
				process.waitFor();
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			} catch (InterruptedException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
        
        }
        if ( source == loadAction ) {
            buttonPanel.clickLoadButton();
        }

        if ( source == quitAction ) {        	
            quit();
        }

        if ( source == aboutAction ) {
            JOptionPane.showMessageDialog (
                null, TITLE + "\n" +
                VERSION + "\n" + BUILD + "\n" +
                AUTHOR + "\n" +
                COPYRIGHT + "\n"
            );
        }
    }

    @Override
    public void propertyChange ( PropertyChangeEvent evt )
    {
    	State state = buttonPanel.getState();    	
        statusLabel.setText ( state.getValue() );

        // get the response packet from the server and parse if not null
        String xmlResponsePacket = buttonPanel.getServerResponse();
        if( xmlResponsePacket != null)
        {
        	HashMap<String,String> map = XmlPacket.parse(xmlResponsePacket);
        	String response = map.get("message");      	
        	statusPane.setText(response);
        }
        
        if( state == State.RUNNING )
        {
        	statusThread = new StatusThread(INET_ADDRESS, PORT);
        	thread = new Thread(statusThread);
        	thread.start();
        	
        	statusListener = new StatusListener(){
				@Override
				public void eventOccurred(StatusEvent event) {
					updateDisplay( statusThread.getResponse() );							
				}};				
        	statusThread.addStatusListener( statusListener );        	
        }
        
        if( state == State.STOPPED && thread.isAlive() ){
        	
        	statusThread.removeStatusListener(statusListener);
        	statusThread.stopStatus();        	
        	try {
				thread.join();
			} catch (InterruptedException e) {
				System.out.println( "Status thread join was interrupted.");
			}
        }
        
        if( state == State.CONFIGURED ){
        	statusPane.setText( "Configuration File Loaded." );
        }
    }

    public void quit()
    {
        if ( buttonPanel.getState() == State.RUNNING ) {
            JOptionPane.showMessageDialog ( 
            		null,
            		"System is currently in operation. Press <Stop> before" +
            " attempting to exit" );
        } else {
        	savePreferences();
            System.exit ( 0 );
        }
    }
}
