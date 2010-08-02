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
#ifndef CONFIG_FILE_H
#define CONFIG_FILE_H

#include <gnuradar/Parser.h>
#include <gnuradar/Units.h>
#include <gnuradar/GnuRadarTypes.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/cstdint.hpp>
#include <cmath>
#include <vector>

using boost::lexical_cast;
using std::vector;
using std::endl;
using std::cout;

///channel structure
struct Channel{
   public:
      double ddc;
      int ddcUnits;
      int phase;
      double phaseUnits;
};

///window structure
struct Window{
   public:
      string name;
      unsigned int start;
      unsigned int size;
      double units;
};

///main structure
struct ConfigFile{
   double sampleRate_;
   int numChannels_;
   float ipp_;
   int numWindows_;
   int decimation_;
   int ippLength_;
   int windowLength_;
   double outputRate_;
   double ippUnits_;
   string fpgaImage_;
   vector<Channel> channels_;
   vector<Window> windows_;

   //window conversion factor
   const double WCF(const string& units){
      double factor=double();
      if(units == "Samples")
         factor = 1.0;
      else if(units == "usec")
         factor = outputRate_ * 1e-6;
      else if(units == "km")
         factor = outputRate_ * 2e-5/3;
      return factor;
   }

   public:

   explicit ConfigFile(const string& fileName): 
      windowLength_(0)
   {
      Units units;
      Parser parser(fileName);
      parser.Load();
      sampleRate_  = parser.Get<double>("SampleRate");
      decimation_  = parser.Get<int>("Decimation");
      outputRate_  = sampleRate_/decimation_;
      numChannels_ = parser.Get<int>("NumChannels");
      numWindows_  = parser.Get<int>("NumWindows");
      ippLength_   = parser.Get<int>("IPP");
      ippUnits_    = units(parser.Get<string>("IPPUnits"));
      ipp_         = ippLength_ * ippUnits_;
      fpgaImage_   = parser.Get<string>("FPGAImage");

      string idx;
      double factor;

      for(int i=0; i<gnuradar::USRP_MAX_CHANNELS; ++i){
         Channel ch;
         idx           = lexical_cast<string>(i);
         ch.ddc        = parser.Get<float>("DDC" + idx);
         ch.ddcUnits   = units(parser.Get<string>("DDCUnits" + idx));
         ch.ddc       *= ch.ddcUnits;
         ch.phase      = parser.Get<int>("Phase" + idx);
         ch.phaseUnits = units(parser.Get<string>("PhaseUnits" + idx));
         //phase in degrees
         ch.phase     *= ch.phaseUnits;
         channels_.push_back(ch);
      }

      for(int i=0; i<numWindows_; ++i){
         Window win;
         idx       = lexical_cast<string>(i);
         win.name  = parser.Get<string>("Name" + idx);
         win.start = parser.Get<int>("Start" + idx);
         win.size  = parser.Get<int>("Size" + idx);
         factor    = WCF(parser.Get<string>("Units" + idx));
         //convert units to samples
         win.start = static_cast<int>(win.start*factor);
         win.size  = static_cast<int>(win.size*factor);
         windows_.push_back(win);
         windowLength_ += win.size;
      }
   }

   const int&    Phase(const int& num)       { return channels_[num].phase; }
   const double& DDC(const int& num)         { return channels_[num].ddc;   }
   const string& WindowName(const int& num)  { return windows_[num].name;   }
   const int&    WindowStart(const int& num) { return windows_[num].start;  }
   const int&    WindowSize(const int& num)  { return windows_[num].size;   }
   const int&    WindowLength()              { return windowLength_;        }
   const double& SampleRate()                { return sampleRate_;          }
   const double& OutputRate()                { return outputRate_;          }
   const double& Decimation()                { return decimation_;          }
   const int&    NumChannels()               { return numChannels_;         }
   const int&    NumWindows()                { return numWindows_;          }
   const double& Bandwidth()                 { return outputRate_;          }
   const float&  IPP()                       { return ipp_;                 }
   const string& FPGAImage()                 { return fpgaImage_;           }
   const vector<Window>& Windows()           { return windows_;             }

   // returns the hardware's output rate in BPS.
   const long BytesPerSecond() {
      return numChannels_ * gnuradar::BYTES_PER_COMPLEX_SAMPLE * 
         ceil(windowLength_/ipp_);
   }
};

#endif


