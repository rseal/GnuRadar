#include <systemc.h>
#include "cordic.hpp"
#include <iostream>
#include <cmath>
using namespace std;

int sc_main(int argc, char* argv[]){
  
  int theta = 40795;

  sc_set_time_resolution(1,SC_NS);
  sc_clock clock("clk",sc_time(2,SC_NS));
  int stages=12;

  sc_signal<sc_int<18> > x0,y0,xout,yout;
  sc_signal<sc_int<16> > z0,zout,sigTheta;  
  
  int scale = pow(2.0f,16);
  float angle = theta;// = 360.0*theta/scale;

  cout << "quad 1 = " << scale/4 << "\n"
       << "quad 2 = " << scale/2 << "\n"
       << "quad 3 = " << scale*3/4 << "\n"
       << "quad 4 = " << scale << endl;

  //remap angles to first or fourth quadrants
  if(theta > scale/4 && theta < scale*3/4){
    if(theta < scale/2)
      angle -= scale/2;
    else
      angle -= scale*3/4;

    angle = -angle;
  }

  cout << "angle = " << angle << " theta = " << theta << endl;

  x0 = scale;
  y0 = 0;
  z0 = angle;
  sigTheta = angle;

  //instantiate DUT
  Cordic<18,16> cordic("cordic",stages);
  cordic.clock(clock.signal());
  cordic.xin(x0);
  cordic.yin(y0);
  cordic.zin(z0);
  cordic.xout(xout);
  cordic.yout(yout);
  cordic.zout(zout);
  cordic.theta(sigTheta);
  
  //sc_initialize();
  sc_start(SC_ZERO_TIME);

  //run simulations for 22 nsec
  sc_start(sc_time(22, SC_NS));

  float x = xout.read();
  float y = yout.read();
  float cAngle = atan2(y,x)*180.0/M_PI;
  float dAngle = 360*angle/scale;
  float error = abs(dAngle - cAngle)/dAngle;
  cout << "x = " << x << " y = " << y << endl;
  cout << "desired angle  = " << dAngle << endl;
  cout << "computed angle = " << cAngle << endl;
  cout << "absolute error = " << error << endl;
  return 0;
}
