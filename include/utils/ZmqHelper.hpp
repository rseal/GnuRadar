#ifndef ZMQ_HELPER_HPP
#define ZMQ_HELPER_HPP
#include<iostream>
#include<zmq.h>

namespace zmq_helper{

   static std::string FormatString( zmq::message_t& msg )
   {
      // Use this method to ensure proper string size and termination.
      std::string message((char*)msg.data(),msg.size());
      message+="\0";
      return message;
   };

};

#endif
