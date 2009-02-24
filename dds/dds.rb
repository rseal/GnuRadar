#require 'serialport.so'

port = "/dev/ttyUSB0"
baudRate = 19200
dataBits = 8
stopBits = 1

sp = SerialPort.open(port, baudRate, dataBits, stopBits, SerialPort::NONE)
sp.write "C I\n"
#print sp.read
sp.puts "Kp 0f\n"
sp.gets
print sp.gets

sp.puts "V0 512\n"
sp.gets
print sp.gets
sp.puts "F0 64.0000000\n"
sp.gets
print sp.gets

sp.puts "V1 512\n"
sp.gets
print sp.gets
sp.puts "F1 20.0000000\n"

#sp.puts "I a\n"
sp.puts "S\n"

sp.puts "V2 512\n"
sp.gets
print sp.gets
sp.puts "F2 20.0000000\n"
#sp.puts "I a\n"
sp.puts "S\n"
sp.close
