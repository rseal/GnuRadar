#include <iostream>
#include <sys/time.h>

#include <boost/shared_ptr.hpp>
#include <boost/lexical_cast.hpp>

#include <usrp/standard.h>

#include <GnuRadarDevice.h>
#include <GnuRadarTypes.hpp>
#include <GnuRadarSettings.h>
#include <SynchronizedBufferManager.hpp>
#include <SharedMemory.h>
#include <ProducerThread.h>
#include <ConsumerThread.h>
#include <ProducerConsumerModel.h>
#include <yaml/SharedBufferHeader.hpp>

#include <HDF5.hpp>
#include <Complex.hpp>
#include <Time.hpp>
#include <Complex.hpp>

#include "IonosondeRxDevice.h"
#include "Scheduler.h"
#include "timer_us.h"

using namespace boost;
using namespace gnuradar;


int main( int argc, char** argv ) {

    typedef boost::shared_ptr<gnuradar::IonosondeRxDevice> IonosondeRxDevicePtr;
    typedef boost::shared_ptr<SynchronizedBufferManager> SynchronizedBufferManagerPtr;
    typedef boost::shared_ptr<SharedMemory> SharedBufferPtr;
    typedef std::vector<SharedBufferPtr> SharedArray;
    typedef boost::shared_ptr<HDF5> Hdf5Ptr;
    typedef boost::shared_ptr<ProducerThread> ProducerThreadPtr;
    typedef boost::shared_ptr<ConsumerThread> ConsumerThreadPtr;
    typedef boost::shared_ptr<ProducerConsumerModel> PCModelPtr;
    typedef boost::shared_ptr< ::yml::SharedBufferHeader> SharedBufferHeaderPtr;
        
    // FIXME Ionosonde parameters -- should be changed to a config file
    const int CLKRATE = 64000000;
    const int SAMPRATE = 500000;
    const int CHANNELS = 2;
    const int PRF = 40;
    const int SAMPBYTES = 4;
    const int NUMBUFFERS = 10;
    const int BYTESPERBUF = SAMPRATE*SAMPBYTES*CHANNELS;
    const int NUMFREQ = 300;
    const float BAUD = 40e-6;
    const std::string CODE = "1111100110101";

    // GnuRadar Settings
    gnuradar::GnuRadarSettingsPtr grSettings( new gnuradar::GnuRadarSettings() );
    grSettings->numChannels = CHANNELS;
    grSettings->decimationRate = CLKRATE / SAMPRATE;
    grSettings->fpgaFileName = "usrp1_iono_rx_300.rbf";
    grSettings->fUsbBlockSize = 0;
    grSettings->fUsbNblocks = 0;
    grSettings->mux = 0xf3f2f1f0;
    grSettings->firmwareFileName = "std.ihx";

    // Set up the HDF5 data tags -- These should come from the config file
    Hdf5Ptr h5File = Hdf5Ptr ( new HDF5 ( "/data/IonosondeRx", hdf5::WRITE ) );
    h5File->Description( "USRP Ionosonde Receiver" );
    h5File->WriteStrAttrib( "INSTRUMENT", "USRP Rev4.5" );
    h5File->WriteStrAttrib( "IPP_s", boost::lexical_cast<std::string>( 1.0/float(PRF) ) );
    h5File->WriteStrAttrib( "SAMP_BW_Hz", boost::lexical_cast<std::string>( SAMPRATE ) );
    h5File->WriteStrAttrib( "SAMP_FORMAT", "Complex 32-bit Integer" );
    h5File->WriteStrAttrib( "CHANNELS", boost::lexical_cast<std::string>( grSettings->numChannels ) );
    h5File->WriteStrAttrib( "SWEEP_TIME_s", "0.2" );
    h5File->WriteStrAttrib( "FPGA_BITSTREAM", grSettings->fpgaFileName );
    h5File->WriteStrAttrib( "BAUD_s", boost::lexical_cast<std::string>( BAUD ) );
    h5File->WriteStrAttrib( "CODE", CODE );

    // The receiver device (inherits from GnuRadarDevice)
    IonosondeRxDevicePtr myUSRP( new gnuradar::IonosondeRxDevice( grSettings, "/home/radar/pisco/config/igram300.txt" ) );

    // Create the 1-s data buffers in /dev/shm
    SharedArray array;

    for ( int i = 0; i < NUMBUFFERS; ++i ) {
        std::string bufferName = "GnuRadar" + boost::lexical_cast<std::string>(i) + ".buf";

        SharedBufferPtr myBufPtr (
            new SharedMemory (
                bufferName,
                BYTESPERBUF,
                SHM::CreateShared,
                0666 )
            );

        array.push_back( myBufPtr );
    }

    // Set up the buffer manager
    SynchronizedBufferManagerPtr bufferManager = SynchronizedBufferManagerPtr(
        new SynchronizedBufferManager( array, NUMBUFFERS, BYTESPERBUF ) );

    std::vector<hsize_t> dimVector;
    dimVector.push_back( static_cast<int> ( PRF ) );
    dimVector.push_back( static_cast<int> ( SAMPRATE / PRF * CHANNELS ) );

    SharedBufferHeaderPtr header = SharedBufferHeaderPtr (
        new ::yml::SharedBufferHeader (
            NUMBUFFERS,                 // # of buffers
            BYTESPERBUF,          // bytes per buffer
            SAMPRATE,            // sample rate
            CHANNELS,                  // # of channels
            PRF,                 // ipps per buffer
            SAMPRATE/PRF*CHANNELS        // samples per buffer
            )
        );


    // Set up the producer/consumer model
    ProducerThreadPtr producer = ProducerThreadPtr (
        new ProducerThread ( bufferManager, myUSRP )
        );
        
    header->Write( 0, 0, 0 );

    ConsumerThreadPtr consumer = ConsumerThreadPtr (
        new ConsumerThread ( bufferManager, header, h5File, dimVector )
        );

    PCModelPtr pcModel ( new ProducerConsumerModel() );
    pcModel->Initialize( bufferManager, producer, consumer );


    // Wait until the system time (synchronized via NTP) is at the next minute 
    //  --> This will be scheduled with cron
    Scheduler myScheduler(60);

    uint64_t tic, toc;

    // Start the ionosonde data collection and retuning
    std::cout << ">>> Starting ionosonde receiver... " << std::endl;
    myUSRP->Start();
    pcModel->Start();

    tic = timer_us();
    myUSRP->Wait();
    toc = timer_us();

    // Finish and clean up
    std::cout << ">>> Ionosonde finished." << std::endl;
    std::cout << ">>> Total elapsed time: " << toc-tic << " us." << std::endl;
    pcModel->Stop();
    myUSRP->Stop();

    return 0;
};
