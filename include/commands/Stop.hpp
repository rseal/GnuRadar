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

#include <GnuRadarCommand.hpp>
#include <ProducerConsumerModel.h>
#include <commands/Response.pb.h>

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

         virtual const gnuradar::ResponseMessage Execute( gnuradar::ControlMessage& msg ){

            // satisfy compiler warning
            (void)msg;

            gnuradar::ResponseMessage response_msg;

            pcModel_->Stop();

            // create a response packet and return to requester
            response_msg.set_value(gnuradar::ResponseMessage::OK);
            response_msg.set_message("Data collection halted.");

            std::cout << "System has been stopped by the user..." << std::endl;

            return response_msg;
         }
      };
   };
};

#endif
