#ifndef PARSER_TEST_UNIT_H
#define PARSER_TEST_UNIT_H

#include <cppunit/extensions/HelperMacros.h>
#include <iostream>
#include "../../include/Parser.h"

using namespace std;

class ParserTestFixture: public CppUnit::TestFixture{

  CPPUNIT_TEST_SUITE(ParserTestFixture);
  CPPUNIT_TEST(Create);
  CPPUNIT_TEST(Read);
  CPPUNIT_TEST_SUITE_END();

 public:
  void setup() {}
  void tearDown() {}

  //test for size failure
  void Create(){
    Parser parse("./parseFile.test");
    parse.AddComment("This is really purposely a long comment to test the wraparound effect and look at the"
		     "alignment of the comment made");
    parse.AddComment("USRP External Clock Rate");
    parse.Put("RefClk", "50 MHz");
    parse.AddComment("USRP Decimation");
    parse.Put("Decimation", "2");
    parse.AddComment("Complex Sample Size (bytes)");
    parse.Put("SampleWidth", 4);
    parse.AddComment("USRP Mux Setting");
    parse.PutHex("Mux", 0x0f0f1f1f);
    parse.Write();
  }
  
  void Read(){
    Parser parse("./parseFile.test");
    parse.Load();
    parse.Print();
    CPPUNIT_ASSERT(parse.Get<string>("key1") == "string1");
    CPPUNIT_ASSERT(parse.Get<string>("key2") == "string2");
    CPPUNIT_ASSERT(parse.Get<int>("key3") == 5);
    CPPUNIT_ASSERT(parse.Get<float>("key4") == 6.0f);
    CPPUNIT_ASSERT(parse.Get<string>("key5") == "string5");
  }
};

CPPUNIT_TEST_SUITE_REGISTRATION(ParserTestFixture);

#endif
