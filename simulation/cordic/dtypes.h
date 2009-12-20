#ifndef DTYPES_H
#define DTYPES_H

#include <systemc.h>
#include <boost/shared_ptr.hpp>

typedef sc_int<18> Int18;
typedef sc_signal<Int18> SigInt18;
typedef sc_int<16> Int16;
typedef sc_signal<Int16> SigInt16;
typedef boost::shared_ptr<SigInt16> SigInt16Ptr;
typedef boost::shared_ptr<SigInt18> SigInt18Ptr;
#endif
