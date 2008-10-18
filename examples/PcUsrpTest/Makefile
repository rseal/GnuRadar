all: producer consumer test

producer: ProducerThread.cpp
	@echo "Building ----> Producer"
	@g++ -c ProducerThread.cpp

consumer: ConsumerThread.cpp
	@echo "Building ----> Consumer"
	@g++ -c ConsumerThread.cpp

test: GnuRadioTest.cpp ConsumerThread.o ProducerThread.o
	@echo "Building ----> GnuRadioTest"
	@g++ -o test GnuRadioTest.cpp ConsumerThread.o ProducerThread.o -lrt -lusrp -lusb 

clean:
	@rm -rf *~ test ConsumerThread.o ProducerThread.o



