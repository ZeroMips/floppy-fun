module top #(parameter clkspd=25000000) (
	input i_Switch_1,
	input i_Clk,
	input io_PMOD_1,
	output o_Segment1_A,
	output o_Segment1_B,
	output o_Segment1_C,
	output o_Segment1_D,
	output o_Segment1_E,
	output o_Segment1_F,
	output o_Segment1_G,
	output o_Segment2_A,
	output o_Segment2_B,
	output o_Segment2_C,
	output o_Segment2_D,
	output o_Segment2_E,
	output o_Segment2_F,
	output o_Segment2_G,
	output o_VGA_HSync,
	output o_VGA_VSync,
	output o_VGA_Red_0,
	output o_VGA_Red_1,
	output o_VGA_Red_2,
	output o_VGA_Grn_0,
	output o_VGA_Grn_1,
	output o_VGA_Grn_2,
	output o_VGA_Blu_0,
	output o_VGA_Blu_1,
	output o_VGA_Blu_2
	);

	wire [7:0] w_Sector;
	wire [7:0] w_SectorData;
	wire w_Segment1_A;
	wire w_Segment1_B;
	wire w_Segment1_C;
	wire w_Segment1_D;
	wire w_Segment1_E;
	wire w_Segment1_F;
	wire w_Segment1_G;
	wire w_Segment2_A;
	wire w_Segment2_B;
	wire w_Segment2_C;
	wire w_Segment2_D;
	wire w_Segment2_E;
	wire w_Segment2_F;
	wire w_Segment2_G;
	wire w_HeaderCRCError;
	wire w_DataCRCError;
	wire w_SectorDataValid;

	wire w_HSync;
	wire w_VSync;
	wire w_DE;
	wire [2:0] w_R;
	wire [2:0] w_G;
	wire [2:0] w_B;

	wire [11:0] w_AF_Level = 512;
	wire w_AF_Flag;
	wire w_Full;
	wire w_Rd_En;
	wire w_Rd_DV;
	wire [7:0] w_Rd_Data;
	wire [11:0] w_AE_Level = 512;
	wire w_AE_Flag;
	wire w_Empty;

	wire _unused_ok = &{1'b0,
		w_Sector,
		w_HeaderCRCError,
		w_DataCRCError,
		w_AF_Flag,
		w_Full,
		w_Rd_DV,
		w_Rd_Data,
		w_AE_Flag,
		w_Empty,
		1'b0
	};

	floppy #(.clkspd(clkspd)) floppy_inst(
		.i_Reset(i_Switch_1),
		.i_Clk(i_Clk),
		.i_Data(io_PMOD_1),
		.o_Sector(w_Sector),
		.o_HeaderCRCError(w_HeaderCRCError),
		.o_DataCRCError(w_DataCRCError),
		.o_Data(w_SectorData),
		.o_Valid(w_SectorDataValid)
	);

	Binary_To_7Segment LowNibble(
		.i_Clk(i_Clk),
		.i_Binary_Num(w_Rd_Data[7:4]),
		.o_Segment_A(w_Segment1_A),
		.o_Segment_B(w_Segment1_B),
		.o_Segment_C(w_Segment1_C),
		.o_Segment_D(w_Segment1_D),
		.o_Segment_E(w_Segment1_E),
		.o_Segment_F(w_Segment1_F),
		.o_Segment_G(w_Segment1_G)
	);

	Binary_To_7Segment HighNibble(
		.i_Clk(i_Clk),
		.i_Binary_Num(w_Rd_Data[3:0]),
		.o_Segment_A(w_Segment2_A),
		.o_Segment_B(w_Segment2_B),
		.o_Segment_C(w_Segment2_C),
		.o_Segment_D(w_Segment2_D),
		.o_Segment_E(w_Segment2_E),
		.o_Segment_F(w_Segment2_F),
		.o_Segment_G(w_Segment2_G)
	);

	vga_timing vga_timing_inst(
		.i_Clk(i_Clk),
		.o_DE(w_DE),
		.o_HSync(w_HSync),
		.o_VSync(w_VSync)
	);

	vga_patterngen vga_patterngen_inst(
		.i_Clk(i_Clk),
		.i_DE(w_DE),
		.i_HSync(w_HSync),
		.i_VSync(w_VSync),
		.o_R(w_R),
		.o_G(w_G),
		.o_B(w_B)
	);

	FIFO  #(.DEPTH(4096)) FIFO_inst (
		.i_Rst_L(!i_Switch_1),
		.i_Clk(i_Clk),
		.i_Wr_DV(w_SectorDataValid),
		.i_Wr_Data(w_SectorData),
		.i_AF_Level(w_AF_Level),
		.o_AF_Flag(w_AF_Flag),
		.o_Full(w_Full),
		.i_Rd_En(w_Rd_En),
		.o_Rd_DV(w_Rd_DV),
		.o_Rd_Data(w_Rd_Data),
		.i_AE_Level(w_AE_Level),
		.o_AE_Flag(w_AE_Flag),
		.o_Empty(w_Empty)
	);

	assign w_Rd_En = !w_AE_Flag;

	assign o_Segment1_A = !w_Segment1_A;
	assign o_Segment1_B = !w_Segment1_B;
	assign o_Segment1_C = !w_Segment1_C;
	assign o_Segment1_D = !w_Segment1_D;
	assign o_Segment1_E = !w_Segment1_E;
	assign o_Segment1_F = !w_Segment1_F;
	assign o_Segment1_G= !w_Segment1_G;

	assign o_Segment2_A = !w_Segment2_A;
	assign o_Segment2_B = !w_Segment2_B;
	assign o_Segment2_C = !w_Segment2_C;
	assign o_Segment2_D = !w_Segment2_D;
	assign o_Segment2_E = !w_Segment2_E;
	assign o_Segment2_F = !w_Segment2_F;
	assign o_Segment2_G= !w_Segment2_G;

	assign o_VGA_HSync = w_HSync;
	assign o_VGA_VSync = w_VSync;
	assign o_VGA_Red_0 = w_DE ? w_R[0] : 0;
	assign o_VGA_Red_1 = w_DE ? w_R[1] : 0;
	assign o_VGA_Red_2 = w_DE ? w_R[2] : 0;
	assign o_VGA_Grn_0 = w_DE ? w_G[0] : 0;
	assign o_VGA_Grn_1 = w_DE ? w_G[1] : 0;
	assign o_VGA_Grn_2 = w_DE ? w_G[2] : 0;
	assign o_VGA_Blu_0 = w_DE ? w_B[0] : 0;
	assign o_VGA_Blu_1 = w_DE ? w_B[1] : 0;
	assign o_VGA_Blu_2 = w_DE ? w_B[2] : 0;

endmodule