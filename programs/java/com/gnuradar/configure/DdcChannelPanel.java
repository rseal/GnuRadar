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
import java.util.HashMap;

import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

public class DdcChannelPanel extends JPanel
            implements ApplicationSettings {

    private static final long serialVersionUID = 1L;
    private final int channelIndex;

    static final double FREQUENCY_INIT = 0.0;
    static final double PHASE_INIT = 0.0;

    JLabel frequencyLabel;
    JTextField frequencyTextField;
    JComboBox frequencyComboBox;
    JPanel frequencyPanel;
    static final String[] frequencyUnits = { "Hz", "kHz", "MHz" };

    JLabel phaseLabel;
    JTextField phaseTextField;
    JComboBox phaseComboBox;
    JPanel phasePanel;
    static final String[] phaseUnits = { "Degrees", "Radians" };

    private void setComponentSize ( JComponent obj, Dimension dimension )
    {
        obj.setMinimumSize ( dimension );
        obj.setPreferredSize ( dimension );
    }

    public DdcChannelPanel ( int channelIndex )

    {
        this.channelIndex = channelIndex;

        frequencyPanel = new JPanel();
        frequencyLabel = new JLabel ( "Frequency", JLabel.RIGHT );
        setComponentSize ( frequencyLabel, new Dimension ( 80, 20 ) );
        frequencyTextField = new JTextField ( Double.toString ( FREQUENCY_INIT ) );
        setComponentSize ( frequencyTextField, new Dimension ( 80, 20 ) );
        frequencyComboBox = new JComboBox ( frequencyUnits );
        setComponentSize ( frequencyComboBox, new Dimension ( 100, 20 ) );
        frequencyPanel.add ( frequencyLabel );
        frequencyPanel.add ( frequencyTextField );
        frequencyPanel.add ( frequencyComboBox );
        this.add ( frequencyPanel );

        phasePanel = new JPanel();
        phaseLabel = new JLabel ( "Phase", JLabel.RIGHT );
        setComponentSize ( phaseLabel, new Dimension ( 80, 20 ) );
        phaseTextField = new JTextField ( Double.toString ( PHASE_INIT ) );
        setComponentSize ( phaseTextField, new Dimension ( 80, 20 ) );
        phaseComboBox = new JComboBox ( phaseUnits );
        setComponentSize ( phaseComboBox, new Dimension ( 100, 20 ) );
        phasePanel.add ( phaseLabel );
        phasePanel.add ( phaseTextField );
        phasePanel.add ( phaseComboBox );
        this.add ( phasePanel );

    }

    public int getChannelIndex()
    {
        return channelIndex;
    }

    @Override
    public HashMap<String, String> getSettings()
    {

        String index = "_" + Integer.toString ( channelIndex );
        HashMap<String, String> settings = new HashMap<String, String> ( 4 );

        settings.put ( "frequency" + index, frequencyTextField.getText() );
        settings.put ( "frequency_units" + index, ( String ) frequencyComboBox.getSelectedItem() );
        settings.put ( "phase" + index, phaseTextField.getText() );
        settings.put ( "phase_units" + index, ( String ) phaseComboBox.getSelectedItem() );

        return settings;
    }

	@Override
	public void pushSettings(HashMap<String, String> map) {
		
		frequencyTextField.setText(map.get("frequency_" + channelIndex));
		frequencyComboBox.setSelectedItem( map.get("frequency_units_" + channelIndex));
		phaseTextField.setText(map.get("phase_" + channelIndex));
		phaseComboBox.setSelectedItem(map.get("phase_units_" + channelIndex));
		// TODO Auto-generated method stub
		
	}
}
