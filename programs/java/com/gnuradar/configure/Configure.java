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
import java.awt.EventQueue;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Point;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.prefs.Preferences;

import javax.swing.Box;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.filechooser.FileNameExtensionFilter;

import org.yaml.snakeyaml.Yaml;

import com.corejava.GBC;
import com.gnuradar.common.ConfigFile;
import com.gnuradar.common.FileParser;
import com.gnuradar.common.FixedFrame;

public class Configure implements ActionListener {

	// define constants
	public static final int DEFAULT_WIDTH = 875;
	public static final int DEFAULT_HEIGHT = 530;
	public static final int LEFT_WIDTH = 420;
	public static final int RIGHT_WIDTH = 200;
	public static final String TITLE = "GnuRadarConfigure";
	public static final String VERSION = "Version: 1.0.0";
	public static final String BUILD = "Build: August 28, 2010";
	public static final String COPYRIGHT = "Copyright: \u00a9 2009-2010";
	public static final String AUTHOR = "Author: Ryan Seal";

	private static File configurationFile;
	private static ConfigFile configuration = null;

	private ButtonPanel configureButtonPanel;
	private SettingsPanel settingsPanel;
	private DdcSettingsPanel ddcSettingsPanel;
	private PulseSettingsPanel pulseSettingsPanel;
	private InformationPanel informationPanel;
	private FileSettingsPanel fileSettingsPanel;
	private static FixedFrame frame;
	private static String userNode = "/com/gnuradar/config";

	private JMenuItem quitAction;
	private JMenuItem loadAction;
	private JMenuItem saveAction;
	private JMenuItem aboutAction;

	private void loadPreferences() {
		Preferences preferences = Preferences.userRoot().node(userNode);
		int x = preferences.getInt("x", 0);
		int y = preferences.getInt("y", 0);
		configurationFile = new File(preferences.get("config_dir", ""));

		frame.setLocation(x, y);
	}

	private void savePreferences() {
		Point point = frame.getLocation();

		Preferences preferences = Preferences.userRoot().node(userNode);

		preferences.put("x", Integer.toString(point.x));
		preferences.put("y", Integer.toString(point.y));
		preferences.put("config_dir", configurationFile.toString());
	}

	public boolean loadFile() throws FileNotFoundException {
		boolean loadSuccess = false;

		FileNameExtensionFilter fileFilter = new FileNameExtensionFilter(
				"USRP Configuration File", "yml");

		JFileChooser jf = new JFileChooser();
		jf.setFileFilter(fileFilter);
		jf.setCurrentDirectory(configurationFile);

		int loadFile = jf.showOpenDialog(null);

		if (loadFile == JFileChooser.APPROVE_OPTION) {
			configurationFile = jf.getSelectedFile();
			FileParser parser = new FileParser(configurationFile);
			configuration = parser.getData();
			loadSuccess = true;
		}

		return loadSuccess;
	}

