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
#ifndef WINDOW_VALIDATOR_HPP
#define WINDOW_VALIDATOR_HPP

#include<gnuradar/GnuRadarTypes.hpp>
#include<gnuradar/commands/Control.pb.h>
#include<boost/shared_ptr.hpp>
#include<iostream>
#include<stdexcept>

struct WindowValidator {

	typedef std::vector<int> MeasuredWindowVector;
	typedef std::vector<gnuradar::iq_t> IqVector;
	typedef IqVector::const_iterator IqIterator;

	IqVector buffer_;
	IqIterator bufferIter_;
	MeasuredWindowVector measuredWindows_;
	gnuradar::File file_;

	// determines the number of samples between data tags
	// and repositions the iterator.
	const int getCount() {
		int count = 0;
		do {
			++count;
			++bufferIter_;
		} while (
				*bufferIter_ != gnuradar::DATA_TAG &&
				bufferIter_ != buffer_.end()
				);

		return count + 1;
	}

	// compares the determined window sizes to the
	// sizes given in the configuration file.
	const bool Compare() {
		bool result = true;

		for ( int i = 0; i < file_.window_size(); ++i ) {
			if ( file_.window(i).width() != measuredWindows_[i] ) {
				result = false;
				break;
			}
		}
		return result;
	}

	public:
	const bool Validate ( 
			const std::vector<gnuradar::iq_t>& buffer, 
			const gnuradar::File& file
			)
  	{
		file_ = file;
		buffer_ = buffer;
		bufferIter_ = buffer_.begin();

		// search for the first data tag and reposition the iterator.
		getCount();

		if ( bufferIter_ == buffer_.end() ) {
			throw std::runtime_error (
					"WindowValidator: Could not locate data tag connections.\n"
					);
		}

		++bufferIter_;

		// store a sample count for each window defined by the window vector.
		for ( int i = 0; i < file.window_size(); ++i )
			measuredWindows_.push_back ( getCount() );

		return Compare();
	}

	void PrintResults ( std::ostream& outputStream ) {

		outputStream << " window " << " configured " << "   " << " measured " << std::endl;
		for ( int i = 0; i < file_.window_size(); ++i ) {
			std::cout
				<< "   "
				<< i << "       "
				<< file_.window(i).width()
				<< "           "
				<< measuredWindows_[i]
				<< std::endl;
		}
	}
};

#endif

