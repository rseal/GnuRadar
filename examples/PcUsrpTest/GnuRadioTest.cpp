#include <gnuradar/ProducerConsumerModel.h>
#include <usrp_standard.h>
#include <gnuradar/GnuRadarDevice.h>
#include <gnuradar/GnuRadarSettings.h>
#include <gnuradar/SThread.h>
#include <simpleHeader/Shs.h>
#include <simpleHeader/Time.h>
#include <stdio.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>


int main(){

    typedef SimpleHeader<short,2> SimpleHeaderSystem;
    const string dataSet = "UIUC-13mar08";

    const int    Kb            = 1024;
    const int    Mb            = Kb*Kb;
    const double MHz           = 1e6;
    const double sampleRate    = 64*MHz;
    const double bandWidth     = 2*MHz;
    const int    decimation    = sampleRate / bandWidth;
    const double outputRate    = sampleRate / decimation;
    const int    numChannels   = 2;
    const int    BPS           = outputRate*4;
    const int    bufferSize    = BPS;
    const int    numBuffers    = 10;

    //create consumer buffer - destination 
    int* buffer = new int[bufferSize/sizeof(int)];

    //50MHz RF with 64MHz sampling - positive image at -14MHz (reversed at +14MHz)
    vector<double> tuningFreq;
    tuningFreq.push_back(-14e6);
    tuningFreq.push_back(-14e6);

    cout << "--------------------Settings----------------------" << endl;
    cout << "Sample Rate                 = " << sampleRate << endl;
    cout << "Bandwidth                   = " << bandWidth  << endl;
    cout << "Decimation                  = " << decimation << endl;
    cout << "Output Rate                 = " << outputRate << endl;
    cout << "Number of Channels          = " << numChannels << endl;
    cout << "Buffer size (bytes)         = " << static_cast<double>(BPS) << endl;
    for(int i=0; i<numChannels; ++i)
	cout << "Channel[" << i << "] Tuning Frequency = " << tuningFreq[i] << endl;
    cout << "--------------------Settings----------------------\n\n" << endl;

    //time stamp class
    Time currentTime;

    //write a test file for demonstration purposes
    SimpleHeaderSystem* 
	header = new SimpleHeaderSystem(dataSet, File::WRITE, File::BINARY);

    //build the primary header
    header->primary.Title("UIUC-GnuRadio-Test");
    header->primary.Description("March 13 2008 Test data");
    header->primary.Add("Instrument", "GNURadio Rev 4", "Receiving Instrument");
    header->primary.Add("Time", currentTime.GetTime(), "Experiment Starting Time (CDT)");
    header->primary.Add("Sample Rate", sampleRate, "Sample Clock Rate");
    header->primary.Add("Bandwidth", bandWidth, "System Bandwidth");
    header->primary.Add("Decimation", decimation, "System Decimation");
    header->primary.Add("Channels", numChannels, "Number of Channels Used");
    header->primary.Add("Output Rate", outputRate, "System Output Rate");

    //write primary header to disk
    header->primary.ProgramInfo(header->file.GetRef());
    header->WritePrimary();
    (header->file.GetRef()).flush();

    //Program GNURadio 
    GnuRadarSettings settings;
    for(int i=0; i<numChannels; ++i){
	settings.Tune(i,tuningFreq[i]);
    }
    settings.decimationRate = decimation;
    settings.fUsbBlockSize = 0;
    settings.fUsbNblocks = 0;

    //Initialize GNURadarDevice class
    GnuRadarDevice grDevice(settings);

    //Initialize Producer/Consumer Model
    ProducerConsumerModel pcmodel(
	bufferSize,
	buffer,
	numBuffers,
	sizeof(int),
	"GnuRadar",
	grDevice);

    //Start Producer/Consumer Model 
    pcmodel.Start();

    pcmodel.RequestData(buffer);

    return 0;
};


