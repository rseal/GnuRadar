#ifndef GNURADAR_TYPES_H
#define GNURADAR_TYPES_H

#include <boost/cstdint.hpp>
// define global constants and static variables here.
namespace gnuradar{

   typedef boost::int16_t iq_t;
   const static unsigned int BYTES_PER_COMPLEX_SAMPLE = 4;
   const static unsigned int BUFFER_ALIGNMENT_SIZE = 128;
   const static unsigned int BUFFER_ALIGNMENT_SIZE_BYTES(
         BUFFER_ALIGNMENT_SIZE*BYTES_PER_COMPLEX_SAMPLE
         );
   const static unsigned int FX2_FLUSH_FIFO_SIZE_BYTES = 
      BUFFER_ALIGNMENT_SIZE_BYTES * 10;
   const static unsigned int DATA_TAG = 16384;
   const static unsigned int USRP_MAX_CHANNELS = 4;
   const static unsigned int PACKET_SIZE_SAMPLES = 128;
   const static unsigned int PACKET_SIZE_BYTES = PACKET_SIZE_SAMPLES * 
      BYTES_PER_COMPLEX_SAMPLE;
};

#endif
