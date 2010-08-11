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

import com.gnuradar.verify.StatusPanel.Status;

public class GnuRadarVerifyButtonPanel extends JPanel 
   implements ActionListener
{
   private static final long serialVersionUID = 1L;
   private static final String PROGRAM_NAME = "gradar-verify";
   private static final String PROGRAM_ARGS = "-f ";
   private static final int BUTTON_WIDTH = 100;
   private static final int BUTTON_HEIGHT = 20;
   private static final Dimension dimension = 
      new Dimension( BUTTON_WIDTH, BUTTON_HEIGHT );
   private final static File CONFIGURATION_DIRECTORY = 
      new File("/usr/local/GnuRadar/config");

   private JButton loadButton;
   private JButton verifyButton;
   private JButton quitButton;
   private JFileChooser fileChooser;
   private File configurationFile = null;
   private JTextPane textPane = null;
   private StatusPanel statusPanel = null;

   public GnuRadarVerifyButtonPanel( 
         StatusPanel statusPanel, JTextPane textPane )
   {
      this.statusPanel = statusPanel;
      this.textPane = textPane;
      this.setLayout( new FlowLayout() );

      Border border = BorderFactory.createEtchedBorder(); 
      this.setBorder( border );

      loadButton = new JButton("Load");
      loadButton.setMinimumSize( dimension );
      loadButton.setPreferredSize( dimension );

      verifyButton = new JButton("Verify");
      verifyButton.setMinimumSize( dimension );
      verifyButton.setPreferredSize( dimension );
      verifyButton.setEnabled( false );

      quitButton = new JButton("Quit");
      quitButton.setMinimumSize( dimension );
      quitButton.setPreferredSize( dimension );

      this.add( loadButton );
      this.add( verifyButton );
      this.add( quitButton );

      loadButton.addActionListener( this );
      verifyButton.addActionListener( this );
      quitButton.addActionListener( this );
   }

   public void actionPerformed( ActionEvent e )
   {
      String SUCCESS = "Success";
      int NOT_FOUND = -1;

      int result = 0;
      Object source = e.getSource();

      if( source == loadButton )
      {
         FileNameExtensionFilter fileFilter = new FileNameExtensionFilter(
               "USRP Configuration File", "ucf");
         fileChooser = new JFileChooser();
         fileChooser.setCurrentDirectory( CONFIGURATION_DIRECTORY );
         fileChooser.setFileFilter( fileFilter );

         result = fileChooser.showDialog(null, "Load File");

         if( result == JFileChooser.APPROVE_OPTION )
         {
            configurationFile = fileChooser.getSelectedFile();
            textPane.setText( 
                  "Loaded " + configurationFile + ".\n\n" + 
                  "Make sure that the radar controller is setup and " + 
                  "enabled, and then press [Verify] to begin the " + 
                  "verification process."
                  );
            statusPanel.setStatus( Status.LOADED );
            verifyButton.setEnabled( true );
         }
      }
      else if( source == quitButton )
      {
         System.out.println("Quit called");
         System.exit(0);
      }
      else if( source == verifyButton )
      {
         Process process = null;
         ProcessBuilder pb = new ProcessBuilder( 
               PROGRAM_NAME, PROGRAM_ARGS + configurationFile );
         pb.redirectErrorStream(true);
         try
         {
            process = pb.start();
            BufferedInputStream bis = 
               new BufferedInputStream( process.getInputStream() );
            textPane.setText(
                  "Validating " + configurationFile + ", please wait...\n\n");

            process.waitFor();

            byte[] bytes = new byte[ bis.available() ];
            bis.read( bytes );
            
            String result1 = new String( bytes );
            textPane.setText( result1 );

            int searchIndex = result1.indexOf( SUCCESS );

            statusPanel.setStatus( searchIndex == NOT_FOUND ?  
                  Status.FAILURE : Status.SUCCESS );
         }
         catch( IOException ioe )
         {
            textPane.setText( 
                  "GnuRadarVerify failed to execute. Please make sure that " + 
                  "the gradar-verify executable exists and is reachable."
                  );
         }
         catch( InterruptedException ie )
         {
            textPane.setText( "GnuRadarVerify was interrupted." );
         }

      }
   }
}
