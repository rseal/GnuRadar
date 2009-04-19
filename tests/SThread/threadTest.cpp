#include<gnuradar/SThread.h>

class TestThread: public SThread{
    int value_;
public:
    TestThread(int value): value_(value){}
    virtual void Run(){
	while(true){cout << value_;}
    };
};


int main(){
    TestThread* thread2 = new TestThread(2);
    TestThread* thread1 = new TestThread(1);

    thread2->Start();
    thread1->Start();

    thread2->Wait();
    thread1->Wait();

    delete thread2;
    delete thread1;



    return 0;
}
