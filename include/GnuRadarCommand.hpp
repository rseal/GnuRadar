#ifndef GNURADAR_COMMAND_HPP
#define GNURADAR_COMMAND_HPP

#include <iostream>

class GnuRadarCommand
{
   std::string name_;

   public:

      GnuRadarCommand( const std::string& name ): name_(name){}
      virtual void Execute( const std::string& args ) = 0;
      const std::string& Name() { return name_; }
};

#endif
