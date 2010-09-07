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
#ifndef STATUS_HPP
#define STATUS_HPP

#include <gnuradar/GnuRadarCommand.hpp>
#include <gnuradar/ProducerConsumerModel.h>
#include <gnuradar/xml/XmlPacket.hpp>
#include <boost/lexical_cast.hpp>

namespace gnuradar {
namespace command {

class Status : public GnuRadarCommand
{
   typedef boost::shared_ptr< ProducerConsumerModel > ProducerConsumerModelPtr;
   ProducerConsumerModelPtr pcModel_;

   public:

      Status( ProducerConsumerModelPtr pcModel ):
         GnuRadarCommand("status"), pcModel_( pcModel ){
         }

      virtual const std::string Execute( const xml::XmlPacketArgs& args )
      {
         // create a response packet and return to requester
         std::string destination = command::ParseArg( "source", args );
         xml::XmlPacketArgs responsePacket;
         responsePacket["destination"] = destination;
         responsePacket["type"] = "response";
         responsePacket["num_buffers"] = 
            boost::lexical_cast<std::string>( pcModel_->NumBuffers() );
         responsePacket["value"] = "OK";
         responsePacket["head"] = 
            boost::lexical_cast<std::string>( pcModel_->Head() );
         responsePacket["tail"] = 
            boost::lexical_cast<std::string>( pcModel_->Tail() );
         responsePacket["depth"] = 
            boost::lexical_cast<std::string>( pcModel_->Depth() );
         responsePacket["over_flow"] = 
            boost::lexical_cast<std::string>( pcModel_->OverFlow() );
         responsePacket["bytes_per_buffer"] = 
            boost::lexical_cast<std::string>( pcModel_->BytesPerBuffer() );

         gnuradar::xml::XmlPacket packet("gnuradar_server");
         const std::string response = packet.Format( responsePacket );

         return response;

      }
};
};
};

#endif 
