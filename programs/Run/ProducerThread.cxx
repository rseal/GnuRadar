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
#include <ProducerThread.h>

/// worker thread implementation. Calls GnuRadarDevice's
/// StartDevice method.
void ProducerThread::Run()
{
   running_ = true;

   std::cout << "Starting Producer Thread" << std::endl;

   while( running_ ){

      device_->RequestData ( bufferManager_->WriteTo() , 
            bufferManager_->BytesPerBuffer() );

      bufferManager_->IncrementHead();

      // wake the consumer thread
      this->Wake( *BaseThread::condition_, *BaseThread::mutex_ );
   }
      //we're exiting now, make sure Consumer is awake.
      this->Wake( *BaseThread::condition_, *BaseThread::mutex_ );
      std::cout << "Stopping Producer Thread" << std::endl;
}
