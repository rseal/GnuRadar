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

import java.awt.GridLayout;
import java.util.HashMap;

import javax.swing.BorderFactory;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.border.Border;
import javax.swing.border.TitledBorder;

public class InformationPanel extends JPanel
            implements ApplicationSettings {

    private static final long serialVersionUID = 1L;

    private JLabel organizationLabel;
    private JTextField organizationTextField;

    private JLabel siteLabel;
    private JTextField siteTextField;

    private JLabel userLabel;
    private JTextField userTextField;

    private JLabel radarLabel;
    private JTextField radarTextField;

    private JLabel receiverLabel;
    private JTextField receiverTextField;

    public InformationPanel ( )
    {
        this.setLayout ( new GridLayout ( 5 , 2 , 20, 20 ) );

        organizationLabel = new JLabel ( "Organization", JLabel.RIGHT );
        organizationTextField =
            new JTextField ( "Organization", JTextField.RIGHT );

        siteLabel = new JLabel ( "Site", JLabel.RIGHT );
        siteTextField = new JTextField ( "Site", JTextField.RIGHT );

        userLabel = new JLabel ( "User", JLabel.RIGHT );
        userTextField = new JTextField ( "User", JTextField.RIGHT );

        radarLabel = new JLabel ( "Radar", JLabel.RIGHT );
        radarTextField = new JTextField ( "Radar", JTextField.RIGHT );

        receiverLabel = new JLabel ( "Receiver", JLabel.RIGHT );
        receiverTextField = new JTextField ( "Receiver", JTextField.RIGHT );

        this.add ( organizationLabel  );
        this.add ( organizationTextField  );
        this.add ( siteLabel  );
        this.add ( siteTextField  );
        this.add ( userLabel  );
        this.add ( userTextField  );
        this.add ( radarLabel  );
        this.add ( radarTextField  );
        this.add ( receiverLabel  );
        this.add ( receiverTextField  );

        Border border = BorderFactory.createEtchedBorder( );
        TitledBorder tBorder =
            new TitledBorder ( border, "HDF5 Header Information" );
        this.setBorder ( tBorder );
    }

    @Override
    public HashMap<String, String> getSettings()
    {
        HashMap<String, String> settings = new HashMap<String, String> ( 5 );

        settings.put ( "organization" , organizationTextField.getText() );
        settings.put ( "site", siteTextField.getText() );
        settings.put ( "user", userTextField.getText() );
        settings.put ( "radar", radarTextField.getText() );
        settings.put ( "receiver", receiverTextField.getText() );

        // TODO Auto-generated method stub
        return settings;
    }

	@Override
	public void pushSettings(HashMap<String, String> map) {
		
		organizationTextField.setText( map.get("organization"));
		siteTextField.setText( map.get("site"));
		userTextField.setText( map.get("user"));
		radarTextField.setText( map.get("radar"));
		receiverTextField.setText( map.get("receiver"));		
	}
}
