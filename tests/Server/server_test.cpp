#include <iostream>

#include <gnuradar/network/TcpRequestServer.hpp>
#include <gnuradar/network/TcpConnection.hpp>
#include <gnuradar/GnuRadarCommand.hpp>
#include <gnuradar/CommandList.hpp>

#include "TestCommand.hpp"

#include <boost/shared_ptr.hpp>

using namespace gnuradar::network;

// This command stops the server and exits
class StopCommand: public GnuRadarCommand
{
   boost::asio::io_service& service_;

   public:
   StopCommand( boost::asio::io_service& service ): GnuRadarCommand("stop"),
   service_(service){}

   virtual void Execute( const std::string& args ){ 
      std::cout << "found args = " << args << std::endl;
      std::cout << "stop this wild son-of-a-bitch" << std::endl;
      service_.stop(); }
};

// test command displays message
class HealthCommand: public GnuRadarCommand
{
   public:
      HealthCommand(): GnuRadarCommand("health"){}

      virtual void Execute( const std::string& args){
         std::cout << "calling health status with args = " << args << std::endl;
      }
};

int main()
{
   boost::asio::io_service io_service;

   // create a command list 
   gnuradar::CommandList commands;
   commands.Add( gnuradar::CommandPtr( new StopCommand( io_service )));
   commands.Add( gnuradar::CommandPtr( new HealthCommand()));

   try
   {
      // pass io_service object and command list to request server
      TcpRequestServer server( io_service, commands );

      // run blocks until stop called
      io_service.run();
   }
   catch (std::exception& e)
   {
      std::cerr << e.what() << std::endl;
   }

   return 0;
}
