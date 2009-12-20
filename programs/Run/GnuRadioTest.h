#ifndef GNURADIOTEST_H
#define GNURADIOTEST_H

#include <gnuradar/ProducerConsumerModel.h>
#include <usrp_standard.h>
#include <gnuradar/GnuRadarDevice.h>
#include <gnuradar/GnuRadarSettings.h>
#include <gnuradar/SThread.h>
#include <gnuradar/Console.h>
#include <gnuradar/ConfigFile.h>
#include <gnuradar/Units.h>
#include <gnuradar/CommandLineParser.h>
#include <simpleHeader/Shs.h>
#include <simpleHeader/Time.h>

typedef SimpleHeader<short,2> SimpleHeaderSystem;
SimpleHeaderSystem* header;

const int    Kb            = 1024;
const int    Mb            = Kb*Kb;
const double ms            = 1e-3;
const double MHz           = 1e6;
const double us            = 1e-6;

double BPS;
string dataSet;
string fileName;

const double IPP           = 25*ms;
const double dataWindow    = 16500.0*us;
const int    numBuffers    = 20;
vector<int> windowVector;
vector<int> dimVector;
vector<double> tuningFreq;
Time currentTime;
GnuRadarSettings settings;
short* buffer;

#endif 
