/*
 * The bit fifo shifts the decoded MFM symbols into a 20 Bit register.
 * S: b10
 * M: b100
 * L: b1000
 * A new symbol is inserted left aligned at bit 3. The decoded symbol is held
 * in the upper 16 bits of the regíster. On sync conditions the fifo counter gets
 * synchronized so that at counter 0 the upper 16 bits hold the resulting symbol.
 */

module mfm_bit_fifo (
	input i_Reset,
	input i_Clk,
	input i_S,
	input i_M,
	input i_L,
	input i_Error,
	input i_Sync,
	output [7:0] o_Data,
	output [7:0] o_Clock,
	output o_Valid);

	reg [19:0] r_Bit_Fifo;
	reg [2:0] r_Buffer_Count;
	reg [3:0] r_Ctr;
	reg [15:0] r_Data;
	reg r_Valid;
	reg r_Valid_Last;

	always @(posedge i_Clk or posedge i_Reset)
	begin
		if (i_Reset)
		begin
			r_Buffer_Count <= 0;
			r_Ctr <= 0;
		end
		else
		begin
			if (i_Sync)
				r_Ctr <= 4'd4;
			else if (r_Buffer_Count > 0)
				if (r_Ctr > 0)
					r_Ctr <= r_Ctr - 1;
			else if (r_Ctr == 0)
				r_Ctr <= 15;
			else if (i_Error)
				r_Ctr <= 0;
			if (i_S)
			begin
				r_Bit_Fifo[3:0] <= 4'b1000;
				r_Buffer_Count <= 3'd2;
			end
			else if (i_M)
			begin
				r_Bit_Fifo[3:0] <= 4'b1000;
				r_Buffer_Count <= 3'd3;
			end
			else if (i_L)
			begin
				r_Bit_Fifo[3:0] <= 4'b1000;
				r_Buffer_Count <= 3'd4;
			end
			if (r_Buffer_Count > 0)
			begin
				r_Bit_Fifo[19:1] <= r_Bit_Fifo[18:0];
				r_Buffer_Count <= r_Buffer_Count - 1;
			end
			if (r_Ctr == 0)
			begin
				r_Data <= r_Bit_Fifo[19:4];
				r_Valid <= 1'b1;
			end
			else
				r_Valid <= 1'b0;
			r_Valid_Last <= r_Valid;
		end
	end

	assign o_Clock[0] = r_Data[0];
	assign o_Clock[1] = r_Data[2];
	assign o_Clock[2] = r_Data[4];
	assign o_Clock[3] = r_Data[6];
	assign o_Clock[4] = r_Data[8];
	assign o_Clock[5] = r_Data[10];
	assign o_Clock[6] = r_Data[12];
	assign o_Clock[7] = r_Data[14];

	assign o_Data[0] = r_Data[1];
	assign o_Data[1] = r_Data[3];
	assign o_Data[2] = r_Data[5];
	assign o_Data[3] = r_Data[7];
	assign o_Data[4] = r_Data[9];
	assign o_Data[5] = r_Data[11];
	assign o_Data[6] = r_Data[13];
	assign o_Data[7] = r_Data[15];

	assign o_Valid = r_Valid && !r_Valid_Last; // rising edge

endmodule
