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
   running_ = true;

   while( running_ ){

      std::cout << "consumer running" << std::endl;

      // sleep if no data available
      if(!bufferManager_->DataAvailable()){
         std::cout << "consumer sleeping" << std::endl;
         this->Pause( *BaseThread::condition_, *BaseThread::mutex_ );
      }

      std::cout << "consumer writing table to disk" << std::endl;
      // write an HDF5 table to disk
      h5File_->CreateTable ( cpx_.GetRef(), space_ );
      h5File_->WriteTStrAttrib ( "TIME", time_.GetTime() );
      h5File_->WriteTable ( bufferManager_->ReadFrom() );

      bufferManager_->IncrementTail();

      // TODO: Fix me. throw exception
      if( bufferManager_->OverFlow() ){
         std::cout << "OVERFLOW DETECTED !!!!" << std::endl;
      }

   }
   h5File_->Close();
   std::cout << "consumer exiting " << std::endl;
}
