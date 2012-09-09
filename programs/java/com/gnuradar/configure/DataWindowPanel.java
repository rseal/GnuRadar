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

import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

import com.gnuradar.common.Window;

public class DataWindowPanel extends JPanel {

    private static final long serialVersionUID = 1L;

    static final double FREQUENCY_INIT = 0.0;
    static final double PHASE_INIT = 0.0;

    private JPanel windowPanel;
    private JLabel startLabel;
    private JTextField startTextField;
    private JLabel stopLabel;
    private JTextField stopTextField;

    private JLabel nameLabel;
    private JTextField nameTextField;

    private JPanel unitsPanel;
    private JLabel unitsLabel;
    private JComboBox unitsComboBox;
    private static final String[] windowUnits = { "usec", "km", "samples" };

    private void setComponentSize ( JComponent obj, Dimension dimension )
    {
        obj.setMinimumSize ( dimension );
        obj.setPreferredSize ( dimension );
    }

    public DataWindowPanel ( int index )
    {

        windowPanel = new JPanel();
        unitsPanel = new JPanel();

        nameLabel = new JLabel ( "Name", JLabel.RIGHT );
        nameTextField = new JTextField();
        setComponentSize ( nameTextField, new Dimension ( 70, 20 ) );

        startLabel = new JLabel ( "Start", JLabel.RIGHT );
        startTextField = new JTextField();
        setComponentSize ( startTextField, new Dimension ( 70, 20 ) );

        stopLabel = new JLabel ( "Stop", JLabel.RIGHT );
        stopTextField = new JTextField();
        setComponentSize ( stopTextField, new Dimension ( 70, 20 ) );

        unitsComboBox = new JComboBox ( windowUnits );
        unitsLabel = new JLabel ( "Units", JLabel.RIGHT );
        setComponentSize ( unitsComboBox, new Dimension ( 70, 20 ) );

        windowPanel.add ( nameLabel );
        windowPanel.add ( nameTextField );
        windowPanel.add ( startLabel );
        windowPanel.add ( startTextField );
        windowPanel.add ( stopLabel );
        windowPanel.add ( stopTextField );

        unitsPanel.add ( unitsLabel );
        unitsPanel.add ( unitsComboBox );

        this.setLayout ( new FlowLayout ( FlowLayout.LEFT ) );
        this.add ( windowPanel );
        this.add ( unitsPanel );

    }

    public Window getSettings()
    {
    	Window window = new Window();

    	window.setName( nameTextField.getText() );
    	window.setStart(Double.parseDouble(startTextField.getText()));
    	window.setStop(Double.parseDouble(stopTextField.getText()));
    	window.setUnits((String) unitsComboBox.getSelectedItem());
    	
    	return window;
    }

    public void pushSettings ( Window window )
    {
        nameTextField.setText ( window.getName() );
        startTextField.setText ( Double.toString(window.getStart()));
        stopTextField.setText ( Double.toString(window.getStop()));
        unitsComboBox.setSelectedItem ( window.getUnits());
    }

}
