// Copyright (c) 2012 Ryan Seal <rlseal -at- gmail.com>
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

import java.io.File;
import java.io.IOException;

import nu.xom.Builder;
import nu.xom.Document;
import nu.xom.Element;
import nu.xom.ParsingException;
import nu.xom.ValidityException;

public class XmlConfigParser
{
	private Document document;
	private Element root;
	
	public XmlConfigParser( File fileName ) throws IOException
	{
		try{
			
			Builder builder = new Builder();
			document = builder.build ( fileName );			
			root = ( Element ) document.getChild ( 0 );
		}
		catch( ValidityException e ){
			throw new IOException(e);						
		}
		catch( ParsingException e){
			throw new IOException(e);
		}
		
	}
	
	public String getServerIP()
	{
		Element child = root.getFirstChildElement("server_location");		
		String name = child.getValue().trim();
		System.out.println("ip name = " + name);		
		return name;
	}
	
	
}