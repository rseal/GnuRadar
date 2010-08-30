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
                    const double sampleRate ) :
            name_ ( name ), start_ ( start ), stop_ ( stop ),
            unitsStr_ ( units ) {

        unitMap_["samples"] = 1.0;
        unitMap_["usec"] = sampleRate_;
        unitMap_["km"] = 20.0 / 3.0;

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

    void Print( std::ostream& stream )
    {
       stream 
          << "Receive Window\n"
          << "name  = " << name_ << "\n"
          << "start = " << start_ << "\n" 
          << "stop  = " << stop_ << "\n"
          << "units = " << unitsStr_ << std::endl;
    }

};

#endif
