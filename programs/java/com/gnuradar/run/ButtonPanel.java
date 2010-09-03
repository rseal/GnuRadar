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

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JFileChooser;
import javax.swing.JPanel;
import javax.swing.border.Border;
import javax.swing.filechooser.FileNameExtensionFilter;

public class ButtonPanel extends JPanel
            implements ActionListener {

	public static enum State{ 
		UNCONFIGURED("UNCONFIGURED"),
		CONFIGURED("CONFIGURED"),
		VERIFIED("VERIFIED"),
		RUNNING("RUNNING"),
		STOPPED("STOPPED")	;
		private String state;
		
		private State( String state ){
			this.state = state;
		}
		
		public String getValue() { return state; }
	}
	
	private State state = State.UNCONFIGURED;
	
    private static final long serialVersionUID = 1L;
    private static boolean running = false;

    private JButton loadButton;
    private JButton verifyButton;
    private JButton runButton;
    private File configurationFile = null;
      
    private Dimension buttonSize = new Dimension ( 100, 25 );

    private void setComponentSize ( JComponent obj, Dimension dimension )
    {
        obj.setMinimumSize ( dimension );
        obj.setPreferredSize ( dimension );
        obj.setMaximumSize(dimension);
    }

    public boolean loadFile()
    {
    	boolean loaded = false;

		 FileNameExtensionFilter fileFilter =
			 new FileNameExtensionFilter (
					 "USRP Configuration File", "ucf" );

		 JFileChooser jf = new JFileChooser();
		 jf.setFileFilter ( fileFilter );

		 int loadFile = jf.showOpenDialog ( null );

		 if ( loadFile == JFileChooser.APPROVE_OPTION ) {
			 loaded = true;
			 configurationFile = jf.getSelectedFile();    	            
		 }
		 
		 return loaded;
    }
    
    public ButtonPanel( )
    {
        this.setLayout ( new BoxLayout ( this, BoxLayout.Y_AXIS ) );

        loadButton = new JButton ( "Load" );
        loadButton.setAlignmentX(CENTER_ALIGNMENT);
        
        setComponentSize ( loadButton, buttonSize );
        verifyButton = new JButton ( "Verify" );
        verifyButton.setAlignmentX(CENTER_ALIGNMENT);
        verifyButton.setEnabled(false);
        setComponentSize ( verifyButton, buttonSize );
        runButton = new JButton ( "Run" );
        runButton.setAlignmentX(CENTER_ALIGNMENT);
        runButton.setEnabled(false);
        setComponentSize ( runButton, buttonSize );
        
        this.add ( Box.createRigidArea ( new Dimension ( 0, 5 ) ) );
        this.add ( loadButton  );
        this.add ( Box.createRigidArea ( new Dimension ( 0, 5 ) ) );
        this.add ( verifyButton  );
        this.add ( Box.createRigidArea ( new Dimension ( 0, 5 ) ) );
        this.add ( runButton  );
        
        this.add ( Box.createVerticalGlue() );

        loadButton.addActionListener( this );
        verifyButton.addActionListener( this );
        runButton.addActionListener( this );
                
        Border border = BorderFactory.createEtchedBorder( );
        this.setBorder ( border );        
    }

    @Override
    public void actionPerformed ( ActionEvent e )
    {
    	State currentState = state;
    	
    	if( e.getSource() == runButton ){
    		
    		if( state == State.RUNNING ){
    			// TODO: Send Stop Message and get response
    			state = State.STOPPED;    		
    			runButton.setText("Run");  
    			loadButton.setEnabled(true);
    		}
    		else{
    			// TODO: Send Start Message and get response
    			state = State.RUNNING;    	
    			runButton.setText( "Stop");
    			loadButton.setEnabled(false);
    		}
    	}
        
    	if( e.getSource() == loadButton ){
    		
    		verifyButton.setEnabled( false );
    		runButton.setEnabled(false);    		
    		if( loadFile() )
    		{
   			 state = State.CONFIGURED;
			 verifyButton.setEnabled(true);
    		}
    		
    	}
    	
    	if( e.getSource() == verifyButton ){
    		    		
    		boolean verified = false;    		
    		// TODO: Send Verification Message and get response
    		// if successful set verified = true
    		state = State.VERIFIED;
    		runButton.setEnabled( verified );   
    		// TODO: Remove me
    		runButton.setEnabled( true );
    	}
    	
    	this.firePropertyChange( "state", currentState.getValue(), 
    			state.getValue());
    }
    
    public boolean isRunning() { return running; }
    public File getConfigurationFile() { return configurationFile; }
    public State getState() { return state; }
    public void clickLoadButton() { loadButton.doClick();}
    
}
