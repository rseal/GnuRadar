package com.gnuradar.common;

public class Channel{
	
	private double frequency;
	private String fUnits;
	private double phase;
	private String pUnits;
	
	public double getFrequency() { return frequency; }
	public void setFrequency( double frequency ) { this.frequency=frequency; }
	public String getfUnits() { return fUnits; }
	public void setfUnits( String fUnits) { this.fUnits = fUnits; }
	public double getPhase() { return phase; }
	public void setPhase( double phase ) { this.phase = phase; }
	public String getpUnits() { return pUnits; }
	public void setpUnits( String pUnits ) { this.pUnits = pUnits; }
	
}