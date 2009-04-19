#include "GnuRadioTest.h"
#include <boost/lexical_cast.hpp>

using boost::lexical_cast;

int main(){

    windowVector.push_back(dataWindow);
    //need to be careful here - definition of multiple channels can be tricky
    //normally I separate the channels : channel 1 = 0 - buffer/2 
    //channel 2: buffer/2 - end
    //These channels, as they are now, are interleaved, so Dim1 
    //should be extended to contain the IPP for both channels (double)
    dimVector.push_back(static_cast<int>(dim0));
    dimVector.push_back(static_cast<int>(dim1));

    //create consumer buffer - destination 
    buffer = new int[bufferSize/sizeof(int)];

    //50MHz RF with 64MHz sampling - positive image at -14MHz (reversed at +14MHz)
    tuningFreq.push_back(-14.0e6);
    tuningFreq.push_back(-14.0e6);
    cout << "BPS = " << BPS << endl;
    cout << "dataWindow = " << dataWindow << endl;
    cout << "BPS*datawindow = " << BPS*dataWindow << endl;
    cout << "BPS*dataWindow/IPP = " << BPS*dataWindow/IPP << endl;
    cout << "trunc = " << static_cast<int>(BPS*dataWindow/IPP) << endl;

//const int    bufferSize    = BPS*dataWindow/IPP;

    cout << "--------------------Settings----------------------" << endl;
    cout << "Sample Rate                 = " << sampleRate << endl;
    cout << "Bandwidth                   = " << bandWidth  << endl;
    cout << "Decimation                  = " << decimation << endl;
    cout << "Output Rate                 = " << outputRate << endl;
    cout << "Number of Channels          = " << numChannels << endl;
    cout << "Bytes Per Second (System)   = " << static_cast<double>(BPS) << endl;
    cout << "BufferSize                  = " << bufferSize << endl;
    cout << "IPP                         = " << IPP << endl;
    for(int i=0; i<numChannels; ++i)
	cout << "Channel[" << i << "] Tuning Frequency = " << tuningFreq[i] << endl;
    cout << "--------------------Settings----------------------\n\n" << endl;

    //write a test file for demonstration purposes
    header = new SimpleHeaderSystem(dataSet, File::WRITE, File::BINARY);

    //build the primary header
    header->primary.Title("USRP Test");
    header->primary.Description("Test Data 03/19/2009");
    header->primary.Add("Instrument", "GNURadio Rev4.5", "Receiving Instrument");
    header->primary.Add("Time", currentTime.GetTime(), "Experiment Starting Time (EDT)");
    header->primary.Add("Sample Rate", sampleRate, "Sample Clock Rate");
    header->primary.Add("Bandwidth", bandWidth, "System Bandwidth");
    header->primary.Add("Decimation", decimation, "System Decimation");
    header->primary.Add("Channels", numChannels, "Number of Channels Used");
    header->primary.Add("Output Rate", outputRate, "System Output Rate");
    header->primary.Add("RF1", 50.20e6, "RF1 frequency");
    header->primary.Add("RF2", 50.02e6, "RF2 frequency");
    header->primary.Add("DDC1", tuningFreq[0], "DDC1 tuning frequency");
    header->primary.Add("DDC2", tuningFreq[1], "DDC2 tuning frequency");

    header->data.SetDim(dimVector);
    for(int i=0; i<windowVector.size(); ++i)
	header->data.Add("Window"+lexical_cast<string>(i), windowVector[i], "Data Window" + lexical_cast<string>(i));

    //Program GNURadio 
    for(int i=0; i<numChannels; ++i){
	settings.Tune(i,tuningFreq[i]);
    }

    settings.numChannels = 2;
    settings.decimationRate = decimation;
    settings.fUsbBlockSize = 0;
    settings.fUsbNblocks = 0;
    settings.mux =  0xf0f0f1f0;
    //testing new gate mode 09/05/2008
    //settings.fpgaFileName = "std_4rx_0tx.rbf";
//    settings.fpgaFileName = "usrp_ext_gate_en.rbf";

//bit image is located at /usr/local/share/usrp/rev4/usrp_ext.rbf
  settings.fpgaFileName = "usrp_trigger_tags.rbf";
//  settings.fpgaFileName = "usrp_ext.rbf";
//moved device ctor here since settings is passed as const - might change this behaviour at some point.
    GnuRadarDevice grDevice(settings);

    //Initialize Producer/Consumer Model
    ProducerConsumerModel pcmodel(
	bufferSize,
	buffer,
	numBuffers,
	sizeof(int),
	"GnuRadar",
	grDevice,
	*header);

    //this is the primary system loop - console controls operation
    cout << "Starting Data Collection... type <quit> to exit" << endl;
    Console console(pcmodel);
    pcmodel.Start();
    pcmodel.RequestData(buffer);
    pcmodel.Wait();
    cout << "Stopping Data Collection... Exiting Program" << endl;

    return 0;
};


