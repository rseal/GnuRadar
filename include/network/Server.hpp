#ifndef SERVER_HPP
#define SERVER_HPP

#include <SThread.h>

namespace gnuradar{
   namespace network{

      //////////////////////////////////////////////////////////////////////////
      //
      //////////////////////////////////////////////////////////////////////////
		class Server : public thread::SThread {

			protected:
				bool active_;

			public:
				Server() : active_(false) {}

				bool IsActive() { return active_; }
		};
	};
};

#endif
