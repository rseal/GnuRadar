#ifndef REQUEST_SERVER_HPP
#define REQUEST_SERVER_HPP

#include<boost/shared_ptr.hpp>
#include<zmq.hpp>

#include<gnuradar/network/Server.hpp>
#include<gnuradar/commands/Control.pb.h>
#include<gnuradar/commands/Response.pb.h>
#include<gnuradar/utils/ZmqHelper.hpp>

namespace gnuradar{
   namespace network{

      //////////////////////////////////////////////////////////////////////////
      //
      //////////////////////////////////////////////////////////////////////////
      class RequestServer : public Server {

         typedef boost::shared_ptr<zmq::socket_t> SocketPtr;
         SocketPtr socket_;

         ///////////////////////////////////////////////////////////////////////
         //
         ///////////////////////////////////////////////////////////////////////
         gnuradar::ResponseMessage ExecuteRequest ( gnuradar::ControlMessage& msg ) {

            gnuradar::ResponseMessage reply_msg;

            std::cout << "EXECUTE COMMAND: " << msg.name() << std::endl;
            sleep(1);

            if( msg.name() == "STOP" )
            {
               this->Stop();
            }

            // Execute the parsed command, passing in arguments, and 
            // receive response message on return.
            // These commands are all derived from GnuRadarCommand.
            reply_msg.set_value( gnuradar::ResponseMessage::OK );

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
         RequestServer( zmq::context_t& ctx, std::string& ipaddr)
         {
            socket_ = SocketPtr( new zmq::socket_t(ctx, ZMQ_REP));
            socket_->bind (ipaddr.c_str());
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

            std::cout << "CLOSING REQUEST SERVER SOCKET" << std::endl;
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
