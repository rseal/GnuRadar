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
#include <boost/lexical_cast.hpp>
#include <boost/asio.hpp>
#include <cmath>

#include <gnuradar/network/TcpRequestServer.hpp>
#include <gnuradar/CommandList.hpp>
#include <gnuradar/commands/Start.hpp>
#include <gnuradar/commands/Stop.hpp>
#include <gnuradar/commands/Status.hpp>

using namespace boost;
using namespace gnuradar;

int main ( )
{
    typedef boost::shared_ptr<command::GnuRadarCommand> CommandPtr;
    typedef boost::shared_ptr<ProducerConsumerModel> PCModelPtr;
    boost::asio::io_service ioService;
    command::CommandList commandList;

    // create a Producer/Consumer model, but don't initialize the
    // object until ready
    PCModelPtr pcModel( new gnuradar::ProducerConsumerModel() );

    CommandPtr startCommand = command::CommandPtr ( 
          new command::Start ( pcModel ) );
    CommandPtr stopCommand = command::CommandPtr (
                                 new command::Stop ( pcModel ) );
    CommandPtr statusCommand = command::CommandPtr (
                                   new command::Status ( pcModel ) );

    commandList.Add ( startCommand );
    commandList.Add ( stopCommand );
    commandList.Add ( statusCommand );

    network::TcpRequestServer server ( ioService, commandList );
    ioService.run();

    return EXIT_SUCCESS;
};


