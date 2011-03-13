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

import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import nu.xom.Builder;
import nu.xom.Element;
import nu.xom.Node;
import nu.xom.ParsingException;

public class XmlPacket {

    private HashMap<String, String> map;
   
    public XmlPacket ( HashMap<String, String> map )
    {
        this.map = map;
    }

    // recursive xml node parser. Places key/value pairs in a map.
    private void parseNode ( Node node )
    {
        // step through each sibling element inside the configuration element
        for ( int i = 0; i < node.getChildCount(); ++i ) {

            Node child = node.getChild ( i );

            // we're only concerned with elements at this depth
            if ( child instanceof Element ) {
                Element element = ( Element ) child;
                map.put ( element.getQualifiedName(), element.getValue() );
            } else {
                // if we didn't find an element, continue to recurse through
                // nodes.
                parseNode ( child );
            }
        }
    }

    // load user configuration settings from a file into a map and return.
    static synchronized public HashMap<String, String> parse ( String xmlPacket )
    {
    	if( xmlPacket == null) return null;
    	
        HashMap<String, String> map = new HashMap<String, String>();

        try {
            XmlPacket packet = new XmlPacket ( map );
            Builder builder = new Builder();
            nu.xom.Document doc = builder.build ( xmlPacket.trim(),null );

            // step into the second level to access the children
            Element root = ( Element ) doc.getChild ( 0 );

            // parse xml file and load variables into map
            packet.parseNode ( root );

        } catch ( ParsingException e ) {
        	e.printStackTrace();
        } catch ( IOException e ) {
        	e.printStackTrace();
        }
        return map;
    }

    /**
     * Parses a given HashMap and forms an XmlPacket
     **/
    static public String format ( HashMap<String, String> map )
    {
        Element root = new Element ( "command" );
        Element child = null;

        // source
        // destination
        // type { status , control }
        // name
        // arguments   < arg1 > value </arg1>

        Set< Map.Entry<String, String>> set = map.entrySet();
        Iterator<Map.Entry<String, String>> iter = set.iterator();

        while ( iter.hasNext() ) {
            Map.Entry<String, String> entry = ( Entry<String, String> ) iter.next();
            child = new Element ( entry.getKey() );
            child.appendChild ( entry.getValue() );
            root.appendChild ( child );
        }

        // TODO: provide validation here.

        return root.toXML();
    }
}
