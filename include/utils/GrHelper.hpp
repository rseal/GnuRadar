#ifndef GR_HELPER_HPP
#define GR_HELPER_HPP

#include<ticpp/ticpp.h>

namespace gr_helper{

   const std::string ReadConfigurationFile(const std::string& networkType )
   {
      std::string pubsub_addr;
      ticpp::Document doc( gnuradar::constants::SERVER_CONFIGURATION_FILE );

      try
      {
         // parse file.
         doc.LoadFile();

         // parse broadcast port from file.
         pubsub_addr = doc.FirstChildElement(networkType)->GetText();
      }
      catch( ticpp::Exception& e ) 
      {
         std::cerr << e.what();
      }

      return pubsub_addr;
   };
};

#endif
