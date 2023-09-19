module Full_Adder_with_JTAG (sum, c_out, a, b, c_in, TDO, TDI, TMS, TCK);
parameter	BSC_SIZE = 14;
parameter	IR_SIZE = 4;
parameter	SIZE = 4;	

input	[SIZE -1 : 0] a, b;
input	c_in;

output	[SIZE -1 : 0] sum;		//  ASIC interface I/O
output	c_out;


input	TDI, TMS, TCK;
output	TDO; 		// TAP interface signals
	

wire	[BSC_SIZE-1 : 0] BSC_Interface;	// Declarations for boundary scan register I/O

// TAP controller outputs
wire 	ShiftIR;
wire 	ClockIR; 
wire 	UpdateIR;
wire 	ShiftDR; 
wire 	ClockDR;
wire 	UpdateDR;
wire	reset_bar;	
wire 	Select_IR;
wire 	enable_TDO;

//Iustruction Decoder Outputs
wire 	Select_BP;
wire	Shift_BP;
wire 	Clock_BP;
wire 	Shift_BSC;
wire 	Clock_BSC;
wire 	Update_BSC;
wire	mode;


wire 	[IR_SIZE-1 : 0]	Dummy_data = 4'b0001;	// Captured in Capture_IR
wire 	[IR_SIZE-1 : 0]	Instruction;

wire	IR_scan_out;		// Instruction register
wire	BSC_scan_out;		// Boundary scan register
wire	BP_scan_out;		// Bypass register
wire	TDR_out;		// Test data register serial datapath

assign 	TDR_out = Select_BP ? BP_scan_out : BSC_scan_out;
assign	TDO = enable_TDO ? Select_IR ? IR_scan_out : TDR_out : 1'bz;


Full_Adder  
#(
 .SIZE(SIZE)
)
M0
(
 .sum (BSC_Interface [13: 10]),
 .c_out (BSC_Interface [9]), 
 .a (BSC_Interface [8: 5]),
 .b (BSC_Interface [4: 1]),
 .c_in (BSC_Interface [0])  
);

Bypass_Register BP0(
  .scan_out (BP_scan_out), 
  .scan_in (TDI), 
  .ShiftDR (Shift_BP), 
  .ClockDR (Clock_BP)
);
  
Boundary_Scan_Cell 
#(
  .SIZE(BSC_SIZE)
)
BSC0
(
  .data_out ({sum, c_out, BSC_Interface[8: 5], BSC_Interface[4: 1], BSC_Interface[0]}),
  .data_in ({BSC_Interface [13: 10], BSC_Interface [9], a, b, c_in}),
  .scan_out (BSC_scan_out), 
  .scan_in (TDI),
  .ShiftDR (ShiftDR), 
  .mode (mode),
  .ClockDR (Clock_BSC), 
  .UpdateDR (Update_BSC)
);

Instruction_Register IR0 (
  .data_out (Instruction), 
  .data_in (Dummy_data), 
  .scan_out (IR_scan_out), 
  .scan_in (TDI),  
  .ShiftIR (ShiftIR), 
  .ClockIR (ClockIR), 
  .UpdateIR (UpdateIR), 
  .reset_bar (reset_bar)
);

Instruction_Decoder ID0 (
  .mode (mode),
  .Select_BP (Select_BP),
  .Shift_BP (Shift_BP),
  .Clock_BP (Clock_BP),
  .Shift_BSC (Shift_BSC),
  .Clock_BSC (Clock_BSC),
  .Update_BSC (Update_BSC),
  .Instruction (Instruction),
  .ShiftDR (ShiftDR),
  .ClockDR (ClockDR),
  .UpdateDR (UpdateDR)
);

TAP_Controller TAP0 (
  .reset_bar(reset_bar), 
  .Select_IR (Select_IR), 
  .ShiftIR (ShiftIR), 
  .ClockIR (ClockIR),  
  .UpdateIR (UpdateIR), 
  .ShiftDR (ShiftDR), 
  .ClockDR (ClockDR), 
  .UpdateDR (UpdateDR), 
  .enable_TDO (enable_TDO), 
  .TMS (TMS), 
  .TCK (TCK)
);

endmodule
