/*
 * This module quantizes the lengths between flux transitions into MFM symbols.
 * For a 3.5 inch HD floppy disk, the values are:
 *   2us: Short(S)
 *   3us: Medium(M)
 *   4us: Long(L)
 * To improve this, PLL like functionality could be used to compensate for drift.
 */

module mfm_quantize #(parameter clkspd=65000000) (
	input i_Clk,
	input i_Data,
	output o_S,
	output o_M,
	output o_L,
	output o_Error);

	localparam WIDTH = $clog2($rtoi($floor(0.0000045 * clkspd))) - 1;
	localparam T_S_ = $rtoi($floor(0.0000025 * clkspd));
	localparam T_M_ = $rtoi($floor(0.0000035 * clkspd));
	localparam T_L_ = $rtoi($floor(0.0000045 * clkspd));
	localparam [WIDTH:0] T_S = T_S_[WIDTH:0];
	localparam [WIDTH:0] T_M = T_M_[WIDTH:0];
	localparam [WIDTH:0] T_L = T_L_[WIDTH:0];

	reg [WIDTH:0] r_Ctr = 0;
	reg r_Last = 0;
	reg r_S = 0;
	reg r_M = 0;
	reg r_L = 0;
	reg r_ERROR = 0;

	always @(posedge i_Clk)
	begin
		if (r_Last && !i_Data)
		begin
			if (r_Ctr < T_S)
			begin
				r_S <= 1;
				r_M <= 0;
				r_L <= 0;
				r_ERROR <= 0;
			end
			else if (r_Ctr < T_M)
			begin
				r_S <= 0;
				r_M <= 1;
				r_L <= 0;
				r_ERROR <= 0;
			end
			else if (r_Ctr < T_L)
			begin
				r_S <= 0;
				r_M <= 0;
				r_L <= 1;
				r_ERROR <= 0;
			end
			else
			begin
				r_S <= 0;
				r_M <= 0;
				r_L <= 0;
				r_ERROR <= 1;
			end

			r_Ctr <= 0;
		end
		else begin
			if (r_Ctr < T_L)
			begin
				r_Ctr <= r_Ctr + 1;
			end
			r_S <= 0;
			r_M <= 0;
			r_L <= 0;
			r_ERROR <= 0;
		end
		r_Last <= i_Data;
	end;

	assign o_S = r_S;
	assign o_M = r_M;
	assign o_L = r_L;
	assign o_Error = r_ERROR;

endmodule
