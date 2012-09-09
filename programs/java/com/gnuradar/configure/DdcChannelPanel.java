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

import javax.swing.Box;
import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

import com.gnuradar.common.Channel;

public class DdcChannelPanel extends JPanel {

	private static final long serialVersionUID = 1L;
	private final int channelIndex;

	static final double FREQUENCY_INIT = 0.0;
	static final double PHASE_INIT = 0.0;

	JLabel frequencyLabel;
	JTextField frequencyTextField;
	JComboBox frequencyComboBox;
	JPanel frequencyPanel;
	static final String[] frequencyUnits = { "hz", "khz", "mhz" };

	JLabel phaseLabel;
	JTextField phaseTextField;
	JComboBox phaseComboBox;
	JPanel phasePanel;
	static final String[] phaseUnits = { "deg", "rad" };

	private void setComponentSize(JComponent obj, Dimension dimension) {
		obj.setMinimumSize(dimension);
		obj.setPreferredSize(dimension);
	}

	public DdcChannelPanel(int channelIndex) {
		this.channelIndex = channelIndex;

		frequencyPanel = new JPanel();
		frequencyLabel = new JLabel("Frequency", JLabel.RIGHT);

		frequencyTextField = new JTextField(Double.toString(FREQUENCY_INIT));
		frequencyComboBox = new JComboBox(frequencyUnits);

		setComponentSize(frequencyLabel, new Dimension(80, 20));
		setComponentSize(frequencyTextField, new Dimension(80, 20));
		setComponentSize(frequencyComboBox, new Dimension(100, 20));

		frequencyPanel.add(frequencyLabel);
		frequencyPanel.add(frequencyTextField);
		frequencyPanel.add(frequencyComboBox);
		frequencyPanel.add(Box.createRigidArea(new Dimension(200, 20)));

		this.add(frequencyPanel);

		phasePanel = new JPanel();
		phaseLabel = new JLabel("Phase", JLabel.RIGHT);

		phaseTextField = new JTextField(Double.toString(PHASE_INIT));
		phaseComboBox = new JComboBox(phaseUnits);

		setComponentSize(phaseLabel, new Dimension(80, 20));
		setComponentSize(phaseTextField, new Dimension(80, 20));
		setComponentSize(phaseComboBox, new Dimension(100, 20));

		phasePanel.add(phaseLabel);
		phasePanel.add(phaseTextField);
		phasePanel.add(phaseComboBox);
		phasePanel.add(Box.createRigidArea(new Dimension(200, 20)));

		this.add(phasePanel);

	}

	public int getChannelIndex() {
		return channelIndex;
	}

	public Channel getSettings() {
		Channel channel = new Channel();
		channel.setFrequency(Double.parseDouble(frequencyTextField.getText()));
		channel.setfUnits((String) frequencyComboBox.getSelectedItem());
		channel.setPhase(Double.parseDouble(phaseTextField.getText()));
		channel.setpUnits((String) phaseComboBox.getSelectedItem());
		return channel;
	}

	public void pushSettings(Channel channel) {
		frequencyTextField.setText(Double.toString(channel.getFrequency()));
		frequencyComboBox.setSelectedItem(channel.getfUnits());
		phaseTextField.setText(Double.toString(channel.getPhase()));
		phaseComboBox.setSelectedItem(channel.getpUnits());
	}

}
