#ifndef GNURADIOTEST_H
#define GNURADIOTEST_H

#include <gnuradar/ProducerConsumerModel.h>
#include <usrp_standard.h>
#include <gnuradar/GnuRadarDevice.h>
#include <gnuradar/GnuRadarSettings.h>
#include <gnuradar/SThread.h>
#include <gnuradar/Console.h>
#include <simpleHeader/Shs.h>
#include <simpleHeader/Time.h>

typedef SimpleHeader<short,2> SimpleHeaderSystem;
SimpleHeaderSystem* header;

const int    Kb            = 1024;
const int    Mb            = Kb*Kb;
const double ms            = 1e-3;
const double MHz           = 1e6;
const double us            = 1e-6;

//user settings
const string dataSet = "/home/rseal/usrpLabTest";
const double sampleRate    = 64*MHz;
const double bandWidth     = 1*MHz;
const int    numChannels   = 2;
const double IPP           = 25*ms;
const double dataWindow    = 16500.0*us;
const int    decimation    = sampleRate / bandWidth;
const double outputRate    = sampleRate / decimation;
const double BPS           = outputRate*numChannels*4;
const int    bufferSize    = BPS*dataWindow*(1.0/IPP);
const int    numBuffers    = 20;
const double dim0          = 1.0/IPP;
const double dim1          = dataWindow*outputRate*numChannels*2;

vector<int> windowVector;
vector<int> dimVector;
vector<double> tuningFreq;
Time currentTime;
GnuRadarSettings settings;
short* buffer;

#endif 
