#include <gnuradar/xml/SharedBufferHeader.hpp>
#include <boost/filesystem.hpp>
#include <fstream>

int main() 
{
   const int BUFFERS = 20;
   const int IPPS = 250;
   const int SAMPLES = 2000;
   const int BYTES = IPPS*SAMPLES*2;
   const std::string FILE="test.xml";

   std::ofstream out("gnuradar.lock");
   out.close();
   xml::SharedBufferHeader header( BUFFERS, BYTES, IPPS, SAMPLES, FILE);
   header.AddWindow("window0", 100, 200 );
   header.AddWindow("window1", 200, 2000 );
   header.Close();
   header.Update(5, 1, 4);
   //boost::filesystem::remove_all( "gnuradar.lock");


   return EXIT_SUCCESS;
}
