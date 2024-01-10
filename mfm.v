module mfm #(parameter clkspd=65000000) (
	input i_Reset,
	input i_Clk,
	input i_Data,
	output [7:0] o_Sector,
	output o_CRCError,
	output o_SectorHeaderValid,
	output [3:0] o_State);

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
	wire w_CRCError;
	wire _unused_ok = &{1'b0,
		w_Clock,
		w_SectorHeaderValid,
		w_Track,
		w_Side,
		w_Sector,
		w_SectorSize,
		w_CRC,
		1'b0};
	reg [7:0] r_Sector;
	reg r_CRCError;
	wire [3:0] w_SectorHeaderState;
	reg [3:0] r_State;

	mfm_quantize #(.clkspd(clkspd)) mfm_quantize_inst(
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
		.o_CRCError(w_CRCError),
		.o_State(w_SectorHeaderState),
		.o_Valid(w_SectorHeaderValid)
	);

	always @(posedge i_Clk or posedge i_Reset)
	begin
		if (i_Reset)
			r_Sector <= 8'd0;
		else
		begin
			if (w_SectorHeaderValid)
			begin
				r_Sector <= w_Sector;
				r_CRCError <= 0;
			end
			if (w_CRCError)
				r_CRCError <= 1;
			r_State[0] <= w_S;
			r_State[1] <= w_M;
			r_State[2] <= w_L;
			r_State[3] <= w_Error;
		end
	end

	assign o_Sector = r_Sector;
	assign o_CRCError = w_CRCError;
	assign o_SectorHeaderValid = w_Sync;
	assign o_State = r_State;

endmodule
