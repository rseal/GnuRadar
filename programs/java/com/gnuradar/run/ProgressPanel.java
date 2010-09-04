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

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JComponent;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.border.Border;

public class ProgressPanel extends JPanel
            implements ActionListener {

    private static final long serialVersionUID = 1L;

    public JProgressBar readLevel;
    public JProgressBar writeLevel;
    public JProgressBar depthLevel;

    private Dimension progressSize = new Dimension ( 400, 15 );

    private void setComponentSize ( JComponent obj, Dimension dimension )
    {
        obj.setMinimumSize ( dimension );
        obj.setPreferredSize ( dimension );        
    }

    public ProgressPanel( )
    {
        this.setLayout ( new BoxLayout ( this, BoxLayout.Y_AXIS ) );

        readLevel = new JProgressBar();
        readLevel.setString ( "READ BUFFER" );
        readLevel.setStringPainted ( true );
        readLevel.setMinimum(0);
        
        writeLevel = new JProgressBar();
        writeLevel.setString ( "WRITE BUFFER" );
        writeLevel.setStringPainted ( true );
        writeLevel.setMinimum(0);
        
        depthLevel = new JProgressBar();
        depthLevel.setString ( "BUFFER LEVEL" );
        depthLevel.setStringPainted ( true );
        depthLevel.setMinimum(0);

        setComponentSize ( readLevel, progressSize );
        setComponentSize ( writeLevel, progressSize );
        setComponentSize ( depthLevel, progressSize );

        this.add ( readLevel );
        this.add ( writeLevel );
        this.add ( depthLevel );

        Border border = BorderFactory.createEtchedBorder( );
        this.setBorder ( border );
    }

    public void setHead( int head ){    
    	writeLevel.setValue(head);
    }
    
    public void setTail( int tail){
    	readLevel.setValue(tail);
    }
    
    public void setDepth( int depth ){
    	depthLevel.setValue(depth);
    }
    
    public void setNumBuffers( int numBuffers ){
    	writeLevel.setMaximum(numBuffers);
    	readLevel.setMaximum(numBuffers);
    	depthLevel.setMaximum(numBuffers);
    }
    
    @Override
    public void actionPerformed ( ActionEvent e )
    {        }
}
