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
#ifndef PARSER_H
#define PARSER_H

#include<iostream>
#include<sstream>
#include<fstream>
#include<map>
#include<algorithm>

using std::string;

class ParserException
{
 public:
  virtual ~ParserException(){};
  virtual void PrintError() { std::cout << "Exception Thrown (from Parser Class)" << std::endl;}
};
  
class FileOpenException: public ParserException
{
 public:
  virtual void PrintError() { std::cout << "File could not be opened (from Parser Class)" << std::endl; }
};

class NoKeyException: public ParserException
{
 public:
  virtual void PrintError() { std::cout << "Key/Value pair does not exist (from Parser Class)" << std::endl; }
};

class Parser{
  
  std::string filename_;
  int mode_;
  char delim_;

 public:

  typedef std::map<std::string, std::string> MapType;
  typedef MapType::iterator Iter;
  typedef std::vector<std::string>::iterator StrIter;
  typedef MapType::value_type ValueType;

  MapType map_;
  std::vector<std::string> printList_;
  
  explicit Parser(std::string filename, char delim='='): filename_(filename), delim_(delim){}

  void Delimiter(char delim) { delim_ = delim;}
  const char& Delimiter() {return delim_;}

  template <typename T>
    T Get(const std::string& name){
    T result = T();
    Iter iter_ = map_.find(name);
    if(iter_ == map_.end()) throw NoKeyException();
    std::istringstream istr(iter_->second);
    istr >> result;
    return result;
  }

  const int GetHex(std::string name){
    int result;
    Iter iter_ = map_.find(name);
    if(iter_ == map_.end()) throw NoKeyException();
    std::istringstream istr(iter_->second);
    istr >> std::hex >> result;
    return result;
  }

  std::string Get(std::string name){
    Iter iter_ = map_.find(name);
    if(iter_ == map_.end()) throw NoKeyException();
    return iter_->second;
  }

  void AddSpace(){
    printList_.push_back("");
  }

  template <typename T>
    void Put(std::string name, T value){
    Iter iter_ = map_.find(name);
    std::ostringstream ostr;
    ostr << value;

    //if nonexisting map then add else update value
    if(iter_ == map_.end()){
      map_.insert(ValueType(name,ostr.str()));
      printList_.push_back(name + delim_ + ostr.str());
    }    
    else
      iter_->second = ostr.str();
  }

  void PutHex(std::string name, int value){
    Iter iter_ = map_.find(name);
    std::ostringstream ostr;
    ostr << std::hex << value;
    
    //if nonexisting map then add else update value
    if(iter_ == map_.end()){
      map_.insert(ValueType(name,ostr.str()));
      printList_.push_back(name + delim_ + ostr.str());
    }    
    else
      iter_->second = ostr.str();
  }



  void Put(std::string name, std::string value){
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

  void AddComment(std::string comment){
    int count=1;
    uint size=40;
    if(comment.size() > size) count += comment.size()/size;

    for(int i=0; i<count; ++i){
    std::string pad(3,'#');
    printList_.push_back(pad + " " + comment.substr(i*size,size)); 
    }
  }

  void Clear(){
    //reset the printList to load the file
    printList_.clear();
  }

  void Load(char delim = '='){

    int index;
    std::string str;
    std::ifstream in(filename_.c_str(), std::ios::in);

    if(!in) {
      std::cout << filename_ << " does not exist" << std::endl;
      //      throw FileOpenException();
    }

    //read and parse the entire file.
    while(!in.eof()){
      getline(in,str);
      printList_.push_back(str);
      index = str.find(delim);
      if(index != (int)std::string::npos)
	map_.insert(ValueType(str.substr(0,index), str.substr(index+1,str.length())));
    }

  }

  void Print(){
    StrIter iter_ = printList_.begin();
    while(iter_ != printList_.end()){
      std::cout << *iter_ << std::endl;
      ++iter_;
    }
  }

  void Write(){
    StrIter iter_ = printList_.begin();
    std::ofstream out(filename_.c_str(), std::ios::out);
    if(!out) throw FileOpenException();
        
    while(iter_ != printList_.end()){
      out << *iter_ << std::endl;
      ++iter_;
    }
  }
};

#endif
