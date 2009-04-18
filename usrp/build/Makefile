CXXFLAGS = -Wall -O -I.
CFLAGS = -Wall -O -I .
INC=../include
SRC=../src

OBJS= 	fusb.o  fusb_linux.o  fusb_sysconfig_linux.o  		\
	usrp_basic.o  usrp_prims.o usrp_standard.o db_boards.o		\
	db_basic.o usrp_dbid.o db_base.o

all: 	fusb fusb_linux fusb_sysconfig_linux usrp_basic usrp_prims	\
	usrp_standard db_boards db_basic usrp_dbid db_base libgrusrp.a 

fusb: $(SRC)/$(@:=.cc) $(INC)/$(@:=.h)
	g++ -c $(SRC)/$(@:=.cc)

fusb_linux: $(SRC)/$(@:=.cc) $(INC)/$(@:=.h)
	g++ -c $(SRC)/$(@:=.cc)

fusb_sysconfig_linux: $(SRC)/$(@:=.cc) $(INC)/$(@:=.h)
	g++ -c $(SRC)/$(@:=.cc)

usrp_basic: $(SRC)/$(@:=.cc) $(INC)/$(@:=.h)
	g++ -c $(SRC)/$(@:=.cc)

usrp_prims: $(SRC)/$(@:=.cc) $(INC)/$(@:=.h)
	g++ -c $(SRC)/$(@:=.cc)

usrp_standard: $(SRC)/$(@:=.cc) $(INC)/$(@:=.h)
	g++ -c $(SRC)/$(@:=.cc)

md5: $(SRC)/$(@:=.cc) $(INC)/$(@:=.h)
	g++ -c $(SRC)/$(@:=.cc)

db_boards: $(SRC)/$(@:=.cc) $(INC)/$(@:=.h)
	g++ -c $(SRC)/$(@:=.cc)

db_basic: $(SRC)/$(@:=.cc) $(INC)/$(@:=.h)
	g++ -c $(SRC)/$(@:=.cc)

db_base: $(SRC)/$(@:=.cc) $(INC)/$(@:=.h)
	g++ -c $(SRC)/$(@:=.cc)

usrp_dbid: $(SRC)/$(@:=.cc) $(INC)/$(@:=.h)
	g++ -c $(SRC)/$(@:=.cc)


libgrusrp.a: $(OBJS)
	ar -r ../lib/$@ $^

clean:
	rm -rf *.o ../lib/libgrusrp.a *~ ../include/*~ ../src/*~
