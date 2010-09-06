#ifndef CONDITION_HPP
#define CONDITION_HPP

#include <pthread.h>
#include <boost/shared_ptr.hpp>

namespace thread{

   struct Condition{

      pthread_cond_t condition_;

      public:

      Condition(){
         pthread_cond_init ( &condition_, NULL );
      }

      pthread_cond_t& Get() { return condition_; }
   };

   typedef boost::shared_ptr<Condition> ConditionPtr;
};

#endif
