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
        //obj.setMaximumSize(dimension);
    }

    public ProgressPanel( )
    {
        this.setLayout ( new BoxLayout ( this, BoxLayout.Y_AXIS ) );

        readLevel = new JProgressBar();
        readLevel.setString ( "READ BUFFER" );
        readLevel.setStringPainted ( true );
        writeLevel = new JProgressBar();
        writeLevel.setString ( "WRITE BUFFER" );
        writeLevel.setStringPainted ( true );
        depthLevel = new JProgressBar();
        depthLevel.setString ( "BUFFER LEVEL" );
        depthLevel.setStringPainted ( true );

        setComponentSize ( readLevel, progressSize );
        setComponentSize ( writeLevel, progressSize );
        setComponentSize ( depthLevel, progressSize );

        this.add ( readLevel );
        this.add ( writeLevel );
        this.add ( depthLevel );

        Border border = BorderFactory.createEtchedBorder( );
        this.setBorder ( border );

    }

    @Override
    public void actionPerformed ( ActionEvent e )
    {        }
}
