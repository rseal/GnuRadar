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
#include "GnuRadarRun.hpp"

#include<iostream>
#include<cmath>
#include<boost/lexical_cast.hpp>
#include<boost/asio.hpp>
#include<zmq.h>

#include<gnuradar/network/RequestServer.hpp>
#include<gnuradar/CommandList.hpp>
#include<gnuradar/commands/Stop.hpp>
#include<gnuradar/commands/Start.hpp>
#include<gnuradar/utils/GrHelper.hpp>

using namespace boost;
using namespace gnuradar;

int main ( )
{
   typedef boost::shared_ptr<command::GnuRadarCommand> CommandPtr;
   typedef boost::shared_ptr<ProducerConsumerModel> PCModelPtr;
   command::CommandList commandList;

   // define network context
   zmq::context_t ctx(1);

   // create a Producer/Consumer model, but don't initialize the
   // object until ready
   PCModelPtr pcModel( new ProducerConsumerModel() );

   // Create various command objects.
   CommandPtr startCommand  = command::CommandPtr ( new command::Start ( ctx, pcModel ) );
   CommandPtr stopCommand   = command::CommandPtr ( new command::Stop ( pcModel ) );

   // Add commands to the command list.
   commandList.Add ( startCommand );
   commandList.Add ( stopCommand );

   std::string ipAddr = gr_helper::ReadConfigurationFile("control");

   std::cout << "SERVER ADDRESS : " << ipAddr << std::endl;

   // Setup a network socket to listen for commands.
   network::RequestServer req_server( ctx, ipAddr, commandList );
   req_server.Start();
   req_server.Wait();

   return EXIT_SUCCESS;
};


