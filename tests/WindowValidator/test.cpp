#include <iostream>
#include <vector>
#include <string.h>
#include <fstream>
#include "SigGen.hpp"
#include <gnuradar/GnuRadarTypes.hpp>
#include <gnuradar/ConfigFile.h>
#include <gnuradar/WindowValidator.hpp>

using namespace std;

int main(void){

   const int OFFSET_SAMPLES = 24;
   const char* CONFIGURATION_FILENAME = "test.ucf";

   //parse configuration file 
   ConfigFile cf( CONFIGURATION_FILENAME );

   int bufferSize = cf.BytesPerSecond() / sizeof( gnuradar::iq_t );

   //create signal generator to test streaming buffer
   SigGen<gnuradar::iq_t> sigGen(
         cf.WindowSize(0),
         bufferSize,
		   gnuradar::DATA_TAG,
		   OFFSET_SAMPLES
		   );

   // create a buffer to store data
   vector<gnuradar::iq_t> buffer( bufferSize );

   // copy generated data stream to the stream buffer
   memcpy(
	   &buffer[0], 
	   sigGen.GenerateTable( bufferSize ),
      cf.BytesPerSecond()
	 );

   WindowValidator windowValidator;
   bool result = windowValidator.Validate( buffer, cf.Windows() );
   windowValidator.PrintResults( cout );
   cout << "result = " << result << endl;

   return EXIT_SUCCESS;
}

