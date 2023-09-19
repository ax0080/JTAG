module tb_Instruction_Register ();
parameter IR_SIZE = 4;

wire 	[IR_SIZE -1: 0]	data_out;
reg		[IR_SIZE -1: 0]	data_in;

reg		scan_in;
wire	scan_out;

reg		ShiftIR, ClockIR, UpdateIR, reset_bar;

Instruction_Register M0 (
.data_in(data_in),
.data_out(data_out),
.scan_in(scan_in), 
.scan_out(scan_out),  
.ShiftIR(ShiftIR), 
.ClockIR(ClockIR), 
.UpdateIR(UpdateIR), 
.reset_bar(reset_bar)
);

initial begin
$fsdbDumpfile("test_cell.fsdb");
$fsdbDumpvars;
end

initial #500 $finish;

initial begin
data_in = 4'HA;
end

initial fork
#5  reset_bar = 0;
#10 reset_bar = 1;
join

initial begin scan_in = 1; end
initial fork
ClockIR = 0;
ShiftIR = 0;
#45 ShiftIR = 1;		// Demonstrate scan in
#40 
begin 
repeat (IR_SIZE) begin 
#10 ClockIR = 1; 
#10 ClockIR = 0; 
end 
#5 ShiftIR = 0; 
end
join

initial begin
#100 
repeat (1) begin 
#10 
ClockIR = 1; 
#10 ClockIR = 0; 
end 
end


initial fork
UpdateIR = 0; 
#150 UpdateIR = 1;
#160 UpdateIR = 0;

#200 ShiftIR = 0;
#200 ClockIR = 1;		// Demonstrate parallel load
#210 ClockIR = 0;
join

initial fork
#250 ShiftIR = 1; 		// Demonstrate scan out
#260 
begin 
repeat (IR_SIZE) begin 
#10 ClockIR = 1; 
#10 ClockIR = 0; 
end 
end
join

endmodule