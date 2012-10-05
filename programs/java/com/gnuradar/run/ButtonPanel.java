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
import java.io.File;
import java.io.IOException;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JFileChooser;
import javax.swing.JPanel;
import javax.swing.border.Border;
import javax.swing.filechooser.FileNameExtensionFilter;

import org.zeromq.ZMQ;

import com.gnuradar.common.ConfigFile;
import com.gnuradar.common.FileParser;
import com.gnuradar.proto.Control;
import com.gnuradar.proto.Control.ControlMessage;
import com.gnuradar.proto.Response.ResponseMessage;

public class ButtonPanel extends JPanel implements ActionListener {

	public static enum State {
		UNCONFIGURED("UNCONFIGURED"), CONFIGURED("CONFIGURED"), VERIFIED(
				"VERIFIED"), RUNNING("RUNNING"), STOPPED("STOPPED"), ERROR(
				"ERROR"), CONNECTION_ERROR("CONNECTION ERROR");

		private String state;

		private State(String state) {
			this.state = state;
		}

		public String getValue() {
			return state;
		}
	}

	private void setState(State next) {
		state = next;
		// probably not the best solution, but it appears
		// to work as long as old and new values are different.
		// thus the 0 and 1.
		firePropertyChange("state", 0, 1);
	}

	private State state = State.UNCONFIGURED;
	private static final long serialVersionUID = 1L;
	private static boolean running = false;
	private String serverMessage;
	private JButton loadButton;
	private JButton verifyButton;
	private JButton runButton;
	private File configurationFile = null;
	private String ipAddress;
	private Dimension buttonSize = new Dimension(100, 25);

	private void setComponentSize(JComponent obj, Dimension dimension) {
		obj.setMinimumSize(dimension);
		obj.setPreferredSize(dimension);
		obj.setMaximumSize(dimension);
	}

	private ResponseMessage WriteToServer(ControlMessage controlMsg)
			throws IOException, SecurityException {
		ZMQ.Context context = ZMQ.context(1);
		ZMQ.Socket socket = context.socket(ZMQ.REQ);

		// send command
		socket.connect(ipAddress);
		socket.send(controlMsg.toByteArray(), 0);

		// get response
		byte[] reply = socket.recv(0);
		socket.close();

		return ResponseMessage.parseFrom(reply);
	}

	public boolean loadFile() {
		boolean loaded = false;

		FileNameExtensionFilter fileFilter = new FileNameExtensionFilter(
				"USRP Configuration File", "yml");

		JFileChooser jf = new JFileChooser();
		jf.setFileFilter(fileFilter);

		// used to set default directory from Preferences API
		jf.setCurrentDirectory(configurationFile);

		int loadFile = jf.showOpenDialog(null);

		if (loadFile == JFileChooser.APPROVE_OPTION) {
			loaded = true;
			configurationFile = jf.getSelectedFile();
			System.out.println("file = " + configurationFile.getAbsolutePath());
		}

		return loaded;
	}

	public ButtonPanel() {
		this.setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));

		loadButton = new JButton("Load");
		loadButton.setAlignmentX(CENTER_ALIGNMENT);

		setComponentSize(loadButton, buttonSize);
		verifyButton = new JButton("Verify");
		verifyButton.setAlignmentX(CENTER_ALIGNMENT);
		verifyButton.setEnabled(false);
		setComponentSize(verifyButton, buttonSize);
		runButton = new JButton("Run");
		runButton.setAlignmentX(CENTER_ALIGNMENT);
		runButton.setEnabled(false);
		setComponentSize(runButton, buttonSize);

		this.add(Box.createRigidArea(new Dimension(0, 5)));
		this.add(loadButton);
		this.add(Box.createRigidArea(new Dimension(0, 5)));
		this.add(verifyButton);
		this.add(Box.createRigidArea(new Dimension(0, 5)));
		this.add(runButton);
		this.add(Box.createVerticalGlue());

		loadButton.addActionListener(this);
		verifyButton.addActionListener(this);
		runButton.addActionListener(this);

		Border border = BorderFactory.createEtchedBorder();
		this.setBorder(border);
	}

	@Override
	public void actionPerformed(ActionEvent e) {

		if (e.getSource() == runButton) {

			if (state == State.RUNNING) {

				ControlMessage control_msg = ControlMessage.newBuilder()
						.setName("stop").build();

				try {

					ResponseMessage response = WriteToServer(control_msg);

					if (response.getValue() == ResponseMessage.Result.OK) {
						// set button states
						setState(State.STOPPED);
						runButton.setText("Run");
						loadButton.setEnabled(true);
					} else {
						serverMessage = response.getMessage();
						setState(State.ERROR);
					}

				} catch (IOException e2) {
					setState(State.CONNECTION_ERROR);
					serverMessage = e2.getMessage();
				}
			} else {
				try {

					FileParser parser = new FileParser(configurationFile);
					ConfigFile config_file = parser.getData();

					Control.File f = ConfigFile.Serialize(config_file);
					ControlMessage control_msg = ControlMessage.newBuilder()
							.setName("start").setFile(f).build();

					ResponseMessage response = WriteToServer(control_msg);

					// clear map and read response packet after transmission.
					if (response.getValue() == ResponseMessage.Result.OK) {
						// set button states
						setState(State.RUNNING);
						runButton.setText("Stop");
						loadButton.setEnabled(false);
					} else {
						serverMessage = response.getMessage();
						setState(State.ERROR);
					}

				} catch (IOException e1) {
					serverMessage = e1.getMessage();
					setState(State.CONNECTION_ERROR);
				} catch (NullPointerException e2) {
					serverMessage = "Invalid Configuration Detected:"
							+ " Did you define receive windows in your configuration?";
					setState(State.ERROR);
					verifyButton.setEnabled(false);
				}
			}
		}

		if (e.getSource() == loadButton) {

			verifyButton.setEnabled(false);
			runButton.setEnabled(false);

			if (loadFile()) {
				setState(State.CONFIGURED);
				verifyButton.setEnabled(true);
			}
		}

		if (e.getSource() == verifyButton) {

			try {

				FileParser parser = new FileParser(configurationFile);
				ConfigFile config_file = parser.getData();

				Control.File f = ConfigFile.Serialize(config_file);
				ControlMessage control_msg = ControlMessage.newBuilder()
						.setName("verify").setFile(f).build();

				ResponseMessage response = WriteToServer(control_msg);

				// clear map and read response packet after transmission.
				if (response.getValue() == ResponseMessage.Result.OK) {
					setState(State.VERIFIED);
					verifyButton.setEnabled(false);
					runButton.setEnabled(true);
				} else {
					serverMessage = response.getMessage();
					System.out.println(response.getMessage());
					setState(State.ERROR);
				}

			} catch (SecurityException e1) {
				serverMessage = e1.getMessage();
				setState(State.ERROR);
			} catch (IOException e1) {
				serverMessage = e1.getMessage();
				setState(State.ERROR);
			} catch (NullPointerException e2) {
				serverMessage = "Invalid Configuration Detected:"
						+ " Did you define receive windows in your configuration?";
				setState(State.ERROR);
				verifyButton.setEnabled(false);
			}
		}
	}

	public boolean isRunning() {
		return running;
	}

	public File getConfigurationFile() {
		return configurationFile;
	}

	public void setConfigurationFile(File file) {
		configurationFile = file;
	}

	public State getState() {
		return state;
	}

	public String getServerResponse() {
		return serverMessage;
	}

	public void clickLoadButton() {
		loadButton.doClick();
	}

	public void setIpAddress(String address) {
		ipAddress = address;
	}
}
