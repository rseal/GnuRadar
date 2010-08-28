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

import javax.swing.JPanel;
import javax.swing.JLabel;

import java.awt.Color;

public class StatusPanel extends JPanel
{
	private static final long serialVersionUID = 1L;
	
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
