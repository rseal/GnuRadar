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

static const int MESSAGE_SIZE_BYTES = 512;

class TcpConnection : public boost::enable_shared_from_this<TcpConnection> {

public:
    typedef boost::shared_ptr<TcpConnection> pointer;
    typedef boost::array< char, MESSAGE_SIZE_BYTES > Message;

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
        Message readMessage;
        std::string result;

        // read incoming message
        size_t readSize = socket_.read_some (
                              boost::asio::buffer ( readMessage ),
                              error_
                          );

        // resize to match actual received message length
        result = readMessage.data();
        result = result.substr ( 0, readSize );

        // run requested command
        ExecuteRequest ( result );

        std::cout << "sending message " << message_ << " from server " 
           << std::endl;

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

        std::cout << "message sent from server " << std::endl;
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
           message_ = commandPtr->Execute ( args );

        } catch ( std::exception& e ) {
            std::cerr
                << "Invalid command " << e.what() 
                << std::endl;
        }

    }


    TcpConnection ( boost::asio::io_service& io_service,
                    gnuradar::command::CommandList& commands ) :
            socket_ ( io_service ), commands_ ( commands ) { }

    void handle_write ( const boost::system::error_code&, size_t size ) { }
};
};
};

#endif
