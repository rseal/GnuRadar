package com.gnuradar.verify;

import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.GridBagLayout;

import javax.swing.Box;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JTextPane;

import com.corejava.GBC;

public class GnuRadarVerify
{
   public static final int DEFAULT_WIDTH = 450;
   public static final int DEFAULT_HEIGHT = 300;
   public static final String TITLE = "GnuRadarVerify";
   public static final String VERSION = "0.99";

   public static void main( String[] args )
   {
      EventQueue.invokeLater( new Runnable() {
         public void run()
      {
         GridBagLayout gridBagLayout = new GridBagLayout();
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

         JMenuBar menuBar;
         JMenu fileMenu;
         JMenu helpMenu;
         menuBar = new JMenuBar();

         fileMenu = new JMenu("File");
         fileMenu.add( new JMenuItem("Load",'L'));
         fileMenu.addSeparator();
         fileMenu.add( new JMenuItem("Quit",'Q'));

         helpMenu = new JMenu("Help");
         helpMenu.add( new JMenuItem("About",'A'));

         menuBar.add( fileMenu );
         menuBar.add( Box.createHorizontalGlue() );
         menuBar.add( helpMenu );

         GnuRadarVerifyButtonPanel buttonPanel = 
            new GnuRadarVerifyButtonPanel( status );

         buttonPanel.setMinimumSize( new Dimension(400,50) );
         buttonPanel.setPreferredSize( new Dimension(400,30) );

         SimpleFrame frame = new SimpleFrame( 
               DEFAULT_WIDTH, DEFAULT_HEIGHT, TITLE + " " + VERSION );

         frame.setLayout( gridBagLayout );
         frame.setJMenuBar( menuBar );
         frame.setDefaultCloseOperation( JFrame.EXIT_ON_CLOSE );

         frame.add( buttonPanel, new GBC( 0,1,100,100).setIpad(5,5));
         frame.add( status, new GBC( 0,0,100,100).setIpad(5,5));
         frame.setVisible( true );
      }});
   }
}


class SimpleFrame extends JFrame 
{
  	private static final long serialVersionUID = 1L;

public SimpleFrame( int width, int height, String title )
   {
      setTitle( title );
      setSize( width, height );
      setResizable( true );
   }
}
