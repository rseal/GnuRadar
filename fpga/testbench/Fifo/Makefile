NAME=fifo_mc
INC1=../../src/megacells
INC2=../../models

all: iverilog vvp

iverilog: $(NAME)_tb.v $(INC1)/$(NAME).v 
	iverilog -o $(NAME)_tb.o -t vvp -s$(NAME)_tb -I$(INC1) -I$(INC2) $(NAME)_tb.v

vvp:
	vvp $(NAME)_tb.o -lxt2	&

gtkwave: 
	gtkwave $(NAME)_tb.lxt

clean:
	rm -f *~ *.o *.lxt
