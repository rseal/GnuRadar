NAME=strobe_gen_tb

all: $(NAME)

strobe_gen_tb: $(NAME).v
	cver $(NAME).v
	gtkwave $(NAME).gtk

clean:
	rm -f *~ run $(NAME).gtk verilog.log
