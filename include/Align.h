#ifndef ALIGN_H
#define ALIGN_H

#include <boost/cstdint.hpp>
#include <vector>

using std::vector;
using std::cout;
using std::endl;
using std::auto_ptr;

template<class T>
struct Align{
    int reqSize_;
    int align_;
    vector<int> sequence_;
    int extra_;

    T* rdAddr_;
    T* wrAddr_;
    T* cpSrc_;
    T* cpDest_;
    T* bufferPtr_;

    int cpSize_;
    vector<T> buffer_;
    bool firstRun_;
    bool init_;
    long bufferSize_;
    long nextBuf_;
    long offset_;

///Searches for hardcoded sequence in data to synchronize data stream
    const bool FindSequence(){
	bool found=false;
	
	//search through buffer for sequence
	for(int i=0; i<bufferSize_; ++i){
	    //cout << "i = " << i << endl;
	    //if sequence if valid exit
	    if(found){
		cout << "origin = " << bufferPtr_ << endl;
		cout << "aligned = " << bufferPtr_+offset_ << endl;
		break;
	    }
	    //cout << "value = " << *(bufferPtr_+i) << "\n";
	    //cout << "sequence = " << sequence_[0] << endl;
	    //if first part of sequence found - check for rest
	    if(*(bufferPtr_+i) == sequence_[0]){
		offset_ = i;
		cout << "found at index = " << i << endl;
		found=true;
		for(int j=0; j<sequence_.size(); ++j){
		    if(*(bufferPtr_+i+j) != sequence_[j]){
			found=false;
			break;
		    }
		}
	    }
	    //cout << "bottom of loop" << endl;
	}
	return found;
    }
    
public:
    Align():
	reqSize_(0), extra_(0), sequence_(), firstRun_(true), 
	nextBuf_(0), offset_(0), init_(false){}

    void Init(const int& reqSize, const int& align, const vector<int>& sequence, const int& extra){
	sequence_ = sequence;
	reqSize_  = reqSize;
	align_    = align;
	extra_    = extra;
	//full allocation size
	bufferSize_  = reqSize_ + align_ + extra_;
	//allocate space for 2 buffers - handle addressing manually
	buffer_.resize(2*bufferSize_);
	bufferPtr_ = &buffer_[0];
	wrAddr_ = bufferPtr_;
	rdAddr_ = bufferPtr_;
	cpSrc_  = bufferPtr_;
	cpDest_ = bufferPtr_;
	init_ = true;
	cout << "Align::Init Variables" << "\n"
	     << "reqSize_    = " << reqSize_    << "\n"
	     << "bufferSize_ = " << bufferSize_ << "\n"
	     << "bufferPtr_  = " << bufferPtr_  << "\n"
	     << "wrAddr_     = " << wrAddr_     << "\n"
	     << "rdAddr_     = " << rdAddr_     << endl;
    };

     T* ReadPtr()  { return rdAddr_;}
     T* WritePtr() { return wrAddr_;}

    void AlignData() {
	
	if(firstRun_){
	    if(!init_){
		cout << "Align: Please call Init(x,x,x) function before using Align class" << endl;
		exit(1);
	    }
	    cout << "Align: Search for sequence" << endl;
	    //find sequence for alignment on first run
	    if(!FindSequence()){
		cout << "Align: Sequence not found! Check sequence settings and data connection" << endl;
		exit(1);
	    }
	    cout << "Align: First Run" << endl;
	}    

	//offset + requested size of current buffer
	cpSrc_ = bufferPtr_ + reqSize_ + (firstRun_ ? offset_ : 0);
	//endpoint of internal buffer - cp address
	cpSize_ = bufferPtr_ + bufferSize_ - cpSrc_;

	//read address
	rdAddr_ = firstRun_ ? bufferPtr_ + offset_ : bufferPtr_;

	//switch buffers
	nextBuf_ = nextBuf_ ? 0 : 1;
	bufferPtr_ = &buffer_[bufferSize_*nextBuf_];

	//new location
	cpDest_ = bufferPtr_;

	//new write address
	wrAddr_ = cpDest_ + cpSize_;

 	cout << "cpSrc_     = " << cpSrc_     << "\n"
 	     << "cpDest_    = " << cpDest_    << "\n"
 	     << "cpSize_    = " << cpSize_    << "\n"
 	     << "nextBuf_   = " << nextBuf_   << "\n"
 	     << "rdAddr_    = " << rdAddr_    << "\n"
 	     << "wrAddr_    = " << wrAddr_    << "\n"
	     << "bufferPtr_ = " << bufferPtr_ << endl;
	
	//copy leftover data to top of next buffer
	memcpy(cpDest_,cpSrc_, cpSize_*sizeof(T));

	firstRun_=false;
	
    };
    
    ///Request size for data alignment
    const int RequestSize() { return firstRun_ ? bufferSize_ : reqSize_ + align_;}
};

#endif
