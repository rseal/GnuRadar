#include <vector>
#include <cmath>
#include "cordic_stage.hpp"
#include "dtypes.h"
#include <boost/shared_ptr.hpp>
#include <boost/lexical_cast.hpp>

using namespace std;

int sc_main(int argc, char* argv[]){

  //define typedefs
  typedef boost::shared_ptr<CordicStage> CordicPtr;

  //set timescale
  sc_set_time_resolution(1,SC_NS);

  //define system clock
  sc_clock clock("clk",sc_time(2,SC_NS));

  //setup vcd dump file for waveform viewer
  sc_trace_file* vcdFile = sc_create_vcd_trace_file("cordic");

  //width is the port width for i/o defined as:
  //p0 = x0, p1 = y, p2 = z
  int angle  = 20192;
  int width  = 2;
  int stages = 12;
  int size   = width*stages;
  SigInt18 theta;  theta.write(angle);

  //define signal vectors to simplify connection code
  //  vector<SigInt18Ptr> sig;
  vector<SigInt18Ptr> xyVec;
  vector<SigInt16Ptr> zVec;
  vector<CordicPtr> cordicArray;

  //create xy vector signals and push into array
  for(int i=0; i<size; ++i){
    SigInt18Ptr xy(new SigInt18);
    xyVec.push_back(xy);
  }
  
  //create z vector signals and push into array
  for(int i=0; i<stages; ++i){
    SigInt16Ptr z(new SigInt16);
    zVec.push_back(z);
  }

  //create cordic stages
  for(int i=0; i<stages; ++i){
    string name = "cordic" + boost::lexical_cast<string>(i);
    CordicPtr cordic(new CordicStage(name.c_str(),i));
    cordicArray.push_back(cordic);
  }
  
  //remap angles to first or fourth quadrants
  if(angle > 16384 && angle < 49152){
    if(angle < 32768)
      angle -= 32768;
    else
      angle += 32768;
    angle = -angle;
  }

  //initial values
  SigInt18 x0; x0.write(65536);
  SigInt18 y0; y0.write(0);
  SigInt16 z0; z0.write(angle);

  cordicArray[0]->xin(x0);
  cordicArray[0]->yin(y0);
  cordicArray[0]->zin(z0);

  //bind input signals for all stages
  for(int i=0; i<stages-1; ++i){
    int idx = i*width;
    cordicArray[i+1]->xin(*xyVec[idx]);
    cordicArray[i+1]->yin(*xyVec[idx+1]);
    cordicArray[i+1]->zin(*zVec[i]);
    string num = boost::lexical_cast<string>(i);
    sc_trace(vcdFile,cordicArray[i+1]->xin,"xin"+num);
    sc_trace(vcdFile,cordicArray[i+1]->yin,"yin"+num);
    sc_trace(vcdFile,cordicArray[i+1]->zin,"zin"+num);
  }

  //bind output signals for all stages
  for(int i=0; i<stages; ++i){
    int idx = i*width;
    string num = boost::lexical_cast<string>(i);
    cordicArray[i]->xout(*xyVec[idx]);
    cordicArray[i]->yout(*xyVec[idx+1]);
    cordicArray[i]->zout(*zVec[i]);
    cordicArray[i]->xout.initialize(0);
    cordicArray[i]->yout.initialize(0);
    cordicArray[i]->zout.initialize(0);
    sc_trace(vcdFile,cordicArray[i]->xout,"xout"+num);
    sc_trace(vcdFile,cordicArray[i]->yout,"yout"+num);
    sc_trace(vcdFile,cordicArray[i]->zout,"zout"+num);
  }

  //define clock and theta inputs
  for(int i=0; i<stages; ++i){
    cordicArray[i]->clock(clock.signal());
    cordicArray[i]->theta(theta);
  }

  sc_trace(vcdFile,theta,"theta");

  //sc_initialize();
  sc_start(SC_ZERO_TIME);

  //run simulations for 2 usec
  sc_start(sc_time(22, SC_NS));

//   for(int i=0; i<stages; ++i){
//     cout << "stage number " << i << endl;
//     cout << "x_out[" << i << "]=" << cordicArray[i]->xout.read() << endl;
//     cout << "y_out[" << i << "]=" << cordicArray[i]->yout.read() << endl;
//     cout << "z_out[" << i << "]=" << cordicArray[i]->zout.read() << endl
//     	 << endl;
//   }

  float desiredAngle = 360*angle/65536.0;
  float x = static_cast<float>(cordicArray[stages-1]->xout.read());
  float y = static_cast<float>(cordicArray[stages-1]->yout.read());

  float computedAngle = atan2(y,x);

  cout << "angle          = " << angle << endl;
  cout << "desired angle  = " << desiredAngle << endl;
  cout << "computed angle = " << computedAngle*180/M_PI << endl;
  cout << "error          = " 
       << 100*abs(desiredAngle - computedAngle*180/M_PI)/desiredAngle << "%" << endl;
  sc_close_vcd_trace_file(vcdFile);
  return 0;
}
