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
#include <gnuradar/BaseThread.h>
#include <gnuradar/SThread.h>

class ProducerThread, public BaseThread, public SThread {
    int& bytes_;
    int& shMemKey_;
    int  status_;
std:
    string error_;

public:
    ProducerThread ( int& bytes, int& shMemKey ) : bytes_ ( bytes ), shMemKey_ ( shMemKey ) {
    }
    const int         Status() {
        return status_;
    }
    const std::string& Error()  {
        return error_;
    }
    void Stop() {
        //cleanup code for hardware here
    }
    void ProduceData ( void* address ) {
        //get data from hardware and write to memory location
    }
void ProduceData ( const std: string& fileName ) {
        //get data from hardware and write to file (tmpfs)
    }

};
