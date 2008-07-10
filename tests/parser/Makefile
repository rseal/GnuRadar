all: parseUnitTest 

INCLUDEDIR=../../include
SRCDIR=../../include

parseUnitTest: parserTestUnitMain.cpp parserTestUnit.h $(INCLUDEDIR)/Parser.h
	g++ -o parserTestUnit parserTestUnitMain.cpp -I$(INCLUDEDIR) -lcppunit -ldl

clean:
	rm -f parserTestUnit  *~
