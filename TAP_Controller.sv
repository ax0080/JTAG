/*********************************************************************
*																	 *
*	TAP_Controller:													 *
*	TEST_LOGIC_RESET = 4'h0;										 *
*	RUN_TEST_IDLE = 4'h1;											 *
*	SELECT_DR = 4'h2;												 *
*   CAPTURE_DR = 4'h3; 												 *
*   SHIFT_DR = 4'h4;   												 *
*   EXIT1_DR = 4'h5;   												 *
*   PAUSE_DR = 4'h6;   												 *
*   EXIT2_DR = 4'h7;   												 *
*   UPDATE_DR = 4'h8;  												 *
*   SELECT_IR = 4'h9;  												 *
*   CAPTURE_IR = 4'hA; 												 *
*   SHIFT_IR = 4'hB;   												 *
*   EXIT1_IR = 4'hC;   												 *
*	PAUSE_IR = 4'hD; 												 *
*	EXIT2_IR = 4'hE; 												 *
*	UPDATE_IR = 4'hF; 												 *
*																	 *
*	ClockDR(IR):Enabled clock signal when state is CAPTURE_DR(IR)	 *
*				or SHIFT_DR(IR), half cycle slower than TCK	to avoid *
*				wrong input or output								 *
*	ShiftDR(IR):Enable when state is SHIFT_DR(IR)					 *
*	UpdateDR(IR):A pulse after state is UPDATE_DR(IR)                *                                     
*	                                                                 *
*	reset_bar:Enabled when state is TEST_LOGIC_RESET                 *
*	enable_TDO:Enabled when state is SHIFT_DR(IR)                   *
*	Select_IR:Instruction or Data    								 *
*																	 *
********************************************************************/
//`timescale 1ns / 100ps
module TAP_Controller(
input TCK,
input TMS,
 
output ClockDR,
output reg ShiftDR,
output UpdateDR,

output ClockIR,
output reg ShiftIR,
output UpdateIR,

output reg reset_bar,
output reg Select_IR, 
output reg enable_TDO


);

//=============Internal Constants======================
parameter IR_SIZE = 4;
parameter STATE_SIZE = 4;

//=============States==================================
parameter TEST_LOGIC_RESET = 4'h0;
parameter RUN_TEST_IDLE = 4'h1;
parameter SELECT_DR = 4'h2;
parameter CAPTURE_DR = 4'h3; 
parameter SHIFT_DR = 4'h4;
parameter EXIT1_DR = 4'h5; 
parameter PAUSE_DR = 4'h6;
parameter EXIT2_DR = 4'h7; 
parameter UPDATE_DR = 4'h8; 
parameter SELECT_IR = 4'h9; 
parameter CAPTURE_IR = 4'hA;
parameter SHIFT_IR = 4'hB;
parameter EXIT1_IR = 4'hC; 
parameter PAUSE_IR = 4'hD;
parameter EXIT2_IR = 4'hE;
parameter UPDATE_IR = 4'hF;


//===============State=================================
reg [STATE_SIZE-1:0] current_state;
reg [STATE_SIZE-1:0] next_state;

always @ (posedge TCK) begin 
	current_state <= next_state;  
end


always @ (current_state or TMS) begin
	case(current_state)
		TEST_LOGIC_RESET: begin next_state = TMS ? TEST_LOGIC_RESET : RUN_TEST_IDLE; Select_IR = 1; 	end
        RUN_TEST_IDLE:    begin next_state = TMS ? SELECT_DR : RUN_TEST_IDLE;		 Select_IR = 1; 	end
        SELECT_DR :       begin next_state = TMS ? SELECT_IR : CAPTURE_DR;           Select_IR = 0; 	end
        CAPTURE_DR :      begin next_state = TMS ? EXIT1_DR : SHIFT_DR;              Select_IR = 0; 	end
        SHIFT_DR:         begin next_state = TMS ? EXIT1_DR : SHIFT_DR;              Select_IR = 0; 	end
        EXIT1_DR:         begin next_state = TMS ? UPDATE_DR : PAUSE_DR;             Select_IR = 0; 	end
        PAUSE_DR:         begin next_state = TMS ? EXIT2_DR : PAUSE_DR;              Select_IR = 0; 	end
        EXIT2_DR:         begin next_state = TMS ? UPDATE_DR : SHIFT_DR;             Select_IR = 0; 	end
        UPDATE_DR:        begin next_state = TMS ? SELECT_DR : RUN_TEST_IDLE;        Select_IR = 0; 	end
        SELECT_IR:        begin next_state = TMS ? TEST_LOGIC_RESET : CAPTURE_IR;    Select_IR = 0; 	end
        CAPTURE_IR:       begin next_state = TMS ? EXIT1_IR : SHIFT_IR;              Select_IR = 1; 	end
        SHIFT_IR :        begin next_state = TMS ? EXIT1_IR : SHIFT_IR;              Select_IR = 1; 	end
        EXIT1_IR:         begin next_state = TMS ? UPDATE_IR : PAUSE_IR;             Select_IR = 1; 	end
        PAUSE_IR:         begin next_state = TMS ? EXIT2_IR : PAUSE_IR;              Select_IR = 1; 	end
        EXIT2_IR:         begin next_state = TMS ? UPDATE_IR : SHIFT_IR;             Select_IR = 1; 	end
        UPDATE_IR:        begin next_state = TMS ? SELECT_DR : RUN_TEST_IDLE;        Select_IR = 1; 	end
	endcase                                                                          
end


//Control Signal
always @ (negedge TCK) begin
	reset_bar <= ~(current_state == TEST_LOGIC_RESET);
end

always @ (negedge TCK) begin
	ShiftDR <= (current_state == SHIFT_DR);
	ShiftIR <= (current_state == SHIFT_IR);
	
	enable_TDO <= (current_state == SHIFT_DR)||(current_state == SHIFT_IR);
end

assign ClockDR = !(((current_state == CAPTURE_DR)||(current_state == SHIFT_DR)) && (~TCK));
assign ClockIR = !(((current_state == CAPTURE_IR)||(current_state == SHIFT_IR)) && (~TCK));

assign  UpdateDR = (current_state == UPDATE_DR) && (~TCK); 
assign  UpdateIR = (current_state == UPDATE_IR) && (~TCK); 


endmodule