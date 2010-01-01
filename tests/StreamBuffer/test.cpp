#include <iostream>
#include <vector>
#include <string.h>
#include <gnuradar/StreamBuffer.hpp>
#include <fstream>
#include "SigGen.hpp"

using namespace std;

int main(void){

   typedef short Int16;

   int samples  = 10;
   int iq       = samples*2;
   int ipp      = 250;
   int tSize    = ipp*iq;
   int offset   = 8;
   int align    = 256;
   int channels = 1;
   int size;
   //data tagging sequence for synchronization
   vector<int> sequence(channels,16384);

   //streaming buffer class to properly align variable size data requests
   //using data tags
   StreamBuffer<Int16> sBuf(tSize,align);
   int atSize = tSize + sBuf.Padding();
   int extra    = atSize/4;

   cout << "Table Size = " << tSize << "\n"
      << "Padding    = " << sBuf.Padding() << "\n"
      << "extra      = " << extra << endl;
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

   fstream fout("test.dat", ios::out);
   size = atSize;
   for(int i=0; i<1000; ++i){
      int wrSize = sBuf.WriteSize();
      memcpy(sBuf.WritePtr(), sigGen.GenerateTable(wrSize/sizeof(Int16)), wrSize);
      sBuf.UpdateWrite();
      fout << sBuf.Level() << endl;
      if(sBuf.Level() >= sBuf.ReadSize()) cout << endl << "Buffer Level at threshold " << endl;
      memcpy(aPtr, sBuf.ReadPtr(), sBuf.ReadSize());
      sBuf.UpdateRead();
      if(locArray[0] != 16384){
         fout << endl << "Misalignment!!!! = " << locArray[i] << endl;
      }
      for(int i=0; i<tSize; ++i){
         fout << locArray[i] << " ";
         //if(i%50 == 0) fout << endl;
         }
      fout << endl << endl;
   }
fout.close();
return 0;
}
