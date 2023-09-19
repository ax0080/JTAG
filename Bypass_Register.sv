/********************************************************************
*																	*
*	Bypass_Register:												*
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
module  Bypass_Register(scan_in, scan_out, ClockDR, ShiftDR);
input scan_in; 
input ClockDR;
input ShiftDR; 
output reg scan_out;

always @ (posedge ClockDR) begin
	scan_out <= scan_in & ShiftDR;
end
endmodule 