// Copyright (c) 2010 Ryan Seal <rlseal -at- gmail.com>
//
// This file is part of GnuRadar Software.
//
// GnuRadar is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//  
// GnuRadar is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GnuRadar.  If not, see <http://www.gnu.org/licenses/>.
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
