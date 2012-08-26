NAME=cordic_12stage
INC1=../../../src

all: iverilog vvp

iverilog: $(NAME)_tb.v $(INC1)/$(NAME).v $(INC1)/cordic_theta_map.v  $(INC1)/cordic_shift_adder.v 
	iverilog -c $(NAME).cmd -o $(NAME)_tb.o -t vvp

vvp:
	vvp $(NAME)_tb.o -lxt2	&

gtkwave: 
	gtkwave $(NAME)_tb.lxt

clean:
	rm -f *~ *.o *.lxt
