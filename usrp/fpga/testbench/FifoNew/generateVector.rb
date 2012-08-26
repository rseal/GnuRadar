#!/usr/bin/ruby

####################################################
#    date: 01/21/09
#  author: rseal
# purpose: Create binary test vectors for FPGA 
#          simulated data input 
####################################################

def PrintBits(data, bits, file)
  bits = bits - 1
  bits.downto(0) {|i| file.print data[i]}
  file.puts
end

file       = File.new("data/input.vec", 'w')
bits       = 16
numSamples = 1024
data       = Array.new(numSamples)  {|i| i+1}

#generate binary bit vectors
0.upto(numSamples-1){ |i| PrintBits(i,16,file)};

puts "#{numSamples} 16-bit elements created"

