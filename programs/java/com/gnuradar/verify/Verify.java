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
import java.awt.EventQueue;
import java.awt.GridBagLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JTextPane;
import javax.swing.border.Border;

import com.corejava.GBC;
import com.gnuradar.common.FixedFrame;



/// This class is a basic wrapper around the C++ command line version.
/// Console IO is captured and printed to the text box in the application.
/// The program is designed to validate proper settings between the receiver's
/// configuration and the radar controller's ( pulse generator ) configuration.
/// Any discrepancies will be reported.
public class Verify {
    // define constants
    public static final int DEFAULT_WIDTH = 450;
    public static final int DEFAULT_HEIGHT = 340;
    public static final String TITLE = "GnuRadarVerify";
    public static final String VERSION = "Version: 1.0.0";
    public static final String BUILD = "Build: August 29, 2010";
    public static final String COPYRIGHT = "Copyright: \u00a9 2009-2010";
    public static final String AUTHOR = "Author: Ryan Seal";

    // main entry point
    public static void main ( String[] args )
    {
        // this is required for proper event-handling
        EventQueue.invokeLater ( new Runnable() {
            public void run() {
                // use the grid bag layout manager
                GridBagLayout gridBagLayout = new GridBagLayout();

                // create a text pane, set properties, and initialize text.
                JTextPane status = new JTextPane();
                status.setMinimumSize ( new Dimension ( 400, 200 ) );
                status.setPreferredSize ( new Dimension ( 400, 200 ) );
                status.setText (
                    "GnuRadarVerify should be used before radiating to ensure " +
                    "that the receiver's receive window settings match the " +
                    "current radar controller's settings. This means that " +
                    "you must have the radar controller configured and " +
                    "generating receive windows for the receiver. The " +
                    "system will collect a small amount of data and analyze " +
                    "it, attempting to determine the width of the receive " +
                    "window by counting samples between the data tags ( " +
                    "data tags indicate the start of a receive window " +
                    "and ensure proper synchronization ). The counts recorded " +
                    "will be compared with those in the given configuration " +
                    "file and any discrepencies will be reported. It is up " +
                    "to the user to correct the configuration file.\n" +
                    "Begin by selecting a configuration file using the [Load] " +
                    "button and then clicking [Verify]."
                );

                // create menu bar and menu items
                JMenuBar menuBar = new JMenuBar();

                JMenu fileMenu = new JMenu ( "File" );
                fileMenu.add ( new JMenuItem ( "Load", 'L' ) );
                fileMenu.addSeparator();
                fileMenu.add ( new JMenuItem ( "Quit", 'Q' ) );

                JMenu helpMenu = new JMenu ( "Help" );

                JMenuItem aboutAction = new JMenuItem ( "About", 'A' );
                helpMenu.add ( aboutAction );

                aboutAction.addActionListener (
                new ActionListener() {
                    public void actionPerformed ( ActionEvent e ) {
                        JOptionPane.showMessageDialog (
                            null, TITLE + "\n" +
                            VERSION + "\n" + BUILD + "\n" +
                            AUTHOR + "\n" +
                            COPYRIGHT + "\n"
                        );
                    }

                } );

                menuBar.add ( fileMenu );
                menuBar.add ( Box.createHorizontalGlue() );
                menuBar.add ( helpMenu );

                Border border = BorderFactory.createEtchedBorder();
                StatusPanel statusPanel = new StatusPanel();
                statusPanel.setMinimumSize ( new Dimension ( 400, 20 ) );
                statusPanel.setBorder ( border );
                statusPanel.setPreferredSize ( new Dimension ( 400, 20 ) );

                // create button panel and set properties.
                ButtonPanel buttonPanel =
                    new ButtonPanel ( statusPanel, status );
                buttonPanel.setMinimumSize ( new Dimension ( 400, 30 ) );
                buttonPanel.setPreferredSize ( new Dimension ( 400, 30 ) );

                // create main window frame and set properties.
                FixedFrame frame = new FixedFrame (
                    DEFAULT_WIDTH, DEFAULT_HEIGHT, TITLE + " " + VERSION );
                frame.setLayout ( gridBagLayout );
                frame.setJMenuBar ( menuBar );
                frame.setDefaultCloseOperation ( JFrame.EXIT_ON_CLOSE );
                frame.add ( statusPanel, new GBC ( 0, 0, 100, 100 ).setIpad ( 5, 5 ) );
                frame.add ( buttonPanel, new GBC ( 0, 2, 100, 100 ).setIpad ( 5, 5 ) );
                frame.add ( status, new GBC ( 0, 1, 100, 100 ).setIpad ( 5, 5 ) );
                frame.setVisible ( true );
            }
        } );
    }
}
