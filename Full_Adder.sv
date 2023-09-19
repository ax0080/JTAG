module Full_Adder (sum, c_out, a, b, c_in);
parameter 	SIZE = 4;

input		[SIZE -1: 0] a, b;
input 		c_in;
output 		[SIZE -1: 0] sum;
output 		c_out;

 
assign {c_out, sum} = a + b + c_in;

endmodule