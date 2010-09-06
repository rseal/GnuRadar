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
#ifndef CONSOLE_H
#define CONSOLE_H
#include <gnuradar/SThread.h>
#include <gnuradar/ProducerConsumerModel.h>

class Console: public thread::SThread {
    gnuradar::ProducerConsumerModel& pcmodel_;
    std::string input_;
    bool quit_;

public:

    Console ( gnuradar::ProducerConsumerModel& pcmodel ) :
            pcmodel_ ( pcmodel ), quit_ ( false ) {
        this->Start();
    }

    virtual void Run() {
        while ( true ) {
           std::cout << ">>>"; 
           std::cin >> input_;
            if ( input_ == "quit" ) pcmodel_.Stop();
            sleep ( 1 );
        }
    }
};

#endif
