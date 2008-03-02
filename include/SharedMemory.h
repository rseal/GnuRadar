#ifndef SHMEM_H
#define SHMEM_H

#include <sys/types.h>
#include <sys/mman.h>
#include <fcntl.h>

#include <iostream>

using namespace std;

namespace SHM{

  enum{CreateShared=0, CreatePrivate, Read, Write};

  class Exception{
  public:
   virtual void PrintError() { cerr << "Shared Memory Exception" << endl;}
   virtual ~Exception() {}
  };

  class OpenFailure: public Exception{
  public:
    virtual void PrintError() {cerr << "Shared Memory Open Failure Exception" << endl;}
  };

  class MapFailure: public Exception{
  public:
    virtual void PrintError() {cerr << "Shared Memory Map Failure Exception" << endl;}
  };

};

struct SharedMemory{
  int size_;
  void* address_;
  string fileName_;
  int desc_;
  bool isCreate_;
  int shFlags_;
  int protFlags_;
  int mapFlags_;

public:
  SharedMemory(string fileName, int size, int props, int perm): size_(size), fileName_(fileName), isCreate_(false) 
  {

    switch(props){
    case SHM::CreateShared: shFlags_ = O_CREAT | O_RDWR | O_TRUNC; 
      protFlags_ = PROT_READ | PROT_WRITE;
      mapFlags_ = MAP_SHARED;
      isCreate_ = true;      
      break;
    case SHM::CreatePrivate: shFlags_    = O_CREAT | O_RDWR | O_TRUNC;
      protFlags_   = PROT_READ | PROT_WRITE;
      mapFlags_ = MAP_PRIVATE;
      isCreate_ = true;
      break;
    case SHM::Read: shFlags_   = O_RDONLY;
      protFlags_ = PROT_READ;
      mapFlags_ = MAP_SHARED;
      break;
    case SHM::Write: shFlags_ = O_RDWR;
      protFlags_ = PROT_READ | PROT_WRITE;
      mapFlags_ = MAP_SHARED;
    }

    desc_ = shm_open(fileName_.c_str(), shFlags_, perm);
    if(!desc_) throw SHM::OpenFailure();
    address_ = mmap(0, size, protFlags_, mapFlags_ ,  desc_, 0);
    if(address_ == MAP_FAILED) throw SHM::MapFailure();
    //cout << "descriptor = " << desc_ << endl;
    //cout << "address = " << address_ << endl;
    ftruncate(desc_, size_);
  }

  void LockPages() {mlock(address_,size_);}
  void* GetPtr() {return address_;}
  
  void Resize(int size){
    size_ = size;
    ftruncate(desc_,size_);
    address_ = mmap(0, size, protFlags_, mapFlags_ ,  desc_, 0);
    if(address_ == MAP_FAILED) throw SHM::MapFailure();
    //    cout << "descriptor = " << desc_ << endl;
    //cout << "address = " << address_ << endl;
  }

  ~SharedMemory() { if(isCreate_) shm_unlink(fileName_.c_str());}
};

#endif
