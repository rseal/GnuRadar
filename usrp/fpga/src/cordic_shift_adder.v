
module cordic_shift_adder( a, b, out, sign );

parameter A_WIDTH  = 16;
parameter B_WIDTH  = 16;
parameter O_WIDTH  = 16;

// Since b is typically a smaller bit-width than a, we use a signed data type
// to properly sign-extend b to match a. Does this defeat savings achieved 
// by bit trimming?
input  wire signed [ A_WIDTH-1:0 ] a; 
input  wire signed [ B_WIDTH-1:0 ] b;
output wire [ O_WIDTH-1:0 ] out;
input  wire sign;

// Simple add/substract operation controlled by sign
assign out = a + ( sign ? -b : b ) ;

endmodule
