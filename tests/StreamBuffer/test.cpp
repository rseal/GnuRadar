#include <iostream>
#include <vector>
#include <string.h>
#include <gnuradar/StreamBuffer.hpp>
#include "SigGen.hpp"

using namespace std;

int main(void){

   typedef short Int16;

   int samples  = 1864;
   int extra    = 16384;
   int iq       = samples*2;
   int ipp      = 250;
   int tSize    = ipp*iq;
   int offset   = 7;
   int align    = 512;
   int channels = 1;
   int size;

   //data tagging sequence for synchronization
   vector<int> sequence(channels,16384);

   //streaming buffer class to properly align variable size data requests
   //using data tags
   StreamBuffer<Int16> sBuf(tSize,align);
   int atSize = tSize + sBuf.Padding();

   //create signal generator to test streaming buffer
   SigGen<Int16> sigGen(iq,atSize,sequence[0],offset);

   //The first buffer contains an unsynchronized data stream and "extra" samples
   //are required to handle alignment
   size = atSize + extra;
   void* tPtr = reinterpret_cast<void*>(sigGen.GenerateTable(size));
   //find tag data and update internal pointers to align data requests
   sBuf.Sync(tPtr,size, sequence);

   //create a local array to store aligned data
   vector<Int16> locArray(tSize);
   void* aPtr = reinterpret_cast<void*>(&locArray[0]);

   //copy data from the streaming buffer to the local array
   memcpy(aPtr, sBuf.ReadPtr(), sBuf.ReadSize());
   sBuf.UpdateRead();

   size = atSize;
   for(int i=0; i<10000; ++i){
      cout << i << " ";
      cout.flush();
      memcpy(sBuf.WritePtr(), sigGen.GenerateTable(sBuf.WriteSize()), sBuf.WriteSize());
      sBuf.UpdateWrite();
      if(sBuf.Level() >= sBuf.ReadSize()) cout << endl << "Buffer Level at threshold " << endl;
      memcpy(aPtr, sBuf.ReadPtr(), sBuf.ReadSize());
      sBuf.UpdateRead();
      if(locArray[0] != 16384) cout << endl << "Misalignment!!!! at i = " << i << endl;
   }
   return 0;
}
