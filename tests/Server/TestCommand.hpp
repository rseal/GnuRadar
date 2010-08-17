#ifndef TEST_COMMAND_HPP
#define TEST_COMMAND_HPP

#include <gnuradar/GnuRadarCommand.hpp>

namespace gnuradar{

   class TestCommand: public GnuRadarCommand
   {
      public:

         TestCommand( ): GnuRadarCommand("test"){}

      virtual void Execute( std::string args )
      {
         std::cout << "Executing " << this->Name() << " command." << std::endl;
         std::cout << "args = " << args << std::endl;
      }

      private:

   };

};


#endif

