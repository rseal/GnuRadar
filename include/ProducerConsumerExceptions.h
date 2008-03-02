#ifndef PRODUCERCONSUMEREXCEPTIONS_H
#define PRODUCERCONSUMEREXCEPTIONS_H

#include <iostream>

using std::endl;
using std::cerr;

namespace PCException{
    class Exception{
	virtual void PrintError() {cerr << "General ProducerConsumer Exception thrown" << endl;}
    };
    class OverFlow: public Exception{
	virtual void PrintError() {cerr << "ProducerConsumer OverFlow Exception thrown" << endl;}
    };
};

#endif
