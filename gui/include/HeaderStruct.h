////////////////////////////////////////////////////////////////////////////////
///HeaderStruct.h
///
///Holds information related to Header files
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef HEADER_STRUCT_H
#define HEADER_STRUCT_H

#include <iostream>
using std::string;

//holds keywords necessary for simple header creation
struct HeaderStruct{

    string institution_;
    string observer_;
    string object_;
    string radar_;
    string receiver_;
    
public:
    HeaderStruct(){}

    HeaderStruct(const string& institution, const string& observer, 
		 const string& object, const string& radar,
		 const string& receiver): 
	institution_(institution), observer_(observer), object_(object),
	radar_(radar), receiver_(receiver){}

    const string& Institution() { return institution_;}
    void Institution(const string& institution) { institution_ = institution;}
    const string& Observer() { return observer_;}
    void Observer(const string& observer) { observer_ = observer;}
    const string& Object() { return object_;}
    void Object(const string& object) { object_ = object;}
    const string& Radar() { return radar_;}
    void Radar(const string& radar) { radar_ = radar;}
    const string& Receiver() { return receiver_;}
    void Receiver(const string& receiver) { receiver_ = receiver;}
};
#endif
