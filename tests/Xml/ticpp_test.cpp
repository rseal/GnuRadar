#include <ticpp/ticpp.h>
#include <cstdlib>
#include <utility>
#include <map>
#include <boost/any.hpp>

#include <gnuradar/xml/XmlPacketPair.hpp>
#include <gnuradar/xml/XmlPacketParser.hpp>

using namespace std;


// main entry point
int main()
{
   // create packet map to store the parsed packet
   gnuradar::xml::XmlPacketMap map;

   // create a sample command packet
   string xmlPacket = "<command>\n" 
      "   <source>gradar-run</source>\n" 
      "   <destination>gradar-run-daemon</destination>\n" 
      "   <type>control</type>\n"  
      "   <name>start</name>\n"  
      "   <args>1,2,3,4,5,6</args>\n" 
      "</command>\n";

   // parse the xml packet
   gnuradar::xml::XmlPacketParser packetParser( xmlPacket );

   // throws when after reading last available node
   map = packetParser.GetMap();

   // iterate through map and print key/value pairs
   gnuradar::xml::XmlPacketMap::iterator iter = map.begin();
   while( iter != map.end() )
   {
      cout 
         << "( " << iter->first << " ),( "
         << boost::any_cast<std::string>(iter->second) << " )"
         << endl;

      ++iter;
   }

   return EXIT_SUCCESS;
}
