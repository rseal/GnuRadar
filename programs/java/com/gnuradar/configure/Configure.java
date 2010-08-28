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
package com.gnuradar.configure;

import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.util.HashMap;

import javax.swing.Box;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.filechooser.FileNameExtensionFilter;

import com.corejava.GBC;
import com.gnuradar.common.FixedFrame;

public class Configure {
    // define constants
    public static final int DEFAULT_WIDTH = 875;
    public static final int DEFAULT_HEIGHT = 530;
    public static final int LEFT_WIDTH = 420;
    public static final int RIGHT_WIDTH = 200;
    public static final String TITLE = "GnuRadarConfigure";
    public static final String VERSION = "0.99";

    private static HashMap<String, String> settingsMap =
        new HashMap<String, String> ( 33 );

    public static void loadFile()
    {   
    	settingsMap.clear();
    	
    	FileNameExtensionFilter fileFilter =
        new FileNameExtensionFilter (
                "USRP Configuration File", "ucf" );

    	JFileChooser jf = new JFileChooser();
    	jf.setFileFilter( fileFilter );
    	
    	int loadFile = jf.showOpenDialog(null);
    	
    	if( loadFile == JFileChooser.APPROVE_OPTION ) {
    		File file = jf.getSelectedFile();
    		settingsMap = XmlParser.load( file);
    	}
    	
    	
    }
    private static void saveFile( )
    {
        FileNameExtensionFilter fileFilter =
            new FileNameExtensionFilter (
            "USRP Configuration File", "ucf" );

        JFileChooser jf = new JFileChooser();
        jf.setFileFilter ( fileFilter );

        int saveChanges = jf.showSaveDialog ( null );

        if ( saveChanges == JFileChooser.APPROVE_OPTION ) {
            File file = jf.getSelectedFile();

            int index = file.getName().lastIndexOf ( ".ucf" );
            if ( index == -1 ) {
                file = new File ( file.toString() + ".ucf" );
            }

            XmlParser.save( file, settingsMap );
        }
    }

