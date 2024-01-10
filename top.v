module top #(parameter clkspd=65000000) (
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
	output o_LED_1,
	output io_PMOD_2,
	output io_PMOD_7,
	output io_PMOD_8,
	output io_PMOD_9,
	output io_PMOD_10
	);

	localparam CLKSPD = 25000000;

	wire [7:0] w_Sector;
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
	wire w_CRCError;
	wire w_SectorHeaderValid;
	wire [3:0] w_State;

	mfm #(.clkspd(CLKSPD)) mfm_inst(
		.i_Reset(i_Switch_1),
		.i_Clk(i_Clk),
		.i_Data(io_PMOD_1),
		.o_Sector(w_Sector),
		.o_CRCError(w_CRCError),
		.o_SectorHeaderValid(w_SectorHeaderValid),
		.o_State(w_State)
	);

	Binary_To_7Segment LowNibble(
		.i_Clk(i_Clk),
		.i_Binary_Num(w_Sector[7:4]),
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
		.i_Binary_Num(w_Sector[3:0]),
		.o_Segment_A(w_Segment2_A),
		.o_Segment_B(w_Segment2_B),
		.o_Segment_C(w_Segment2_C),
		.o_Segment_D(w_Segment2_D),
		.o_Segment_E(w_Segment2_E),
		.o_Segment_F(w_Segment2_F),
		.o_Segment_G(w_Segment2_G)
	);

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

	assign o_LED_1 = w_CRCError;
	assign io_PMOD_2 = w_SectorHeaderValid;
	assign io_PMOD_7 = w_State[0];
	assign io_PMOD_8 = w_State[1];
	assign io_PMOD_9 = w_State[2];
	assign io_PMOD_10 = w_State[3];

endmodule