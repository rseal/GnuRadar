#ifndef GNURADAR_TCP_REQUEST_SERVER 
#define GNURADAR_TCP_REQUEST_SERVER

#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <map>
#include <gnuradar/network/TcpConnection.hpp>

using boost::asio::ip::tcp;

namespace gnuradar{
   namespace network{

      static const int GNURADAR_TCP_SERVICE_PORT = 54321;

      class TcpRequestServer
      {

         public:

            TcpRequestServer ( boost::asio::io_service& io_service, 
                  TcpConnection::MessageMap& map ) 
               : acceptor_ ( io_service, tcp::endpoint(tcp::v4(), 
                        GNURADAR_TCP_SERVICE_PORT )), map_(map) {
                  start_accept();
               }

         private:

            TcpConnection::MessageMap& map_;
            tcp::acceptor acceptor_;

            // accept request from client
            void start_accept()
            {
               // create a new tcp connection
               TcpConnection::pointer new_connection =
                  TcpConnection::create(acceptor_.io_service(), map_);

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
            void handle_accept(TcpConnection::pointer connection,
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
