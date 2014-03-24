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
#ifndef VERIFY_HPP
#define VERIFY_HPP

#include <vector>
#include <utils/GrHelper.hpp>
#include <GnuRadarCommand.hpp>
#include <commands/Response.pb.h>
#include <SystemValidation.hpp>

namespace gnuradar {
	namespace command {

		class Verify : public GnuRadarCommand {

			typedef std::vector<gnuradar::iq_t> Buffer;
			typedef Buffer::iterator BufferIterator;

			public:

			Verify(): GnuRadarCommand( "verify" ){ }

			virtual const gnuradar::ResponseMessage Execute( gnuradar::ControlMessage& msg )
			{

				Buffer buffer;

				gnuradar::ResponseMessage response_msg;

				gnuradar::File* file = msg.mutable_file();

				// standardizes units of input file.
				gr_helper::FormatFileFromMessage( file );

				gnuradar::RadarParameters* rp = file->mutable_radarparameters();

				// buffer one second's worth of data
				buffer.resize ( rp->bytespersecond() / sizeof ( gnuradar::iq_t ) );
				void* bufferPtr = &buffer[0];

				try
				{

					// set require gnuradar settings.
					GnuRadarSettings settings;

					settings.numChannels    = file->numchannels();
					settings.decimationRate = file->decimation();
					settings.fpgaFileName   = file->fpgaimage();
					settings.fUsbBlockSize  = 0;
					settings.fUsbNblocks    = 0;
					settings.mux            = 0xf3f2f1f0;

					for ( int i = 0; i < file->numchannels(); ++i ) {
						gnuradar::Channel* channel = file->mutable_channel(i);
						settings.Tune ( i, channel->frequency() );
						settings.Phase ( i, channel->phase() );
					}

					// create a USRP object.
					usrp_standard_rx_sptr usrp = usrp_standard_rx::make (
							settings.whichBoard,
							settings.decimationRate,
							settings.numChannels,
							settings.mux,
							settings.mode,
							settings.fUsbBlockSize,
							settings.fUsbNblocks,
							settings.fpgaFileName,
							settings.firmwareFileName
							);

					//check to see if device is connected
					if ( usrp.get() == 0 ) {
						throw std::runtime_error (
								"GnuRadarVerify: No USRP device found - please check your "
								"connections.\n"
								);
					}

					// setup frequency and phase for each ddc
					for ( int i = 0; i < settings.numChannels; ++i ) {
						usrp->set_rx_freq ( i, settings.Tune ( i ) );
						usrp->set_ddc_phase ( i, 0 );
					}

					//set all gain to 0dB by default
					for ( unsigned int i = 0; i < gnuradar::USRP_MAX_CHANNELS; ++i )
						usrp->set_pga ( i, 0 );

					// initialize data collection and flush FX2 buffer.
					usrp->start();
					bool over_flow;
					usrp->read ( bufferPtr, gnuradar::FX2_FLUSH_FIFO_SIZE_BYTES, &over_flow );

					// resize buffer aligned on required byte boundary - 512 bytes
					int byteRequest = rp->bytespersecond();
					int alignedBytes = byteRequest % gnuradar::BUFFER_ALIGNMENT_SIZE_BYTES;
					int alignedByteRequest = byteRequest - alignedBytes;
					buffer.resize ( alignedByteRequest / sizeof ( gnuradar::iq_t ) );

					//read data from USRP
					int bytesRead = usrp->read ( bufferPtr, alignedByteRequest, &over_flow);

					usrp->stop();

					if ( bytesRead != alignedByteRequest ) {
						throw std::runtime_error (
								"GnuRadarVerify: Number of bytes read is not equal to the "
								"number of requested bytes.\n Expected " +
								lexical_cast<string> ( alignedByteRequest ) + " Found " +
								lexical_cast<string> ( bytesRead )  + "\n"
								);
					}

					int stride = file->numchannels() * 2;

					Buffer channelBuffer ( buffer.size() / stride );
					BufferIterator bufferIter = buffer.begin();
					BufferIterator channelBufferIter = channelBuffer.begin();

					while ( bufferIter != buffer.end() ) {
						*channelBufferIter = *bufferIter;
						bufferIter += stride ;
						++channelBufferIter;
					}

					// validate collected window sizes with those in configuration file.
					SystemValidation validator;
					bool valid = validator.Validate ( channelBuffer, file );

					if( !valid )
					{
						throw std::runtime_error( validator.GetResults() );
					}

				   std::cout << "HERE" << std::endl;

					// create a response packet and return to requester
					response_msg.set_value(gnuradar::ResponseMessage::OK);
					response_msg.set_message("Configuration Verified.");

				   std::cout << "HERE" << std::endl;

				}
				catch( std::runtime_error& e ){

					response_msg.set_value(gnuradar::ResponseMessage::ERROR);
					response_msg.set_message(e.what());

				}

				return response_msg;
			}
		};
	};
};

#endif