    // main entry point
    public static void main ( String[] args )
    {
        // this is required for proper event-handling
        EventQueue.invokeLater ( new Runnable() {
            public void run() {
                // use the grid bag layout manager
                GridBagLayout gridBagLayout = new GridBagLayout();

                final SettingsPanel settingsPanel =
                    new SettingsPanel();
                settingsPanel.setMinimumSize (
                    new Dimension ( LEFT_WIDTH, 90 ) );
                settingsPanel.setPreferredSize (
                    new Dimension ( LEFT_WIDTH, 90 ) );

                final DdcSettingsPanel ddcSettingsPanel =
                    new DdcSettingsPanel();
                ddcSettingsPanel.setMinimumSize (
                    new Dimension ( LEFT_WIDTH, 170 ) );
                ddcSettingsPanel.setPreferredSize (
                    new Dimension ( LEFT_WIDTH, 170 ) );

                final PulseSettingsPanel pulseSettingsPanel =
                    new PulseSettingsPanel (
                    new Dimension ( LEFT_WIDTH, 170 )
                );
                pulseSettingsPanel.setMinimumSize (
                    new Dimension ( LEFT_WIDTH, 170 ) );
                pulseSettingsPanel.setPreferredSize (
                    new Dimension ( LEFT_WIDTH, 170 ) );

                final InformationPanel informationPanel =
                    new InformationPanel();
                final FileSettingsPanel fileSettingsPanel =
                    new FileSettingsPanel();

                ButtonPanel configureButtonPanel =
                    new ButtonPanel();

                // each time the settings panel changes the number of channels
                // we need to alert the ddc settings panel to enable/disable
                // the proper tabs.
                settingsPanel.channelsComboBox.addActionListener (
                    ddcSettingsPanel );

                // create menu bar and menu items
                JMenuBar menuBar = new JMenuBar();

                JMenu fileMenu = new JMenu ( "File" );
                fileMenu.add ( new JMenuItem ( "Load", 'L' ) );
                fileMenu.addSeparator();
                fileMenu.add ( new JMenuItem ( "Quit", 'Q' ) );

                JMenu helpMenu = new JMenu ( "Help" );
                helpMenu.add ( new JMenuItem ( "About", 'A' ) );

                menuBar.add ( fileMenu );
                menuBar.add ( Box.createHorizontalGlue() );
                menuBar.add ( helpMenu );

                // create main window frame and set properties.
                FixedFrame frame = new FixedFrame (
                    DEFAULT_WIDTH, DEFAULT_HEIGHT, TITLE + " " + VERSION );
                frame.setLayout ( gridBagLayout );
                frame.setJMenuBar ( menuBar );
                frame.setDefaultCloseOperation ( JFrame.EXIT_ON_CLOSE );

                frame.add ( settingsPanel,
                            new GBC ( 0, 0, 10, 100 ).setIpad ( 5, 5 ).
                            setSpan ( 1, 1 ).setFill (
                               GridBagConstraints.HORIZONTAL )
                          );
                frame.add ( ddcSettingsPanel,
                            new GBC ( 0, 1, 10, 100 ).setIpad ( 5, 5 ).
                            setSpan ( 1, 1 ).setFill (
                                GridBagConstraints.HORIZONTAL )
                          );
                frame.add ( pulseSettingsPanel,
                            new GBC ( 0, 2, 10, 100 ).setIpad ( 5, 5 ).
                            setSpan ( 1, 1 ).setFill (
                                GridBagConstraints.BOTH )
                          );
                frame.add ( informationPanel,
                            new GBC ( 1, 0, 10, 100 ).setIpad ( 5, 5 ).
                            setSpan ( 1, 2 ).setFill (
                                GridBagConstraints.BOTH )
                          );

                frame.add ( fileSettingsPanel,
                            new GBC ( 1, 2, 10, 100 ).setIpad ( 5, 5 ).
                            setSpan ( 1, 1 ).setFill (
                                GridBagConstraints.BOTH )
                          );

                frame.add ( configureButtonPanel,
                            new GBC ( 0, 3, 10, 100 ).setIpad ( 5, 5 ).
                            setSpan ( 2, 1 ).setFill (
                                GridBagConstraints.HORIZONTAL )
                          );
                             
                configureButtonPanel.saveButton.addActionListener (

                new ActionListener() {
                    public void actionPerformed ( ActionEvent e ) {
                    	settingsMap.clear();
                        settingsMap.putAll ( settingsPanel.getSettings() );
                        settingsMap.putAll ( ddcSettingsPanel.getSettings() );
                        settingsMap.putAll ( pulseSettingsPanel.getSettings() );
                        settingsMap.putAll ( informationPanel.getSettings() );
                        settingsMap.putAll ( fileSettingsPanel.getSettings() );

                        saveFile();
                        
                        }
                 } );

                configureButtonPanel.loadButton.addActionListener(
                		
                            		
                		new ActionListener() {
                		public void actionPerformed( ActionEvent e){
                			                			loadFile();
                        settingsPanel.pushSettings( settingsMap );
                        ddcSettingsPanel.pushSettings( settingsMap );
                        pulseSettingsPanel.pushSettings( settingsMap );
                        informationPanel.pushSettings( settingsMap );
                        fileSettingsPanel.pushSettings( settingsMap );
                		}
                		});
                		
                configureButtonPanel.quitButton.addActionListener (

                new ActionListener() {
                    public void actionPerformed ( ActionEvent e ) {
                        HashMap<String, String> map =
                            new HashMap<String, String> (50);
                        map.putAll ( settingsPanel.getSettings() );
                        map.putAll ( ddcSettingsPanel.getSettings() );
                        map.putAll ( pulseSettingsPanel.getSettings() );
                        map.putAll ( informationPanel.getSettings() );
                        map.putAll ( fileSettingsPanel.getSettings() );

                        // compare our local map with the global to see if
                        // the user has changed anything since their last
                        // save. If so, give them a chance to save
                        // modifications.
                        if ( !map.equals ( settingsMap ) &&
                        !settingsMap.isEmpty() ) {
                            System.out.println ( " Settings do not match " );
                            int saveChanges =
                                JOptionPane.showConfirmDialog (
                                    null, "Unsaved changes detected. Would " +
                                    "you like to save now?",
                                    "Input", JOptionPane.YES_NO_OPTION );

                            if ( saveChanges == JOptionPane.YES_OPTION ) {
                            	settingsMap.clear();
                                settingsMap.putAll ( settingsPanel.getSettings() );
                                settingsMap.putAll ( ddcSettingsPanel.getSettings() );
                                settingsMap.putAll ( pulseSettingsPanel.getSettings() );
                                settingsMap.putAll ( informationPanel.getSettings() );
                                settingsMap.putAll ( fileSettingsPanel.getSettings() );
                                saveFile();
                            }
                        }
                        System.exit ( 0 );
                    }
                } );
                frame.setVisible ( true );
            }
        } );
    }
}
