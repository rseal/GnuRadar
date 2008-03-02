#ifndef LOCK_H
#define LOCK_H

using namespace std;
#include <pthread.h>

class MutexException{
 public:
  virtual void PrintError() {std::cerr << "Mutex Exception" << std::endl;}
  virtual ~MutexException() {}
};

class LockException: public MutexException{
 public:
  virtual void PrintError() {std::cerr << "Lock Exception" << std::endl;}
};

class UnlockException: public MutexException{
 public:
  virtual void PrintError() {std::cerr << "Unlock Exception" << std::endl;}
};


class Mutex{
  pthread_mutex_t mutex_;
  pthread_mutexattr_t attr_;
 public:
  Mutex():mutex_(){
      pthread_mutexattr_init(&attr_);
      pthread_mutexattr_setpshared(&attr_, PTHREAD_PROCESS_SHARED);
      pthread_mutex_init(&mutex_,&attr_);      
  }
  ~Mutex() {      
      pthread_mutex_destroy(&mutex_);
  }

  void Lock(){
    if(pthread_mutex_lock(&mutex_)) throw LockException();
  }

  void Unlock(){
    if(pthread_mutex_unlock(&mutex_)) throw UnlockException();
  }
};

class ScopedLock{
  Mutex& mutex_;
 public:
  ScopedLock(Mutex& mutex): mutex_(mutex) {mutex_.Lock();}
  ~ScopedLock(){mutex_.Unlock();}
};

class ScopedPThreadLock{
  pthread_mutex_t& mutex_;
 public:
  ScopedPThreadLock(pthread_mutex_t& mutex): mutex_(mutex) {pthread_mutex_lock(&mutex_);}
  ~ScopedPThreadLock() {pthread_mutex_unlock(&mutex_);}
};

#endif
