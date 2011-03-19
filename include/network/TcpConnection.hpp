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
#ifndef GNURADAR_TCP_REQUEST_CONNECTION_HPP
#define GNURADAR_TCP_REQUEST_CONNECTION_HPP

#include <stdexcept>
#include <iostream>

#include <boost/enable_shared_from_this.hpp>
#include <boost/bind.hpp>
#include <boost/asio.hpp>
#include <boost/array.hpp>
#include <gnuradar/CommandList.hpp>
#include <gnuradar/xml/XmlPacket.hpp>

using boost::asio::ip::tcp;

namespace gnuradar {
namespace network {

// Data buffer must be large enough to transfer a complete configuration file, which 
// is approximately 1869 bytes + encoding at the time of this comment.
static const int MAX_MESSAGE_SIZE_BYTES = 4096;

class TcpConnection : public boost::enable_shared_from_this<TcpConnection> {

public:
    typedef boost::shared_ptr<TcpConnection> pointer;
    typedef boost::array< char, MAX_MESSAGE_SIZE_BYTES > Message;

    // create and return a shared pointer to this
    static pointer create ( boost::asio::io_service& io_service,
                            gnuradar::command::CommandList& commands ) {
        return pointer ( new TcpConnection ( io_service, commands ) );
    }

    // return the connection's socket
    tcp::socket& socket() {
        return socket_;
    }

    // run thread
    void start() {

       const std::string END_OF_TRANSMISSION_TOKEN = "</command>";
       Message readMessage;
       std::string result;
       bool end_of_transmission = false;
       int read_size = 0;

       // listen for incoming data until we receive the end-of-transmission 
       // tokent
       while( !end_of_transmission )
       {
          read_size += socket_.read_some ( boost::asio::buffer ( readMessage ), error_);
          result   += readMessage.data();
          end_of_transmission = result.find(END_OF_TRANSMISSION_TOKEN) != std::string::npos;
       }

       // find the end of the packet and resize the string to truncate 
       // any floating garbage in the message buffer.
       int idx = result.find("</command>");
       result = result.substr ( 0, idx+10 );

       // run requested command
       ExecuteRequest ( result );

       // send a response message back to the client.
       boost::asio::async_write (
             socket_,
             boost::asio::buffer ( message_ + "\n" ),
             boost::bind (
                &TcpConnection::handle_write,
                shared_from_this(),
                boost::asio::placeholders::error,
                boost::asio::placeholders::bytes_transferred
                )
             );
    }

private:
    gnuradar::command::CommandList& commands_;
    boost::system::error_code error_;
    tcp::socket socket_;
    std::string message_;

    void ExecuteRequest ( const std::string& message ) {

       try {

          // parse the received xml packet
          const xml::XmlPacketArgs args = xml::XmlPacket::Parse( message );

          xml::XmlPacketArgs::const_iterator iter = args.find( "name" );

          if( iter == args.end() )
          {
             throw std::runtime_error( 
                   "TcpConnection command name was not found");
          }

          const std::string commandName = iter->second;
          command::CommandPtr commandPtr = commands_.Find ( commandName );

          std::cout << "EXECUTE COMMAND: " << commandName << std::endl;

          // Execute the parsed command, passing in arguments, and 
          // receive response message on return.
          // These commands are all derived from GnuRadarCommand.
          message_ = commandPtr->Execute ( args );

       } catch ( std::exception& e ) {
          std::cerr << "Invalid command " << e.what() << std::endl;
       }

    }

    TcpConnection ( boost::asio::io_service& io_service,
          gnuradar::command::CommandList& commands ) :
       socket_ ( io_service ), commands_ ( commands ) {

       }

    void handle_write ( const boost::system::error_code&, size_t size ) { }
};
};
};

#endif
