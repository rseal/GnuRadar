#include "GnuRadarRun.hpp"
#include <boost/lexical_cast.hpp>

using boost::lexical_cast;

int main(int argc, char** argv){

    //class to handle command line options/parsing
    CommandLineParser clp(argc,argv);
    Arg arg1("f", "configuration file name", 1, false, "test.ucf");
    Arg arg2("d", "base file name", 1, true);
    Switch sw1("h", "print this message", false);
    Switch sw2("help", "print this message", false);
    clp.AddSwitch(sw1);
    clp.AddSwitch(sw2);
    clp.AddArg(arg1);
    clp.AddArg(arg2);
    clp.Parse();

    if(clp.SwitchSet("h") || clp.SwitchSet("help")){
	    clp.PrintHelp();
	    exit(0);
    }

    fileName = clp.GetArgValue<string>("f");
    dataSet  = clp.GetArgValue<string>("d");

    //parse configuration file 
    ConfigFile cf(fileName);

    //compute bytes per second
    BPS = cf.OutputRate()*cf.NumChannels()*4;
    float PRF = ceil(1.0f/cf.IPP());
    //buffersize in bytes
    //window / IPP * numChannels * 4 = bytes per second
    int bufferSize = cf.WindowLength()*cf.NumChannels()*4*static_cast<int>(PRF);
    
    cout << "PRF        = " << PRF             << endl;
    cout << "BPS        = " << BPS             << endl;
    cout << "BufferSize = " << bufferSize      << endl;
    cout << "sampleRate = " << cf.SampleRate() << endl;
    cout << "Decimation = " << cf.Decimation() << endl;
    cout << "OutputRate = " << cf.OutputRate() << endl;
    
    cout << endl;
    for (int i=0; i<cf.NumWindows(); ++i){
	cout << "Window: " << cf.WindowName(i)  << "\n"
	     << "Start = " << cf.WindowStart(i) << "\n"
	     << "Size  = " << cf.WindowSize(i)  << "\n" << endl;
    }
    
    cout << "WindowLength = " << cf.WindowLength() << endl;

    for (int i=0; i<cf.NumChannels(); ++i)
	cout << "ddc" + lexical_cast<string>(i) << " = " << cf.DDC(i) << endl;
    
    //need to be careful here - definition of multiple channels can be tricky
    //normally I separate the channels : channel 1 = 0 - buffer/2 
    //channel 2: buffer/2 - end
    //These channels, as they are now, are interleaved, so Dim1 
    //should be extended to contain the IPP for both channels (double)
    cout << "dim0 = " << PRF << endl;
    cout << "dim1 = " << cf.WindowLength()*cf.NumChannels()*2 << endl;

    dimVector.push_back(static_cast<int>(PRF));
    dimVector.push_back(static_cast<int>(cf.WindowLength()*cf.NumChannels()*2));

    //create consumer buffer - destination 
    buffer = new short[bufferSize/sizeof(short)];

    cout << "--------------------Settings----------------------" << endl;
    cout << "Sample Rate                 = " << cf.SampleRate()  << endl;
    cout << "Bandwidth                   = " << cf.Bandwidth()   << endl;
    cout << "Decimation                  = " << cf.Decimation()  << endl;
    cout << "Output Rate                 = " << cf.OutputRate()  << endl;
    cout << "Number of Channels          = " << cf.NumChannels() << endl;
    cout << "Bytes Per Second (System)   = " << BPS << endl;
    cout << "BufferSize                  = " << bufferSize << endl;
    cout << "IPP                         = " << cf.IPP() << endl;
    for(int i=0; i<cf.NumChannels(); ++i)
	cout << "Channel[" << i << "] Tuning Frequency = " << cf.DDC(i) << endl;
    cout << "--------------------Settings----------------------\n\n" << endl;

    //write a test file for demonstration purposes
    header = new SimpleHeaderSystem(dataSet, File::WRITE, File::BINARY);

    //build the primary header
    header->primary.Title("USRP Test");
    header->primary.Description("Test Data 06/28/2009");
    header->primary.Add("Instrument", "GNURadio Rev4.5", "Receiving Instrument");
    header->primary.Add("Time", currentTime.GetTime(), "Experiment Starting Time (EDT)");
    header->primary.Add("Sample Rate", cf.SampleRate(), "Sample Clock Rate");
    header->primary.Add("Bandwidth", cf.Bandwidth(), "System Bandwidth");
    header->primary.Add("Decimation", cf.Decimation(), "System Decimation");
    header->primary.Add("Channels", cf.NumChannels(), "Number of Channels Used");
    header->primary.Add("Output Rate", cf.OutputRate(), "System Output Rate");
    header->primary.Add("RF", 49.80e6, "RF Carrier");
    header->primary.Add("IPP", cf.IPP(), "Inter-pulse period");
    for(int i=0; i<cf.NumChannels(); ++i)
	header->primary.Add("DDC" + lexical_cast<string>(i), cf.DDC(i), 
			    "DDC" + lexical_cast<string>(i) + "tuning frequency");
    header->data.SetDim(dimVector);

    //define data windows in header
    for(int i=0; i<cf.NumWindows(); ++i)
	header->data.Add(cf.WindowName(i), cf.WindowSize(i), "Data Window (SAMPLES)");

    //Program GNURadio 
    for(int i=0; i<cf.NumChannels(); ++i) settings.Tune(i,cf.DDC(i));
    
    settings.numChannels    = cf.NumChannels();
    settings.decimationRate = cf.Decimation();
    settings.fpgaFileName   = cf.FPGAImage();    

    //change these as needed
    settings.fUsbBlockSize  = 0;
    settings.fUsbNblocks    = 0;
    settings.mux            = 0xf0f0f1f0;

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


