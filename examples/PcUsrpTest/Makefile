all: test

consumer: ConsumerThread.cpp
	@echo "Building ----> Consumer"
	@g++ -c ConsumerThread.cpp

test: GnuRadioTest.cpp 
	@echo "Building ----> GnuRadioTest"
	@g++ -o test GnuRadioTest.cpp -lrt -lusrp -lusb 

clean:
	@rm -rf *~ test ConsumerThread.o



