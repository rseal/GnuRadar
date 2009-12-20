#ifndef CORDIC_HPP
#define CORDIC_HPP

#include "cordic_stage.hpp"
#include <systemc.h>
#include <boost/shared_ptr.hpp>
#include <boost/lexical_cast.hpp>
#include <iostream>
#include <vector>

//N= xy vector bitwidth
//M= z vector bitwidth
template< uint N, uint M>
class Cordic: public sc_module{
public:
  typedef sc_int<N> DType;
  typedef sc_int<M> ZType;
  typedef sc_signal<DType> DSig;
  typedef sc_signal<ZType> ZSig;
  typedef boost::shared_ptr<DSig> DSigPtr;
  typedef boost::shared_ptr<ZSig> ZSigPtr;
  typedef boost::shared_ptr<CordicStage<N,M> > CordicStagePtr;

  std::vector<DSigPtr> dataVec;
  std::vector<ZSigPtr> zVec;
  std::vector<CordicStagePtr> cordicVec;

  SC_HAS_PROCESS(Cordic);

  Cordic(sc_module_name nm, const int& stages): 
    sc_module(nm){


    for(int i=0; i<stages-1; ++i){
      //create xy signals
      DSigPtr x(new DSig);
      DSigPtr y(new DSig);
      dataVec.push_back(x);
      dataVec.push_back(y);
      //create z signals
      ZSigPtr z(new ZSig);
      zVec.push_back(z);
    }
    
    for(int i=0; i<stages; ++i){
      //create cordic stages
      std::string name = "cordic" + boost::lexical_cast<std::string>(i);
      CordicStagePtr cs(new CordicStage<N,M>(name.c_str(), i));
      cordicVec.push_back(cs);
    }

    //bind and initialize output signals for all stages
    for(int i=0; i<stages-1; ++i){
      cordicVec[i+1]->xin(*dataVec[2*i]);
      cordicVec[i+1]->yin(*dataVec[2*i+1]);
      cordicVec[i+1]->zin(*zVec[i]);
      cordicVec[i]->xout(*dataVec[2*i]);
      cordicVec[i]->yout(*dataVec[2*i+1]);
      cordicVec[i]->zout(*zVec[i]);
      cordicVec[i]->xout.initialize(0);
      cordicVec[i]->yout.initialize(0);
      cordicVec[i]->zout.initialize(0);
      cordicVec[i]->theta(theta);
      cordicVec[i]->clock(clock);
    }

    cordicVec[0]->xin(xin);
    cordicVec[0]->yin(yin);
    cordicVec[0]->zin(zin);
    cordicVec[stages-1]->xout(xout);
    cordicVec[stages-1]->yout(yout);
    cordicVec[stages-1]->zout(zout);
    cordicVec[stages-1]->theta(theta);
    cordicVec[stages-1]->clock(clock);
    xout.initialize(0);
    yout.initialize(0);
    zout.initialize(0);
  }

  sc_in<bool>   clock;
  sc_in<DType>  xin;
  sc_in<DType>  yin;
  sc_in<ZType>  zin;
  sc_out<DType> xout;
  sc_out<DType> yout;
  sc_out<ZType> zout;
  sc_in<ZType>  theta;
};

#endif
