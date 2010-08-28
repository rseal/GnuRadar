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
///ChannelStruct.h
///
///
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef CHANNEL_STRUCT_H
#define CHANNEL_STRUCT_H
#include <iostream>
using std::cout;
using std::endl;
///Each USRP channel defines the down-conversion frequency
///and phase.
struct ChannelStruct {
public:
    float ddc;
    int ddcUnits;
    float phase;
    int phaseUnits;
    void Print() {
        cout << "ddc        = " << ddc        << "\n"
             << "ddcUnits   = " << ddcUnits   << "\n"
             << "phase      = " << phase      << "\n"
             << "phaseUnits = " << phaseUnits << endl;
    }
};

#endif
