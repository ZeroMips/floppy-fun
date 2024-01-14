module floppy #(parameter clkspd=65000000) (
	input i_Reset,
	input i_Clk,
	input i_Data,
	output [7:0] o_Sector,
	output o_HeaderCRCError,
	output o_DataCRCError,
	output [7:0] o_Data,
	output o_Valid
	);

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
	wire [7:0] w_SectorData;
	wire w_HeaderValid;
	wire w_SectorDataValid;
	wire w_HeaderCRCError;
	wire w_DataCRCError;
	wire _unused_ok = &{1'b0,
		w_Clock,
		w_Track,
		w_Side,
		w_Sector,
		w_SectorSize,
		1'b0};

	reg [7:0] r_Sector;

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
		.o_CRCError(w_HeaderCRCError),
		.o_Valid(w_HeaderValid)
	);

	sector_data sector_datainst(
		.i_Reset(i_Reset),
		.i_Clk(i_Clk),
		.i_Sync(w_Sync),
		.i_Data(w_Data),
		.i_Valid(w_DataValid),
		.o_Data(w_SectorData),
		.o_CRCError(w_DataCRCError),
		.o_Valid(w_SectorDataValid)
	);

	always @(posedge i_Clk or posedge i_Reset)
	begin
		if (i_Reset)
			r_Sector <= 8'd0;
		else
		begin
			if (w_HeaderValid)
			begin
				r_Sector <= w_Sector;
			end
		end
	end

	assign o_Sector = r_Sector;
	assign o_HeaderCRCError = w_HeaderCRCError;
	assign o_DataCRCError = w_DataCRCError;
	assign o_Valid = w_SectorDataValid;
	assign o_Data = w_SectorData;

endmodule
