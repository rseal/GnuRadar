////////////////////////////////////////////////////////////////////////////////
///UsrpConfigStruct.cxx
///
///Provides necessary rule checking and conversions for displayed/stored 
///configuration data.
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#include "../include/UsrpConfigStruct.h"

///UsrpConfigStruct Contructor
///Provides variable initialization for optional variables.
UsrpConfigStruct::UsrpConfigStruct(): 
    validSampleRate_(false),channels_(4),sampleRate_(0),decimation_(0),
    numChannels_(0),ipp_(0),fpgaImage_("../../fpga/std_4rx_0tx.rbf")
{
//    std::cout << "UsrpConfigStruct::CTOR" << std::endl;
	
}

///Stores DDC and Phase settings for the specified channel.
void UsrpConfigStruct::Channel(const int& chNum, const float& ddc, 
				const float& phase){
    if(chNum != 1 || chNum !=2 || chNum !=4)
	cerr << "UsrpConfigStruct::ProgramChannel - invalid channel number " 
	     << chNum << " requested" << endl;
    else{
	channels_[chNum].ddc = ddc;
	channels_[chNum].phase = phase;
    }    
}

///Validates and stores the desired Sample Rate
///This must match the external clock frequency used
///by the USRP. If using the internal clock, set to 64MHz.
void UsrpConfigStruct::SampleRate(const float& sampleRate){
    if(sampleRate < 1e6 || sampleRate > 64e6){
	cerr << "UsrpConfigStruct::SampleRate - invalid sample rate "
	     << sampleRate << " requested" << endl;
	validSampleRate_ = false;
    }
    else{
	sampleRate_ = sampleRate;
	validSampleRate_ = true;
    }
}

///Validates and stores the number of channels used.
void UsrpConfigStruct::NumChannels(const int& numChannels){
    if(numChannels != 1 || numChannels !=2 || numChannels !=4)
	cerr << "UsrpConfigStruct::NumChannels - invalid number of channels " 
	     << numChannels << " requested" << endl;
    else numChannels_ = numChannels;
}

///Validates and stores the selected decimation. 
void UsrpConfigStruct::Decimation(const int& decimation){
    if(decimation < 8 || decimation > 256)
	cerr << "UsrpConfigStruct::Decimation - invalid decimation request "
	     << decimation << endl;
    else
	decimation_ = decimation;

}

///Validates and stores the Interpulse Period (IPP) length. 
///Units are stored in microseconds
void UsrpConfigStruct::IPP(const int& ipp, const int& units){
    float scale=1.0f;

    switch(units){
    case 0: //msec
	scale = 1000.0f;
	break;
    case 1: //usec
	scale = 1.0f;
	break;
    case 2: //Km
	scale = 6.6667f;
	break;
    default:
	cerr << "UsrpConfigStruct::IPP - invalid units " << units << " detected" << endl;
    } 
	    
    ipp_ = static_cast<int>(ipp*scale);
    ippUnits_ = units;
}

///Stores the FPGA bit image to load into the FPGA
void UsrpConfigStruct::FPGAImage(const string& fpgaImage){
    if(fpgaImage.size() == 0) 
	cerr << "UsrpConfigStruct::FPGAImage - empty string detected" << endl;
    else
	fpgaImage_ = fpgaImage;
}

///Stores the system's data window selection.
///Stored units are samples.
void UsrpConfigStruct::DataWindow(const int& start, const int& size, const int& units){
    float scale=1.0f;
    int start_,size_;

    if(!validSampleRate_) 
	cerr << "UsrpConfigStruct::DataWindow - invalid sample rate detected" << endl;
    else{
	switch(units){
	case 0: //Samples
	    scale = 1.0f;
	    break;
	case 1: //usec
	    scale = 1.0f/sampleRate_;
		break;
	case 2: //kilometers
	    scale = 6.6667f/sampleRate_;
	    break;
	default:
	    cerr << "UsrpConfigStruct::DataWindow - invalid units " 
		 << units << " requested" << endl;
	}
	
	start_ = static_cast<int>(start*scale);
	size_ = static_cast<int>(size*scale);
	DataWindowStruct dw(start_,size_,units);
	windows_.push_back(dw);
    }
}

///Stores Header information
void UsrpConfigStruct::Header(const HeaderStruct header){
    header_ = header;
}
