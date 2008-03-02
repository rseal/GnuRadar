#ifndef STHREAD_H
#define STHREAD_H

#include <iostream>
#include <sys/time.h>
#include <errno.h>
#include <pthread.h>
#include <gnuradar/Lock.h>

using std::cerr;
using std::endl;

namespace ST{
  enum{ us, ms, sec};
};

class SThread
{
  
 public:

    SThread() {  
	pthread_mutex_init(&mutex_,NULL);
	pthread_attr_init(&attr_);
	pthread_cond_init(&condition_, NULL);
    }

  virtual ~SThread(){
  }

  virtual void Run()=0;
 
  static void* Init(void* _this){
   SThread* p_object = reinterpret_cast<SThread*>(_this);
   p_object->Run();
   return NULL;
  }

  void Start(){
    int status=-1;
    status = pthread_create(&p_sthread_, NULL, Init, this);
    if(status < 0)
      cerr << "STHREAD: thread creation failed" << endl;
  }    
 
  void Wait(){ pthread_join(p_sthread_, NULL);}

  void Detach(){pthread_detach(p_sthread_);}

  void Destroy(){
    int status;
    pthread_exit(reinterpret_cast<void*>(&status));
  }

//  void Lock(Mutex& mutex) {mutex.Lock();}
//  void Unlock(Mutex& mutex) {mutex.Unlock();}
  
  void Lock(pthread_mutex_t& mutex){
    pthread_mutex_lock(&mutex);
  }

  void Unlock(pthread_mutex_t& mutex){
    pthread_mutex_unlock(&mutex);
  }
  
  void Pause(){
    ScopedPThreadLock Lock(mutex_);
    pthread_cond_wait(&condition_, &mutex_);
  }

  void Wake(){ pthread_cond_signal(&condition_);}
  
  void Sleep(int _type = ST::us, long _value = 1000){
    int status=0;

    gettimeofday(&time_now_, NULL);

    switch(_type){
    case ST::us:
      timeout_.tv_sec = time_now_.tv_sec;
      timeout_.tv_nsec = time_now_.tv_usec + 1000*_value;
      break;
    case ST::ms:
      timeout_.tv_sec = time_now_.tv_sec;
      timeout_.tv_nsec = time_now_.tv_usec + _value*1000000;
      break;
    case ST::sec:
      timeout_.tv_sec = time_now_.tv_sec + _value;
      timeout_.tv_nsec = time_now_.tv_usec*1000;
      break;
    default:
      cerr << "STHREAD: invalid sleep value. default to 1 sec" << endl;
      timeout_.tv_sec = time_now_.tv_sec + 1;
      timeout_.tv_nsec = time_now_.tv_usec*1000;
    }

    ScopedPThreadLock Lock(mutex_);
    while(status != ETIMEDOUT)
      status  = pthread_cond_timedwait(&condition_, &mutex_, &timeout_);
  }  

  void Priority(int _value);
  void SetCondition(int _value);

 protected:
  pthread_t p_sthread_;
  pthread_mutex_t mutex_;
  pthread_attr_t attr_;
  pthread_cond_t condition_;
  timeval time_now_;
  timespec timeout_;
};

#endif
