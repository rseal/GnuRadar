#ifndef STATUS_SERVER_HPP
#define STATUS_SERVER_HPP

#include<boost/shared_ptr.hpp>
#include<zmq.hpp>

#include<gnuradar/xml/XmlPacket.hpp>
#include<gnuradar/ProducerConsumerModel.h>
#include<gnuradar/network/Server.hpp>
#include<gnuradar/Constants.hpp>
#include<gnuradar/commands/Status.pb.h>

namespace gnuradar{
   namespace network{

      //////////////////////////////////////////////////////////////////////////
      //
      //////////////////////////////////////////////////////////////////////////
      class StatusServer : public Server {

         typedef boost::shared_ptr< ProducerConsumerModel > PcModelPtr;
         typedef boost::shared_ptr<zmq::socket_t> SocketPtr;

         SocketPtr socket_;
         PcModelPtr pcModel_;

         public:

         StatusServer( zmq::context_t& ctx, const std::string& ipAddr, PcModelPtr pcModel ) : pcModel_(pcModel) 
         {
            socket_ = SocketPtr( new zmq::socket_t(ctx, ZMQ_PUB));
            socket_->bind (ipAddr.c_str());
         }

         //////////////////////////////////////////////////////////////////////////
         //
         //////////////////////////////////////////////////////////////////////////
         void Run()
         {
            std::cout << "StatusServer: START " << std::endl;
            active_ = true;
            gnuradar::StatusMessage status_msg;

            while( active_ )
            {
               status_msg.set_name("status");
               status_msg.set_head(pcModel_->Head() );
               status_msg.set_tail(pcModel_->Tail() );
               status_msg.set_depth( pcModel_->Depth());
               status_msg.set_over_flow(pcModel_->OverFlow() );
               status_msg.set_bytes_per_buffer( pcModel_->BytesPerBuffer() );

               sleep(gnuradar::constants::STATUS_REFRESH_RATE_MSEC);
            }

            std::cout << "StatusServer: STOP " << std::endl;
            socket_->close();
         }

         //////////////////////////////////////////////////////////////////////////
         //
         //////////////////////////////////////////////////////////////////////////
         void Stop()
         {
            active_ = false;
         }
      };
   };
};

#endif

