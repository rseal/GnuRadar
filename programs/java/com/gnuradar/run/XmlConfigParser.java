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