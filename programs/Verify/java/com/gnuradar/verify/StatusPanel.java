package com.gnuradar.verify;

import javax.swing.JPanel;
import javax.swing.JLabel;

import java.awt.Color;

public class StatusPanel extends JPanel
{
   //private static final long serialVersionUID = 1L;

   private JLabel label;

   public StatusPanel()
   {
      label = new JLabel("", JLabel.CENTER);
      this.add( label );
      setStatus( Status.IDLE );
   }

   public void setStatus( Status status )
   {
      switch( status )
      {
         case IDLE:
            this.setBackground( Color.YELLOW );
            label.setText("IDLE");
            break;
         case LOADED:
            this.setBackground( Color.YELLOW );
            label.setText("Configuration Loaded");
            break;
         case VERIFY:
            this.setBackground( Color.ORANGE );
            label.setText("Verifying...");
            break;
         case SUCCESS:
            this.setBackground( Color.GREEN );
            label.setText("VERIFICATION PASSED");
            break;
         case FAILURE:
            this.setBackground( Color.RED );
            label.setText("VERIFICATION FAILED");
            break;
         default:
            System.out.println("StatusPanel.setStatus : Unrecognized option");
            break; 
      }
   }
}
