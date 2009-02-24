NAME=ext_gate_tb

INCLUDE=../../sdr_lib

all: $(NAME)

$(NAME): $(NAME).v $(INCLUDE)/rx_buffer_ge.v 
	iverilog -o $(NAME).gtk -t vvp $(NAME).v
	vvp -lxt-speed $(NAME).gtk
#	cver $(NAME).v
#	gtkwave $(NAME).gtk

clean:
	rm -f *~ run $(NAME).gtk verilog.log
