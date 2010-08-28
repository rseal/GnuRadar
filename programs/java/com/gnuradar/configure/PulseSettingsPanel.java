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
import java.awt.FlowLayout;
import java.util.HashMap;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.border.Border;
import javax.swing.border.TitledBorder;

public class PulseSettingsPanel extends JPanel
            implements ApplicationSettings {

    static private final int IPP_MSEC_INIT = 10;
    private JPanel ippPanel;
    private JLabel ippLabel;
    private JTextField ippTextField;
    private JComboBox ippComboBox;
    private String[] ippUnits = { "MSEC", "USEC", "SAMPLES" };

    private JButton addDataWindowButton;
    private JButton removeDataWindowButton;
    private JPanel buttonPanel;
    private DataSettingsPanel dataSettingsPanel;

    private JPanel leftPanel;

    // DataWindowPanel

    private static final long serialVersionUID = 1L;

    private void setComponentSize ( JComponent obj, Dimension dimension )
    {
        obj.setMinimumSize ( dimension );
        obj.setPreferredSize ( dimension );
    }

    public PulseSettingsPanel ( Dimension dims )
    {
        this.setLayout ( new FlowLayout ( FlowLayout.CENTER, 2, 2 ) );
        setComponentSize ( this, dims );

        Border border = BorderFactory.createEtchedBorder();
        TitledBorder tBorder = new TitledBorder (
            border, "Data Window and Pulse Settings" );
        this.setBorder ( tBorder );

        leftPanel = new JPanel ( new FlowLayout ( FlowLayout.CENTER, 2, 2 ) );

        ippPanel = new JPanel();
        ippLabel = new JLabel ( "IPP", JLabel.RIGHT );
        ippTextField = new JTextField ( IPP_MSEC_INIT );
        setComponentSize ( ippTextField, new Dimension ( 10, 20 ) );
        ippComboBox = new JComboBox ( ippUnits );
        ippPanel.add ( ippLabel );
        ippPanel.add ( ippTextField );
        ippPanel.add ( ippComboBox );

        buttonPanel = new JPanel();
        addDataWindowButton = new JButton ( "Add" );
        setComponentSize ( addDataWindowButton, new Dimension ( 60, 20 ) );
        removeDataWindowButton = new JButton ( "Remove" );
        setComponentSize ( removeDataWindowButton, new Dimension ( 100, 20 ) );
        buttonPanel.add ( addDataWindowButton );
        buttonPanel.add ( removeDataWindowButton );

        leftPanel.add ( ippPanel );
        leftPanel.add ( buttonPanel );

        dataSettingsPanel = new DataSettingsPanel();

        this.add ( dataSettingsPanel );
        this.add ( leftPanel );

        addDataWindowButton.addActionListener ( dataSettingsPanel );
        removeDataWindowButton.addActionListener ( dataSettingsPanel );
    }

    @Override
    public HashMap<String, String> getSettings()
    {
        HashMap<String, String> settings = new HashMap<String, String> ( 3 );
        settings.putAll ( dataSettingsPanel.getSettings() );
        settings.put ( "ipp", ippTextField.getText() );
        settings.put ( "ipp_units", ( String ) ippComboBox.getSelectedItem() );

        return settings;
    }

	@Override
	public void pushSettings(HashMap<String, String> map) {		
		ippTextField.setText( map.get("ipp"));
		ippComboBox.setSelectedItem( map.get("ipp_units"));
		dataSettingsPanel.pushSettings(map);		
	}


}
