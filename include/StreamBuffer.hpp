#ifndef STREAM_BUFFER_HPP
#define STREAM_BUFFER_HPP
#include<vector>
#include<string.h>

template<typename T>
struct StreamBuffer{
   void* rdPtr_;
   void* wrPtr_;
   void* cpPtr_;
   int userSize_;
   int pad_;
   int align_;
   int level_;
   int bufSize_;
   int wrSize_;
   std::vector<T> buf_;

   const int Bytes(const int& size) { return size*sizeof(T);}

   public:
   StreamBuffer(){};

   StreamBuffer(const int& userSize, const int& pad){ Init(userSize,pad);}

   void Init(const int& userSize, const int& pad){
      userSize_ = userSize;
      pad_      = pad;
      align_    = pad;
      level_    = 0;

      if(userSize_%pad_ != 0){
         pad_ = static_cast<int>(userSize/pad_ + 1)*pad_;
         pad_ -= userSize_;
      }
      else pad_=0;

      bufSize_ = userSize_ + pad_;
      wrSize_ = bufSize_;
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
         //std::cout << "buf[" << i << "]=" << buf[i] << std::endl;
         if(buf[i]==sequence[0]){
            found=true;
            std::cout << "found sequence at index " << i << std::endl;
            for(j=0; j<sequence.size(); ++j)
               if(buf[i+j] != sequence[j]) found=false;
         }
         if(found) break;
      }

      if(found){
         size_ -= i;
         memcpy(rdPtr_,reinterpret_cast<void*>(&buf[i]),size_*sizeof(T));
         level_ += size;
         wrPtr_ = &buf_[level_];
      }

      return found;
   }

   void UpdateWrite(){
      //memcpy(wrPtr_,src,Bytes(size));
      level_ += wrSize_;
   } 

   void* WritePtr() { return wrPtr_;}
   void* ReadPtr() { return rdPtr_;}
   const int ReadSize() { return Bytes(userSize_);}
   const int WriteSize() { return Bytes(wrSize_);}

   void UpdateRead(){
      //memcpy(dest, rdPtr_, Bytes(size)); 
      level_ -= userSize_;
      memcpy(rdPtr_,cpPtr_,Bytes(level_));
      wrPtr_ = &buf_[level_];
      //since the aligned size coming in is larger than
      //the userSize going out, the buffer is growing at
      //a rate of pad_ samples per request. This prevents
      //eventual overflows
      wrSize_ = (level_ >= userSize_) ? align_ : bufSize_;
      if(level_ > userSize_) std::cout << "DECREASING WRITE REQUEST SIZE" << std::endl;
      if(static_cast<T*>(cpPtr_) + level_ > &buf_[buf_.size()-1]) std::cout << "CRITICAL: BUFFER SIZE EXCEEDED" << std::endl;
   }

   const int& Level() {return level_;}
   const int& Padding() {return pad_;}

};
#endif
