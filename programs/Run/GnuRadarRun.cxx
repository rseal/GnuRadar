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
#include "GnuRadarRun.hpp"
#include <boost/lexical_cast.hpp>
#include <cmath>

using namespace boost;

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
   cout << "dim1 = " << cf.WindowLength()*cf.NumChannels() << endl;

   dimVector.push_back(static_cast<int>(PRF));
   dimVector.push_back(static_cast<int>(cf.WindowLength()*cf.NumChannels()));

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
   //header = new SimpleHeaderSystem(dataSet, File::WRITE, File::BINARY);
   h5File.reset(new HDF5(dataSet + "_", hdf5::WRITE));

   h5File->Description("USRP Radar Receiver");
   h5File->WriteStrAttrib("START_TIME", currentTime.GetTime());
   h5File->WriteStrAttrib("INSTRUMENT", "GNURadio Rev4.5");

   h5File->WriteAttrib<int>("CHANNELS", cf.NumChannels(), H5::PredType::NATIVE_INT, H5::DataSpace());
   h5File->WriteAttrib<double>("SAMPLE_RATE", cf.SampleRate(), H5::PredType::NATIVE_DOUBLE, H5::DataSpace());
   h5File->WriteAttrib<double>("BANDWIDTH", cf.Bandwidth(), H5::PredType::NATIVE_DOUBLE, H5::DataSpace());
   h5File->WriteAttrib<int>("DECIMATION", cf.Decimation(), H5::PredType::NATIVE_INT, H5::DataSpace());
   h5File->WriteAttrib<double>("OUTPUT_RATE", cf.OutputRate(), H5::PredType::NATIVE_DOUBLE, H5::DataSpace());
   h5File->WriteAttrib<double>("IPP", cf.IPP(), H5::PredType::NATIVE_DOUBLE, H5::DataSpace());
   h5File->WriteAttrib<double>("RF", 49.80e6, H5::PredType::NATIVE_DOUBLE, H5::DataSpace());
   for(int i=0; i<cf.NumChannels(); ++i){
      h5File->WriteAttrib<double>("DDC" + lexical_cast<string>(i), cf.DDC(i), H5::PredType::NATIVE_DOUBLE, H5::DataSpace());
   }
   h5File->WriteAttrib<int>("SAMPLE_WINDOWS", cf.NumWindows(), H5::PredType::NATIVE_INT, H5::DataSpace());
   for(int i=0; i<cf.NumWindows(); ++i){
      h5File->WriteAttrib<int>(cf.WindowName(i)+"_START", cf.WindowStart(i), H5::PredType::NATIVE_INT, H5::DataSpace());
      h5File->WriteAttrib<int>(cf.WindowName(i)+"_SIZE", cf.WindowSize(i), H5::PredType::NATIVE_INT, H5::DataSpace());
   }

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
         h5File,
         dimVector
         );

   //this is the primary system loop - console controls operation
   cout << "Starting Data Collection... type <quit> to exit" << endl;
   Console console(pcmodel);
   pcmodel.Start();
   pcmodel.RequestData(buffer);
   pcmodel.Wait();
   cout << "Stopping Data Collection... Exiting Program" << endl;

   return 0;
};


