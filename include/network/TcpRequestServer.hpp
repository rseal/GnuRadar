#ifndef GNURADAR_TCP_REQUEST_SERVER 
#define GNURADAR_TCP_REQUEST_SERVER

#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <gnuradar/network/TcpConnection.hpp>
#include <gnuradar/CommandList.hpp>

using boost::asio::ip::tcp;

namespace gnuradar{
   namespace network{

      static const int GNURADAR_TCP_SERVICE_PORT = 54321;

      class TcpRequestServer
      {

         public:

            TcpRequestServer ( boost::asio::io_service& io_service, 
                  gnuradar::CommandList& commands ) : acceptor_ ( 
                     io_service, 
                     tcp::endpoint(tcp::v4(), GNURADAR_TCP_SERVICE_PORT )), 
                  commands_(commands) 
         {
            start_accept();
         }

         private:

            gnuradar::CommandList& commands_;
            tcp::acceptor acceptor_;

            // accept request from client
            void start_accept()
            {
               // create a new tcp connection
               TcpConnection::pointer new_connection =
                  TcpConnection::create(acceptor_.io_service(), commands_);

               // wait for incoming requests
               acceptor_.async_accept(
                     new_connection->socket(),
                     boost::bind(
                        &TcpRequestServer::handle_accept, 
                        this, 
                        new_connection,
                        boost::asio::placeholders::error)
                     );
            }

            // accept handler to handle incoming request
            void handle_accept(
                  TcpConnection::pointer connection,
                  const boost::system::error_code& error)
            {
               if (!error)
               {
                  connection->start();
                  start_accept();
               }
            }
      };
   };
};

#endif
