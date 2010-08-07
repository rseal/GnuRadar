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
#ifndef GNURADAR_VERIFY_HPP
#define GNURADAR_VERIFY_HPP

#include<usrp_standard.h>
#include <gnuradar/GnuRadarSettings.h>
#include <gnuradar/ConfigFile.h>
#include <gnuradar/GnuRadarTypes.hpp>
#include <gnuradar/WindowValidator.hpp>
#include <clp/CommandLineParser.hpp>
#include <stdexcept>
#include <vector>

typedef std::vector<gnuradar::iq_t> Buffer;
typedef Buffer::iterator BufferIterator;

Buffer buffer;
#endif
