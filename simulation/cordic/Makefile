all: cordic_test


cordic_test: cordic_stage.hpp cordic.hpp test_bench.cpp 
	g++ -g -msse3 -march=native -o cordic_test test_bench.cpp -lsystemc


clean:
	rm -rf cordic_test *~
