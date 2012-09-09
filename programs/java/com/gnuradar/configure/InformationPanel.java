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
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.border.Border;
import javax.swing.border.TitledBorder;

import com.gnuradar.common.ConfigFile;

public class InformationPanel extends JPanel implements ApplicationSettings,
		ActionListener {

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

	public InformationPanel() {
		this.setLayout(new GridLayout(5, 2, 20, 20));

		organizationLabel = new JLabel("Organization", JLabel.RIGHT);
		organizationTextField = new JTextField("Organization", JTextField.RIGHT);

		siteLabel = new JLabel("Site", JLabel.RIGHT);
		siteTextField = new JTextField("Site", JTextField.RIGHT);

		userLabel = new JLabel("User", JLabel.RIGHT);
		userTextField = new JTextField("User", JTextField.RIGHT);

		radarLabel = new JLabel("Radar", JLabel.RIGHT);
		radarTextField = new JTextField("Radar", JTextField.RIGHT);

		receiverLabel = new JLabel("Receiver", JLabel.RIGHT);
		receiverTextField = new JTextField("Receiver", JTextField.RIGHT);

		this.add(organizationLabel);
		this.add(organizationTextField);
		this.add(siteLabel);
		this.add(siteTextField);
		this.add(userLabel);
		this.add(userTextField);
		this.add(radarLabel);
		this.add(radarTextField);
		this.add(receiverLabel);
		this.add(receiverTextField);

		Border border = BorderFactory.createEtchedBorder();
		TitledBorder tBorder = new TitledBorder(border,
				"HDF5 Header Information");
		this.setBorder(tBorder);
	}

	@Override
	public void getSettings(ConfigFile configuration) {
		configuration.setOrganization(organizationTextField.getText());
		configuration.setSite(siteTextField.getText());
		configuration.setUser(userTextField.getText());
		configuration.setRadar(radarTextField.getText());
		configuration.setReceiver(receiverTextField.getText());
	}

	@Override
	public void pushSettings(ConfigFile configuration) {
		organizationTextField.setText(configuration.getOrganization());
		siteTextField.setText(configuration.getSite());
		userTextField.setText(configuration.getUser());
		radarTextField.setText(configuration.getRadar());
		receiverTextField.setText(configuration.getReceiver());
	}

	@Override
	public void actionPerformed(ActionEvent e) {
	}
}
