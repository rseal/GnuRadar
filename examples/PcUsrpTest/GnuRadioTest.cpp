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

class Console: public SThread{
  ProducerConsumerModel& pcmodel_;
  std::string input_;
  bool quit_;

public:

  Console(ProducerConsumerModel& pcmodel): pcmodel_(pcmodel),quit_(false){this->Start();}
  virtual void Run(){
    while(true){
      cout << ">>>";
      cin >> input_;
      if(input_ == "quit") pcmodel_.Stop();
      sleep(1);
    }
  }
};

int main(){

    typedef SimpleHeader<short,2> SimpleHeaderSystem;
    const string dataSet = "/home/rseal/data/UIUC-15mar08";

    const int    Kb            = 1024;
    const int    Mb            = Kb*Kb;
    const double ms            = 1e-3;
    const double MHz           = 1e6;
    const double sampleRate    = 64*MHz;
    const double bandWidth     = 1*MHz;
    const int    decimation    = sampleRate / bandWidth;
    const double outputRate    = sampleRate / decimation;
    const int    numChannels   = 2;
    const int    BPS           = outputRate*4*numChannels;
    const int    bufferSize    = BPS;
    const int    numBuffers    = 10;
    const double IPP           = 4*ms;
    
    vector<int> dimVector;

    //need to be careful here - definition of multiple channels can be tricky
    //normally I separate the channels : channel 1 = 0 - buffer/2 
    //channel 2: buffer/2 - end
    //These channels, as they are now, are interleaved, so Dim1 
    //should be extended to contain the IPP for both channels (double)
    dimVector.push_back(static_cast<int>(outputRate*IPP*numChannels));
    dimVector.push_back(static_cast<int>(outputRate/dimVector[0]));
    

    //create consumer buffer - destination 
    int* buffer = new int[bufferSize/sizeof(int)];

    //50MHz RF with 64MHz sampling - positive image at -14MHz (reversed at +14MHz)
    vector<double> tuningFreq;
    tuningFreq.push_back(-14.2e6);
    tuningFreq.push_back(-14.2e6);

    cout << "--------------------Settings----------------------" << endl;
    cout << "Sample Rate                 = " << sampleRate << endl;
    cout << "Bandwidth                   = " << bandWidth  << endl;
    cout << "Decimation                  = " << decimation << endl;
    cout << "Output Rate                 = " << outputRate << endl;
    cout << "Number of Channels          = " << numChannels << endl;
    cout << "Buffer size (bytes)         = " << static_cast<double>(BPS) << endl;
    cout << "IPP                         = " << IPP << endl;
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
    header->primary.Description("March 14 2008 Test data");
    header->primary.Add("Instrument", "GNURadio Rev 4", "Receiving Instrument");
    header->primary.Add("Time", currentTime.GetTime(), "Experiment Starting Time (CDT)");
    header->primary.Add("Sample Rate", sampleRate, "Sample Clock Rate");
    header->primary.Add("Bandwidth", bandWidth, "System Bandwidth");
    header->primary.Add("Decimation", decimation, "System Decimation");
    header->primary.Add("Channels", numChannels, "Number of Channels Used");
    header->primary.Add("Output Rate", outputRate, "System Output Rate");
    header->primary.Add("East Array" , "CH1 - RX-A", "Antenna Array");
    header->primary.Add("West Array" , "CH2 - RX-B", "Antenna Array");
    header->primary.Add("TX RF", 49.8e6, "RF frequency");
    header->primary.Add("TX PULSE", 77e-6, "TX Pulse Width");

    header->data.SetDim(dimVector);

    //write primary header to disk
    //    header->primary.ProgramInfo(header->file.GetRef());
    // header->WritePrimary();
    //(header->file.GetRef()).flush();

    //Program GNURadio 
    GnuRadarSettings settings;
    for(int i=0; i<numChannels; ++i){
	settings.Tune(i,tuningFreq[i]);
    }

    settings.numChannels = 2;
    settings.decimationRate = decimation;
    settings.fUsbBlockSize = 0;
    settings.fUsbNblocks = 0;
    settings.mux =  0xf0f0f1f0;
    settings.fpgaFileName = "std_4rx_0tx.rbf";

    //Initialize GNURadarDevice class
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

    cout << "Starting Data Collection... type <quit> to exit" << endl;
    Console console(pcmodel);
    pcmodel.Start();
    pcmodel.RequestData(buffer);
    pcmodel.Wait();
    cout << "Stopping Data Collection... Exiting Program" << endl;

    return 0;
};