	private boolean saveFile() {

		boolean saveSuccess = false;

		FileNameExtensionFilter fileFilter = new FileNameExtensionFilter(
				"USRP Configuration File", "yml");

		JFileChooser jf = new JFileChooser();
		jf.setFileFilter(fileFilter);

		int saveChanges = jf.showSaveDialog(null);

		if (saveChanges == JFileChooser.APPROVE_OPTION) {
			File file = jf.getSelectedFile();

			int index = file.getName().lastIndexOf(".yml");
			if (index == -1) {
				file = new File(file.toString() + ".yml");
			}

			try {
				FileWriter writer = new FileWriter(file);
				Yaml yaml = new Yaml();
				yaml.dump(configuration, writer);
				saveSuccess = true;
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}

		return saveSuccess;
	}

	// main entry point
	public static void main(String[] args) {
		// create an instance of the containing class. Should
		// probably put this in another class file to minize
		// confusion. Java still feels a bit weird with the
		// inner static main member.
		final Configure configure = new Configure();

		// this is required for proper event-handling
		EventQueue.invokeLater(new Runnable() {
			public void run() {

				// use the grid bag layout manager
				GridBagLayout gridBagLayout = new GridBagLayout();

				configure.settingsPanel = new SettingsPanel();
				configure.settingsPanel.setMinimumSize(new Dimension(
						LEFT_WIDTH, 90));
				configure.settingsPanel.setPreferredSize(new Dimension(
						LEFT_WIDTH, 90));

				configure.ddcSettingsPanel = new DdcSettingsPanel();
				configure.ddcSettingsPanel.setMinimumSize(new Dimension(
						LEFT_WIDTH, 170));
				configure.ddcSettingsPanel.setPreferredSize(new Dimension(
						LEFT_WIDTH, 170));

				configure.pulseSettingsPanel = new PulseSettingsPanel(
						new Dimension(LEFT_WIDTH, 170));
				configure.pulseSettingsPanel.setMinimumSize(new Dimension(
						LEFT_WIDTH, 170));
				configure.pulseSettingsPanel.setPreferredSize(new Dimension(
						LEFT_WIDTH, 170));

				configure.informationPanel = new InformationPanel();
				configure.fileSettingsPanel = new FileSettingsPanel();
				configure.configureButtonPanel = new ButtonPanel();

				// each time the settings panel changes the number of channels
				// we need to alert the ddc settings panel to enable/disable
				// the proper tabs.
				configure.settingsPanel.channelsComboBox
						.addActionListener(configure.ddcSettingsPanel);

				// create menu bar and menu items
				JMenuBar menuBar = new JMenuBar();

				configure.loadAction = new JMenuItem("Load", 'L');
				configure.loadAction.addActionListener(configure);
				configure.saveAction = new JMenuItem("Save", 'S');
				configure.saveAction.addActionListener(configure);
				configure.quitAction = new JMenuItem("Quit", 'Q');
				configure.quitAction.addActionListener(configure);
				configure.aboutAction = new JMenuItem("About", 'A');
				configure.aboutAction.addActionListener(configure);

				JMenu fileMenu = new JMenu("File");
				fileMenu.add(configure.loadAction);
				fileMenu.add(configure.saveAction);
				fileMenu.addSeparator();
				fileMenu.add(configure.quitAction);

				JMenu helpMenu = new JMenu("Help");
				helpMenu.add(configure.aboutAction);

				menuBar.add(fileMenu);
				menuBar.add(Box.createHorizontalGlue());
				menuBar.add(helpMenu);

				// create main window frame and set properties.
				frame = new FixedFrame(DEFAULT_WIDTH, DEFAULT_HEIGHT, TITLE
						+ " " + VERSION);
				frame.setLayout(gridBagLayout);
				frame.setJMenuBar(menuBar);
				frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

				frame.add(configure.settingsPanel,
						new GBC(0, 0, 10, 100).setIpad(5, 5).setSpan(1, 1)
								.setFill(GridBagConstraints.HORIZONTAL));
				frame.add(configure.ddcSettingsPanel,
						new GBC(0, 1, 10, 100).setIpad(5, 5).setSpan(1, 1)
								.setFill(GridBagConstraints.HORIZONTAL));
				frame.add(configure.pulseSettingsPanel,
						new GBC(0, 2, 10, 100).setIpad(5, 5).setSpan(1, 1)
								.setFill(GridBagConstraints.BOTH));
				frame.add(configure.informationPanel,
						new GBC(1, 0, 10, 100).setIpad(5, 5).setSpan(1, 2)
								.setFill(GridBagConstraints.BOTH));

				frame.add(configure.fileSettingsPanel,
						new GBC(1, 2, 10, 100).setIpad(5, 5).setSpan(1, 1)
								.setFill(GridBagConstraints.BOTH));

				frame.add(configure.configureButtonPanel,
						new GBC(0, 3, 10, 100).setIpad(5, 5).setSpan(2, 1)
								.setFill(GridBagConstraints.HORIZONTAL));

				configure.loadPreferences();

				configure.configureButtonPanel.saveButton
						.addActionListener(configure);
				configure.configureButtonPanel.loadButton
						.addActionListener(configure);
				configure.configureButtonPanel.quitButton
						.addActionListener(configure);

				frame.setVisible(true);
			}
		});
	}

	private void updateSettings() {

		try {
			settingsPanel.getSettings(configuration);
			ddcSettingsPanel.getSettings(configuration);
			pulseSettingsPanel.getSettings(configuration);
			informationPanel.getSettings(configuration);
			fileSettingsPanel.getSettings(configuration);
		} catch (Exception e) {
			//pass
		}
	}

	private void loadSettings() {
		try {
			settingsPanel.pushSettings(configuration);
			ddcSettingsPanel.pushSettings(configuration);
			pulseSettingsPanel.pushSettings(configuration);
			informationPanel.pushSettings(configuration);
			fileSettingsPanel.pushSettings(configuration);
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	@Override
	public void actionPerformed(ActionEvent e) {

		Object source = e.getSource();

		if (source == configureButtonPanel.loadButton || source == loadAction) {
			try {
				if (loadFile()) {
					loadSettings();
				}
			} catch (FileNotFoundException e1) {
				e1.printStackTrace();
			}
		}

		if (source == configureButtonPanel.saveButton || source == saveAction) {
			if( configuration == null)
			{
				configuration = new ConfigFile();
			}
			updateSettings();
			saveFile();
		}

		if (source == configureButtonPanel.quitButton || source == quitAction) {

			updateSettings();

			int saveChanges = JOptionPane.showConfirmDialog(null,
					"Save changes?", "Input", JOptionPane.YES_NO_OPTION);

			if (saveChanges == JOptionPane.YES_OPTION) {
				saveFile();
			}

			savePreferences();
			System.exit(0);
		}

		if (source == aboutAction) {
			JOptionPane.showMessageDialog(null, TITLE + "\n" + VERSION + "\n"
					+ BUILD + "\n" + AUTHOR + "\n" + COPYRIGHT + "\n");
		}
	}
}
