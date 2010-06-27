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

#include<vector>
#include<cassert>

template<typename T>
struct StreamBuffer{
   T* rdPtr_;
   T* wrPtr_;
   T* cpPtr_;
   int userSize_;
   int pad_;
   int align_;
   int level_;
   int bufSize_;
   int wrSize_;
   int cpSize_;
   std::vector<T> buf_;

   const int Bytes(const int& size) { return size*sizeof(T);}

   void Copy(T* dest, T* src, int size){
      for(int i=0; i<size; ++i) *(dest+i) = *(src+i);
   }

   public:
   StreamBuffer(){};

   StreamBuffer(const int& userSize, const int& pad){ Init(userSize,pad);}

   void Init(const int& userSize, const int& pad){
      userSize_ = userSize;
      pad_      = pad;
      align_    = pad;
      level_    = 0;

      if(userSize_%pad_ != 0){
         pad_ = static_cast<int>(userSize/align_ + 1)*align_;
         pad_ -= userSize_;
      }
      else pad_=0;

      bufSize_ = userSize_ + pad_;
      wrSize_  = bufSize_;
      cpSize_  = 0;
      
      //create 2 oversized buffers to manage data stream
      buf_.resize(bufSize_*2);

      rdPtr_ = &buf_[0];
      wrPtr_ = &buf_[0];
      cpPtr_ = &buf_[userSize_];
   }

   const bool Sync(void* src, const int& size, const std::vector<int>& sequence){
      bool found=false;
      int size_=size;
      int i,j;
      T* buf = reinterpret_cast<T*>(src);
      for(i=0; i<size_; ++i){
         if(buf[i]==sequence[0]){
            found=true;
            for(j=0; j<sequence.size(); ++j)
               if(buf[i+j] != sequence[j]) found=false;
         }
         if(found) break;
      }

      if(found){
         size_ -= i;
         Copy(rdPtr_,&buf[i],size_);
         level_ = size_;
         wrPtr_ = &buf_[level_];
         assert(i+size_ <= buf_.size()-1);
      }
      return found;
   }

   void UpdateWrite(){
      level_ += wrSize_;
      assert(rdPtr_ + level_ > cpPtr_);
   } 

   void* WritePtr() { return wrPtr_;}
   void* ReadPtr() { return rdPtr_;}
   const int ReadSize()  { return Bytes(userSize_); }
   const int WriteSize() { return Bytes(wrSize_);   }

   void UpdateRead(){
      assert(level_ <= buf_.size()-1);
      level_ -= userSize_;
      assert(rdPtr_ + level_ < cpPtr_);
      Copy(rdPtr_,cpPtr_,level_);
      wrPtr_ = &buf_[level_];
      assert(rdPtr_ + level_  == wrPtr_);

      //the write size always meets the n-byte boundary requirements
      //this algorithm simply minimizes the memory footprint by constantly 
      //adjusting the write size based on buffer levels
      wrSize_ = static_cast<int>((userSize_-level_)/align_ + 1)*align_;

      if(level_ >= userSize_) std::cout << "DECREASING WRITE REQUEST SIZE" << std::endl;
      if(static_cast<T*>(cpPtr_) + level_ > &buf_[buf_.size()-1]) std::cout << "CRITICAL: BUFFER SIZE EXCEEDED" << std::endl;
   }

   const int& Level()   {return level_;}
   const int& Padding() {return pad_;}
};
#endif
