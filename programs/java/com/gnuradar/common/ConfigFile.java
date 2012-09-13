package com.gnuradar.common;

import java.util.LinkedList;
import java.util.List;

import com.gnuradar.proto.Control;
import com.gnuradar.proto.Control.File;


public class ConfigFile implements Cloneable{
	
	private String version = "0.0.0";
	private double sampleRate = 0.0;
	private int decimation=1;
	private double bandwidth=0.0;
	private String bandwidthUnits = "mhz";
	private double pri=0.0;
	private String priUnits = "msec";
	private double txCarrier=0.0;
	private int numChannels=1;
	private String organization="";
	private String user="";
	private String radar="";
	private String site="";
	private String receiver="";
	private String fpgaImage = "";
	private String baseFile = null;
	private List<Channel> channels = null;
	private List<Window> windows = null;
	
	public String getVersion() { return version; }
	public void setVersion( String version ) { this.version = version;}
	public double getSampleRate() { return sampleRate;}
	public void setSampleRate( double sampleRate ) { this.sampleRate = sampleRate;}
	public int getDecimation() { return decimation; }
	public void setDecimation( int decimation ) { this.decimation = decimation;}
	public double getBandwidth() { return bandwidth; }
	public void setBandwidth( double bandwidth ) { this.bandwidth = bandwidth; }
	public String getBandwidthUnits() { return bandwidthUnits;}
	public void setBandwidthUnits( String bandwidthUnits) { this.bandwidthUnits = bandwidthUnits;}
	public double getPri() { return pri; }
	public void setPri( double pri) { this.pri = pri; }
	public String getPriUnits() { return priUnits; }
	public void setPriUnits( String priUnits) { this.priUnits = priUnits;}
	public double getTxCarrier() { return txCarrier; }
	public void setTxCarrier( double txCarrier ) { this.txCarrier = txCarrier; }
	public int getNumChannels() { return numChannels; }
	public void setNumChannels( int numChannels ) { this.numChannels = numChannels;}
	public String getOrganization() { return organization; }
	public void setOrganization( String organization ) { this.organization = organization; }
	public String getSite() { return site; }
	public void setSite( String site ) { this.site = site; }
	public String getUser() { return user; }
	public void setUser( String user ) { this.user = user; }
	public String getRadar() { return radar; }
	public void setRadar( String radar ) { this.radar = radar; }
	public String getReceiver() { return receiver; }
	public void setReceiver( String receiver ) { this.receiver = receiver; }
	public String getFpgaImage() { return fpgaImage; }
	public void setFpgaImage( String fpgaImage ) { this.fpgaImage = fpgaImage; }
	public String getBaseFile() { return baseFile; }
	public void setBaseFile( String baseFile ) { this.baseFile = baseFile; }
	
	public List<Channel> getChannels() { return channels; }
	public void setChannels( List<Channel> channels) { this.channels = channels; }
	public List<Window> getWindows() { return windows;}
	public void setWindows( List<Window> windows) { this.windows = windows; }
	
	public static File Serialize( ConfigFile file )
	{
		
		List<Control.Channel> channels = new LinkedList<Control.Channel>();
		List<Control.Window> windows = new LinkedList<Control.Window>();
		
		for( Channel ch : file.getChannels() )
		{
			Control.Channel channel = Control.Channel.newBuilder()
					.setFrequency((float)ch.getFrequency())
					.setFrequencyUnits(ch.getfUnits())
					.setPhase((float)ch.getPhase())
					.setPhaseUnits(ch.getpUnits())
					.build();
			
			channels.add(channel);
			
		}
		
		for( Window win : file.getWindows() )
		{
			Control.Window window = Control.Window.newBuilder()
					.setName(win.getName())
					.setStart((float)win.getStart())
					.setStop((float)win.getStop())
					.setUnits(win.getUnits())
					.build();
			
			windows.add(window);
		}
		
		File f = File.newBuilder()
				.addAllWindow(windows)
				.addAllChannel(channels)
				.setVersion(file.getVersion())
				.setSampleRate((float) file.getSampleRate())
				.setBandwidth((float)file.getBandwidth())
				.setBandwidthUnits(file.getBandwidthUnits())
				.setBaseFileName(file.getBaseFile())
				.setDecimation(file.getDecimation())
				.setFpgaImage(file.getFpgaImage())
				.setIpp((float)file.getPri())
				.setIppUnits(file.getPriUnits())
				.setNumChannels(file.getNumChannels())
				.setNumWindows(windows.size())
				.setOrganization(file.getOrganization())
				.setRadar(file.getRadar())
				.setReceiver(file.getReceiver())
				.setSite(file.getSite())
				.setTxCarrier((float)file.getTxCarrier())
				.setUser(file.getUser())
				.build();
		
		
		return f;
		
	}
	
	public ConfigFile clone() throws CloneNotSupportedException {
		return (ConfigFile) super.clone();
	}
}