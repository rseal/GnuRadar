#ifndef GR_HELPER_HPP
#define GR_HELPER_HPP

#include<fstream>
#include<boost/filesystem.hpp>
#include<yaml-cpp/yaml.h>
#include<gnuradar/Constants.hpp>
#include<gnuradar/commands/Control.pb.h>
#include<hdf5r/HDF5.hpp>

namespace gr_helper{

   /////////////////////////////////////////////////////////////////////////////
   /////////////////////////////////////////////////////////////////////////////
   std::string GetIpAddress(const std::string& networkType )
   {
      std::string ip_addr;

      try{
         std::ifstream fin( gnuradar::constants::SERVER_CONFIGURATION_FILE.c_str() );
         YAML::Parser parser(fin);
         YAML::Node doc;
         parser.GetNextDocument(doc);
         doc[networkType]  >> ip_addr;
      }
      catch( YAML::ParserException& e ) 
      {
         std::cerr << e.what();
      }

      return ip_addr;
   };


   /////////////////////////////////////////////////////////////////////////////
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

   void FormatFileFromMessage( gnuradar::File* file )
   {
      const int BYTES_PER_SAMPLE=4;
      const double SECONDS_PER_BUFFER=1.0;
      int sum=0;

      Units units;

      // convert units
      file->set_samplerate( file->samplerate() * 1e6);
      file->set_outputrate( file->samplerate() / file->decimation());
      file->set_ipp( file->ipp() * units(file->ippunits()).multiplier);
      file->set_bandwidth( file->bandwidth() * units(file->bandwidthunits()).multiplier);
      file->set_txcarrier( file->txcarrier() * 1e6);

      for ( int i = 0; i < file->channel_size(); ++i ) {
         gnuradar::Channel* channel = file->mutable_channel(i);
         channel->set_frequency( channel->frequency() * 
               units(channel->frequencyunits()).multiplier);
         channel->set_phase( channel->phase() * 
               units(channel->phaseunits()).multiplier);
      }

      for ( int i = 0; i < file->window_size(); ++i ) {
         gnuradar::Window* window = file->mutable_window(i);
         UnitType u = units(window->units());
         double multiplier = u.units == "samples" ? 1e0 : u.multiplier*file->outputrate();
         window->set_start( window->start() * multiplier);
         window->set_stop( window->stop() * multiplier);
         sum += ceil(window->stop()-window->start());
      }

      gnuradar::RadarParameters* rp = file->mutable_radarparameters();
      rp->set_samplesperpri( sum );
      rp->set_pri( file->ipp() );
      rp->set_prf( 1.0/rp->pri() );
      rp->set_bytespersample( BYTES_PER_SAMPLE );
      rp->set_secondsperbuffer( SECONDS_PER_BUFFER );
      rp->set_samplesperbuffer( Round(rp->prf()*rp->samplesperpri()) );
      rp->set_prisperbuffer( Round(rp->samplesperbuffer()/rp->samplesperpri()) );
      rp->set_bytesperbuffer( Round(rp->samplesperbuffer()*rp->bytespersample()) );
      rp->set_bytespersecond( Round(rp->bytesperbuffer()/rp->secondsperbuffer()) );

   }
};

#endif
