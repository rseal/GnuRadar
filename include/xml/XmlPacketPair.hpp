#ifndef XML_PACKET_PAIR_HPP
#define XML_PACKET_PAIR_HPP

#include <map>
#include <iostream>
#include <boost/any.hpp>

namespace gnuradar{
   namespace xml{

      // define map of xml packet map
      typedef std::map< std::string, boost::any > XmlPacketMap;
      typedef std::pair<std::string, boost::any> XmlPacketPair;

      // compact way to parse an xml packet with the ability 
      // to generically cast its value.
      static XmlPacketPair ParseXmlNode( ticpp::Node* node )
      {
         return std::make_pair<std::string,boost::any>(
               node->Value(),
               boost::any(node->ToElement()->GetText())
               );
      }

   };
};

#endif

