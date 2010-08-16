#ifndef GNURADAR_COMMAND_HPP
#define GNURADAR_COMMAND_HPP

#include <gnuradar/GnuRadarArguments.hpp>
#include <iostream>

class Command
{
   std::string name_;

   public:

      virtual void Execute( GnuRadarArguments args ) = 0;

      const std::string& Name() { return name_ };
      void Name( const std:string name ) { name_ = name };
};

#endif
