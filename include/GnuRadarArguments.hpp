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
#ifndef GNURADAR_ARGUMENTS_HPP
#define GNURADAR_ARGUMENTS_HPP

#include <boost/any.hpp>
#include <vector>

struct Arguments {
public:
    typedef std::vector< boost::any > ArgumentList;

    Arguments ( const ArgumentList args ) {
        args_ = args;
    }

    void Add ( const boost::any value ) {
        args_.push_back ( value );
    }

    const ArgumentList& GetRef() {
        return args_;
    }

    template< typename T>
    const T& Get ( const int index ) {
        // throws on out of bounds or bad cast
        T value = boost::any_cast<T> ( args_.at ( index ) );
        return T;
    }

private:
    const ArgumentList args_;
};

#endif
