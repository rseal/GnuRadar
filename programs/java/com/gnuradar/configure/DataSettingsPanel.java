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

import javax.swing.JButton;
import javax.swing.JTabbedPane;

public class DataSettingsPanel extends JTabbedPane
            implements ActionListener, ApplicationSettings {

    private static final long serialVersionUID = 1L;

    private List< DataWindowPanel > windows;
    private static final int MIN_WINDOWS = 1;
    private static final int MAX_WINDOWS = 4;
    private int numTabs = 0;

    public DataSettingsPanel ()
    {
        windows = new LinkedList< DataWindowPanel >();
        addWindow();
    }

    public void addWindow()
    {
        if ( numTabs != MAX_WINDOWS ) {

            DataWindowPanel dataWindowPanel = new DataWindowPanel ( numTabs );
            this.addTab ( "Window " + ++numTabs , dataWindowPanel );
            windows.add ( dataWindowPanel );
        }
    }

    public void removeWindow()
    {
        if ( numTabs != MIN_WINDOWS ) {
            // does this dispose of objects in the tab?
            this.removeTabAt ( this.getSelectedIndex() );
            windows.remove ( this.getSelectedIndex() );
            --numTabs;
        }

        if ( numTabs == MIN_WINDOWS ) {
            this.setTitleAt ( 0, "Window 1" );
        }
    }

    @Override
    public void actionPerformed ( ActionEvent e )
    {
        JButton button = ( JButton ) e.getSource();

        if ( button.getText() == "Add" )
            addWindow();
        else
            removeWindow();
    }

    @Override
    public HashMap<String, String> getSettings()
    {
        HashMap<String, String> settings = new HashMap<String, String>();

        settings.put ( "num_windows", Integer.toString ( windows.size() ) );

        for ( int i = 0; i < windows.size(); ++i ) {
            settings.putAll ( windows.get ( i ).getSettings() );
        }

        return settings;
    }

    @Override
    public void pushSettings ( HashMap<String, String> map )
    {

        int numAdd = Integer.valueOf ( map.get ( "num_windows" ) );

        // remove existing windows first.
        this.removeAll();
        windows.clear();
        numTabs = 0;

        // add windows from configuration file
        for ( int i = 0; i < numAdd; ++i ) {
            addWindow();
            windows.get ( i ).pushSettings ( map );
        }
    }
}
