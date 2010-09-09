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
package com.gnuradar.verify;

import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.IOException;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JPanel;
import javax.swing.JTextPane;
import javax.swing.border.Border;
import javax.swing.filechooser.FileNameExtensionFilter;

public class ButtonPanel extends JPanel
            implements ActionListener {
    private static final long serialVersionUID = 1L;
    private static final String PROGRAM_NAME = "gradar-verify-cli";
    private static final String PROGRAM_ARGS = "-f ";
    private static final int BUTTON_WIDTH = 100;
    private static final int BUTTON_HEIGHT = 20;
    private static final Dimension dimension =
        new Dimension ( BUTTON_WIDTH, BUTTON_HEIGHT );
    
    public JButton loadButton;
    public JButton verifyButton;
    public JButton quitButton;
    private JFileChooser fileChooser;
    private File configurationFile = null;
    private JTextPane textPane = null;
    private StatusPanel statusPanel = null;

    public ButtonPanel (
        StatusPanel statusPanel, JTextPane textPane )
    {
        this.statusPanel = statusPanel;
        this.textPane = textPane;
        this.setLayout ( new FlowLayout() );

        Border border = BorderFactory.createEtchedBorder();
        this.setBorder ( border );

        loadButton = new JButton ( "Load" );
        loadButton.setMinimumSize ( dimension );
        loadButton.setPreferredSize ( dimension );

        verifyButton = new JButton ( "Verify" );
        verifyButton.setMinimumSize ( dimension );
        verifyButton.setPreferredSize ( dimension );
        verifyButton.setEnabled ( false );

        quitButton = new JButton ( "Quit" );
        quitButton.setMinimumSize ( dimension );
        quitButton.setPreferredSize ( dimension );

        this.add ( loadButton );
        this.add ( verifyButton );
        this.add ( quitButton );

        loadButton.addActionListener ( this );
        verifyButton.addActionListener ( this );
        quitButton.addActionListener ( this );
    }

    public void actionPerformed ( ActionEvent e )
    {
        String SUCCESS = "passed";
        int NOT_FOUND = -1;

        int result = 0;
        Object source = e.getSource();

        if ( source == loadButton ) {
            FileNameExtensionFilter fileFilter = new FileNameExtensionFilter (
                "USRP Configuration File", "ucf" );
            fileChooser = new JFileChooser();
            fileChooser.setCurrentDirectory ( configurationFile );
            fileChooser.setFileFilter ( fileFilter );

            result = fileChooser.showDialog ( null, "Load File" );

            if ( result == JFileChooser.APPROVE_OPTION ) {
                configurationFile = fileChooser.getSelectedFile();
                textPane.setText (
                    "Loaded " + configurationFile + ".\n\n" +
                    "Make sure that the radar controller is setup and " +
                    "enabled, and then press [Verify] to begin the " +
                    "verification process."
                );
                statusPanel.setStatus ( Status.LOADED );
                verifyButton.setEnabled ( true );
            }        
        } else if ( source == verifyButton ) {
            Process process = null;
            ProcessBuilder pb = new ProcessBuilder (
                PROGRAM_NAME, PROGRAM_ARGS + configurationFile );
            pb.redirectErrorStream ( true );
            try {
                process = pb.start();
                BufferedInputStream bis =
                    new BufferedInputStream ( process.getInputStream() );
                textPane.setText (
                    "Validating " + configurationFile + ", please wait...\n\n" );

                process.waitFor();

                byte[] bytes = new byte[ bis.available() ];
                bis.read ( bytes );

                String result1 = new String ( bytes );
                textPane.setText ( result1 );

                int searchIndex = result1.indexOf ( SUCCESS );

                statusPanel.setStatus ( searchIndex == NOT_FOUND ?
                                        Status.FAILURE : Status.SUCCESS );
            } catch ( IOException ioe ) {
                textPane.setText (
                    "GnuRadarVerify failed to execute. Please make sure that " +
                    "the " + PROGRAM_NAME + " executable exists and is reachable."
                );
            } catch ( InterruptedException ie ) {
                textPane.setText ( "GnuRadarVerify was interrupted." );
            }

        }      
    }
    
    public File getConfigurationFile(){ return configurationFile; }
    
    public void setConfigurationFile( File file){
    	configurationFile = file;
    }
        
}