all: ProducerThread ConsumerThread GnuRadioTest

CXXFLAGS= -msse3 -march=athlon-xp -fomit-frame-pointer -pipe -O2 

ProducerThread: $(@:=.cpp)
	@echo "Building ----> Producer"
	@g++ $(CXXFLAGS) -g -c $(@:=.cpp)

ConsumerThread: $(@:=.cpp)
	@echo "Building ----> Consumer"
	@g++ $(CXXFLAGS) -g -c $(@:=.cpp)

GnuRadioTest: $(@:=.cpp) ConsumerThread.o ProducerThread.o
	@echo "Building ----> GnuRadioTest"
	@g++ $(CXXFLAGS) -g -o grTest $(@:=.cpp) $? -lrt -lusrp -lusb -lpthread

clean:
	@rm -rf *~ grTest ConsumerThread.o ProducerThread.o



