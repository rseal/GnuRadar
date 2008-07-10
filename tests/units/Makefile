all: unitTestUnit 

INCLUDEDIR=../../include
SRCDIR=../../include

unitTestUnit: unitTestUnitMain.cpp unitTestUnit.h $(INCLUDEDIR)/Units.h
	g++ -o unitTestUnit unitTestUnitMain.cpp -I$(INCLUDEDIR) -lcppunit -ldl

clean:
	rm -f unitTestUnit  *~
