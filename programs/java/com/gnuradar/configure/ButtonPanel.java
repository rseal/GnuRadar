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
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JPanel;
import javax.swing.border.Border;

public class ButtonPanel extends JPanel
            implements ActionListener {

    private static final long serialVersionUID = 1L;

    public JButton loadButton;
    public JButton saveButton;
    public JButton quitButton;
    private Dimension buttonSize = new Dimension ( 100, 30 );

    private void setComponentSize ( JComponent obj, Dimension dimension )
    {
        obj.setMinimumSize ( dimension );
        obj.setPreferredSize ( dimension );
    }

    public ButtonPanel( )
    {
        this.setLayout ( new BoxLayout ( this, BoxLayout.X_AXIS ) );

        loadButton = new JButton ( "Load" );
        setComponentSize ( loadButton, buttonSize );
        saveButton = new JButton ( "Save" );
        setComponentSize ( saveButton, buttonSize );
        quitButton = new JButton ( "Quit" );
        setComponentSize ( quitButton, buttonSize );

        this.add ( loadButton  );
        this.add ( Box.createRigidArea ( new Dimension ( 15, 0 ) ) );
        this.add ( saveButton  );
        this.add ( Box.createHorizontalGlue() );
        this.add ( quitButton  );

        Border border = BorderFactory.createEtchedBorder( );
        this.setBorder ( border );

    }

    @Override
    public void actionPerformed ( ActionEvent e )
    {
        // TODO Auto-generated method stub

    }
}
