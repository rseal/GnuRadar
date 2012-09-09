#include <boost/shared_ptr.hpp>
#include "RequestServer.hpp"
#include <zmq.hpp>

using namespace gnuradar::network;
int main()
{
   typedef boost::shared_ptr<RequestServer> RequestServerPtr;

   zmq::context_t ctx(1);
   std::string ip_address = "tcp://*:5555";
   
   RequestServerPtr server( new RequestServer(ctx, ip_address));
   server->Start();
   server->Wait();

   return 0;
}
