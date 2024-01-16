module vga_rle (
	input i_Clk,
	input i_DE,
	input i_VSync,
	output [2:0] o_R,
	output [2:0] o_G,
	output [2:0] o_B);

	reg [2:0] r_R;
	reg [2:0] r_G;
	reg [2:0] r_B;
	reg [14:0] r_Ctr;
	reg [10:0] r_Memptr;
	reg [15:0] r_Val;

	reg [15:0] r_Mem[2048];

	initial
	begin
		$readmemh("rom.bin", r_Mem);
	end

	wire _unused_ok = &{1'b0,
		1'b0
	};

	always @(posedge i_Clk)
	begin
		if (!i_VSync)
		begin
			r_Ctr <= 0;
			r_Memptr <= 0;
		end
		else if (i_DE)
		begin
			if (r_Ctr == 0)
			begin
				r_Val <= r_Mem[r_Memptr];
				r_Ctr <= r_Mem[r_Memptr][15:1];
				if (r_Mem[r_Memptr][0])
				begin
					r_R <= 0;
					r_G <= 0;
					r_B <= 0;
				end
				else begin
					r_R <= 7;
					r_G <= 7;
					r_B <= 7;
				end
				r_Memptr <= r_Memptr + 1;
			end
			else
				r_Ctr <= r_Ctr - 1;
		end
	end

	assign o_R = r_R;
	assign o_G = r_G;
	assign o_B = r_B;

endmodule
