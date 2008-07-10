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
    parse.AddComment("This is really purposely a long comment to test the wraparound effect and look at the \
alignment of the comment made");
    parse.Put("key1", "string1");
    parse.Put("key5", "string5");
    parse.Put("key6", "string6");
    parse.AddComment("KEY2");
    parse.Put("key2", "string2");
    parse.AddComment("KEY3");
    parse.Put("key3", 5);
    parse.AddComment("KEY4");
    parse.Put("key4", 6.0f);
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
