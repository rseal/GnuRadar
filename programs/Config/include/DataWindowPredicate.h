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
#ifndef DATAWINDOW_PREDICATE_H
#define DATAWINDOW_PREDICATE_H

#include <string>
#include "DataWindowInterface.h"
#include <boost/shared_ptr.hpp>

using std::string;

class FindDataWindow {
    const string& name_;
public:
    FindDataWindow ( const string& name ) : name_ ( name ) {}

    const bool operator() ( boost::shared_ptr<DataGroup> dgp ) {
        const DataWindowStruct& dws = dgp->DataWindowRef();
        return dws.name == name_;
    }
};

#endif
