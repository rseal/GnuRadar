#include <ticpp/ticpp.h>
#include <cstdlib>
#include <utility>
#include <map>
#include <boost/any.hpp>

#include <gnuradar/xml/XmlPacket.hpp>

using namespace std;


// main entry point
int main()
{
   // create packet map to store the parsed packet
   gnuradar::xml::XmlPacketArgs map;

   // create an XmlPacket object and populate
   gnuradar::xml::XmlPacket packet( "command", "ticpp_test");
   map["destination"] = "server_test";
   map["type"] = "control";
   map["name"] = "start";
   map["file_name"] = "/usr/local/GnuRadar/config/HomeTest.ucf";

   // convert the XmlPacket into a string representation
   string xmlString = packet.Format( map );

   // construct a map from an xml string 
   map = gnuradar::xml::XmlPacket::Parse( xmlString );

   cout << "xml packet = " << xmlString << endl;

   // iterate through map and print key/value pairs
   gnuradar::xml::XmlPacketArgs::iterator iter = map.begin();
   while( iter != map.end() )
   {
      cout 
         << iter->first << " = "
         << boost::any_cast<std::string>(iter->second) 
         << endl;

      ++iter;
   }

   return EXIT_SUCCESS;
}
