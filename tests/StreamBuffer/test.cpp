#include <iostream>
#include <vector>
#include <string.h>
#include <StreamBuffer.hpp>
#include <fstream>
#include <boost/cstdint.hpp>
#include <boost/shared_ptr.hpp>
#include "SigGen.hpp"

using namespace std;

int main(void){

   // define an output file stream
   typedef boost::shared_ptr< ofstream > FileOutputStreamPtr;
   FileOutputStreamPtr fos;

   const char* DATA_OUTPUT_FILE_NAME = "test.dat";
   const int NUM_STREAM_BUFFERS = 100;
   const int DATA_TAG = 16384;
   const int PACKET_SIZE_SAMPLES = 128;
   const int OFFSET_SAMPLES = 24;
   const int SAMPLES_PER_IPP = 466;
   const int IPPS_PER_SECOND = 250;
   const int NUM_CHANNELS = 1;
   const int TABLE_SIZE_SAMPLES = SAMPLES_PER_IPP * IPPS_PER_SECOND * 
      NUM_CHANNELS;
   const int SEQUENCE_SPACING_SAMPLES = SAMPLES_PER_IPP;

   //data tagging sequence for synchronization
   vector<int> tags(NUM_CHANNELS, DATA_TAG);

   // Device under test.
   StreamBuffer<boost::int16_t> 
      streamBuffer( TABLE_SIZE_SAMPLES, PACKET_SIZE_SAMPLES, tags );

   //create signal generator to test streaming buffer
   SigGen<boost::int16_t> sigGen(
         SEQUENCE_SPACING_SAMPLES,
         streamBuffer.WriteSize(),
         tags[0],
         OFFSET_SAMPLES
         );

   // copy generated data stream to the stream buffer
   memcpy(
         streamBuffer.WritePtr(), 
         sigGen.GenerateTable( streamBuffer.WriteSize() ),
         streamBuffer.WriteSizeBytes() 
         );

   // sync the data stream and exit if we couldn't locate the tag.
   if(!streamBuffer.Sync()) {
      cerr << "Could not locate sync tag" << endl;
      exit(1);
   }

   //create a local array to store aligned data
   vector<boost::int16_t> locArray( streamBuffer.ReadSize() );
   void* localPtr = reinterpret_cast<void*>(&locArray[0]);

   // create an output file stream
   fos = FileOutputStreamPtr( new ofstream(DATA_OUTPUT_FILE_NAME, ios::out));

   // perform several iterations to ensure that the data stream
   // remains synchronized.
   for(int i=0; i<NUM_STREAM_BUFFERS; ++i){

      // write data into stream buffer
      memcpy ( 
            streamBuffer.WritePtr(), 
            sigGen.GenerateTable( streamBuffer.WriteSize() ),
            streamBuffer.WriteSizeBytes()
            );

      // read data from stream buffer
      memcpy(localPtr, streamBuffer.ReadPtr(), streamBuffer.ReadSizeBytes());

      // update the read/write pointers
      streamBuffer.Update();

      // if an error is detected, alert the user.
      if(locArray[0] != DATA_TAG){
       cout << endl << "Misalignment!!!! = " << locArray[0] << endl;
      }

      // dump the output to a file for debugging.
      //*fos << "Table " << i << endl;
      //for(int i=0; i<streamBuffer.ReadSize(); ++i){
      //  *fos << locArray[i] << " ";
      //  }
      //*fos << endl << endl;
      //fos->flush();
   }
   //fos->close();
   return 0;
}

