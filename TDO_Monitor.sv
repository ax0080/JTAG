module TDO_Monitor (to_TDI, from_TDO, strobe, TCK);
parameter	BSC_SIZE = 14;
parameter	TEST_WIDTH = 5;

input		from_TDO, strobe, TCK;
output		to_TDI;

reg			[BSC_SIZE -1: 0]	 Pattern_Buffer_1, Pattern_Buffer_2, TDO_Reg;
reg 		Error;


wire 	enable_TDO = tb_Full_Adder_with_JTAG.FA0.enable_TDO;
wire	[TEST_WIDTH -1 : 0]	Expected_out = Pattern_Buffer_2 [BSC_SIZE -1 : BSC_SIZE - TEST_WIDTH];
wire	[TEST_WIDTH -1 : 0]	ASIC_out = TDO_Reg [BSC_SIZE - 1 : BSC_SIZE - TEST_WIDTH];

initial Error = 0;

always @ (negedge enable_TDO) if (strobe == 1) Error = |(Expected_out ^ ASIC_out);

always @ (posedge TCK) if (enable_TDO) begin
    Pattern_Buffer_1 <= {to_TDI, Pattern_Buffer_1 [BSC_SIZE -1 : 1]};
    Pattern_Buffer_2 <= {Pattern_Buffer_1 [0], Pattern_Buffer_2 [BSC_SIZE -1 : 1]};
    TDO_Reg <= {from_TDO, TDO_Reg [BSC_SIZE -1: 1]};
end  
endmodule