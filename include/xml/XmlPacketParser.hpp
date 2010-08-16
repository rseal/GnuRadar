#ifndef XML_PACKET_PARSER
#define XML_PACKET_PARSER

#include <iostream>
#include <gnuradar/xml/XmlPacketPair.hpp>
#include <ticpp/ticpp.h>

namespace gnuradar{
   namespace xml{

      struct XmlPacketParser
      {
         public:

            XmlPacketParser( const std::string& xmlPacket )
            {
               ticpp::Document document;
               document.Parse( xmlPacket );

               ticpp::Iterator< ticpp::Node > iter = 
                  document.FirstChildElement("command")->FirstChildElement();

               while( iter != iter.end() ){
                  map_.insert( ParseXmlNode( iter.Get() ) );
                  ++iter;
               }
            }

            const XmlPacketMap& GetMap() { return map_; }

         private:

            XmlPacketMap map_;
      };
   };
};
#endif
