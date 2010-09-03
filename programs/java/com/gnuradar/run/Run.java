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

import java.awt.Color;
import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.Font;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextPane;
import javax.swing.border.Border;
import javax.swing.border.TitledBorder;

import com.corejava.GBC;
import com.gnuradar.common.FixedFrame;
import com.gnuradar.run.ButtonPanel.State;

public class Run implements ActionListener, PropertyChangeListener {

	
    // define constants
    public static final int DEFAULT_WIDTH = 575;
    public static final int DEFAULT_HEIGHT = 560;
    public static final int LEFT_WIDTH = 420;
    public static final int RIGHT_WIDTH = 200;
    public static final String TITLE = "GnuRadarRun";
    public static final String VERSION = "Version: 1.0.0";
    public static final String BUILD = "Build: September 01, 2010";
    public static final String COPYRIGHT = "Copyright: \u00a9 2009-2010";
    public static final String AUTHOR = "Author: Ryan Seal";

    private JLabel statusLabel;
    private JTextPane statusPane;
    private ProgressPanel progressPanel;
    
    private static ButtonPanel buttonPanel;
    
    private JMenuItem quitAction;
    private JMenuItem loadAction;    
    private JMenuItem aboutAction;
    private JMenuItem plotAction;
    private JMenuItem bpgAction;

    private static void setComponentSize ( JComponent obj, Dimension dimension )
    {
        obj.setMinimumSize ( dimension );
        obj.setPreferredSize ( dimension );
    }
        
    // main entry point
    public static void main ( String[] args )
    {       
        final Run run = new Run();
        
        // this is required for proper event-handling
        EventQueue.invokeLater ( new Runnable() {
            public void run() {

                // use the grid bag layout manager
                GridBagLayout gridBagLayout = new GridBagLayout();

                Border border = BorderFactory.createEtchedBorder( );
                TitledBorder tBorder = BorderFactory.createTitledBorder(border,"Status");
                tBorder.setTitleJustification(TitledBorder.CENTER);
                
                run.statusPane = new JTextPane();
                
                run.statusPane.setBorder(tBorder);
                
                setComponentSize( run.statusPane, new Dimension(400,390));
                
                JPanel statusPanel = new JPanel();               
                statusPanel.setBorder(border);
                
                run.statusLabel = new JLabel("UNCONFIGURED", JLabel.CENTER); 
                run.statusLabel.setFont( new Font( "", Font.BOLD, 16));
                run.statusLabel.setForeground(Color.WHITE);
                
                setComponentSize( statusPanel, new Dimension(400,25));
          
                statusPanel.setBackground(Color.BLUE);  
                
                statusPanel.add( run.statusLabel);
                
                buttonPanel = new ButtonPanel(); 
                setComponentSize( buttonPanel, new Dimension(100,400));
                
                run.progressPanel = new ProgressPanel();
                setComponentSize( run.progressPanel, new Dimension(400,50));
               
                // create menu bar and menu items
                JMenuBar menuBar = new JMenuBar();

                run.loadAction = new JMenuItem ( "Load", 'L' );
                run.loadAction.addActionListener ( run );
                run.quitAction = new JMenuItem ( "Quit", 'Q' );
                run.quitAction.addActionListener ( run );
                run.plotAction = new JMenuItem ( "Plotter", 'P');
                run.plotAction.addActionListener(run);
                run.bpgAction = new JMenuItem ("BitPatternGenerator", 'B');
                run.bpgAction.addActionListener(run);
                run.aboutAction = new JMenuItem ( "About", 'A' );
                run.aboutAction.addActionListener ( run );

                JMenu fileMenu = new JMenu ( "File" );
                fileMenu.add ( run.loadAction );
                fileMenu.addSeparator();
                fileMenu.add ( run.quitAction );
                
                JMenu toolMenu = new JMenu ( "Tools");
                toolMenu.add( run.plotAction);
                toolMenu.add( run.bpgAction);
                
                JMenu helpMenu = new JMenu ( "Help" );
                helpMenu.add ( run.aboutAction );
                
                //TODO: Enable these when ready
                
                run.plotAction.setEnabled(false);
                run.bpgAction.setEnabled(false);

                menuBar.add ( fileMenu );
                menuBar.add ( toolMenu );
                menuBar.add ( Box.createHorizontalGlue() );
                menuBar.add ( helpMenu );

                // create main window frame and set properties.
                FixedFrame frame = new FixedFrame (
                    DEFAULT_WIDTH, DEFAULT_HEIGHT, TITLE + " " + VERSION );
                frame.setLayout ( gridBagLayout );
                frame.setJMenuBar ( menuBar );
                frame.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
              
                frame.addWindowListener(
                		new WindowAdapter(){
                			public void windowClosing( WindowEvent e){
                				run.quit();
                			}
                		});
                		
                frame.add ( buttonPanel,
                            new GBC ( 0, 1, 10, 100 ).setIpad ( 5, 5 ).
                            setSpan ( 1, 4 ).setFill (
                                GridBagConstraints.VERTICAL )
                          );
                frame.add ( statusPanel,
                        new GBC ( 0, 0, 10, 10 ).setIpad ( 5, 5 ).
                        setSpan ( 4, 1 ).setFill (
                            GridBagConstraints.HORIZONTAL )
                      );
                frame.add ( run.statusPane,
                        new GBC ( 1, 1, 100, 100 ).setIpad ( 5, 5 ).
                        setSpan ( 3, 3 ).setFill (
                            GridBagConstraints.HORIZONTAL )
                      );
                frame.add ( run.progressPanel,
                        new GBC ( 1, 4, 100, 100 ).setIpad ( 5, 5 ).
                        setSpan ( 3, 1 ).setFill (
                            GridBagConstraints.HORIZONTAL )
                      );
                
                buttonPanel.addPropertyChangeListener(run);
                frame.setVisible ( true );
            }
        } );
    }

    @Override
    public void actionPerformed ( ActionEvent e )
    {
        Object source = e.getSource();

        if ( source == loadAction ){ 
        	buttonPanel.clickLoadButton();        	
        }
        
        if ( source == quitAction ){
         quit();
        }

        if ( source == aboutAction ) {
            JOptionPane.showMessageDialog ( 
            		null, TITLE + "\n" +
            		VERSION + "\n" + BUILD + "\n" +
            		AUTHOR + "\n" +
            		COPYRIGHT + "\n"
            );
        }
    }

	@Override
	public void propertyChange(PropertyChangeEvent evt) {		
		statusLabel.setText( buttonPanel.getState().getValue());			
	}
	
	public void quit(){
		
		  if( buttonPanel.getState() == State.RUNNING ){
       	   JOptionPane.showMessageDialog(null, 
       			   "System is currently in operation. Press <Stop> before" +
       			   " attempting to exit");
          }
          else{
       	   System.exit(0);
          }
	}
}
