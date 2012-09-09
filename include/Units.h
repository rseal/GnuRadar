// Copyright (c) 2010 Ryan Seal <rlseal -at- gmail.com>
//
// This file is part of GnuRadar Software.
//
// GnuRadar is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// GnuRadar is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GnuRadar.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////////////
///\file Units.h
///
/// This file defines and implements the Units structure, which is responsible
/// for parsing various given units and returning time of type double.
///
///Author: Ryan Seal
///Modified: 01/26/09
////////////////////////////////////////////////////////////////////////////////
#ifndef UNITS_H
#define UNITS_H

#include <iostream>
#include <boost/algorithm/string.hpp>
#include <map>

using std::string;
using std::cout;
using std::endl;
using std::map;
using namespace boost;

struct UnitType{
	public:
	const std::string units;
	const double multiplier;
	UnitType( const std::string& u, const double m ) : units(u), multiplier(m) {}
};

///\brief Parses various defined time units and returns time with double precision
struct Units {

	typedef map<string, UnitType > UnitTypeMap;
	UnitTypeMap unitMap;

	// finds a matching unit and returns a UnitType object.
	UnitType Find( const string& token )
	{
		std::string str = token;
		//remove everything to the left of 'units'
		str.erase ( 0, str.find_last_of ( " " ) + 1 );

		//search map for token and assign if found
		UnitTypeMap::iterator iter = unitMap.find ( str );
		
		return iter->second;
	}

	// converts incoming token to lower for standardization.
	std::string Format( const string& token )
	{
		string str = token;
		to_lower ( str );
		return str;
	}

	public:

	Units() {

		// resulting unit : hz
		unitMap.insert( std::pair<std::string,UnitType>("mhz",UnitType("hz",1e6)));
		unitMap.insert( std::pair<std::string,UnitType>("khz",UnitType("hz",1e3)));
		unitMap.insert( std::pair<std::string,UnitType>("hz",UnitType("hz",1e0)));

		// resulting unit : sec
		unitMap.insert( std::pair<std::string,UnitType>("nsec",UnitType("sec",1e-9)));
		unitMap.insert( std::pair<std::string,UnitType>("usec",UnitType("sec",1e-6)));
		unitMap.insert( std::pair<std::string,UnitType>("msec",UnitType("sec",1e-3)));
		unitMap.insert( std::pair<std::string,UnitType>("sec",UnitType("sec",1e0)));
		unitMap.insert( std::pair<std::string,UnitType>("km",UnitType("sec",(2.0/3.0)*1e-6)));
		unitMap.insert( std::pair<std::string,UnitType>("m",UnitType("sec",(2.0/3.0)*1e-3)));

		// resulting unit : deg
		unitMap.insert( std::pair<std::string,UnitType>("deg",UnitType("deg",1e0)));
		unitMap.insert( std::pair<std::string,UnitType>("rad",UnitType("deg",180.0*11.0/7.0)));

		unitMap.insert( std::pair<std::string,UnitType>("samples",UnitType("samples",1e0)));
	}

	const UnitType operator() ( const string& token ) {
		return this->Find(this->Format(token));
	}

};

#endif
