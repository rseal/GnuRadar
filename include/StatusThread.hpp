
#ifndef STATUS_THREAD_HPP
#define STATUS_THREAD_HPP

#include <stdexcept>
#include <ticpp/ticpp.h>
#include <gnuradar/Constants.hpp>
#include <gnuradar/ProducerConsumerModel.h>
#include <gnuradar/xml/XmlPacket.hpp>
#include <gnuradar/SThread.h>
#include <boost/asio.hpp>
#include <boost/shared_ptr.hpp>
#include <iostream>

namespace gnuradar 
{

   /// <summary>
   /// Multicasts server status using a configurable ip address and port. 
   /// </summary>
class StatusThread: public thread::SThread
	{
		static const int REFRESH_RATE_MSEC = 1000;
		bool running_;

		typedef boost::shared_ptr< ProducerConsumerModel > PcModelPtr;
		typedef boost::asio::ip::udp::endpoint EndPoint;
		typedef boost::asio::ip::udp::socket UdpSocket;
		typedef boost::asio::io_service IoService;
		typedef boost::asio::ip::address IpAddress;
		typedef boost::shared_ptr< UdpSocket > UdpSocketPtr;

		PcModelPtr pcModel_;
		UdpSocketPtr socket_;
		EndPoint endPoint_;

		/// <summary>
		/// Generate a status packet for transmission back to listening clients.
		/// </summary>
		const std::string CreateStatusPacket()
		{
			// Create arguments containing system status. This will be sent back 
			// to any subscribers.
			xml::XmlPacketArgs args;
			args["destination"]      = "status_listener";
			args["type"]             = "";
			args["num_buffers"]      = boost::lexical_cast<std::string>( pcModel_->NumBuffers() );
			args["value"]            = "OK";
			args["head"]             = boost::lexical_cast<std::string>( pcModel_->Head() );
			args["tail"]             = boost::lexical_cast<std::string>( pcModel_->Tail() );
			args["depth"]            = boost::lexical_cast<std::string>( pcModel_->Depth() );
			args["over_flow"]        = boost::lexical_cast<std::string>( pcModel_->OverFlow() );
			args["bytes_per_buffer"] = boost::lexical_cast<std::string>( pcModel_->BytesPerBuffer() );

			// Create an xml packet for transmission.
			gnuradar::xml::XmlPacket packet("gnuradar_server");

			// Format the arguments into xml and return the entire message as a string.
			const std::string response = packet.Format( args );

			return response;
		}

		void ReadConfigurationFile()
		{
			ticpp::Document doc( gnuradar::constants::SERVER_CONFIGURATION_FILE );

			try
			{

				// parse file.
				doc.LoadFile();

				// parse multicast port from file.
				std::string port_str = doc.FirstChildElement("multicast_port")->GetText();
				int port = boost::lexical_cast<int>( port_str );

				// parse multicast ip address from file.
				std::string ip_str = doc.FirstChildElement("multicast_address")->GetText();
				IpAddress ip_address = IpAddress::from_string( ip_str );

				// create socket endpoint.
				endPoint_ = EndPoint( ip_address, port );

			}
			catch( ticpp::Exception& e ) 
			{
				std::cout << e.what();
			}
		}

		public:

		/// Constructor
		StatusThread ( IoService& ioService, PcModelPtr pcModel ) : pcModel_( pcModel )
		{
			// Configure multicast address and port to send udp packets.
			ReadConfigurationFile();

			socket_ = UdpSocketPtr( new UdpSocket( ioService, endPoint_.protocol() ) );

		}

		virtual void Run()
		{
			running_ = true;

			while( running_ )
			{ 
				// generate status message.
				std::string message = CreateStatusPacket();

				// Send UDP packet to multicast endpoint.
				socket_->send_to( boost::asio::buffer( message ), endPoint_ );

				// sleep and repeat.
				this->Sleep( REFRESH_RATE_MSEC );
			}
		}

		void Stop()
		{
			if( !running ) return;

			running_ = false;
			this->Wait();
		}

	};
};

#endif
