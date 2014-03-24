#include <string>
#include <iostream>
#include <zmq.hpp>
#include <boost/lexical_cast.hpp>
#include <google/protobuf/message.h>
#include <commands/Control.pb.h>
#include <commands/Response.pb.h>

int main ()
{
    gnuradar::ControlMessage ctrl_message;
    std::string serial_msg;

    const std::string server_ip = "tcp://localhost:54321";

    // Prepare our context and socket
    zmq::context_t context (1);
    zmq::socket_t socket (context, ZMQ_REQ);

    std::cout << "Connecting to server..." << std::endl;
    socket.connect (server_ip.c_str());

    // Do 10 requests, waiting each time for a response
    for (int request_nbr = 0; request_nbr != 21; ++request_nbr) {
        
        ctrl_message.set_name("start");

        if( request_nbr == 9 )
        {
           ctrl_message.set_name("STOP");
           std::cout << "STOP REQUESTED" << std::endl;
        }

        ctrl_message.SerializeToString( &serial_msg );

        zmq::message_t request (serial_msg.size());
        memcpy ((void *) request.data (), serial_msg.c_str(), serial_msg.size());
        socket.send (request);

        // Get the reply.
        zmq::message_t reply;
        socket.recv (&reply);
        std::string recv_msg((char*)reply.data(),reply.size());
        recv_msg+="\0";
        gnuradar::ResponseMessage msg;
        msg.ParseFromString(recv_msg);
        std::cout << "Client Value   : " << msg.value() << std::endl;
        std::cout << "Client Message : " << msg.message() << std::endl;

        sleep(5);
    }
    return 0;
}
