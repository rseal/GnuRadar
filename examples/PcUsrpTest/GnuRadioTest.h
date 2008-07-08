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

//user settings
const string dataSet = "/home/rseal/data/UIUC-15mar08";
const double sampleRate    = 64*MHz;
const double bandWidth     = 1*MHz;
const int    numChannels   = 2;
const double IPP           = 4*ms;

const int    decimation    = sampleRate / bandWidth;
const double outputRate    = sampleRate / decimation;
const int    BPS           = outputRate*4*numChannels;
const int    bufferSize    = BPS;
const int    numBuffers    = 10;


vector<int> dimVector;
vector<double> tuningFreq;
Time currentTime;
GnuRadarSettings settings;
GnuRadarDevice grDevice(settings);
int* buffer;

#endif 
