/********************************************************************
*																	*
*	tb_Boundary_Scan_Cell:											*
*	test case 1: EXTEST=0, Bypass, TDO <= data_in					*
*	test case 2: EXTEST=1, TDO <= TDI, data_out <= TDI 				*
*	 																*
*	 																*
*	 																*
*	 																*
*	 																*
*	 																*
*																	*
*																	*
********************************************************************/

`timescale 1ns/100ps 
module tb_Boundary_Scan_Cell();
parameter size = 8;

reg [size-1 : 0] data_in; 
wire [size-1 : 0] data_out;
reg scan_in;
wire scan_out;

//clock
reg ClockDR;
 
//Control Signal
reg ShiftDR, UpdateDR, mode;


Boundary_Scan_Cell 
#(
	.size(8)
)
bsc
(
	.data_in(data_in),
	.data_out(data_out),
	.scan_in(scan_in),
	.scan_out(scan_out),
	.ClockDR(ClockDR),
	.ShiftDR(ShiftDR),
	.UpdateDR(UpdateDR),
	.mode(mode)
);

initial begin
//waveform
$fsdbDumpfile("test_cell.fsdb");
$fsdbDumpvars;
end	

initial #520 $finish;

initial begin
data_in = 8'HAA;
scan_in = 0;
#50 scan_in = 1;
end

initial fork
mode = 0;
#350 mode = 1;
#400 mode = 0;

ShiftDR = 0;
ClockDR = 0;
UpdateDR = 0;

#50 ClockDR = 1;
#60 ClockDR = 0;

#90 UpdateDR = 1;
#100 UpdateDR = 0;
join

initial fork
#120 ShiftDR = 1;
#130 
initial
repeat (8) begin 
#10 ClockDR = 1; 
#10 ClockDR = 0; 
end 
#5 ShiftDR = 0; 
end
join

initial fork
UpdateDR = 0; 
#330 UpdateDR = 1;
#340 UpdateDR = 0;
#440 ClockDR = 1;
#450 ClockDR = 0;

join
	
endmodule