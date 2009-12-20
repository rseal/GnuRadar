////////////////////////////////////////////////////////////////////////////////
///\file CommandLineParser.h
///
///
/// This file contains a custom class to parse the command line. It provides
/// methods for both argument and switch options. Additionally an interface
/// has been designed for the help switch.
///
///Author: Ryan Seal
///Modified: 06/29/07
////////////////////////////////////////////////////////////////////////////////
#ifndef COMMAND_LINE_PARSER_H
#define COMMAND_LINE_PARSER_H

#include <iostream>
#include <iomanip>
#include <vector>
#include <boost/lexical_cast.hpp>

using std::string;
using std::vector;
using std::cout;
using std::endl;

///\brief Provides an interface for defining switches on the command line. 
struct Switch{
    string name_;
    string helpDesc_;
    bool required_;
    bool set_;
    
public:
    Switch(const string& name, const string& helpDesc, const bool& required)
	: name_(name), helpDesc_(helpDesc), required_(required), set_(false) {}
    void Set(bool const& state) {set_ = state;}
    const bool& Set() {return set_;}
    const string& Name() { return name_;}
    const string& Help() { return helpDesc_;}
    const bool& Required() {return required_;}
};


///\brief Provides an interface for defining arguments on the command line
struct Arg{
    string name_;
    string helpDesc_;
    int numItems_;
    bool required_;
    bool set_;
    vector<string> list_;
    void Set(bool const& state) {set_ = state;}
public:
    Arg(
	const string& name, 
	const string& helpDesc, 
	const int& numItems, 
	const bool& required
	)
	: name_(name), helpDesc_(helpDesc), numItems_(numItems),
	  required_(required), set_(false), list_(0){}

    const int NumItems() { return numItems_;}
    const string& Value(const int& index) { return list_.at(index);}
    void Add(const string& value) { list_.push_back(value);}
    const string& Name() { return name_;};
    const string& Help() { return helpDesc_;}
    const bool& Set() { return set_;}
    const bool& Required() { return required_;}
};

///\brief CommandLineParser uses both Switch and Arg classes to 
/// provide a complete interface for parsing the command line.
struct CommandLineParser{

    string programName_;
    vector<string> inputList_;
    vector<Switch> switchList_;
    vector<Arg> argList_;
    vector<string> argHelpList_;
    vector<int> argNumInputs_;

    bool switchExists_;
    bool argExists_;

