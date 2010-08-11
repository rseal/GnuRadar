package com.gnuradar.verify;

import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.GridBagLayout;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JTextPane;
import javax.swing.border.Border;

import com.corejava.GBC;

/// This class is a basic wrapper around the C++ command line version.
/// Console IO is captured and printed to the text box in the application.
/// The program is designed to validate proper settings between the receiver's 
/// configuration and the radar controller's ( pulse generator ) configuration.
/// Any discrepancies will be reported. 
public class GnuRadarVerify
{
   // define constants
   public static final int DEFAULT_WIDTH = 450;
   public static final int DEFAULT_HEIGHT = 340;
   public static final String TITLE = "GnuRadarVerify";
   public static final String VERSION = "0.99";

   // main entry point
   public static void main( String[] args )
   {
      // this is required for proper event-handling
      EventQueue.invokeLater( new Runnable() {
         public void run()
      {
         // use the grid bag layout manager
         GridBagLayout gridBagLayout = new GridBagLayout();

         // create a text pane, set properties, and initialize text.
         JTextPane status = new JTextPane();
         status.setMinimumSize( new Dimension( 400, 200 ) );
         status.setPreferredSize( new Dimension( 400, 200 ) );
         status.setText( 
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

         JMenu fileMenu = new JMenu("File");
         fileMenu.add( new JMenuItem("Load",'L'));
         fileMenu.addSeparator();
         fileMenu.add( new JMenuItem("Quit",'Q'));

         JMenu helpMenu = new JMenu("Help");
         helpMenu.add( new JMenuItem("About",'A'));

         menuBar.add( fileMenu );
         menuBar.add( Box.createHorizontalGlue() );
         menuBar.add( helpMenu );
         
         Border border = BorderFactory.createEtchedBorder();
         StatusPanel statusPanel = new StatusPanel();
         statusPanel.setMinimumSize( new Dimension(400,20) );
         statusPanel.setBorder( border);
         statusPanel.setPreferredSize( new Dimension(400,20) );

         // create button panel and set properties.
         GnuRadarVerifyButtonPanel buttonPanel = 
            new GnuRadarVerifyButtonPanel( statusPanel, status );
         buttonPanel.setMinimumSize( new Dimension(400,30) );
         buttonPanel.setPreferredSize( new Dimension(400,30) );

         // create main window frame and set properties.
         FixedFrame frame = new FixedFrame( 
               DEFAULT_WIDTH, DEFAULT_HEIGHT, TITLE + " " + VERSION );
         frame.setLayout( gridBagLayout );
         frame.setJMenuBar( menuBar );
         frame.setDefaultCloseOperation( JFrame.EXIT_ON_CLOSE );
         frame.add( statusPanel, new GBC( 0,0,100,100).setIpad(5,5));
         frame.add( buttonPanel, new GBC( 0,2,100,100).setIpad(5,5));
         frame.add( status, new GBC( 0,1,100,100).setIpad(5,5));
         frame.setVisible( true );
      }});
   }
}
