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
   int pLength_,tLength_;
   int sequence_, offset_;
   int idx_;
   vector<T> table_;

   public:
   SigGen(const int& pLength, const int& tLength, const int& sequence, 
         const int& offset): 
      pLength_(pLength),tLength_(tLength),sequence_(sequence),
      offset_(offset),table_(tLength,0){
      idx_ = pLength_ - offset_;
   }

   // The purpose of this function is to replicate a continuous stream of data
   // with a data tag inserted into the stream. The user requests a table of 
   // data that represents a snap shot in time of streaming data. 
   T* GenerateTable(const int size){
      //table_.clear();
      table_.resize(size,0);

      for(int i=0; i<size; ++i){
         table_[i]=idx_;
         if((idx_%pLength_)==0){
            table_[i]=sequence_;
            idx_=0;
         }
         ++idx_;
      }
      
      return &table_[0];
   }
};
