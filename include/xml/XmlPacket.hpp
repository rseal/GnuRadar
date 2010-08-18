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
