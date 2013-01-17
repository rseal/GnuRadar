#include<gnuradar/yaml/SharedBufferHeader.hpp>

int main()
{
   // buffers/bytes/sampleRate/channels/ipps/samples
   yml::SharedBufferHeader header(10,1024,64e6,1,1000,333);
   header.AddWindow("rx1", 100, 200);
   header.AddWindow("rx2", 400, 500);
   header.AddWindow("rx3", 500, 600);
   header.Write(0,0,0);
   header.Write(1,2,1);
   header.Write(2,3,4);
   header.Write(200,3000,400);
   return 0;
}
