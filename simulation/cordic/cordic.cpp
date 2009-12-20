#include "cordic_stage.hpp"
#include <systemc.h>
#include <boost/shared_ptr.hpp>
#include <boost/lexical_cast.hpp>

//N= xy vector bitwidth
//M= z vector bitwidth
template< typename N, typename M>
class Cordic: public sc_module{

  const int stages_;
  const int theta_;

public:
  typedef sc_int<N> DType;
  typedef sc_int<M> ZType;
  typedef boost::shared_ptr<sc_signal<DType> > DSigPtr;
  typedef boost::shared_ptr<sc_signal<ZType> > ZSigPtr;
  typedef boost::lexical_cast<string> StringConvert;

  vector<DSigPtr> dataVec;
  vector<ZSigPtr> zVec;
  vector<CordicStage> cordicVec;

  SC_HAS_PROCESS(Cordic);

  Cordic(const sc_module_name& nm, const int& stages): 
    sc_module(nm), stages_(stages), theta_(theta){

    for(int i=0; i<stages_; ++i){
      //create xy signals
      DSigPtr x(new DType);
      DSigPtr y(new DType);
      dataVec.push_back(x);
      dataVec.push_back(y);
      //create z signals
      ZSigPtr z(new ZType);
      zVec.push_back(z);
      //create cordic stages
      std::string name = "cordic" + StringConvert(i);
      CordicStage cs(name.c_str(), i);
      cordicVec.push_back(cs);
    }
    
    //compute and load initial values
    int x0 = pow(2.0f,N);
    cordicVec[0]->xin(xin);
    cordicVec[0]->yin(yin);
    cordicVec[0]->zin(theta);

    //bind input signals for all stages
    for(int i=0; i<stages-1; ++i){
      int idx = i*width;
      cordicVec[i+1]->xin(*dataVec[idx]);
      cordicVec[i+1]->yin(*dataVec[idx+1]);
      cordicVec[i+1]->zin(*zVec[i]);
    }

    //bind and initialize output signals for all stages
    for(int i=0; i<stages; ++i){
      int idx = i*width;
      string num = boost::lexical_cast<string>(i);
      cordicVec[i]->xout(*dataVec[idx]);
      cordicVec[i]->yout(*dataVec[idx+1]);
      cordicVec[i]->zout(*zVec[i]);
      cordicVec[i]->xout.initialize(0);
      cordicVec[i]->yout.initialize(0);
      cordicVec[i]->zout.initialize(0);
    }

    //define clock and theta inputs
    for(int i=0; i<stages_; ++i){
      cordicVec[i]->clock(clock.signal());
      cordicVec[i]->theta(theta);
    }
  }
    
  sc_in<bool>   clock;
  sc_in<DType>  theta;
  sc_in<DType>  xin;
  sc_in<DType>  yin;
  sc_in<ZType>  zin;
  sc_out<DType> xout;
  sc_out<DType> yout;
  sc_out<ZType> zout;
}
