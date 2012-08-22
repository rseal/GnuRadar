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
#ifndef GNURADAR_TCP_REQUEST_SERVER
#define GNURADAR_TCP_REQUEST_SERVER

#include <boost/asio.hpp>
#include <boost/bind.hpp>
#include <gnuradar/network/TcpConnection.hpp>
#include <gnuradar/CommandList.hpp>

using boost::asio::ip::tcp;


namespace gnuradar {
   namespace network {

      static const int GNURADAR_TCP_SERVICE_PORT = 54321;

      class TcpRequestServer {

         public:

            TcpRequestServer ( boost::asio::io_service& io_service, 
                  command::CommandList& commands )
               : acceptor_ ( io_service, tcp::endpoint ( tcp::v4(), GNURADAR_TCP_SERVICE_PORT ) ),
               commands_ ( commands ) {
                  start_accept();
               }

         private:

            command::CommandList& commands_;
            tcp::acceptor acceptor_;

            // accept request from client
            void start_accept() {
               // create a new tcp connection
               TcpConnection::pointer new_connection =
                  TcpConnection::create ( acceptor_.get_io_service(), commands_ );

               // wait for incoming requests
               acceptor_.async_accept (
                     new_connection->socket(),
                     boost::bind (
                        &TcpRequestServer::handle_accept,
                        this,
                        new_connection,
                        boost::asio::placeholders::error )
                     );
            }

            // accept handler to handle incoming request
            void handle_accept (
                  TcpConnection::pointer connection,
                  const boost::system::error_code& error ) {
               if ( !error ) {
                  connection->start();
                  start_accept();
               }
            }
      };
   };
};

#endif
