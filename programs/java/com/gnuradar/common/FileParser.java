package com.gnuradar.common;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;

import org.yaml.snakeyaml.TypeDescription;
import org.yaml.snakeyaml.Yaml;
import org.yaml.snakeyaml.constructor.Constructor;

public class FileParser{
	
	private ConfigFile data;
	
	public FileParser( File file ) throws FileNotFoundException
	{
		Constructor ctor = new Constructor( ConfigFile.class );
		TypeDescription configDescription = new TypeDescription(ConfigFile.class);
		configDescription.putListPropertyType("channels", Channel.class);
		configDescription.putListPropertyType("windows", Window.class);
		ctor.addTypeDescription(configDescription);
		
		FileInputStream fin = new FileInputStream( file );
		Yaml yaml = new Yaml(ctor);
		data = (ConfigFile) yaml.load(fin);
	}
	
	public ConfigFile getData() { return data; }
}