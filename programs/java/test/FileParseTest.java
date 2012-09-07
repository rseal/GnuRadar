package test;

import java.io.File;
import java.io.FileNotFoundException;
import java.net.URL;

import com.gnuradar.common.ConfigFile;
import com.gnuradar.common.FileParser;


public class FileParseTest{
	
	public static void main(String[] args) {
		
		try 
		{
			URL url = FileParseTest.class.getResource("file_test.yml");
			File file = new File(url.getPath());
			FileParser parser = new FileParser(file);
			ConfigFile cf = parser.getData();
			System.out.println(cf.getBandwidth());
			System.out.println(cf.getBandwidthUnits());
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		
	}
}