NAME=ch_select

INCLUDE=../../src

all: $(NAME)

$(NAME): $(NAME)_tb.v $(INCLUDE)/$(NAME).v 
	iverilog -o $(NAME)_tb.gtk -t vvp $(NAME)_tb.v
	vvp -lxt-speed $(NAME)_tb.gtk
	gtkwave $(NAME)_tb.gtk

clean:
	rm -f *~ run $(NAME)_tb.gtk verilog.log xt-speed
