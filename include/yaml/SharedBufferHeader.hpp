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

   ///////////////////////////////////////////////////////////////////////////
   ///
   ///////////////////////////////////////////////////////////////////////////
   struct RxWindow{
      std::string name;
      double start;
      double stop;
   };

   ///////////////////////////////////////////////////////////////////////////
   ///
   ///////////////////////////////////////////////////////////////////////////
   struct SharedBufferHeader{

      private:

      typedef std::vector<RxWindow> RxWindowVector;
      typedef boost::shared_ptr<YAML::Node> NodePtr;

      const int numBuffers_;
      const int bytesPerBuffer_;
      const int pri_;
      const float sampleRate_;
      const int numChannels_;
      const int samplesPerBuffer_;
      const std::string bufferFileName_;
      RxWindowVector windows_;

      ////////////////////////////////////////////////////////////////////////
      ///
      ////////////////////////////////////////////////////////////////////////
      void CreateEmitter(NodePtr nodePtr, int head, int tail, int depth)
      {
         (*nodePtr)["head"]        = head;
         (*nodePtr)["tail"]        = tail;
         (*nodePtr)["depth"]       = depth;
         (*nodePtr)["buffers"]     = numBuffers_;
         (*nodePtr)["bytes"]       = bytesPerBuffer_;
         (*nodePtr)["sample_rate"] = sampleRate_;
         (*nodePtr)["channels"]    = numChannels_;
         (*nodePtr)["ipps"]        = pri_;
         (*nodePtr)["samples"]     = samplesPerBuffer_;
      }

      public:

      ////////////////////////////////////////////////////////////////////////
      ///
      ////////////////////////////////////////////////////////////////////////
      SharedBufferHeader( 
            const int buffers     ,
            const int bytes       ,
            const float sampleRate,
            const int channels    ,
            const int pri         ,
            const int samples     ,
            const std::string file= "/dev/shm/GnuRadarHeader.yml"
            ):
         numBuffers_( buffers ), bytesPerBuffer_( bytes ), pri_( pri ), 
         sampleRate_( sampleRate ), numChannels_( channels ), 
         samplesPerBuffer_( samples ), bufferFileName_( file )
      { }

      ////////////////////////////////////////////////////////////////////////
      ///
      ////////////////////////////////////////////////////////////////////////
      void AddWindow( const std::string& name, const int start, const int stop)
      {
         RxWindow window;
         window.name  = name;
         window.start = start;
         window.stop  = stop;
         windows_.push_back( window );
      }

      ////////////////////////////////////////////////////////////////////////
      ///
      ////////////////////////////////////////////////////////////////////////
      void Write(int head, int tail, int depth)
      {
         NodePtr root_node = NodePtr( new YAML::Node());

         CreateEmitter(root_node,head,tail,depth);

         for( unsigned int i=0; i<windows_.size(); ++i)
         {
            YAML::Node node;

            node["name"]  = windows_[i].name;
            node["start"] = windows_[i].start;
            node["stop"]  = windows_[i].stop;

            (*root_node)["rx_win"].push_back(node);
         }

         std::ofstream fout( bufferFileName_.c_str());
         fout << *root_node;
         fout.close();

      }
   };
};

#endif

