module tb_Full_Adder_with_JTAG ();				// Testbench
parameter	SIZE = 4;
parameter	BSC_SIZE = 14;
parameter	IR_SIZE = 4;  
parameter 	N_FA_Patterns = 8;
parameter 	N_TAP_Instructions = 8;
parameter	Pause_Time = 40;
parameter	End_of_Test = 1500;
parameter	time_1 = 350, time_2 = 550;

wire		[SIZE -1: 0] 	sum;
wire		[SIZE -1: 0] 	sum_fr_FA0 = FA0.BSC_Interface [13: 10];

wire		c_out;
wire		c_out_fr_FA = FA0.BSC_Interface [9];
reg			[SIZE -1: 0]	a, b;
reg			c_in;
wire		[SIZE -1: 0]	a_to_FA = FA0.BSC_Interface [8: 5];
wire		[SIZE -1: 0]	b_to_FA = FA0.BSC_Interface [4: 1];
wire		c_in_to_FA = FA0.BSC_Interface [0];

reg 		TMS, TCK;
wire 		TDI;
wire 		TDO;

reg			load_TDI_Generator;		
reg			Error, strobe;			//TDO Debug
integer		pattern_ptr;
reg			[BSC_SIZE -1: 0] 	Array_of_FA_Test_Patterns [0: N_FA_Patterns -1];
reg			[IR_SIZE -1: 0] 	Array_of_TAP_Instructions [0: N_TAP_Instructions -1];
reg			[BSC_SIZE -1: 0]	Pattern_Register;		// Size to maximum TDR
reg			enable_bypass_pattern;

Full_Adder_with_JTAG FA0 (sum, c_out, a, b, c_in, TDO, TDI, TMS, TCK);

TDI_Generator TG0(
  .to_TDI (TDI),
  .scan_pattern (Pattern_Register),
  .load (load_TDI_Generator),
  .enable_bypass_pattern (enable_bypass_pattern), 
  .TCK (TCK)
);

/*
TDO_Monitor TM0(
  .to_TDI (TDI), 
  .from_TDO (TDO), 
  .strobe (strobe),
  .TCK (TCK)
);
*/

initial #End_of_Test $finish;

//waveform
initial begin
$fsdbDumpfile("test_JTAG.fsdb");
$fsdbDumpvars;
end	


initial begin TCK = 0; forever #5 TCK = ~TCK; end	 

/*  Summary of  a basic test plan for Full_Adder_with TAP

Verify default to bypass instruction
Verify bypass register action: Scan 10 cycles, with pause before exiting
Verify pull up action on TMS and TDI
Reset  to S_Reset after five assertions of TMS
Boundary scan in, pause, update, return to S_Run_Idle
Boundary scan in, pause, resume scan in, pause, update, return to S_Run_Idle
Instruction scan in, pause, update, return to S_Run_Idle
Instruction scan in, pause, resume scan in, pause, update, return to S_Run_Idle
*/
// TEST PATTERNS 
// External I/O for normal operation

initial fork
 // {a, b, c_in} = 9'b0;
{a, b, c_in} = 9'b1010_0101_0;  // sum = F, c_out = 0, a = A, b = 5, c_in = 0 
join

/*  Option to force error to test fault detection

  initial begin :Force_Error
  force M0.BSC_Interface [13: 10] = 4'b0;
  end
*/

initial begin 		// Test sequence: Scan, pause, return to S_Run_Idle
Initial_Condition;  //Give current state a initial value
//strobe  = 0;
Declare_Array_of_TAP_Instructions;
Declare_Array_of_FA_Test_Patterns;
Reset_TAP;

// Test for power-up and default to BYPASS instruction (all 1s in IR), with default path 
// through the Bypass Register, with BSC register remaining in wakeup state (all x).
// FA test pattern is scanned serially, entering at TDI, passing through the bypass register,
// and exiting at TDO.  The BSC register and the IR are not changed.
pattern_ptr = 0; 
Load_FA_Test_Pattern;	
Go_to_S_Run_Idle;
Go_to_S_Select_DR;
Go_to_S_Capture_DR; 
Go_to_S_Shift_DR;
//enable_bypass_pattern = 1;
Scan_Ten_Cycles; 
//enable_bypass_pattern = 0;
Go_to_S_Exit1_DR;
Go_to_S_Pause_DR;
Pause;
Go_to_S_Exit2_DR;
Go_to_S_Update_DR;	
Go_to_S_Run_Idle;
end

// Test to load instruction register with INTEST instruction
initial #time_1 begin
pattern_ptr = 3; 
//strobe = 0;
Load_TAP_Instruction;	
Go_to_S_Run_Idle;
Go_to_S_Select_DR;
Go_to_S_Select_IR;
Go_to_S_Capture_IR;			// Capture dummy data (3'b011)
repeat (IR_SIZE) Go_to_S_Shift_IR;
Go_to_S_Exit1_IR;
Go_to_S_Pause_IR;
Pause;
Go_to_S_Exit2_IR;
Go_to_S_Update_IR;
Go_to_S_Run_Idle;
end
  

