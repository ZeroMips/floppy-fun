module vga_timing (
	input i_Clk,
	output o_DE,
	output o_HSync,
	output o_VSync);

	reg [9:0] h_ctr = 0;
	reg [8:0] v_ctr = 0;
	reg r_h_sync;
	reg r_v_sync;
	reg r_h_active;
	reg r_v_active;

	localparam POS_H_SYNC = 96;
	localparam POS_H_BACKPORCH = POS_H_SYNC + 48;
	localparam POS_H_ACTIVE = POS_H_BACKPORCH + 640;
	localparam POS_H_FRONTPORCH = POS_H_ACTIVE + 16;
	localparam H_POL = 0;

	localparam POS_V_SYNC = 2;
	localparam POS_V_BACKPORCH = POS_V_SYNC + 31;
	localparam POS_V_ACTIVE = POS_V_BACKPORCH + 480;
	localparam POS_V_FRONTPORCH = POS_V_ACTIVE + 11;
	localparam V_POL = 0;

	always @(posedge i_Clk)
	begin
		/*
		 * Horizonal Dots         640
		 * Vertical Scan Lines    480
		 * Horiz. Sync Polarity   NEG
		 * A Scanline time        800
		 * B Sync pulse lenght     96
		 * C Back porch            48
		 * D Active video time    640
		 * E Front porch           16
		 *          ______________________          ________
		 * ________|        VIDEO         |________| VIDEO (next line)
		 *     |-C-|----------D-----------|-E-|
		 * __   ______________________________   ___________
		 *   |_|                              |_|
		 *   |B|
		 *   |---------------A----------------|
		 */
		if (h_ctr < POS_H_SYNC)
		begin
			r_h_sync <= H_POL;
			h_ctr <= h_ctr + 1;
		end
		else if (h_ctr < POS_H_BACKPORCH)
		begin
			r_h_sync <= !H_POL;
			h_ctr <= h_ctr + 1;
		end
		else if (h_ctr < POS_H_ACTIVE)
		begin
			h_ctr <= h_ctr + 1;
			r_h_active <= 1;
		end
		else if (h_ctr < POS_H_FRONTPORCH)
		begin
			h_ctr <= h_ctr + 1;
			r_h_active <= 0;
		end
		else
		begin
			h_ctr <= 0;
			v_ctr <= v_ctr + 1;
		end

		/*
		 * Horizonal Dots         640
		 * Vertical Scan Lines    480
		 * Vert. Sync Polarity    NEG
		 * Vertical Frequency     60Hz
		 * O Total frame          524
		 * P Sync length            2
		 * Q Back porch            31
		 * R Active video         480
		 * S Front porch           11
		 *          ______________________          ________
		 * ________|        VIDEO         |________|  VIDEO (next frame)
		 *     |-Q-|----------R-----------|-S-|
		 * __   ______________________________   ___________
		 *   |_|                              |_|
		 *   |P|
		 *   |---------------O----------------|
		 */
		if (v_ctr < POS_V_SYNC)
		begin
			r_v_sync <= V_POL;
		end
		else if (v_ctr < POS_V_BACKPORCH)
		begin
			r_v_sync <= !V_POL;
		end
		else if (v_ctr < POS_V_ACTIVE)
		begin
			r_v_active <= 1;
		end
		else if (v_ctr < POS_V_FRONTPORCH)
		begin
			r_v_active <= 0;
		end
		else
		begin
			v_ctr <= 0;
		end
	end

	assign o_HSync = r_h_sync;
	assign o_VSync = r_v_sync;
	assign o_DE = r_h_active && r_v_active;

endmodule
