#ifndef COMMAND_LIST
#define COMMAND_LIST

#include <iostream>
#include <vector>
#include <stdexcept>

#include <boost/shared_ptr.hpp>

#include <gnuradar/GnuRadarCommand.hpp>

namespace gnuradar{

   typedef boost::shared_ptr< GnuRadarCommand > CommandPtr;

   struct CommandList
   {
      typedef std::vector< CommandPtr > CommandVector;
      CommandVector commands_;

      public:
      CommandList() {}

      void Add( CommandPtr commandPtr ) {
         commands_.push_back( commandPtr );
      }

      const CommandPtr Find( std::string& name) 
      {
         CommandVector::const_iterator iter = commands_.begin();

         while( iter != commands_.end() )
         {
            if( name == (*iter)->Name() ) break;
            ++iter;
         }

         // check for an invalid command and throw
         if( iter == commands_.end() ) 
            throw std::runtime_error( "Invalid command request");

         return *iter;
      }
   };

};

#endif
