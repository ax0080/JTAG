module TDI_Generator (to_TDI, scan_pattern,  load, enable_bypass_pattern, TCK);
parameter 	BSC_SIZE = 14;

input 	[BSC_SIZE -1: 0] scan_pattern;
input	load, enable_bypass_pattern, TCK;
output	to_TDI;


reg		[BSC_SIZE -1: 0]	TDI_Reg;
wire	enable_TDO = tb_Full_Adder_with_JTAG.FA0.enable_TDO;
assign 	to_TDI = TDI_Reg [0];

always @ (posedge TCK) begin 
	if (load) TDI_Reg <= scan_pattern;
	else if (enable_TDO || enable_bypass_pattern) TDI_Reg <= (TDI_Reg >> 1);
end
endmodule