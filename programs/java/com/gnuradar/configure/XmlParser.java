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

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;

import nu.xom.Attribute;
import nu.xom.Builder;
import nu.xom.Document;
import nu.xom.Element;
import nu.xom.Node;
import nu.xom.ParsingException;
import nu.xom.Serializer;

public class XmlParser {

    private HashMap<String, String> map;

    public XmlParser ( HashMap<String, String> map )
    {
        this.map = map;
    }

    // iterate through the given child's elements
    private void parseChildren ( Element element )
    {
        Node child = null;
        String num = parseAttribute ( element );

        for ( int i = 0; i < element.getChildCount(); ++i ) {
            child = element.getChild ( i );
            if ( child instanceof Element ) {            
                map.put ( ( ( Element ) child ).getQualifiedName()
                          + "_" + num,
                          child.getValue() );
            }
        }
    }

    private String parseAttribute ( Element element )
    {
        String result = null;

        // parse the window or channel number attribute.
        if ( element.getAttributeCount() != 0 ) {
            Attribute attr = element.getAttribute ( 0 );
            result = attr.getValue();
        }
        return result;
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

                // channel and window elements each have children elements -
                // parse them when found.
                if ( element.getQualifiedName() == "channel" ) {
                    parseChildren ( element );
                } else if ( element.getQualifiedName() == "window" ) {
                    parseChildren ( element );
                } else {
                    map.put ( element.getQualifiedName(), element.getValue() );
                }

            } else {
               // if we didn't find an element, continue to recurse through
               // nodes.
                parseNode ( child );
            }
        }
    }

    // load user configuration settings from a file into a map and return.
    static public HashMap<String, String> load ( File fileName )
    {
        HashMap<String, String> map = new HashMap<String, String>();

        try {

            XmlParser parser = new XmlParser ( map );
            Builder builder = new Builder();
            nu.xom.Document doc = builder.build ( fileName );

            // step into the second level to access the children
            Element root = ( Element ) doc.getChild ( 0 );
            Element configuration = ( Element ) root.getFirstChildElement ( "configuration" );

            // parse xml file and load variables into map
            parser.parseNode ( configuration );

        } catch ( ParsingException e ) {
        } catch ( IOException e ) {
        }

        return map;
    }

    // pull user settings from the GUI, place in a map, and then write to a file.
    static public void save ( File fileName, HashMap<String, String> map )
    {
        XmlParser parser = new XmlParser ( map );
        Element root = new Element ( "gnuradar" );
        Element configuration = new Element ( "configuration" );

        configuration.appendChild ( parser.constructElement ( "sample_rate" ) );
        configuration.appendChild ( parser.constructElement ( "decimation" ) );
        configuration.appendChild ( parser.constructElement ( "num_channels" ) );
        configuration.appendChild ( parser.constructElement ( "bandwidth" ) );
        configuration.appendChild ( parser.constructElement ( "bandwidth_units" ) );
        configuration.appendChild ( parser.constructElement ( "num_windows" ) );

        String index;
        Element child;
        for ( int i = 0; i < 4; ++i ) {
            index = Integer.toString ( i );

            child = new Element ( "channel" );

            child.addAttribute ( new Attribute ( "number" , index ) );
            child.appendChild ( parser.constructElement ( "frequency_" + i,
                                "frequency" ) );
            child.appendChild ( parser.constructElement ( "frequency_units_" + i,
                                "frequency_units" ) );
            child.appendChild ( parser.constructElement ( "phase_" + i,
                                "phase" ) );
            child.appendChild ( parser.constructElement ( "phase_units_" + i,
                                "phase_units" ) );
            configuration.appendChild ( child );
        }

        int numWindows = Integer.valueOf ( map.get ( "num_windows" ) );

        for ( int i = 0; i < numWindows; ++i ) {
            index = Integer.toString ( i );
            child = new Element ( "window" );

            child.addAttribute ( new Attribute ( "number", index ) );
            child.appendChild ( parser.constructElement ( "name_" + i,
                                "name" ) );
            child.appendChild ( parser.constructElement ( "start_" + i,
                                "start" ) );
            child.appendChild ( parser.constructElement ( "stop_" + i,
                                "stop" ) );
            child.appendChild ( parser.constructElement ( "units_" + i,
                                "units" ) );

            configuration.appendChild ( child );
        }

        configuration.appendChild ( parser.constructElement ( "ipp" ) );
        configuration.appendChild ( parser.constructElement ( "ipp_units" ) );
        configuration.appendChild ( parser.constructElement ( "organization"  ) );
        configuration.appendChild ( parser.constructElement ( "site" ) );
        configuration.appendChild ( parser.constructElement ( "user" ) );
        configuration.appendChild ( parser.constructElement ( "radar" ) );
        configuration.appendChild ( parser.constructElement ( "receiver" ) );
        configuration.appendChild ( parser.constructElement ( "fpga_image_file" ) );
        configuration.appendChild ( parser.constructElement ( "base_file_name" ) );

        root.appendChild ( configuration );

        Document doc = new Document ( root );

        try {
            OutputStream writer = new FileOutputStream ( fileName );

            Serializer serializer = new Serializer ( writer, "ISO-8859-1" );
            serializer.setIndent ( 4 );
            serializer.setMaxLength ( 64 );
            serializer.write ( doc );
            writer.close();
        } catch ( IOException e ) {
            e.printStackTrace();
        }
    }

    // build a new element from a provided key.
    private Element constructElement ( String key )
    {
        String value = map.get ( key );
        Element element = new Element ( key );
        element.appendChild ( value );

        return element;
    }

    // build a new element from a provided key and suggested key name.
    // This variation provides a unique name to window and channel children.
    private Element constructElement ( String key, String keyName )
    {
        String value = map.get ( key );
        Element element = new Element ( keyName );
        element.appendChild ( value );

        return element;
    }
}
