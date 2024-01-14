module vga_patterngen (
	input i_Clk,
	input i_DE,
	input i_HSync,
	input i_VSync,
	output [2:0] o_R,
	output [2:0] o_G,
	output [2:0] o_B);

	reg [2:0] r_R;
	reg [2:0] r_G;
	reg [2:0] r_B;
	reg [8:0] r_Ctr;

	wire _unused_ok = &{1'b0,
		i_VSync,
		1'b0};

	always @(posedge i_Clk)
	begin
		if (!i_HSync)
		begin
			r_R <= 3'd7;
			r_G <= 3'd7;
			r_B <= 3'd7;
			r_Ctr <= 0;
		end
		else if (i_DE)
		begin
			r_Ctr <= r_Ctr + 1;
			if (r_Ctr >= 30)
			begin
				if (|r_R)
					r_R <= r_R - 1;
				else if (|r_G)
					r_G <= r_G - 1;
				else if (|r_B)
					r_B <= r_B - 1;
				r_Ctr <= 0;
			end
		end
	end

	assign o_R = r_R;
	assign o_G = r_G;
	assign o_B = r_B;

endmodule
