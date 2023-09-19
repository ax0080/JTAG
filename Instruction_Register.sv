/********************************************************************
*																	*
*	Instruction_Register:											*
*																	*
*	 																*
*	 																*
*	 																*
*	 																*
*	 																*
*	 																*
*	 																*
*																	*
*																	*
********************************************************************/
module Instruction_Register (data_in, data_out, scan_in, scan_out, ClockIR, ShiftIR, UpdateIR, reset_bar);
parameter IR_SIZE = 4;

input	[IR_SIZE-1 : 0] data_in;
output 	[IR_SIZE-1 : 0] data_out;

input	scan_in;
output	scan_out;

input	ClockIR;
input	ShiftIR; 
input	UpdateIR; 
input	reset_bar;

reg	[IR_SIZE-1 : 0]	IR_Scan_Register;
reg	[IR_SIZE-1 : 0] IR_Output_Register;

assign	data_out = IR_Output_Register;
assign	scan_out = IR_Scan_Register[0];

always @ (posedge ClockIR) begin
	IR_Scan_Register <= ShiftIR ? {scan_in, IR_Scan_Register [IR_SIZE - 1: 1]} : data_in;
end

always @ (posedge UpdateIR or negedge reset_bar)	// asynchronous required by 1140.1a.
	if (reset_bar==0) IR_Output_Register <= 4'b0;		// Fills IR with 0s for BYPASS instruction
	else IR_Output_Register <= IR_Scan_Register;
endmodule