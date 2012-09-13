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
#include <gnuradar/ConsumerThread.h>

// worker thread implementation.
void ConsumerThread::Run()
{
   static const char* LOCK_FILE = "/dev/shm/gnuradar.lock";
   running_ = true;

	std::cout << "Consumer Thread Started " << std::endl;

   while( running_ ){


      // sleep if no data available
      if(!bufferManager_->DataAvailable()){
         this->Pause( *BaseThread::condition_, *BaseThread::mutex_ );
      }

		std::cout << "Buffer address = " << (long)bufferManager_->ReadFrom() << std::endl;

      // write an HDF5 table to disk
		h5File_->CreateTable ( cpx_.GetRef(), space_ );
		h5File_->WriteTStrAttrib ( "TIME", time_.GetTime() );
		h5File_->WriteTable ( bufferManager_->ReadFrom() );

      bufferManager_->IncrementTail();

      // TODO: Fix me. throw exception
      if( bufferManager_->OverFlow() ){
         std::cout << "OVERFLOW DETECTED !!!!" << std::endl;
      }

      // create a lock file for other readers
      std::ofstream out( LOCK_FILE );
      out.close();

      // update the header file
      header_->Write(
            bufferManager_->Head(), 
            bufferManager_->Tail(), 
            bufferManager_->Depth()
            );

      // remove lock after update
      boost::filesystem::remove_all( LOCK_FILE );
   }
   h5File_->Close();
   std::cout << "Consumer Thread Exiting " << std::endl;
}
