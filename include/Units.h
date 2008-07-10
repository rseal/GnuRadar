////////////////////////////////////////////////////////////////////////////////
///\file Units.h
///
/// This file defines and implements the Units structure, which is responsible
/// for parsing various given units and returning time of type double.
///
///Author: Ryan Seal
///Modified: 06/28/07
////////////////////////////////////////////////////////////////////////////////
#ifndef UNITS_H
#define UNITS_H

#include <iostream>
#include <boost/algorithm/string.hpp>


using std::string;
using std::cout;
using std::endl;
using namespace boost;

///\brief Parses various defined time units and returns time with double precision
struct Units{


public:

///Overloaded operator creates a function operator (functor) that parses the supplied units
///and returns time with double precision
    const double operator()(string& token){
	double multiplier;

	token.erase(0,token.find("=")+1);
	boost::to_lower(token);

	if(find_first(token,"mhz")){
	    boost::erase_all(token,"mhz");
	    multiplier = 1e6;
	}
	else
	    if(find_first(token,"khz")) {
		boost::erase_all(token,"khz");
		multiplier = 1e3;
	    }
	    else
		if(find_first(token,"hz")){
		    boost::erase_all(token,"hz");
		    multiplier = 1e0;
		}
		else
		    if(find_first(token,"nsec")){
			boost::erase_all(token,"nsec");
			multiplier = 1e-9;
		    }
		    else
			if(find_first(token,"usec")){
			    boost::erase_all(token,"usec");
			    multiplier = 1e-6;
			}
			else
			    if(find_first(token,"msec")){
				boost::erase_all(token,"msec");
				multiplier = 1e-3;
			    }
			    else
				if(find_first(token,"sec")){
				    boost::erase_all(token,"sec");
				    multiplier = 1e0;
				}
				else
				    if(find_first(token,"km")){
					boost::erase_all(token,"km");
					multiplier = (2.0/3.0)*1e-6;
				    }
				    else
					if(find_first(token,"m")){
					    boost::erase_all(token,"m");
					    multiplier = (2.0/3.0)*1e-3;
					}
	
	return multiplier;	
    }
};

#endif
