//////////////////////////////////////////////////////////////
// File: 
//
//
//////////////////////////////////////////////////////////////
#include <iostream>
#include <vector>

using namespace std;

template<typename T>
struct SigGen{
   const int MODULO_NUMBER;
   const int TABLE_SIZE_SAMPLES;
   const int sequence_;
   const int OFFSET_SAMPLES;
   int idx_;
   vector<T> table_;

   public:
   SigGen(const int moduloSize, const int tableSize, const int sequence, 
         const int offset): 
      MODULO_NUMBER(moduloSize), TABLE_SIZE_SAMPLES(tableSize),
      sequence_(sequence), OFFSET_SAMPLES(offset), table_(tableSize,0)
   {
      idx_ = MODULO_NUMBER - OFFSET_SAMPLES;
   }

   // The purpose of this function is to replicate a continuous stream of data
   // with a data tag inserted into the stream. The user requests a table of 
   // data that represents a snap shot in time of streaming data. 
   T* GenerateTable(const int size){

      table_.resize(size,0);

      for(int i=0; i<size; ++i){
         table_[i]=idx_;
         if((idx_%MODULO_NUMBER)==0){
            table_[i]=sequence_;
            idx_=0;
         }
         ++idx_;
      }
      
      return &table_[0];
   }
};
