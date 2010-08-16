#ifndef GNURADAR_TCP_REQUEST_CONNECTION_HPP
#define GNURADAR_TCP_REQUEST_CONNECTION_HPP

#include <boost/enable_shared_from_this.hpp>
#include <boost/bind.hpp>
#include <boost/asio.hpp>
#include <boost/array.hpp>

using boost::asio::ip::tcp;

namespace gnuradar{
   namespace network{

      static const int MESSAGE_SIZE_BYTES = 512;

      class TcpConnection
         : public boost::enable_shared_from_this<TcpConnection>
      {
         public:
            typedef boost::shared_ptr<TcpConnection> pointer;
            typedef boost::array< char, MESSAGE_SIZE_BYTES > Message;
            typedef std::map< std::string, std::string > MessageMap;

            // create and return a shared pointer to this
            static pointer create(boost::asio::io_service& io_service,
                  MessageMap& map)
            {
               return pointer( 
                     new TcpConnection(io_service, map) );
            }

            // return the connection's socket
            tcp::socket& socket()
            {
               return socket_;
            }

            // run thread
            void start()
            {
               Message readMessage;
               std::string result;

               size_t readSize = socket_.read_some( 
                     boost::asio::buffer( readMessage ),
                     error_
                     );

               result = readMessage.data();
               result = result.substr(0,readSize);

               ExecuteRequest( result );

               //std::cout << "message is " << message_ << std::endl;


               boost::asio::async_write(
                     socket_, 
                     boost::asio::buffer(message_),
                     boost::bind(
                        &TcpConnection::handle_write, 
                        shared_from_this(),
                        boost::asio::placeholders::error,
                        boost::asio::placeholders::bytes_transferred
                        )
                     );
            }

         private:
            MessageMap& map_;
            boost::system::error_code error_;
            tcp::socket socket_;
            std::string message_;

            void ExecuteRequest( std::string& message )
            {

               // TODO: Add XML parser here and pass in XML structure

               MessageMap::iterator iter = map_.find( message );

               if( iter != map_.end() ) message_ = iter->second;
               else
                  throw std::runtime_error( 
                        "TcpConnection: invalid Message request" );
            }


            TcpConnection(
                  boost::asio::io_service& io_service, MessageMap& map)
               : socket_(io_service), map_(map) { }

            void handle_write(const boost::system::error_code&, size_t size) { }
      };
   };
};

#endif
