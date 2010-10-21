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
#ifndef RECEIVE_WINDOW_HPP
#define RECEIVE_WINDOW_HPP

#include<iostream>
#include<boost/algorithm/string/case_conv.hpp>

/// Receive window information. Native units are in samples, meaning that
/// units will be internally converted to a sample representation based
/// on the output sampling rate of the system.
class ReceiveWindow {

    typedef std::map< std::string, double > UnitMap;
    typedef UnitMap::iterator UnitMapIterator;
    UnitMap unitMap_;

    std::string name_;
    std::string unitsStr_;
    double start_;
    double stop_;
    double sampleRate_;


    // convert window parameters to samples.
    void ConvertUnits() {
        boost::to_lower ( unitsStr_ );

        UnitMapIterator iter = unitMap_.find ( unitsStr_ );

        if ( iter == unitMap_.end() )
            std::runtime_error (
                "ReceiveWindow: invalid units detected. Conversion failed"
            );

        start_ *= iter->second;
        stop_ *= iter->second;
    }

public:

    ReceiveWindow ( const std::string& name, const double start,
                    const double stop, const std::string& units,
                    const double outputRate ) :
            name_ ( name ), start_ ( start ), stop_ ( stop ),
            unitsStr_ ( units ) {

        unitMap_["samples"] = 1.0;
        unitMap_["usec"] = 1.0e6/outputRate_;
        unitMap_["km"] = 1.0e6*20.0 / ( 3.0 * outputRate_ );

        ConvertUnits();
    }

    unsigned int Start() {
        return start_;
    }

    unsigned int Stop() {
        return stop_;
    }

    unsigned int Size() {
        return stop_ - start_;
    }

    const std::string& Name() {
        return name_;
    }

    void Print ( std::ostream& stream ) {
        stream
        << "Receive Window\n"
        << "name  = " << name_ << "\n"
        << "start = " << start_ << "\n"
        << "stop  = " << stop_ << "\n"
        << "units = " << unitsStr_ << std::endl;
    }

};

#endif
