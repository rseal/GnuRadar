all: client

client: client_test.cpp
	g++ -o client_test client_test.cpp -lpthread -lboost_system -ltinyxmlcpp -DTIXML_USE_TICPP

clean:
	rm -f client_test *~
	

	
