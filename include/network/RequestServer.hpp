#ifndef REQUEST_SERVER_HPP
#define REQUEST_SERVER_HPP

#include<boost/shared_ptr.hpp>
#include<zmq.hpp>

#include<gnuradar/network/Server.hpp>
#include<gnuradar/commands/Control.pb.h>
#include<gnuradar/commands/Response.pb.h>
#include<gnuradar/CommandList.hpp>
#include<gnuradar/utils/ZmqHelper.hpp>

namespace gnuradar{
   namespace network{

      //////////////////////////////////////////////////////////////////////////
      //
      //////////////////////////////////////////////////////////////////////////
      class RequestServer : public Server {

         typedef boost::shared_ptr<zmq::socket_t> SocketPtr;
         SocketPtr socket_;
         gnuradar::command::CommandList& commands_;

         ///////////////////////////////////////////////////////////////////////
         //
         ///////////////////////////////////////////////////////////////////////
         const gnuradar::ResponseMessage ExecuteRequest ( gnuradar::ControlMessage& msg ) {

            gnuradar::ResponseMessage reply_msg;

            try {
               std::cout << "EXECUTE COMMAND: " << msg.name() << std::endl;

               command::CommandPtr commandPtr = commands_.Find ( msg.name() );

               // Execute the parsed command, passing in arguments, and 
               // receive response message on return.
               // These commands are all derived from GnuRadarCommand.
               reply_msg = commandPtr->Execute ( msg );

            } catch ( std::exception& e ) {
               reply_msg.set_value( gnuradar::ResponseMessage::ERROR );
               reply_msg.set_message(e.what());
               std::cerr << "Invalid command " << e.what() << std::endl;
            }

            return reply_msg;

         }

         ///////////////////////////////////////////////////////////////////////
         //
         ///////////////////////////////////////////////////////////////////////
         void SendResponse( gnuradar::ResponseMessage& msg ){
            std::string serial_msg;
            msg.SerializeToString(&serial_msg);
            zmq::message_t reply (serial_msg.size());
            memcpy ((void *) reply.data (), serial_msg.c_str(), serial_msg.size());
            socket_->send (reply);
         }

         public:

         ///////////////////////////////////////////////////////////////////////
         // CTOR
         ///////////////////////////////////////////////////////////////////////
         RequestServer( 
               zmq::context_t& ctx, 
               std::string& ipAddr,
               gnuradar::command::CommandList& commands ) :  commands_(commands)
         {
            socket_ = SocketPtr( new zmq::socket_t(ctx, ZMQ_REP));
            socket_->bind (ipAddr.c_str());
         }

         ///////////////////////////////////////////////////////////////////////
         // Starts Request Server in Thread.
         ///////////////////////////////////////////////////////////////////////
         void Run()
         {
            active_ = true;
            std::string reply_msg;
            std::string data;
            gnuradar::ControlMessage request_msg;
            gnuradar::ResponseMessage response_msg;
            zmq::message_t request;

            std::cout << "RequestServer: START " << std::endl;

            while( active_ )
            {
               // Wait for next request from client.
               socket_->recv (&request);

               // Parse message from wire.
               request_msg.ParseFromString( zmq_helper::FormatString(request) );

               // Execute client request
               response_msg = this->ExecuteRequest( request_msg );

               // Send reply
               this->SendResponse( response_msg );

            }

            std::cout << "RequestServer: STOP " << std::endl;
            socket_->close();
         }

         ///////////////////////////////////////////////////////////////////////
         //
         ///////////////////////////////////////////////////////////////////////
         void Stop()
         {
            active_ = false;
         }
      };
   };
};

#endif
