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
#ifndef XML_PACKET_HPP
#define XML_PACKET_HPP

#include <iostream>
#include <sstream>
#include <ticpp/ticpp.h>
#include <boost/shared_ptr.hpp>

namespace gnuradar{
   namespace xml{

      typedef std::map< std::string, std::string > XmlPacketMap;

      struct XmlPacket
      {
         typedef boost::shared_ptr< ticpp::Node > NodePtr;
         NodePtr documentPtr_;
         NodePtr rootPtr_;

         public:

         XmlPacket( const std::string& rootName, 
               const std::string& sourceName )
         {

            documentPtr_ = NodePtr( new ticpp::Document() );
            rootPtr_ = NodePtr( new ticpp::Element( rootName ) );

            documentPtr_->InsertEndChild( *rootPtr_ );

            NodePtr sourcePtr = NodePtr( 
                  new ticpp::Element( "source" , sourceName ));

            rootPtr_->InsertEndChild( *sourcePtr );
         }


         static const XmlPacketMap Parse( std::string& xmlPacket ){

            XmlPacketMap map;
            ticpp::Document document;
            document.Parse( xmlPacket );

            ticpp::Iterator< ticpp::Node > iter = 
               document.FirstChildElement("command")->FirstChildElement();

            while( iter != iter.end() ){

               ticpp::Element* element = iter->ToElement();
               map.insert( 
                     std::make_pair< std::string, std::string >( 
                        element->Value(), element->GetText()
                        ));
               //ParseXmlNode( iter.Get() ) );
               ++iter;
            }

            return map;
         }

         const std::string Format( XmlPacketMap map ){

            XmlPacketMap::iterator iter = map.begin();

            while( iter != map.end() )
            {
               NodePtr nodePtr = NodePtr( new ticpp::Element( iter->first , 
                        boost::any_cast<std::string>(iter->second) ));
               rootPtr_->InsertEndChild( *nodePtr );
               ++iter;
            }

            // write stream to string
            std::ostringstream ostr;
            ostr << *rootPtr_;

            return ostr.str();
         }
      };
   };
};
#endif
