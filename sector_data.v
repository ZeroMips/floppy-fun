module sector_data (
	input i_Reset,
	input i_Clk,
	input i_Sync,
	input [7:0] i_Data,
	input i_Valid,
	output o_Valid,
	output [7:0] o_Data,
	output o_CRCError
	);

	localparam WAIT_SYNC = 4'd0;
	localparam WAIT_A1_0 = 4'd1;
	localparam WAIT_A1_1 = 4'd2;
	localparam WAIT_A1_2 = 4'd3;
	localparam WAIT_FX = 4'd4;
	localparam GET_DATA = 4'd5;
	localparam GET_CRC0 = 4'd6;
	localparam GET_CRC1 = 4'd7;
	localparam CHECK_CRC = 4'd8;

	reg [15:0] r_CRCRead;
	reg [15:0] r_CRCCalc;

	reg [7:0] r_Data;

	reg [3:0] r_State;
	reg r_CRCError;
	reg r_Valid;
	reg [8:0] r_DataCtr;

	always @(posedge i_Clk or posedge i_Reset)
	begin
		if (i_Reset)
		begin
			r_State <= WAIT_SYNC;
			r_CRCError <= 0;
			r_DataCtr <= 0;
		end
		else
		begin
			if (i_Sync && (r_State != WAIT_A1_1) && (r_State != WAIT_A1_2))
			begin
				r_State <= WAIT_A1_0;
				r_CRCCalc <= 16'hffff;
			end
			else if (i_Valid)
			begin
				if (r_State < GET_CRC0)
					r_CRCCalc <= crc(r_CRCCalc, i_Data);
				case (r_State)
				WAIT_A1_0:
					if (i_Data == 8'hA1)
						r_State <= WAIT_A1_1;
					else
						r_State <= WAIT_SYNC;
				WAIT_A1_1:
					if (i_Data == 8'hA1)
						r_State <= WAIT_A1_2;
					else
						r_State <= WAIT_SYNC;
				WAIT_A1_2:
					if (i_Data == 8'hA1)
						r_State <= WAIT_FX;
					else
						r_State <= WAIT_SYNC;
				WAIT_FX:
					if ((i_Data == 8'hFA) || (i_Data == 8'hFB))
						r_State <= GET_DATA;
					else
						r_State <= WAIT_SYNC;
				GET_DATA:
					begin
						r_Data <= i_Data;
						r_Valid <= 1;
						r_DataCtr <= r_DataCtr + 1;
						if (r_DataCtr == 511)
						begin
							r_State <= GET_CRC0;
							r_DataCtr <= 0;
						end
					end
				GET_CRC0:
					begin
						r_CRCRead[15:8] <= i_Data;
						r_State <= GET_CRC1;
					end
				GET_CRC1:
					begin
						r_CRCRead[7:0] <= i_Data;
						r_State <= CHECK_CRC;
					end
				default:
					r_State <= WAIT_SYNC;
				endcase
			end
			if (r_State == CHECK_CRC)
			begin
				if (r_CRCCalc != r_CRCRead)
					r_CRCError <= 1;
				r_State <= WAIT_SYNC;
			end
			if (r_Valid)
				r_Valid <= 0;
			if (r_CRCError)
				r_CRCError <= 0;
		end

	end

	assign o_CRCError = r_CRCError;
	assign o_Data = r_Data;
	assign o_Valid = r_Valid;

endmodule