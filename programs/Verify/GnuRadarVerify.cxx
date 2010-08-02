#include "GnuRadarVerify.hpp"

using std::string;
using std::vector;

int main(int argc, char** argv)
{
   bool overFlow = false;

   CommandLineParser clp(argc,argv);
   Arg arg1("f", "configuration file name", 1, true);
   Switch sw1("h", "print this message", false);
   Switch sw2("help", "print this message", false);
   clp.AddSwitch(sw1);
   clp.AddSwitch(sw2);
   clp.AddArg(arg1);
   clp.Parse();
   
   if(clp.SwitchSet("h") || clp.SwitchSet("help")){
      clp.PrintHelp();
      exit(0);
   }

   clp.Validate();

   string fileName = clp.GetArgValue<string>("f");

   //parse configuration file 
   ConfigFile cf(fileName);

   // buffer one second's worth of data
   buffer.resize( cf.BytesPerSecond() /sizeof(gnuradar::iq_t) );
   void* bufferPtr = &buffer[0];

   // set require gnuradar settings.
   GnuRadarSettings settings;
   for(int i=0; i<cf.NumChannels(); ++i) settings.Tune(i,cf.DDC(i));
   settings.numChannels    = cf.NumChannels();
   settings.decimationRate = cf.Decimation();
   settings.fpgaFileName   = cf.FPGAImage();    
   settings.fUsbBlockSize  = 0;
   settings.fUsbNblocks    = 0;
   settings.mux            = 0xf0f0f1f0;

   // create a USRP object.
   usrp_standard_rx_sptr usrp = usrp_standard_rx::make(
         settings.whichBoard,
         settings.decimationRate,
         settings.numChannels,
         settings.mux,
         settings.mode,
         settings.fUsbBlockSize,
         settings.fUsbNblocks,
         settings.fpgaFileName,
         settings.firmwareFileName
         );

   //check to see if device is connected
   if(usrp.get()==0){ 
         throw std::runtime_error(
               "GnuRadarVerify: No USRP device found - please check your " 
               "connections.\n"
               );
   }

   // setup frequency and phase for each ddc
   for(int i=0; i<settings.numChannels; ++i){
      usrp->set_rx_freq(i,settings.Tune(i));
      usrp->set_ddc_phase(i,0);
   }

   //set all gain to 0dB by default	
   for(unsigned int i=0; i<gnuradar::USRP_MAX_CHANNELS; ++i) 
      usrp->set_pga(i,0);

   // initialize data collection and flush FX2 buffer.
   usrp->start();
   usrp->read( bufferPtr, gnuradar::FX2_FLUSH_FIFO_SIZE_BYTES, &overFlow );

   //read data from USRP
   int bytesRead = usrp->read( bufferPtr, cf.BytesPerSecond(), &overFlow );

   if( bytesRead != cf.BytesPerSecond() ){
         throw std::runtime_error(
               "GnuRadarVerify: Number of bytes read is not equal to the "
               "number of requested bytes.\n"
               );
   }

   // validate collected window sizes with those in configuration file.
   WindowValidator windowValidator_;
   bool valid = windowValidator_.Validate( buffer, cf.Windows() );

   if( !valid ){
      cout << " GnuRadar window verification failed. \n";
      windowValidator_.PrintResults( cout );
   }
   else{
      cout << " GnuRadar window verification passed. \n"; 
   }

   return EXIT_SUCCESS;
}
