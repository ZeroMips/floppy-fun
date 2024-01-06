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
	wire w_DataValid;
	wire [7:0] w_Track;
	wire [7:0] w_Side;
	wire [7:0] w_Sector;
	wire [7:0] w_SectorSize;
	wire [15:0] w_CRC;
	wire w_SectorHeaderValid;
	wire _unused_ok = &{1'b0,
		w_Clock,
		w_SectorHeaderValid,
		w_Track,
		w_Side,
		w_Sector,
		w_SectorSize,
		w_CRC,
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
		.o_Valid(w_DataValid)
	);

	sector_header sector_headerinst(
		.i_Reset(i_Reset),
		.i_Clk(i_Clk),
		.i_Sync(w_Sync),
		.i_Data(w_Data),
		.i_Valid(w_DataValid),
		.o_Track(w_Track),
		.o_Side(w_Side),
		.o_Sector(w_Sector),
		.o_SectorSize(w_SectorSize),
		.o_CRC(w_CRC),
		.o_Valid(w_SectorHeaderValid)
	);

endmodule
