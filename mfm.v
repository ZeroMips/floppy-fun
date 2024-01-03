module mfm #(parameter clkspd=65000000) (
	input i_Reset,
	input i_Clk,
	input i_Data);

	wire w_S;
	wire w_M;
	wire w_L;
	wire w_Error;
	wire w_Sync;
	wire [7:0] w_Data;
	wire [7:0] w_Clock;
	wire w_Valid;
	wire _unused_ok = &{1'b0,
		w_Data,
		w_Clock,
		w_Valid,
		1'b0};

	mfm_quantize mfm_quantize_inst(
		.i_Clk(i_Clk),
		.i_Data(i_Data),
		.o_S(w_S),
		.o_M(w_M),
		.o_L(w_L),
		.o_Error(w_Error)
	);

	mfm_sync mfm_sync_inst(
		.i_Reset(i_Reset),
		.i_Clk(i_Clk),
		.i_S(w_S),
		.i_M(w_M),
		.i_L(w_L),
		.i_Error(w_Error),
		.o_Sync(w_Sync)
	);

	mfm_bit_fifo mfm_bit_fifo_inst(
		.i_Reset(i_Reset),
		.i_Clk(i_Clk),
		.i_S(w_S),
		.i_M(w_M),
		.i_L(w_L),
		.i_Error(w_Error),
		.i_Sync(w_Sync),
		.o_Data(w_Data),
		.o_Clock(w_Clock),
		.o_Valid(w_Valid)
	);

endmodule
