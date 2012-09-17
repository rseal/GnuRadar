// Copyright (c) 2012 Ryan Seal <rlseal -at- gmail.com>
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
#ifndef SHARED_BUFFER_HEADER_HPP
#define SHARED_BUFFER_HEADER_HPP

#include <iostream>
#include <fstream>
#include <boost/shared_ptr.hpp>
#include <boost/lexical_cast.hpp>
#include<boost/tokenizer.hpp>
#include<boost/foreach.hpp>
#include<yaml-cpp/yaml.h>

namespace yml{

   struct RxWindow{
      std::string name;
      double start;
      double stop;
   };

   struct SharedBufferHeader{

      typedef std::vector<RxWindow> WindowVec;
      typedef boost::shared_ptr<YAML::Emitter> EmitterPtr;
      WindowVec windows_;

      const std::string FILE_NAME;
      const int BUFFERS;
      const int BYTES;
      const int IPPS;
      const int SAMPLES;
      const float SAMPLE_RATE;
      const int CHANNELS;

      EmitterPtr emitter_;
      

      void CreateEmitter(int head, int tail, int depth)
      {
         emitter_.reset();
         emitter_ = EmitterPtr( new YAML::Emitter() );
         *emitter_ << YAML::BeginMap;
         *emitter_ << YAML::Key << "head"        << YAML::Value << head;
         *emitter_ << YAML::Key << "tail"        << YAML::Value << tail;
         *emitter_ << YAML::Key << "depth"       << YAML::Value << depth;
         *emitter_ << YAML::Key << "buffers"     << YAML::Value << BUFFERS;
         *emitter_ << YAML::Key << "bytes"       << YAML::Value << BYTES;
         *emitter_ << YAML::Key << "sample_rate" << YAML::Value << SAMPLE_RATE;
         *emitter_ << YAML::Key << "channels"    << YAML::Value << CHANNELS;
         *emitter_ << YAML::Key << "ipps"        << YAML::Value << IPPS;
         *emitter_ << YAML::Key << "samples"     << YAML::Value << SAMPLES;
      }

      public:
      SharedBufferHeader( const int buffers, const int bytes, 
            const float sampleRate, const int channels, const int ipps,
            const int samples, const std::string& file= "/dev/shm/GnuRadarHeader.yml"):
         BUFFERS( buffers ), BYTES( bytes ), IPPS( ipps ), 
         SAMPLE_RATE( sampleRate ), CHANNELS( channels ), 
         SAMPLES( samples ), FILE_NAME( file )
         { }

      void AddWindow( const std::string& name, const int start, const int stop)
      {
         RxWindow window;
         window.name  = name;
         window.start = start;
         window.stop  = stop;
         windows_.push_back( window );
      }

      void Write(int head, int tail, int depth)
      {
         CreateEmitter(head,tail,depth);

         *emitter_ << YAML::Key << "rx_win";
         *emitter_ << YAML::Value << YAML::BeginSeq;

         for( int i=0; i<windows_.size(); ++i)
         {
            *emitter_ << YAML::BeginMap;
            *emitter_ << YAML::Key << "name";
            *emitter_ << YAML::Value << windows_[i].name;
            *emitter_ << YAML::Key << "start";
            *emitter_ << YAML::Value << windows_[i].start;
            *emitter_ << YAML::Key << "stop";
            *emitter_ << YAML::Value << windows_[i].stop;
            *emitter_ << YAML::EndMap;
         }
         *emitter_ << YAML::EndSeq;
         *emitter_ << YAML::EndMap;

         std::ofstream fout( FILE_NAME.c_str());
         fout << emitter_->c_str();
         fout.close();

      }
   };
};

#endif

