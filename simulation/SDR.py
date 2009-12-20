################################################################################
### Author: Ryan Seal
###   Date: November 20, 2009
###   File: Pipelined version of CORDIC rotational mode - single stage
################################################################################

import numpy
import math

# din   : 2D array representing an x,y coordinate pair
# theta : desired angle
# z     : performance variable to measure error
# stage : stage number
# type  : date type which defaults to float if unspecified

def Cordic(din,theta,z,stage,type='float'):

    #scale   = 1#(2**16)-1
    scale   = 2**16-1
    shift   = 2**-stage

    #verified results
    theta_i = numpy.int16(math.atan(shift)*scale/(2*math.pi))
    #theta_i = numpy.float(math.atan(shift))#*scale/(2*math.pi))
    #print theta_i
    
    #determine sign of error
    sign=1
    if(z < 0.0): sign=-1

    coeff  = sign*scale*shift;
    R      = numpy.array(([1,-coeff],[coeff,1]),type)
    din    = numpy.dot(R,din)
    #print 'din[0]=' + str(din[0])
    #print 'din[1]=' + str(din[1])
    z = z - sign*theta_i
    return din,z
