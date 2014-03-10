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
      typedef boost::shared_ptr<YAML::Node> NodePtr;
      WindowVec windows_;

      const std::string FILE_NAME;
      const int BUFFERS;
      const int BYTES;
      const int IPPS;
      const int SAMPLES;
      const float SAMPLE_RATE;
      const int CHANNELS;

      NodePtr node_;
      

      void CreateEmitter(int head, int tail, int depth)
      {
         node_ = NodePtr( new YAML::Node() );
         (*node_)["head"]=head;
         (*node_)["tail"]=tail;
         (*node_)["depth"]=BUFFERS;
         (*node_)["bytes"]=SAMPLE_RATE;
         (*node_)["channels"]=CHANNELS;
         (*node_)["ipps"]=IPPS;
         (*node_)["samples"]=SAMPLES;
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

         for( int i=0; i<windows_.size(); ++i)
         {
            YAML::Node node;
            node["name"] = windows_[i].name;
            node["start"] = windows_[i].start;
            node["stop"] = windows_[i].stop;

            (*node_)["rx_win"].push_back(node);
         }

         std::ofstream fout( FILE_NAME.c_str());
         fout << (*node_);
         fout.close();

      }
   };
};

#endif

