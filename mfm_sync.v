/*
 * This is the sync state machine. It looks for the sequence 'LMLM' in the MFM
 * symbol stream. This sequence implements an invalid clock condition and is used
 * to mark the sector headers.
 */

module mfm_sync (
	input i_Reset,
	input i_Clk,
	input i_S,
	input i_M,
	input i_L,
	input i_Error,
	output o_Sync);

	localparam WAIT_L0 = 3'd0;
	localparam WAIT_M0 = 3'd1;
	localparam WAIT_L1 = 3'd2;
	localparam WAIT_M1 = 3'd3;
	localparam DONE = 3'd4;

	reg [2:0] r_State;

	always @(posedge i_Clk or posedge i_Reset)
	begin
		if (i_Reset)
			r_State <= WAIT_L0;
		else
		begin
			case (r_State)
			WAIT_L0:
				if (i_L)
					r_State <= WAIT_M0;
			WAIT_M0:
				if (i_M)
					r_State <= WAIT_L1;
				else if (i_S || i_L || i_Error)
					r_State <= WAIT_L0;
			WAIT_L1:
				if (i_L)
					r_State <= WAIT_M1;
				else if (i_S || i_M || i_Error)
					r_State <= WAIT_L0;
			WAIT_M1:
				if (i_M)
					r_State <= DONE;
				else if (i_S || i_L || i_Error)
					r_State <= WAIT_L0;
			default:
				r_State <= WAIT_L0;
			endcase
		end
	end

	assign o_Sync = (r_State == DONE);

endmodule
