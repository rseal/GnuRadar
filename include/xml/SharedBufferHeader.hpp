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
#include <ticpp/ticpp.h>
#include <boost/shared_ptr.hpp>
#include <boost/lexical_cast.hpp>

namespace xml{

   struct SharedBufferHeader{

      typedef boost::shared_ptr< ticpp::Node > NodePtr;
      NodePtr document_;
      NodePtr root_;
      const std::string FILE_NAME;
      const int BUFFERS;
      const int BYTES;
      const int IPPS;
      const int SAMPLES;
      const float SAMPLE_RATE;
      const int CHANNELS;

      public:
      SharedBufferHeader( const int buffers, const int bytes, 
            const float sampleRate, const int channels, const int ipps,
            const int samples, const std::string& file=
            "/dev/shm/GnuRadarHeader.xml"):
         BUFFERS( buffers ), BYTES( bytes ), IPPS( ipps ), 
         SAMPLE_RATE( sampleRate ), CHANNELS( channels ), 
         SAMPLES( samples ), FILE_NAME( file )
      {
         document_ = NodePtr( new ticpp::Document() );

         NodePtr node( new ticpp::Declaration("1.0","","" ));
         document_->InsertEndChild( *node );

         root_ = NodePtr( new ticpp::Element( "gnuradar" ) );

         node = NodePtr( new ticpp::Element( "buffers", 
                  boost::lexical_cast<std::string>( BUFFERS )));
         root_->InsertEndChild( *node );

         node = NodePtr( new ticpp::Element( "bytes", 
               boost::lexical_cast<std::string>( BYTES ) ) );
         root_->InsertEndChild( *node );

         node = NodePtr( new ticpp::Element( "sample_rate", 
               boost::lexical_cast<std::string>( SAMPLE_RATE ) ) );
         root_->InsertEndChild( *node );

         node = NodePtr( new ticpp::Element( "channels", 
               boost::lexical_cast<std::string>( CHANNELS ) ) );
         root_->InsertEndChild( *node );

         node = NodePtr( new ticpp::Element( "ipps", 
                  boost::lexical_cast<std::string>( IPPS ) ) );
         root_->InsertEndChild( *node );

         node = NodePtr( new ticpp::Element( "samples", 
                  boost::lexical_cast<std::string>( SAMPLES ) ) );
         root_->InsertEndChild( *node );

         node = NodePtr( new ticpp::Element( "head", "0" ) );
         root_->InsertEndChild( *node ); 
         node = NodePtr( new ticpp::Element( "tail", "0" ) );
         root_->InsertEndChild( *node );
         node = NodePtr( new ticpp::Element( "depth", "0" ) );
         root_->InsertEndChild( *node );
      }

      void AddWindow( const std::string& name, const int start, const int stop)
      {
         NodePtr root( new ticpp::Element( "rx_win" ) );
         NodePtr node( new ticpp::Element( "name", name ) );
         root->InsertEndChild( *node );
         node = NodePtr(new ticpp::Element( "start", 
                  boost::lexical_cast<std::string>(start) ) );
         root->InsertEndChild( *node );
         node = NodePtr(new ticpp::Element( "stop", 
                  boost::lexical_cast<std::string>(stop) ) );
         root->InsertEndChild( *node );
         root_->InsertEndChild( *root );
      }

      void Close()
      {
         ticpp::Document* document = document_->ToDocument();
         document->InsertEndChild( *root_ );
         document->SaveFile( FILE_NAME );
      }

      void Update( const int head, const int tail, const int depth )
      {
         // create updated nodes for replacement in existing file.
         NodePtr headPtr( new ticpp::Element("head", 
                  boost::lexical_cast<std::string>(head)));
         NodePtr tailPtr( new ticpp::Element("tail", 
                  boost::lexical_cast<std::string>(tail)));
         NodePtr depthPtr( new ticpp::Element("depth", 
                  boost::lexical_cast<std::string>(depth)));

         // load existing file since we're updating a few fields.
         ticpp::Document document( FILE_NAME );
         document.LoadFile();
         
         // get the root node
         ticpp::Node* root = document.FirstChildElement("gnuradar");

         // update children
         root->ReplaceChild( root->FirstChildElement("head"), *headPtr );
         root->ReplaceChild( root->FirstChildElement("tail"), *tailPtr );
         root->ReplaceChild( root->FirstChildElement("depth"), *depthPtr );

         document.SaveFile( FILE_NAME );
      }
   };
};

#endif

