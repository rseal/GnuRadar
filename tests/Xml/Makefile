all: test

test: sharedBuffer_test.cpp
	g++ -o test sharedBuffer_test.cpp -ltinyxmlcpp -DTIXML_USE_TICPP -lboost_filesystem

clean:
	rm -f test
	
