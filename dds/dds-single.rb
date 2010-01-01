#!/usr/bin/ruby -rserialport
#require 'serialport.so'
#require 'rubygems'
#require 'serialport'
port = "/dev/ttyUSB0"
baudRate = 19200
dataBits = 8
stopBits = 1

sp = SerialPort.open(port, baudRate, dataBits, stopBits, SerialPort::NONE)

sp.write "C I\n"
sp.gets
print sp.gets

sp.puts "Kp 0f\n"
sp.gets
print sp.gets

sp.puts "F0 49.8000000\n"
sp.puts "S\n"
sp.gets
print sp.gets

sp.puts "V0 37\n"
sp.gets
print sp.gets

sp.close
