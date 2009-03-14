NAME=rx_fifo
INC1=../../src
INC2=../../include
INC3=../../src/megacells

all: $(NAME)

$(NAME): $(NAME)_tb.v $(INC1)/$(NAME).v 
	iverilog -o $(NAME)_tb.gtk -t vvp -s$(NAME)_tb -I$(INC1) -I$(INC2) -I$(INC3) $(NAME)_tb.v
	vvp -lxt-speed $(NAME)_tb.gtk
	gtkwave $(NAME)_tb.gtk
clean:
	rm -f *~ run $(NAME)_tb.gtk verilog.log xt-speed
