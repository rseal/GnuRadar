all: ProducerThread ConsumerThread GnuRadioTest

ProducerThread: $(@:=.cpp)
	@echo "Building ----> Producer"
	@g++ -g -c $(@:=.cpp)

ConsumerThread: $(@:=.cpp)
	@echo "Building ----> Consumer"
	@g++ -g -c $(@:=.cpp)

GnuRadioTest: $(@:=.cpp) ConsumerThread.o ProducerThread.o
	@echo "Building ----> GnuRadioTest"
	@g++ -g -o grTest $(@:=.cpp) $? -lrt -lusrp -lusb 

clean:
	@rm -rf *~ grTest ConsumerThread.o ProducerThread.o



