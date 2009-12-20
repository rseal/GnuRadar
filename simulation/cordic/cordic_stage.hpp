#ifndef CORDICSTAGE_HPP
#define CORDICSTAGE_HPP

#include <systemc.h>
#include <boost/shared_ptr.hpp>

template<uint N, uint M>
class CordicStage: public sc_module{
  int stage_;
  const int scale_;

  typedef sc_int<N> DType;
  typedef sc_signal<DType> DSig;
  typedef boost::shared_ptr<DSig> DSigPtr;

  typedef sc_int<M> ZType;
  typedef sc_signal<ZType> ZSig;
  typedef boost::shared_ptr<ZSig> ZSigPtr;


protected:
  void Compute(){
    
    float scale = pow(2.0,M);
    int   sign=1;
    float coeff;
    float shift = pow(2,-stage_);
    int theta_i = atan(shift)*scale/(2.0*M_PI);

    float angle = zin.read();

    //remap angles to first or fourth quadrants
    if(angle > scale/4 && angle < scale*3/4){
      //      if(angle < scale/2)
	angle -= scale/2;
//       else
// 	angle += scale/2;
      angle = -angle;
    }
    
    if(angle < 0) sign=-1;
    
    coeff=sign*shift;
 
    xout = xin.read() - coeff*yin.read();
    yout = yin.read() + coeff*xin.read();
    zout = angle - sign*theta_i;
  }

  void PrintOutputs(){
    cout << "stage number = " << stage_ << endl;
    cout << "xin = " << xin.read() << ", xout = " << xout.read() << endl;
    cout << "yin = " << yin.read() << ", yout = " << yout.read() << endl;
    cout << "zin = " << zin.read() << ", zout = " << zout.read() << endl << endl;
    
  }

public:
  //required by systemc when not using CTOR macros
  SC_HAS_PROCESS(CordicStage);

  //CTOR
  CordicStage(sc_module_name nm, const int& stage): sc_module(nm), stage_(stage), scale_(65536){
    SC_METHOD(Compute);
    sensitive << clock.pos();
  }

  //define interface to module
  sc_in<bool>   clock;
  sc_in<ZType>  theta;
 
  sc_in<DType>  xin;
  sc_out<DType> xout;

  sc_in<DType>  yin;
  sc_out<DType> yout;
 
  sc_in<ZType>  zin;
  sc_out<ZType> zout;
};

#endif
