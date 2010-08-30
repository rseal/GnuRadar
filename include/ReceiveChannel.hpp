#ifndef RECEIVE_CHANNEL_HPP
#define RECEIVE_CHANNEL_HPP

#include <boost/math/constants/constants.hpp>
#include<boost/algorithm/string/case_conv.hpp>
#include <map>
#include <iostream>

struct ReceiveChannel
{
    typedef std::map< std::string, double > UnitMap;
    typedef UnitMap::iterator UnitMapIterator;
    UnitMap frequencyMap_;
    UnitMap phaseMap_;

    std::string frequencyUnitStr_;
    std::string phaseUnitStr_;
    int frequencyUnits_;
    double frequency_;
    double phase_;

    ConvertUnits()
    {
       // remove case sensitivity
       boost::to_lower( frequencyUnitStr_ );
       boost::to_lower( phaseUnitStr_ );

       // search for match
       UnitMapIterator frequencyIter = frequencyMap_.find( frequencyUnitStr_ );
       UnitMapIterator phaseIter = phaseMap_.find( phaseUnitStr_ );

       // if frequency units not found - throw
       if( frequencyIter == frequencyMap_.end() )
          throw std::runtime_error( 
                "ReceiveChannel frequency unit conversion failed.");

       // if phase units not found - throw
       if( phaseIter == phaseMap_.end() )
          throw std::runtime_error( 
                "ReceiveChannel phase unit conversion failed.");

       // compute frequency and phase
       frequency_ *= frequencyIter->second;
       phase_ *= phaseIter->second;

    }

   public:

    ReceiveChannel(
          double frequency,
          const std::string& frequencyUnitStr,
          double phase,
          const std::string& phaseUnitStr
          ): 
       frequency_(frequency), frequencyUnitStr_(frequencyUnitStr), phase_(phase), 
       phaseUnitStr_(phaseUnitStr)
   {
      frequencyMap_["hz"] = 1.0;
      frequencyMap_["khz"] = 1.0e3;
      frequencyMap_["mhz"] = 1.0e6;

      phaseMap_["degrees"] = 1.0;
      phaseMap_["radians"] = 180.0/boost::math::constants::pi<double>();

      ConvertUnits();
   }

    const double Frequency() { return frequency_; }
    const double Phase() { return phase_; }
};

#endif
