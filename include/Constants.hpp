// Copyright (c) 2012 Ryan Seal <rlseal -at- gmail.com>
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
#ifndef CONSTANTS_HPP
#define CONSTANTS_HPP

namespace gnuradar{
   namespace constants{
      static int NUM_BUFFERS = 20;
      static std::string BUFFER_BASE_NAME = "GnuRadar";
		static std::string SERVER_CONFIGURATION_FILE = "/usr/local/gnuradar/gnuradar_server.yml";
		static int STATUS_REFRESH_RATE_MSEC = 1000;
   };
};

#endif
