#require 'serialport.so'

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

sp.puts "F2 64.0000000\n"
sp.puts "S\n"
sp.gets
print sp.gets

sp.puts "V0 512\n"
sp.gets
print sp.gets

sp.puts "V1 512\n"
sp.gets
print sp.gets

sp.puts "V2 512\n"
sp.gets
print sp.gets

sp.puts "V3 1023\n"
sp.gets
print sp.gets

sp.puts "F0 50.1000000\n"
sp.puts "S\n"
sp.gets
print sp.gets

sp.puts "F1 50.0200000\n"
sp.puts "S\n"
sp.gets
print sp.gets


sp.puts "F3 10.0000000\n"
sp.puts "S\n"
sp.gets
print sp.gets
sp.close
