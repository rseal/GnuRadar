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

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.JComboBox;
import javax.swing.JTabbedPane;
import javax.swing.border.Border;
import javax.swing.border.TitledBorder;

public class DdcSettingsPanel extends JTabbedPane
            implements ActionListener, ApplicationSettings {

    private static final long serialVersionUID = 1L;

    private List< DdcChannelPanel > channels;
    private static final int MAX_CHANNELS = 4;

    public DdcSettingsPanel ()
    {
        channels = new LinkedList< DdcChannelPanel >();

        for ( int i = 0; i < MAX_CHANNELS; ++i ) {
            DdcChannelPanel ddcChannelPanel = new DdcChannelPanel ( i );
            channels.add ( ddcChannelPanel );
            this.addTab ( "Channel " + ( i + 1 ) , ddcChannelPanel );
        }
        setEnabledTabs ( 1 );

        Border border = BorderFactory.createEtchedBorder( );
        TitledBorder tBorder = new TitledBorder ( border, "DDC Settings" );
        this.setBorder ( tBorder );
    }

    @Override
    public void actionPerformed ( ActionEvent e )
    {

        JComboBox comboBox = ( JComboBox ) e.getSource();
                
        try{
        Integer value = Integer.valueOf ( ( String )
                                          comboBox.getSelectedItem() );
        setEnabledTabs ( value );
        }
        catch( NumberFormatException nfe)
        {
        	nfe.printStackTrace();
        }
       
    }

    private void setEnabledTabs ( int tabs )
    {
        for ( int i = 0; i < MAX_CHANNELS; ++i )
            this.setEnabledAt ( i, false );

        for ( int i = 0; i < tabs; ++i )
            this.setEnabledAt ( i, true );

        this.setSelectedIndex ( 0 );
    }

    @Override
    public HashMap<String, String> getSettings()
    {

        int size = channels.size();
        HashMap<String, String> settings = new HashMap<String, String> ( 16 );
        // collect settings from each channel
        for ( int i = 0; i < size; ++i ) {
            settings.putAll ( channels.get ( i ).getSettings() );
        }

        return settings;
    }

	@Override
	public void pushSettings(HashMap<String, String> map) {
		
		for( int i=0; i<MAX_CHANNELS; ++i)
		{
			this.setEnabledAt(i, false);
			channels.get(i).pushSettings(map);
		}
		
		int activeChannels = Integer.valueOf(map.get("num_channels"));
			
		for( int i=0; i<activeChannels; ++i)
		{
			this.setEnabledAt(i,true);			
		}
		
	}
}
