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
#ifndef STREAM_BUFFER_HPP
#define STREAM_BUFFER_HPP

#include<boost/circular_buffer.hpp>
#include<vector>
#include<deque>
#include<cassert>
#include<iomanip>

using std::cout;
using std::endl;

template<typename T>
struct StreamBuffer{

   // define constants
   const int NUM_BUFFERS;
   const int READ_SIZE;
   const int READ_SIZE_BYTES;
   const int PACKET_SIZE;
   const int PACKET_SIZE_BYTES;
   const int START_INDEX;
   // these are considered constants.
   int BUFFER_SIZE;
   int STORAGE_SIZE;
   int END_INDEX;

   typedef std::vector<T> Buffer;
   typedef std::vector<int> TagVector;
   TagVector tags_;

   // pointers for buffer positioning
   T* readPtr_;
   T* writePtr_;
   T* copyPtr_;
   T* beginPtr_;
   T* endPtr_;
   Buffer buffer_;

   int writeSize_;
   int bufferLevel_;
   int bufferRemaining_;
   int currentBuffer_;

   int readIndex_;
   int writeIndex_;
   int startIndex_;
   int endIndex_;

   bool isSynchronized_;

   /// copies remaining data from last buffer to the top of first, giving
   /// the appearance of a circular buffer, but not quite. This was 
   /// necessary since we have no control over read/write pointers, 
   /// they're used by external processes.
   void Copy(int destIndex, int srcIndex) {

      readIndex_ = 0;
      writeIndex_ = 0;
      T temp;

      for( int i=0; i<bufferLevel_; ++i) {
         buffer_[destIndex+i] = buffer_[srcIndex + i] ;
         ++writeIndex_;
      }
   }

   public:
   StreamBuffer(){};

   /// Accepts alignment size and buffer size in bytes and sets up
   /// an internal aligned buffer
   StreamBuffer( const int readSize, const int packetSize, 
         const TagVector& tags ): 
      START_INDEX(0), NUM_BUFFERS(3), READ_SIZE(readSize), 
      READ_SIZE_BYTES(readSize*sizeof(T)), PACKET_SIZE(packetSize),
      PACKET_SIZE_BYTES(packetSize*sizeof(T)), isSynchronized_(false)
   {
      // adjust write size if alignment required
      writeSize_ = !READ_SIZE%PACKET_SIZE ? 
         READ_SIZE : static_cast<int>(READ_SIZE/PACKET_SIZE + 1)*PACKET_SIZE;

      BUFFER_SIZE = writeSize_;
      STORAGE_SIZE = NUM_BUFFERS*BUFFER_SIZE;
      END_INDEX = STORAGE_SIZE;

      bufferLevel_= 0;
      bufferRemaining_ = STORAGE_SIZE;
      currentBuffer_ = 0;
      tags_ = tags;
      
      readIndex_=0;
      writeIndex_=0;
      
      // manually create contiguous buffer and pointers
      buffer_ = Buffer( STORAGE_SIZE );
   }

   /// get write pointer to write to the data buffer
   void* WritePtr() { return &buffer_[writeIndex_]; }

   /// get read pointer to read from the data buffer
   void* ReadPtr() { return &buffer_[readIndex_]; }

   /// get read size in bytes 
   const int ReadSize()  { return READ_SIZE; }
   const int ReadSizeBytes()  { return READ_SIZE_BYTES; }

   /// get write size in bytes 
   const int WriteSize() { return writeSize_; }
   const int WriteSizeBytes() { return writeSize_*sizeof(T); }

   /// Monitors the buffersize and adjust subsequent write sizes 
   /// in an attempt to minimize buffer depth.
   void AdjustWriteSize() {

      int samplesRequired = READ_SIZE - bufferLevel_;
      writeSize_ = samplesRequired > 0 ? 
         (samplesRequired/PACKET_SIZE + 1 )*PACKET_SIZE : PACKET_SIZE ;
   }

   /// Called after a write and subsequent read. Updates read and write
   /// indexes, as well as the buffer level.
   void Update(){

      writeIndex_ += writeSize_;
      readIndex_ += READ_SIZE;
      bufferLevel_ = writeIndex_ - readIndex_;

      AdjustWriteSize();

      int nextWriteIndex = writeIndex_ + writeSize_;
      int nextReadIndex  = readIndex_ + READ_SIZE;

      if( nextWriteIndex > STORAGE_SIZE || nextReadIndex > STORAGE_SIZE ) {
         Copy( START_INDEX , readIndex_ );
      }
   }
   
   /// returns the current buffer level
   const int& Level()   { return bufferLevel_; }

   /// returns the buffers smallest unit ( a.k.a packet size ).
   const int& PacketSize() { return PACKET_SIZE; }

   /// Synchronizes data stream by finding the tag sequence. Called
   /// internally on the first buffer write.
   const bool Sync( )
   {

      int i=0;
      int j=0;
      bool found=false;
      
      // we have to assume the user has written samples before syncing
      writeIndex_ = writeSize_;

      // search for data tag
      for( i=0; i<BUFFER_SIZE; ++i) {

         if( buffer_[i] == tags_[j] ){

            found = true;
            readIndex_ = i;

            for( j=1; j<tags_.size(); ++j){
               if( buffer_[i+j] != tags_[j] )
                  found = false;
            }
            break;
         }
      }

      bufferLevel_ = writeSize_ - readIndex_;
      isSynchronized_ = true;
      return found;
   }

   /// Used for debugging. Displays current state of all important variables.
   void Status(){
      static int printHeader = 0;

      if( !(printHeader%30) ){
         cout 
            << std::setw(10) << "rd " 
            << std::setw(10) << "wr " 
            << std::setw(10) << "wr size " 
            << std::setw(10) << "level " 
            << std::setw(10) << " max " 
            << endl;
      }

      cout 
         << std::setw(10) << readIndex_
         << std::setw(10) << writeIndex_
         << std::setw(10) << writeSize_
         << std::setw(10) << bufferLevel_ 
         << std::setw(10) << STORAGE_SIZE
         << endl;

      ++printHeader;
   }

   /// Returns a reference to the internal buffer. Currently
   /// used for debugging purposes.
   Buffer& GetBuffer() { return buffer_;}
};
#endif
