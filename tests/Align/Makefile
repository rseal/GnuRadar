all: Align TestDataGenerator

INC=../../include

Align: $(@:=TestUnitMain.cpp) $(@:=TestUnit.h) $(INC)/$(@:=.h)
	g++ -o test $(@:=TestUnitMain.cpp) -I$(INC) -lcppunit -ldl

TestDataGenerator: $(@:=.cpp)
	g++ -o tsg $(@:=.cpp)

clean:
	rm -f test tsg test.dat *~
