#ifndef GNURADAR_VERIFY_HPP
#define GNURADAR_VERIFY_HPP

#include<usrp_standard.h>
#include <gnuradar/GnuRadarSettings.h>
#include <gnuradar/ConfigFile.h>
#include <gnuradar/GnuRadarTypes.hpp>
#include <gnuradar/WindowValidator.hpp>
#include <clp/CommandLineParser.hpp>
#include <stdexcept>
#include <vector>

typedef std::vector<gnuradar::iq_t> Buffer;
typedef Buffer::iterator BufferIterator;

Buffer buffer;
#endif
