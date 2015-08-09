#ifndef IONOSONDERXDEVICE_H
#define IONOSONDERXDEVICE_H

#include <fstream>
#include <iostream>

#include <GnuRadarDevice.h>
#include <SThread.h>

#include <boost/lexical_cast.hpp>
#include <usrp/basic.h>
#include <fpga/fpga_regs_standard.h>

#include "timer_us.h"

namespace gnuradar{

const double DEFAULT_START_FREQ = 2000000;
const double DEFAULT_END_FREQ = 20000000;
const double DEFAULT_FREQ_STEP = 2000000;
const int DEFAULT_STEP_TIME_US = 200000;

// FIXME: No longer doing frequency retuning on the host computer, hence
//   the the commented code.  It should all be removed at some point to
//   simplify the code.

class IonosondeRxDevice: public GnuRadarDevice, public thread::SThread {
    
    std::vector<double> freqList_;
    std::string freqListFilename_;
    std::vector<double>::iterator freqPos_;
    bool fixedTimeStep_;  // not used currently, but planned for variable step operation

    void ResetFreqSweep_(){
        
        usrp_->_write_fpga_reg( FR_USER_1, 1 );     // Pull reset high
        usrp_->_write_fpga_reg( FR_USER_0, 0 );     // Make sure frequency sweep is disabled
        usrp_->_write_fpga_reg( FR_USER_1, 0 );     // Bring reset low again
    }

    void InitFreqList_(){

        if ( !freqListFilename_.compare("") ) {
            // Load a default (linearly spaced) frequency list
            for( double i=DEFAULT_START_FREQ; i < DEFAULT_END_FREQ; i+=DEFAULT_FREQ_STEP )
                freqList_.push_back( i );

            //std::cout << "Default frequency list loaded." << std::endl;
        }
        else {
            // Load a frequency list from a file
            std::ifstream f_file;
            f_file.open( freqListFilename_.c_str(), std::ios::in );

            if( f_file.good() ) {
                std::string currFreq;

                while( !f_file.eof() ) {
                    getline( f_file, currFreq );
                    freqList_.push_back( atof( currFreq.c_str() ) );
                }
                //std::cout << "Loaded frequency list from " << freqListFilename_ << std::endl;
            }
            else {
                // If there's a problem loading the file, load the default list
                //std::cout << "Error loading " << freqListFilename_ << 
                //    ". Loading default frequency list..." << std::endl;
                freqListFilename_ = "";
                InitFreqList_();
            }
        }

        freqPos_ = freqList_.begin();

        for( int i=0; i < grSettings_->numChannels; ++i ) {
            Retune( i, freqList_[0] );
            //std::cout << "### Channel " << i << " initialized to " << freqList_[0] << 
            //    " Hz." << std::endl;
        }

    };

public:

    IonosondeRxDevice( GnuRadarSettingsPtr grSettings ) : 
        GnuRadarDevice ( grSettings ),
        fixedTimeStep_ ( true ),
        freqListFilename_ ( "" ) {
        
        std::cout << "### Instantiating IonosondeRxDevice... ";
        InitFreqList_();
        ResetFreqSweep_();
        for( int i=0; i < 4; ++i )
            usrp_->set_pga( i, 20 );
        }

    IonosondeRxDevice( GnuRadarSettingsPtr grSettings, std::string freqListFilename ) :
        GnuRadarDevice( grSettings ),
        fixedTimeStep_ ( true ),
        freqListFilename_ ( freqListFilename ) {

        std::cout << "### Instantiating IonosondeRxDevice... ";
        InitFreqList_();
        ResetFreqSweep_();
        for( int i=0; i < 4; ++i )
            usrp_->set_pga( i, 20 );
    }
        
    void Retune( const int channel, const double newFreq ) {

        grSettings_->Tune( channel, newFreq );
        //usrp_->set_rx_freq( channel, grSettings_->tuningFrequency[channel] );   
    }

    void SetFreqList( std::string freqListFilename ) {
        freqListFilename_ = freqListFilename;
        InitFreqList_();
    }

    virtual void Run() {
        uint64_t t1, t2;

        // Enable frequency sweeping on the FPGA
        usrp_->_write_fpga_reg( FR_USER_0, 1 );
        
        // The end()-1 is so we don't retune to baseband at the end
        while ( freqPos_ != freqList_.end()-1 ) {
            
            t1 = timer_us();
            for( int i=0; i < grSettings_->numChannels; ++i ) 
                Retune( i, *freqPos_ );
            freqPos_++;
            t2 = timer_us();
            Sleep(thread::USEC, DEFAULT_STEP_TIME_US - (t2-t1) );
        }
        
        // Disable frequency sweeping on the FPGA
        usrp_->_write_fpga_reg( FR_USER_0, 0 );

    }

};

};

#endif
