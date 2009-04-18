#ifndef ALIGN_TEST_UNIT_H
#define ALIGN_TEST_UNIT_H

#include <cppunit/extensions/HelperMacros.h>
#include <iostream>
#include <fstream>
#include "../../include/Align.h"
#include <cstring>

using namespace std;


class AlignTestFixture: public CppUnit::TestFixture{

  CPPUNIT_TEST_SUITE(AlignTestFixture);
  CPPUNIT_TEST(Create);
//  CPPUNIT_TEST(Read);
  CPPUNIT_TEST_SUITE_END();
    
 public:
  void setup() {}
  void tearDown() {}

  //test for size failure
  void Create(){
      //real and imag component size in bytes
      int units = 2;
      //number of channels to receive
      int ch=1;
      //packet size in units
      int psize=256;
      //512 samples for receive window
      int win=512;
      //1msec inter-pulse period
      double IPP=1e-3;
      //there is a rounding error if used with int
      double sps = 1/IPP;

      //size of buffer in units of iq
      int size = (units*win*ch)*sps;

      //extra allocation units for data alignment
      int extra=2048;

      vector<int> seq(ch*2,8192);
      Align<int16_t> align(size,seq,extra);

      //open test data and read file into vector
      ifstream din("test.dat", ios::in | ios::binary);
 
      if(!din) {
	  cout << "ERROR: could not locate ./test.dat" << endl;
	  exit(1);
      }

      vector<int16_t> testData(win*units*sps);
      const short* tDataPtr = &testData[0];

      din.read(reinterpret_cast<char*>(&testData[0]),testData.size()*sizeof(int16_t));

      //copy incoming data to Align class
      std::memcpy(
	  align.WritePtr(), 
	  tDataPtr, 
	  align.RequestSize()
	  );

      cout << "Requested Size = " << align.RequestSize() << endl;
      align.AlignData();
      cout << "Requested Size = " << align.RequestSize() << endl;

      //validate test data
      for(int i=0; i<10; ++i)
	  cout << *(align.ReadPtr() + i) << endl;

  }
  
  void Read(){
  }
};

CPPUNIT_TEST_SUITE_REGISTRATION(AlignTestFixture);

#endif
