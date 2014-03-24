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

#include <GnuRadarTypes.hpp>
#include <commands/Control.pb.h>
#include<boost/shared_ptr.hpp>
#include<boost/lexical_cast.hpp>
#include<iostream>
#include<stdexcept>

struct SystemValidation {

	typedef std::vector<int> WindowVector;
	typedef std::vector<gnuradar::iq_t> IqVector;
	typedef IqVector::const_iterator IqIterator;

	IqVector buffer_;
	IqIterator bufferIter_;
	WindowVector measuredWindows_;
	WindowVector windowWidth_;
	gnuradar::File* file_;

	// determines the number of samples between data tags
	// and repositions the iterator.
	int getCount() 
	{
		int count = 0;
		do
	  	{
			++count;
			++bufferIter_;
		} while ( *bufferIter_ != gnuradar::DATA_TAG && bufferIter_ != buffer_.end());

		return count + 1;
	}

	// compares the determined window sizes to the
	// sizes given in the configuration file.
	bool Compare()
	{

		bool result = true;

		for(int i=0; i<file_->window_size(); ++i)
		{
			double start = file_->window(i).start();
			double stop = file_->window(i).stop();
			int width = ceil(stop-start);
			windowWidth_.push_back(width);

			if( width != measuredWindows_[i] )
			{
				result = false;
				break;
			}
		}

		return result;
	}

	public:
	bool Validate ( const std::vector<gnuradar::iq_t>& buffer, gnuradar::File* file)
	{
		file_ = file;
		buffer_ = buffer;
		bufferIter_ = buffer_.begin();

		// search for the first data tag and reposition the iterator.
		getCount();

		if ( bufferIter_ == buffer_.end() ) {
			throw std::runtime_error (
					"SystemValidation: Could not locate data tag connections.\n"
					);
		}

		++bufferIter_;

		// store a sample count for each window defined by the window vector.
		for ( int i = 0; i < file_->window_size(); ++i )
			measuredWindows_.push_back ( getCount() );

		return Compare();
	}

	std::string GetResults ( ) 
	{
		std::string result;
		for ( int i = 0; i < file_->window_size(); ++i ) 
		{
			double start = file_->window(i).start();
			double stop = file_->window(i).stop();
			result+= "window   : " + boost::lexical_cast<string>(i) + "\n";
			result+= "start    : " + boost::lexical_cast<string>(start) + "\n";
			result+= "stop     : " + boost::lexical_cast<string>(stop) + "\n";
			result+=	"width    : " + boost::lexical_cast<string>(windowWidth_[i]) + "\n";
			result+= "measured : " + boost::lexical_cast<string>(measuredWindows_[i]) + "\n";
		}

		return result;
	}

};

#endif

