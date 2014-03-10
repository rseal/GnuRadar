all: test shared_header

test: main.cpp Control.pb.cc.3.o
	g++ -o test main.cpp -lyaml-cpp -lprotobuf -lboost_filesystem -lboost_system Control.pb.cc.3.o

shared_header: shared_header.cpp
	g++ -o shared_header shared_header.cpp -lyaml-cpp -lboost_filesystem -lboost_system

clean: 
	rm -f test shared_header *~
