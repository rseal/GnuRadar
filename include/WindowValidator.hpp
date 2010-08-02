#ifndef WINDOW_VALIDATOR_HPP
#define WINDOW_VALIDATOR_HPP

#include <gnuradar/ConfigFile.h>
#include <gnuradar/GnuRadarTypes.hpp>

struct WindowValidator{

   typedef std::vector<int> MeasuredWindowVector;
   typedef std::vector<Window> WindowVector;
   typedef std::vector<gnuradar::iq_t> IqVector;
   typedef IqVector::const_iterator IqIterator;

   IqVector buffer_;
   IqIterator bufferIter_;
   WindowVector windows_;
   MeasuredWindowVector measuredWindows_;

   // determines the number of samples between data tags
   // and repositions the iterator.
   const int getCount(){
      int count = 0;
      do{
         ++count;
         ++bufferIter_;
      } 
      while( 
            *bufferIter_ != gnuradar::DATA_TAG && 
            bufferIter_ != buffer_.end() 
           );

      return count;
   }

   // compares the determined window sizes to the 
   // sizes given in the configuration file.
   const bool Compare(){
      bool result = true;

      for(int i=0; i<windows_.size(); ++i){
         if( windows_[i].size != measuredWindows_[i] ) {
            result = false;
            break;
         }
      }
      return result;
   }

   public:
   const bool Validate( 
         const std::vector<gnuradar::iq_t>& buffer, 
         const std::vector<Window>& windows
         )
   {
      buffer_ = buffer;
      windows_ = windows;

      bufferIter_ = buffer_.begin();

      // search for the first data tag and reposition the iterator.
      getCount();

      if( bufferIter_ == buffer_.end()){ 
         throw std::runtime_error(
               "WindowValidator: Could not locate data tag"
               "connections.\n"
               );
      }

      // store a sample count for each window defined by the window vector.
      for( int i=0; i<windows_.size(); ++i) 
         measuredWindows_.push_back( getCount() ); 

      return Compare();
   }

   void PrintResults( std::ostream& outputStream ){

      outputStream << " window " << " configured " << "   " << " measured " << endl;
      for( int i=0; i< windows_.size(); ++i){
         cout 
            << "   "  
            << i << "       " 
            << windows_[i].size 
            << "           " 
            << measuredWindows_[i] 
            << endl;
      }
   }
};

#endif

