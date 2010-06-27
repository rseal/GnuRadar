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
////////////////////////////////////////////////////////////////////////////////
///Parser.h
///
///Custom parser to load/store settings in ASCII format.
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef PARSER_H
#define PARSER_H

#include<iostream>
#include<sstream>
#include<fstream>
#include<map>
#include<algorithm>
#include<boost/lexical_cast.hpp>

using namespace std;
using boost::lexical_cast;

class ParserException
{
 public:
  virtual ~ParserException(){};
  virtual void PrintError() { cout << "Exception Thrown (from Parser Class)" << endl;}
};
  
class FileOpenException: public ParserException
{
 public:
  virtual void PrintError() { cout << "File could not be opened (from Parser Class)" << endl; }
};

class NoKeyException: public ParserException
{
 public:
  virtual void PrintError() { cout << "Key/Value pair does not exist (from Parser Class)" << endl; }
};

class Parser{
  
  string filename_;
  int mode_;
  char delim_;

 public:

  typedef map<string, string> MapType;
  typedef MapType::iterator Iter;
  typedef vector<string>::iterator StrIter;
  typedef MapType::value_type ValueType;

  MapType map_;
  vector<string> printList_;
  
  explicit Parser(string filename, char delim='='): filename_(filename), delim_(delim){}

  void Delimiter(char delim) { delim_ = delim;}
  const char& Delimiter() {return delim_;}

  template <typename T>
    T Get(const string& name){
    Iter iter_ = map_.find(name);
    if(iter_ == map_.end()) throw NoKeyException();
    return lexical_cast<T>(iter_->second);
  }

  const int GetHex(string name){
    Iter iter_ = map_.find(name);
    if(iter_ == map_.end()) throw NoKeyException();
    return lexical_cast<int>(iter_->second);
  }

  string Get(string name){
    Iter iter_ = map_.find(name);
    if(iter_ == map_.end()) throw NoKeyException();
    return iter_->second;
  }

  void AddSpace(){
    printList_.push_back("");
  }

  template <typename T>
    void Put(string name, T value){
    Iter iter_ = map_.find(name);
    string str = lexical_cast<string>(value);
    //if nonexisting map then add else update value
    if(iter_ == map_.end()){
	map_.insert(ValueType(name,str));
      printList_.push_back(name + delim_ + str);
    }    
    else
      iter_->second = str;
  }

  void PutHex(string name, int value){
    Iter iter_ = map_.find(name);
    string str = lexical_cast<string>(value);
    //if nonexisting map then add else update value
    if(iter_ == map_.end()){
	map_.insert(ValueType(name,str));
      printList_.push_back(name + delim_ + str);
    }    
    else
      iter_->second = str;
  }

  void Put(string name, string value){
    Iter iter_ = map_.find(name);
    StrIter strIter = printList_.begin();

    //if nonexisting map then add else update value
    if(iter_ == map_.end()){
      map_.insert(ValueType(name,value));
      printList_.push_back(name + delim_ + value);
    }    
    else{
      iter_->second = value;
      while(strIter != printList_.end()){
	if(strIter->find(name+delim_) != string::npos)
	  *strIter = name + delim_ + value;
	++strIter;
      }
    }
  }

  void AddComment(string comment){
    int count=1;
    uint size=40;
    if(comment.size() > size) count += comment.size()/size;

    for(int i=0; i<count; ++i){
    string pad(3,'#');
    printList_.push_back(pad + " " + comment.substr(i*size,size) + " " + pad); 
    }
  }

  void Clear(){
    //reset the printList to load the file
    printList_.clear();
  }

  void Load(char delim = '='){

    int index;
    string str;
    ifstream in(filename_.c_str(), ios::in);

    if(!in) {
      cout << filename_ << " does not exist" << endl;
      //      throw FileOpenException();
    }

    //read and parse the entire file.
    while(!in.eof()){
      getline(in,str);
      printList_.push_back(str);
      index = str.find(delim);
      if(index != (int)string::npos)
	map_.insert(ValueType(str.substr(0,index), str.substr(index+1,str.length())));
    }

  }

  void Print(){
    StrIter iter_ = printList_.begin();
    while(iter_ != printList_.end()){
      cout << *iter_ << endl;
      ++iter_;
    }
  }

  void Write(){
    StrIter iter_ = printList_.begin();
    ofstream out(filename_.c_str(), ios::out);
    if(!out) throw FileOpenException();
        
    while(iter_ != printList_.end()){
      out << *iter_ << endl;
      ++iter_;
    }
  }
};

#endif