    void SwitchExists(const bool& state) { switchExists_ = state;}
    void ArgExists(const bool& state) { argExists_ = state;}    
    
public:
///Constructor accepting c-style argc and argv parameters.
    CommandLineParser(int argc, char** argv): switchExists_(false),
					      argExists_(false){
	string tStr;
	int index;

	programName_ = argv[0];
	
	for(int i=1; i<argc; ++i){
	    tStr = argv[i];
	    index = tStr.find("-");

	    //strip all hyphens
	    while( index != string::npos){
		tStr.erase(index,1);
		index = tStr.find("-");
	    }
	    inputList_.push_back(tStr);
	}     
    }

///Direct method for defining a command line argument. The user may also create an argument separately and add 
/// through the alternate AddArg(const Arg& arg) interface.
    void AddArg(string const& name, string const& helpDesc, int const& numInputs=1, bool const& required=false){
	Arg temp(Arg(name,helpDesc,numInputs,required));
	argList_.push_back(temp);
    }

///Member allowing a standalone Arg structure to be passed to the CommandLineParser structure
    void AddArg(const Arg& arg){
	argList_.push_back(arg);
    }

///Direct method for defining a command line switch. An alternate method allows a standalone Switch struct to 
/// be added by reference AddSwitch(const Switch& swtch).
    void AddSwitch(string const& name, string const& helpDesc, bool const& required=false){
	Switch temp(name, helpDesc, required);
	switchList_.push_back(temp);
    }

///Member allowing a standalone Switch structure to be passed to the CommandLineParser by reference.
    void AddSwitch(const Switch& swtch){
	switchList_.push_back(swtch);
    }

///Returns the first argument which is the name of the executed program.
    string const& ProgramName() { return programName_;}

///GetArgValue makes use of a template, allowing the user to define the return type. This allows for conversion 
/// from string to any desired type. If the conversion is not possible, an exception will be thrown. 
    template<typename T>
    const T GetArgValue(string const& name, const int& itemNum=0){
	T temp;
	for(int i=0; i<argList_.size(); ++i){
	    if(name == argList_[i].Name())
		temp = boost::lexical_cast<T>(argList_[i].Value(itemNum));
	}
	return temp;
    }

///Returns true if the switch was found in the parsed input.
    const bool SwitchSet(string const& name){
	bool result=false;
	vector<Switch>::iterator sIter;
	for(sIter = switchList_.begin(); sIter != switchList_.end(); ++sIter){
	    if(name == sIter->Name()){
		result = sIter->Set();
		break;
	    }
	}
	return result;
    }
    
///Returns true if the argument was found in the parsed input.
    const bool ArgSet(string const& name){
	bool result=false;
	vector<Arg>::iterator aIter;
	for(aIter = argList_.begin(); aIter != argList_.end(); ++aIter){
	    if(name == aIter->Name()){
//		cout << "found arg set" << endl;
		result = aIter->Set();	   
//		cout << "result = " << result << endl;
		break;
	    }
	}
	return result;
    }

///This member performs the work of parsing the command line list and storing information relating
/// to defined switches and arguments
    void Parse(){
	vector<Switch>::iterator sIter;
	vector<Arg>::iterator aIter;
	vector<string>::const_iterator inputIter = inputList_.begin();

	while(inputIter != inputList_.end()){

	    //loop through switch list for each clp argument - looking for match
	    for(sIter = switchList_.begin(); sIter != switchList_.end(); ++sIter){
		if(*inputIter == sIter->Name()){		
		    sIter->Set(true);
		    SwitchExists(true);
		}
	    }

	    //loop through arg list for each clp argument - looking for match
	    //when matched - the proper number of items should follow and be stored
	    //there is a potential for problems here - but use it for now.
	    for(aIter = argList_.begin(); aIter != argList_.end(); ++aIter){
		if(*inputIter == aIter->Name()){
		    for(int j=0; j < aIter->NumItems(); ++j){
			++inputIter;
 			aIter->Add(*inputIter);
//			cout << "adding " << *inputIter << endl;
		    }		   
		    aIter->Set(true);
		    ArgExists(true);
		}
	    }
	    ++inputIter;
	}

	//check for required switches and fail as needed.
	inputIter = inputList_.begin();
	for(sIter = switchList_.begin(); sIter != switchList_.end(); ++sIter){
	    if(sIter->Required() && sIter->Set() != true){
		cout << "CommandLineParser::Switch " << sIter->Name() << " is required for proper operation" << endl;
		exit(1);
	    }
	}
	inputIter = inputList_.begin();
	for(aIter = argList_.begin(); aIter != argList_.end(); ++aIter){
	    if(aIter->Required() && aIter->Set() != true){
		cout << "CommandLineParser::Argument " << aIter->Name() << " is required for proper operation" << endl;
		exit(1);
	    }
	}
    }

///Returns true if either an Argument or Switch was found in the parsed input.
    const bool OptionsExist() {return argExists_ || switchExists_;}

    void PrintHelp(const int& type){
	
	cout.fill(' ');

	if(type == ARGS){
	    cout << "   available arguments: " << endl;
	    if(argList_.size() == 0) 
		cout << "      No argument options available" << endl;
	    else{
		for(int i=0; i<argList_.size(); ++i)
		    cout << "      " 
			 << std::left 
			 << std::setw(10) 
			 << "-" + argList_[i].Name() 
			 << std::left 
			 << argList_[i].Help() 
			 << endl;
	    }
	    cout << endl;
	}
	else if(type == SWITCH){
	    cout << "   available switches: " << endl;
	    for(int i=0; i < switchList_.size(); ++i)
		cout << "      "
		     << std::left
		     << std::setw(10)
		     << "-" + switchList_[i].Name() 
		     << std::left 
		     << switchList_[i].Help() 
		     << endl; 
	    cout << endl;
	}
    }

    typedef CommandLineParser Clp;
    enum {ARGS=1, SWITCH=2};
};



#endif
