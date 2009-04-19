all: writeTest


writeTest: usrp-interface-test.cpp  
	@g++ -o test usrp-interface-test.cpp -lusrp -lusb

clean:
	@rm -rf test *~

