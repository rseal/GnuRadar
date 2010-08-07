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
#ifndef GNURADIOTEST_H
#define GNURADIOTEST_H

#include <gnuradar/ProducerConsumerModel.h>
#include <usrp_standard.h>
#include <gnuradar/GnuRadarDevice.h>
#include <gnuradar/GnuRadarTypes.hpp>
#include <gnuradar/GnuRadarSettings.h>
#include <gnuradar/SThread.h>
#include <gnuradar/Console.h>
#include <gnuradar/ConfigFile.h>
#include <gnuradar/Units.h>
#include <clp/CommandLineParser.hpp>
#include <HDF5/HDF5.hpp>
#include <HDF5/Complex.hpp>
#include <HDF5/Time.hpp>
#include <boost/shared_ptr.hpp>

typedef boost::shared_ptr<HDF5> Hdf5Ptr;
Hdf5Ptr h5File;

const int BYTES_PER_SAMPLE = 4;
const int NUM_BUFFERS      = 20;
const int    Kb            = 1024;
const int    Mb            = Kb*Kb;
const double ms            = 1e-3;
const double MHz           = 1e6;
const double us            = 1e-6;

double BPS;
string dataSet;
string fileName;

vector<int> windowVector;
vector<hsize_t> dimVector;
vector<double> tuningFreq;

Time currentTime;
GnuRadarSettings settings;
gnuradar::iq_t* buffer;

#endif 
