#ifndef GR_HELPER_HPP
#define GR_HELPER_HPP

#include <iostream>
#include<fstream>
#include<boost/filesystem.hpp>
#include<yaml-cpp/yaml.h>
#include <Units.h>
#include <Constants.hpp>
#include <commands/Control.pb.h>
#include <HDF5.hpp>

namespace gr_helper{

   /////////////////////////////////////////////////////////////////////////////
   /// Parses ip address from network configuration file
   /////////////////////////////////////////////////////////////////////////////
   std::string GetIpAddress(const std::string& networkType )
   {
      std::string ip_addr;

      try{
         YAML::Node node = YAML::LoadFile(gnuradar::constants::SERVER_CONFIGURATION_FILE);
         ip_addr = node[networkType].as<std::string>();
      }
      catch( YAML::ParserException& e ) 
      {
         std::cerr << e.what();
      }

      return ip_addr;
   };


   /////////////////////////////////////////////////////////////////////////////
   /// Checks for existing hdf5 file.
   /////////////////////////////////////////////////////////////////////////////
   bool HdfFileExists ( const std::string& fileSet )
   {
      std::string fileName = fileSet + "." + hdf5::FILE_EXT;
      boost::filesystem::path file ( fileName );
      return boost::filesystem::exists ( file );
   }

   int Round( double x)
   {
      return static_cast<int>(floor( x + 0.5 ));
   }

   /////////////////////////////////////////////////////////////////////////////
   /// Standardizes units in configuration file
   /////////////////////////////////////////////////////////////////////////////
   void FormatFileFromMessage( gnuradar::File* file )
   {
      const int BYTES_PER_SAMPLE=4;
      const double SECONDS_PER_BUFFER=1.0;
      int total_samples =0;

      // create unit converter object
      Units units;

      // sample rate in Hz
      const double sample_rate_hz = file->samplerate()*1e6;
      const double output_rate_hz = sample_rate_hz / file->decimation();
      const double pri_sec = file->pri() * units(file->priunits()).multiplier;
      const double bandwidth_hz = file->bandwidth() * units(file->bandwidthunits()).multiplier;
      const double txcarrier_hz = file->txcarrier()*1e6;
      const unsigned int num_channels = file->numchannels();

      // assign standardized units to file
      file->set_samplerate(sample_rate_hz);
      file->set_outputrate(output_rate_hz);
      file->set_pri(pri_sec);
      file->set_bandwidth(bandwidth_hz);
      file->set_txcarrier(txcarrier_hz);

      for ( unsigned int i = 0; i < num_channels; ++i ) {

         gnuradar::Channel* channel = file->mutable_channel(i);

         const double frequency_hz = channel->frequency() * units(channel->frequencyunits()).multiplier;
         const double phase_deg = channel->frequency() * units(channel->frequencyunits()).multiplier;

         // assign standardize units to each channel
         channel->set_frequency(frequency_hz);
         channel->set_phase(phase_deg);
      }

      for ( int i = 0; i < file->window_size(); ++i ) {

         // get pointer to window definition
         gnuradar::Window* window = file->mutable_window(i);

         // get the units provided by the user
         UnitType u = units(window->units());

         // convert units to samples 
         const double multiplier = u.units == "samples" ? 1e0 : u.multiplier*file->outputrate();
         const double window_start_samples = window->start() * multiplier;
         const double window_stop_samples = window->stop() * multiplier;

         // assign window size with units in samples
         window->set_start(window_start_samples);
         window->set_stop(window_stop_samples);

         // keep track of the total number of samples
         total_samples += ceil(window_stop_samples - window_start_samples);
      }

      // get pointer to radar parameters
      gnuradar::RadarParameters* rp = file->mutable_radarparameters();

      rp->set_pri( file->pri() );
      rp->set_prf( Round( 1.0/rp->pri() ) );
      rp->set_bytespersample   ( BYTES_PER_SAMPLE   );
      rp->set_secondsperbuffer ( SECONDS_PER_BUFFER );

      // total samples is receive window samples x number of channels
      rp->set_samplesperpri( total_samples * num_channels);

      // total samples per buffer is PRI_PER_BUFFER * SAMPLES_PER_PRI
      // In the case PRI_PER_BUFFER = PRF since we maintain fixed one-second
      // buffer sizes
      rp->set_samplesperbuffer ( rp->prf() *rp->samplesperpri() );

      // PRI_PER_BUFFER = PRF because of one-second buffer size
      rp->set_prisperbuffer    ( rp->prf() );

      // Each sample is 4 bytes
      rp->set_bytesperbuffer   ( rp->samplesperbuffer() *rp->bytespersample());

      // Fixed one-second buffer => BYTES_PER_BUFFER = BYTES_PER_SECOND
      rp->set_bytespersecond   ( rp->bytesperbuffer() /rp->secondsperbuffer());

      //std::cout << "      num channels : " << num_channels           << std::endl;
      //std::cout << "               pri : " << file->pri()            << std::endl;
      //std::cout << "   samples per pri : " << total_samples          << std::endl;
      //std::cout << "samples per buffer : " << rp->samplesperbuffer() << std::endl;
      //std::cout << "    pri per buffer : " << rp->prisperbuffer()    << std::endl;
      //std::cout << "  bytes per buffer : " << rp->bytesperbuffer()   << std::endl;
      //std::cout << "  bytes per second : " << rp->bytespersecond()   << std::endl;

   }
};

#endif
