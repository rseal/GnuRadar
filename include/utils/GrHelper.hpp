#ifndef GR_HELPER_HPP
#define GR_HELPER_HPP

#include<fstream>
#include<yaml-cpp/yaml.h>
#include<gnuradar/Constants.hpp>

namespace gr_helper{

   std::string ReadConfigurationFile(const std::string& networkType )
   {
      std::string ip_addr;

      try{
         std::ifstream fin( gnuradar::constants::SERVER_CONFIGURATION_FILE.c_str() );
         YAML::Parser parser(fin);
         YAML::Node doc;
         parser.GetNextDocument(doc);
         doc[networkType]  >> ip_addr;
      }
      catch( YAML::ParserException& e ) 
      {
         std::cerr << e.what();
      }

      return ip_addr;
   };
};

#endif
