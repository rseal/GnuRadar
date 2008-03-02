all: producer consumer test

test: PCModelTest.cpp 
	@echo "Building ----> PCModelTest"
	@g++ -o test PCModelTest.cpp ProducerThread.o ConsumerThread.o -lrt

producer: ProducerThread.cpp
	@echo "Building ----> ProducerThread"
	@g++ -c ProducerThread.cpp

consumer: ConsumerThread.cpp
	@echo "Building ----> ConsumerThread"
	@g++ -c ConsumerThread.cpp

clean:
	@rm -rf *~ test ProducerThread.o ConsumerThread.o


