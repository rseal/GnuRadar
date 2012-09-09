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
import java.awt.GridBagLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.text.DecimalFormat;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.border.Border;
import javax.swing.border.TitledBorder;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import com.corejava.GBC;
import com.gnuradar.common.ConfigFile;

public class SettingsPanel extends JPanel implements ActionListener,
		ChangeListener, ApplicationSettings {
	private static final long serialVersionUID = 1L;

	private static final int LABEL_WIDTH = 100;
	private static final int LABEL_HEIGHT = 20;
	private static final int DECIMATION_INIT = 128;

	private static final double SAMPLE_RATE_MIN = 1.0;
	private static final double SAMPLE_RATE_MAX = 64.0;
	private static final double SAMPLE_RATE_INIT = 64.0;
	private static final String SAMPLE_RATE_UNIT_INIT = "MHz";

	private static final double BANDWIDTH_INIT = 500.0;
	private static final int NUM_CHANNELS_INIT = 1;
	private static final String BANDWIDTH_UNIT_INIT = "kHz";

	private int decimation = DECIMATION_INIT;
	private double sampleRate = SAMPLE_RATE_INIT;
	private double bandwidth = BANDWIDTH_INIT;
	private int numChannels = NUM_CHANNELS_INIT;

	private static final Dimension dimension = new Dimension(LABEL_WIDTH,
			LABEL_HEIGHT);

	private JLabel sampleRateLabel;
	private JLabel sampleRateUnitsLabel;
	private JTextField sampleRateTextField;
	private JPanel sampleRatePanel;

	private JLabel decimationLabel;
	// private JTextField decimationTextField;
	private JComboBox decimationComboBox;
	private String[] decimationValues = { "8", "16", "32", "64", "128" };
	// private JSlider decimationSlider;
	private JPanel decimationPanel;

	private JLabel channelsLabel;
	public JComboBox channelsComboBox;
	private String[] channels = { "1", "2", "4" };
	private JPanel channelsPanel;

	private JLabel bandwidthLabel;
	private JLabel bandwidthUnitsLabel;
	private JTextField bandwidthTextField;
	private JPanel bandwidthPanel;

	private void setComponentSize(JComponent obj, Dimension dimension) {
		obj.setMinimumSize(dimension);
		obj.setPreferredSize(dimension);
	}

	public SettingsPanel() {

		// use the grid bag layout manager
		GridBagLayout gridBagLayout = new GridBagLayout();
		this.setLayout(gridBagLayout);

		Border border = BorderFactory.createEtchedBorder();
		TitledBorder tBorder = new TitledBorder(border, "General Settings");
		this.setBorder(tBorder);

		sampleRateLabel = new JLabel("Sample Rate", JLabel.RIGHT);
		sampleRateTextField = new JTextField(Double.toString(SAMPLE_RATE_INIT));
		sampleRateTextField.addActionListener(this);

		sampleRateUnitsLabel = new JLabel(SAMPLE_RATE_UNIT_INIT, JLabel.LEFT);

		sampleRatePanel = new JPanel();
		sampleRatePanel.add(sampleRateLabel);
		sampleRatePanel.add(sampleRateTextField);
		sampleRatePanel.add(sampleRateUnitsLabel);
		sampleRatePanel.setSize(dimension);

		setComponentSize(sampleRateUnitsLabel, new Dimension(50, 20));
		setComponentSize(sampleRateTextField, new Dimension(80, 20));
		this.add(sampleRatePanel, new GBC(0, 0, 100, 100).setIpad(5, 5));

		decimationLabel = new JLabel("Decimation", JLabel.RIGHT);
		decimationComboBox = new JComboBox(decimationValues);
		decimationComboBox.addActionListener(this);

		setComponentSize(decimationComboBox, new Dimension(80, 20));
		decimationPanel = new JPanel();
		decimationPanel.add(decimationLabel);
		decimationPanel.add(decimationComboBox);
		decimationPanel.add(Box.createRigidArea(new Dimension(50, 20)));

		this.add(decimationPanel, new GBC(0, 1, 100, 100).setIpad(5, 5));

		channelsPanel = new JPanel();
		channelsLabel = new JLabel("Channels", JLabel.RIGHT);

		channelsComboBox = new JComboBox(channels);
		channelsComboBox.addActionListener(this);

		channelsPanel.add(channelsLabel);
		channelsPanel.add(channelsComboBox);

		setComponentSize(channelsComboBox, new Dimension(80, 20));
		this.add(channelsPanel, new GBC(1, 0, 100, 100).setIpad(5, 5));

		bandwidthPanel = new JPanel();
		bandwidthLabel = new JLabel("Bandwidth", JLabel.RIGHT);

		bandwidthUnitsLabel = new JLabel(BANDWIDTH_UNIT_INIT, JLabel.LEFT);

		bandwidthTextField = new JTextField(Double.toString(BANDWIDTH_INIT));
		bandwidthTextField.setEditable(false);

		bandwidthPanel.add(bandwidthLabel);
		bandwidthPanel.add(bandwidthTextField);
		bandwidthPanel.add(bandwidthUnitsLabel);

		setComponentSize(bandwidthTextField, new Dimension(50, 20));
		setComponentSize(bandwidthUnitsLabel, new Dimension(30, 20));
		this.add(bandwidthPanel, new GBC(1, 1, 100, 100).setIpad(5, 5));

		this.updateSettings();

	}

	private void validateSampleRate() {
		try {

			this.sampleRate = Double.valueOf(sampleRateTextField.getText()
					.trim());

			if (this.sampleRate > SAMPLE_RATE_MAX) {
				this.sampleRate = SAMPLE_RATE_MAX;
			}

			if (this.sampleRate < SAMPLE_RATE_MIN) {
				this.sampleRate = SAMPLE_RATE_MIN;
			}

			sampleRateTextField.setText(Double.toString(this.sampleRate));
		} catch (NumberFormatException e) {
			System.out.println("number format exception caught");
		}

	}

	private void setBandwidth() {
		numChannels = Integer.valueOf((String) channelsComboBox
				.getSelectedItem());
		bandwidth = sampleRate / decimation;
		double value;
		DecimalFormat formatter = new DecimalFormat("#0.00");

		double totalBandwidth = bandwidth * numChannels;

		if (totalBandwidth > 8e0) {

			bandwidth = 8e0 / numChannels;

			switch (numChannels) {
			case 1:
				decimationComboBox.setSelectedIndex(0);
				break;
			case 2:
				decimationComboBox.setSelectedIndex(1);
				break;
			case 4:
				decimationComboBox.setSelectedIndex(2);
				break;
			}

		}

		if (bandwidth >= 1e0) {
			value = bandwidth;
			bandwidthUnitsLabel.setText("mhz");
		} else {
			value = bandwidth * 1e3;
			bandwidthUnitsLabel.setText("khz");
		}
		bandwidthTextField.setText(formatter.format(value));
	}

	public double sampleRate() {
		return sampleRate;
	}

	public int decimation() {
		return decimation;
	}

	public int channels() {
		return numChannels;
	}

	public double bandwidth() {
		return bandwidth;
	}

	private void updateSettings() {
		decimation = Integer.valueOf((String) decimationComboBox
				.getSelectedItem());
		validateSampleRate();
		setBandwidth();
	}

	public void stateChanged(ChangeEvent e) {
		updateSettings();
	}

	public void actionPerformed(ActionEvent e) {
		updateSettings();
	}

	@Override
	public void getSettings(ConfigFile configuration) {
		configuration.setSampleRate(Double.parseDouble(sampleRateTextField
				.getText()));
		configuration.setBandwidth(Double.parseDouble(bandwidthTextField
				.getText()));
		configuration.setBandwidthUnits(bandwidthUnitsLabel.getText());
		configuration.setDecimation(decimation);
		configuration.setNumChannels(Integer.parseInt((String)channelsComboBox.getSelectedItem()));
	}

	@Override
	public void pushSettings(ConfigFile configuration) {
		sampleRateTextField.setText(Double.toString(configuration
				.getSampleRate()));
		channelsComboBox.setSelectedItem(configuration.getNumChannels());
		bandwidthTextField
				.setText(Double.toString(configuration.getBandwidth()));
		bandwidthUnitsLabel.setText(configuration.getBandwidthUnits());
		decimationComboBox.setSelectedItem(Integer.toString(configuration
				.getDecimation()));
	}
}
