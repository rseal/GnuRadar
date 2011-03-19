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
#include <map>
#include <ticpp/ticpp.h>
#include <boost/shared_ptr.hpp>
#include <boost/any.hpp>
#include <boost/algorithm/string.hpp>

namespace gnuradar{
   namespace xml{

      typedef std::map< std::string, std::string > XmlPacketArgs;

      struct XmlPacket
      {
         typedef boost::shared_ptr< ticpp::Node > NodePtr;
         NodePtr documentPtr_;
         NodePtr rootPtr_;

         public:

         XmlPacket( const std::string& sourceName )
         {

            documentPtr_ = NodePtr( new ticpp::Document() );
            rootPtr_ = NodePtr( new ticpp::Element( "command" ) );

            documentPtr_->InsertEndChild( *rootPtr_ );

            NodePtr sourcePtr = NodePtr( 
                  new ticpp::Element( "source" , sourceName ));

            rootPtr_->InsertEndChild( *sourcePtr );
         }


         static const XmlPacketArgs Parse( const std::string& xmlPacket ){

            XmlPacketArgs map;
            ticpp::Document document;
            document.Parse( xmlPacket,true );

            ticpp::Iterator< ticpp::Node > iter = 
               document.FirstChildElement("command")->FirstChildElement();

            while( iter != iter.end() ){

               ticpp::Element* element = iter->ToElement();
               map.insert( 
                     std::make_pair< std::string, std::string >( 
                        element->Value(), element->GetText()
                        ));
               ++iter;
            }

            return map;
         }

         /// Removes encoding use to transfer xml data inside an xml element.
         ///
         /// The networked gnuradarrun transmits an xml file embedded inside of 
         /// an xml element, and certain characters are not allowed in the element
         /// to avoid parser confusion. In our case, after we receive the file, 
         /// we need to decode the file back into its original xml format so that 
         /// the contents can be parsed to determine system configuration.
         static const std::string DecodeXml( const std::string& xmlPacket )
         {
            string result = xmlPacket;

            // these are all of the special characters defined by the 
            // XML standard.
            boost::replace_all( result, "&lt;", "<" );
            boost::replace_all( result, "&gt;", ">" );
            boost::replace_all( result, "&qout;", "\"" );
            boost::replace_all( result, "&apos;", "'" );
            boost::replace_all( result, "&amp;", "&" );

            return result;
         }

         const std::string Format( XmlPacketArgs map ){

            XmlPacketArgs::iterator iter = map.begin();

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
