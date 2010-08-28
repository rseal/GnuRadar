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
///DataWindowStruct.h
///
///
///
///Author: Ryan Seal
///Modified: 08/17/08
////////////////////////////////////////////////////////////////////////////////
#ifndef DATA_WINDOW_STRUCT_H
#define DATA_WINDOW_STRUCT_H
#include <iostream>
using std::cout;
using std::endl;
using std::string;

///Describes an arbitrary number of windows that determine
///which portions of data to collect.
struct DataWindowStruct {
    string name;
    int start;
    int size;
    int units;
    int id;
    DataWindowStruct() : start ( 0 ), size ( 0 ), units ( 0 ), id ( 0 ) {}
    void Print() {
        cout << "name   = " << name  << "\n"
             << "start  = " << start
             << "size   = " << size
             << "units  = " << units << "\n"
             << "id     = " << id    << endl;
    }
};
#endif
