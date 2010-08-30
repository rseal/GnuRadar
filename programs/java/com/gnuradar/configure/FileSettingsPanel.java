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
import java.io.File;
import java.util.HashMap;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.border.Border;
import javax.swing.border.TitledBorder;
import javax.swing.filechooser.FileNameExtensionFilter;

public class FileSettingsPanel extends JPanel
            implements ApplicationSettings {

    private static final long serialVersionUID = 1L;

    private final static File CONFIGURATION_DIRECTORY =
        new File ( "/usr/local/share/usrp/rev4" );

    private JLabel fpgaImageLabel;
    private JTextField fpgaImageTextField;
    private JButton fpgaImageButton;
    private JPanel fpgaImagePanel;
    private File fpgaImageFile;

    private JLabel fileBaseNameLabel;
    private JTextField fileBaseNameTextField;
    private JButton fileBaseNameButton;
    private JPanel fileBaseNamePanel;
    private File baseNameFile;


    public FileSettingsPanel ( )
    {
        this.setLayout ( new GridLayout ( 2 , 1 , 10, 5 ) );

        fpgaImagePanel = new JPanel ( new GridLayout ( 3, 1, 5, 5 ) );
        fpgaImageLabel = new JLabel ( "FPGA Bit Image", JLabel.CENTER );
        fpgaImageTextField = new JTextField();
        fpgaImageButton = new JButton ( "Browse FPGA Bit Image" );
        fpgaImagePanel.add ( fpgaImageLabel );
        fpgaImagePanel.add ( fpgaImageTextField );
        fpgaImagePanel.add ( fpgaImageButton );

        // add an inline action listener
        fpgaImageButton.addActionListener (

        new ActionListener() {

            public void actionPerformed ( ActionEvent e ) {

                FileNameExtensionFilter fileFilter =
                    new FileNameExtensionFilter (
                    "USRP FPGA Bit Image ", "rbf" );

                JFileChooser fileChooser = new JFileChooser();
                fileChooser.setCurrentDirectory ( CONFIGURATION_DIRECTORY );
                fileChooser.setFileFilter ( fileFilter );

                int result = fileChooser.showOpenDialog ( null );

                if ( result == JFileChooser.APPROVE_OPTION ) {
                    fpgaImageFile = fileChooser.getSelectedFile();
                    fpgaImageTextField.setText (
                        fpgaImageFile.getAbsolutePath() );
                }
            }
        } );

        fileBaseNamePanel = new JPanel ( new GridLayout ( 3, 1, 5, 5 ) );
        fileBaseNameLabel = new JLabel ( "Data Set Base Name", JLabel.CENTER );
        fileBaseNameTextField = new JTextField();
        fileBaseNameButton = new JButton ( "Set File Base Name" );
        fileBaseNamePanel.add ( fileBaseNameLabel );
        fileBaseNamePanel.add ( fileBaseNameTextField );
        fileBaseNamePanel.add ( fileBaseNameButton );

        fileBaseNameButton.addActionListener (
        new ActionListener() {

            public void actionPerformed ( ActionEvent e ) {

                JFileChooser fileChooser = new JFileChooser();
                fileChooser.setFileSelectionMode ( JFileChooser.SAVE_DIALOG );
                fileChooser.setCurrentDirectory (
                    new File ( System.getProperty ( "user.home" ) ) );

                int result = fileChooser.showSaveDialog ( null );

                if ( result == JFileChooser.APPROVE_OPTION ) {
                    baseNameFile = fileChooser.getSelectedFile();
                    fileBaseNameTextField.setText (
                        baseNameFile.getAbsolutePath() );
                }
            }
        } );

        this.add ( fpgaImagePanel  );
        this.add ( fileBaseNamePanel  );

        Border border = BorderFactory.createEtchedBorder( );
        TitledBorder tBorder =
            new TitledBorder ( border, "File Settings" );
        this.setBorder ( tBorder );
    }

    @Override
    public HashMap< String, String > getSettings()
    {
        HashMap<String, String> settings = new HashMap<String, String> ( 2 );
        settings.put ( "fpga_image_file", fpgaImageTextField.getText() );
        settings.put ( "base_file_name", fileBaseNameTextField.getText() );

        return settings;
    }

	@Override
	public void pushSettings(HashMap<String, String> map) {
		
		fpgaImageTextField.setText( map.get("fpga_image_file"));
		fileBaseNameTextField.setText( map.get("base_file_name"));
		
	}

}
