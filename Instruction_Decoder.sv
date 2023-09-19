/********************************************************************
*																	*
*	Instruction_Decoder:											*
*																	*
*																	*
*	 																*
*	 																*
*	 																*
*	 																*
*	 																*
*	 																*
*																	*
*																	*
********************************************************************/
module Instruction_Decoder (Instruction, ClockDR, ShiftDR, UpdateDR, Select_BP, Shift_BP, Clock_BP, Shift_BSC, Clock_BSC, Update_BSC, mode);
parameter 	IR_SIZE = 4;
parameter	BYPASS			= 4'b0000;	// Required by 1149.1a
parameter	EXTEST			= 4'b1111;	// Required by 1149.1a
parameter	SAMPLE_PRELOAD	= 4'b0001;
parameter	INTEST			= 4'b0010;
parameter	RUNBIST			= 4'b0011;
parameter	IDCODE			= 4'b0100;

input	[IR_SIZE-1: 0]	Instruction;

input	ClockDR;
input 	ShiftDR; 
input	UpdateDR;

output	reg Select_BP;
output 	Shift_BP;
output	reg Clock_BP;

output	Shift_BSC; 
output	reg Clock_BSC; 
output	reg Update_BSC;

output 	reg mode;

assign Shift_BP = ShiftDR;
assign Shift_BSC = ShiftDR;


always @ (Instruction or ClockDR or UpdateDR) begin
	case (Instruction)
		EXTEST:			begin mode = 1; Select_BP = 0; Clock_BP = 1;  Clock_BSC = ClockDR; Update_BSC = UpdateDR; end	
		INTEST:			begin mode = 1; Select_BP = 0; Clock_BP = 1;  Clock_BSC = ClockDR; Update_BSC = UpdateDR; end	
		SAMPLE_PRELOAD:	begin mode = 0; Select_BP = 0; Clock_BP = 1;  Clock_BSC = ClockDR; Update_BSC = UpdateDR; end
		RUNBIST:		begin mode = 0; Select_BP = 0; Clock_BP = 1;  Clock_BSC = 1; Update_BSC = 0; end		
		IDCODE:			begin mode = 0; Select_BP = 1; Clock_BP = ClockDR;  Clock_BSC = 1; Update_BSC = 0; end 
		BYPASS:			begin mode = 0; Select_BP = 1; Clock_BP = ClockDR;  Clock_BSC = 1; Update_BSC = 0; end	 	
		default:		begin mode = 0; Select_BP = 1; Clock_BP = 1;  Clock_BSC = 1; Update_BSC = 0; end	 				

	endcase	
end	
endmodule