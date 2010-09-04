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
#ifndef STOP_HPP
#define STOP_HPP

#include <gnuradar/GnuRadarCommand.hpp>
#include <gnuradar/ProducerConsumerModel.h>
#include <gnuradar/xml/XmlPacket.hpp>

namespace gnuradar {
namespace command {

class Stop : public GnuRadarCommand {

    // setup shared pointers to extend life beyond this call
    typedef boost::shared_ptr< ProducerConsumerModel > ProducerConsumerModelPtr;
    ProducerConsumerModelPtr pcModel_;

   public:

    Stop( ProducerConsumerModelPtr pcModel ): 
       GnuRadarCommand( "stop" ), pcModel_( pcModel ) {
       }

    virtual const std::string Execute( const xml::XmlPacketArgs& args ) {

       // TODO: Uncomment these when official testing is ready.
       //pcModel_->Stop();
       //pcModel_->Wait();
       
       std::cout << " Stop Command " << std::endl;

       // create a response packet and return to requester
       std::string destination = command::ParseArg( "destination", args );
       xml::XmlPacketArgs responsePacket;
       responsePacket["destination"] = destination;
       responsePacket["type"] = "response";
       responsePacket["value"] = "OK";
       gnuradar::xml::XmlPacket packet("gnuradar_server");
       const std::string response = packet.Format( responsePacket );

       return response;
    }
};
};
};

#endif
