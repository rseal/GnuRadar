#ifndef USRP_DEFINITIONS_H
#define USRP_DEFINITIONS_H

#include <vector>
#include <cstdlib>
#include <boost/lexical_cast.hpp>

// An attempt to remove some of the c/c++ intermixed repetitive garbage sprinkled throughout
// the USRP code base. This code could be rewritten in 1/10 of the current size if using 
// proper C++.
namespace usrp
{
   static const std::string USRP_ENV_PATH             = "USRP_PATH";
   static const std::string DEFAULT_PATH              = "/usr/local/share/usrp";
   static const std::string DEFAULT_FIRMWARE_FILENAME = "std.ihx";
   static const std::string DEFAULT_FPGA_FILENAME     = "std_2rxhb_2tx.rbf";
};

#endif