// Load FA test pattern 
initial #time_2 begin
pattern_ptr = 0; 
Load_FA_Test_Pattern;	
Go_to_S_Run_Idle;
Go_to_S_Select_DR;
Go_to_S_Capture_DR;
repeat (BSC_SIZE) Go_to_S_Shift_DR;
Go_to_S_Exit1_DR;
Go_to_S_Pause_DR;
Pause;
Go_to_S_Exit2_DR;
Go_to_S_Update_DR;
Go_to_S_Run_Idle;

// Capture data and scan out while scanning in another pattern
pattern_ptr = 2; 
Load_FA_Test_Pattern;	
Go_to_S_Select_DR;
Go_to_S_Capture_DR;
//strobe = 1;
repeat (BSC_SIZE) Go_to_S_Shift_DR;

Go_to_S_Exit1_DR;

Go_to_S_Pause_DR;
Go_to_S_Exit2_DR;
Go_to_S_Update_DR;
//strobe = 0;
Go_to_S_Run_Idle;
end

/*************************************** INITIAL CONDITION ***************************************/
task Initial_Condition;
begin
	FA0.TAP0.current_state = 4'b0;
	
end
endtask
/************************************** TAP CONTROLLER TASKS *************************************/

task  Reset_TAP;
begin
    TMS = 1;
    repeat (5) @ (negedge TCK); 
end
endtask

task Pause;			begin #Pause_Time;		end endtask

task  Go_to_S_Reset;		begin @ (negedge TCK) TMS = 1;	end endtask
task  Go_to_S_Run_Idle;		begin @ (negedge TCK) TMS = 0;	end endtask

task  Go_to_S_Select_DR;	begin @ (negedge TCK) TMS = 1;	end endtask
task  Go_to_S_Capture_DR; 	begin @ (negedge TCK) TMS = 0;	end endtask
task  Go_to_S_Shift_DR; 	begin @ (negedge TCK) TMS = 0;	end endtask
task  Go_to_S_Exit1_DR;  	begin @ (negedge TCK) TMS = 1;	end endtask
task  Go_to_S_Pause_DR; 	begin @ (negedge TCK) TMS = 0;	end endtask
task  Go_to_S_Exit2_DR;  	begin @ (negedge TCK) TMS = 1;	end endtask
task  Go_to_S_Update_DR;	begin @ (negedge TCK) TMS = 1;  end endtask

task  Go_to_S_Select_IR; 	begin @ (negedge TCK) TMS = 1;	end endtask
task  Go_to_S_Capture_IR;  	begin @ (negedge TCK) TMS = 0;
	end endtask
task  Go_to_S_Shift_IR; 	begin @ (negedge TCK) TMS = 0;	end endtask
task  Go_to_S_Exit1_IR;  	begin @ (negedge TCK) TMS = 1;	end endtask
task  Go_to_S_Pause_IR;		begin @ (negedge TCK) TMS = 0;	end endtask
task  Go_to_S_Exit2_IR;  	begin @ (negedge TCK) TMS = 1;	end endtask
task  Go_to_S_Update_IR; 	begin @ (negedge TCK) TMS = 1;  end endtask

task Scan_Ten_Cycles;		
begin 
	repeat (10) begin 
		@ (negedge TCK) TMS = 0;
		//@ (posedge TCK) TMS = 1; 
	end 
end 
endtask

/************************************** FA TEST PATTERNS  *************************************/
task Load_FA_Test_Pattern;	
begin
  Pattern_Register = Array_of_FA_Test_Patterns [pattern_ptr];
  @ (negedge TCK)  load_TDI_Generator = 1;
  @ (negedge TCK)  load_TDI_Generator = 0;
end
endtask

task Declare_Array_of_FA_Test_Patterns;
begin
//s3 s2 s1 s0_ c0_a3 a2 a1 a0_b3 b2 b1 b0_c_in;

Array_of_FA_Test_Patterns [0] = 14'b0100_1_1010_1010_0; 
Array_of_FA_Test_Patterns [1] = 14'b0000_0_0000_0000_0; 
Array_of_FA_Test_Patterns [2] = 14'b1111_1_1111_1111_1;  
Array_of_FA_Test_Patterns [3] = 14'b0100_1_0101_0101_0; //Wrong Case
end endtask

/************************************** INSTRUCTION PATTERNS *************************************/
parameter	BYPASS			= 4'b0000;	// Required by 1149.1a
parameter	EXTEST			= 4'b1111;	// Required by 1149.1a
parameter	SAMPLE_PRELOAD	= 4'b0001;
parameter	INTEST			= 4'b0010;
parameter	RUNBIST			= 4'b0011;
parameter	IDCODE			= 4'b0100;


task Load_TAP_Instruction;	
begin
    Pattern_Register = Array_of_TAP_Instructions [pattern_ptr];
    @ (negedge TCK ) load_TDI_Generator = 1;
    @ (negedge TCK)  load_TDI_Generator = 0;
end
endtask

task Declare_Array_of_TAP_Instructions;
begin
    Array_of_TAP_Instructions [0] = BYPASS;
    Array_of_TAP_Instructions [1] = EXTEST;
    Array_of_TAP_Instructions [2] = SAMPLE_PRELOAD;
    Array_of_TAP_Instructions [3] = INTEST;
    Array_of_TAP_Instructions [4] = RUNBIST;
    Array_of_TAP_Instructions [5] = IDCODE;
end
endtask  
endmodule
