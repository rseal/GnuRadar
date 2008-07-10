#ifndef PARSER_TEST_UNIT_H
#define PARSER_TEST_UNIT_H

#include <cppunit/extensions/HelperMacros.h>
#include <iostream>
#include "../../include/Units.h"

using namespace std;

class UnitTestFixture: public CppUnit::TestFixture{

    CPPUNIT_TEST_SUITE(UnitTestFixture);
    CPPUNIT_TEST(Frequency);
    CPPUNIT_TEST(Time);
    CPPUNIT_TEST(Distance);
    CPPUNIT_TEST_SUITE_END();

public:
    void setup() {}
    void tearDown() {}

    //converts frequency to time (sec)
    void Frequency(){
      	string temp = "sampleRate = 50 MHz";
	Units unit;
	double multiplier = 1e6;
	CPPUNIT_ASSERT(multiplier == unit(temp));
	temp = "sampleRate = 50 KHz";
	multiplier = 1e3;
	CPPUNIT_ASSERT(multiplier == unit(temp));
	temp = "sampleRate = 50 Hz";
	multiplier = 1;
	CPPUNIT_ASSERT(multiplier == unit(temp));
    }

    //converts time units to seconds
    void Time(){
      	string temp = "sampleRate = 50 nsec";
	Units unit;
	double multiplier = 1e-9;
	CPPUNIT_ASSERT(multiplier == unit(temp));
	temp = "sampleRate = 50 usec";
	multiplier = 1e-6;
	CPPUNIT_ASSERT(multiplier == unit(temp));
	temp = "sampleRate = 50 msec";
	multiplier = 1e-3;
	CPPUNIT_ASSERT(multiplier == unit(temp));
	temp = "sampleRate = 50 sec";
	multiplier = 1;
	CPPUNIT_ASSERT(multiplier == unit(temp));
    }

    //converts distance to time (sec) assuming wave propagation at the speed of light
    void Distance(){
      	string temp = "distance = 50 km";
	Units unit;
	double multiplier = (2.0/3.0)*1e-6;
	CPPUNIT_ASSERT(multiplier == unit(temp));
	temp = "distance = 50 m";
	multiplier = (2.0/3.0)*1e-3;
	CPPUNIT_ASSERT(multiplier == unit(temp));
    }
};

CPPUNIT_TEST_SUITE_REGISTRATION(UnitTestFixture);

#endif
