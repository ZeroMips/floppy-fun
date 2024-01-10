/*
 * Find and parse the fd sector header
 */

function automatic [15:0] crc;
    input [15:0] crcIn;
    input [7:0] data;
begin
    crc[0] = crcIn[8] ^ crcIn[12] ^ data[0] ^ data[4];
    crc[1] = crcIn[9] ^ crcIn[13] ^ data[1] ^ data[5];
    crc[2] = crcIn[10] ^ crcIn[14] ^ data[2] ^ data[6];
    crc[3] = crcIn[11] ^ crcIn[15] ^ data[3] ^ data[7];
    crc[4] = crcIn[12] ^ data[4];
    crc[5] = crcIn[8] ^ crcIn[12] ^ crcIn[13] ^ data[0] ^ data[4] ^ data[5];
    crc[6] = crcIn[9] ^ crcIn[13] ^ crcIn[14] ^ data[1] ^ data[5] ^ data[6];
    crc[7] = crcIn[10] ^ crcIn[14] ^ crcIn[15] ^ data[2] ^ data[6] ^ data[7];
    crc[8] = crcIn[0] ^ crcIn[11] ^ crcIn[15] ^ data[3] ^ data[7];
    crc[9] = crcIn[1] ^ crcIn[12] ^ data[4];
    crc[10] = crcIn[2] ^ crcIn[13] ^ data[5];
    crc[11] = crcIn[3] ^ crcIn[14] ^ data[6];
    crc[12] = crcIn[4] ^ crcIn[8] ^ crcIn[12] ^ crcIn[15] ^ data[0] ^ data[4] ^ data[7];
    crc[13] = crcIn[5] ^ crcIn[9] ^ crcIn[13] ^ data[1] ^ data[5];
    crc[14] = crcIn[6] ^ crcIn[10] ^ crcIn[14] ^ data[2] ^ data[6];
    crc[15] = crcIn[7] ^ crcIn[11] ^ crcIn[15] ^ data[3] ^ data[7];
end
endfunction

module sector_header (
	input i_Reset,
	input i_Clk,
	input i_Sync,
	input [7:0] i_Data,
	input i_Valid,
	output [7:0] o_Track,
	output [7:0] o_Side,
	output [7:0] o_Sector,
	output [7:0] o_SectorSize,
	output [15:0] o_CRC,
	output o_CRCError,
	output [3:0] o_State,
	output o_Valid);

	localparam WAIT_SYNC = 4'd0;
	localparam WAIT_A1_0 = 4'd1;
	localparam WAIT_A1_1 = 4'd2;
	localparam WAIT_A1_2 = 4'd3;
	localparam WAIT_FE = 4'd4;
	localparam GET_TRACK = 4'd5;
	localparam GET_SIDE = 4'd6;
	localparam GET_SECTOR = 4'd7;
	localparam GET_SECTOR_SIZE = 4'd8;
	localparam GET_CRC0 = 4'd9;
	localparam GET_CRC1 = 4'd10;
	localparam CHECK_CRC = 4'd11;

	reg [7:0] r_Track;
	reg [7:0] r_Side;
	reg [7:0] r_Sector;
	reg [7:0] r_SectorSize;
	reg [15:0] r_CRCRead;
	reg [15:0] r_CRCCalc;

	reg [3:0] r_State;
	reg r_CRCError;
	reg r_Valid;

	always @(posedge i_Clk or posedge i_Reset)
	begin
		if (i_Reset)
		begin
			r_State <= WAIT_SYNC;
			r_CRCError <= 0;
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
						r_State <= WAIT_FE;
					else
						r_State <= WAIT_SYNC;
				WAIT_FE:
					if (i_Data == 8'hFE)
						r_State <= GET_TRACK;
					else
						r_State <= WAIT_SYNC;
				GET_TRACK:
					begin
						r_Track <= i_Data;
						r_State <= GET_SIDE;
					end
				GET_SIDE:
					begin
						r_Side <= i_Data;
						r_State <= GET_SECTOR;
					end
				GET_SECTOR:
					begin
						r_Sector <= i_Data;
						r_State <= GET_SECTOR_SIZE;
					end
				GET_SECTOR_SIZE:
					begin
						r_SectorSize <= i_Data;
						r_State <= GET_CRC0;
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
				if (r_CRCCalc == r_CRCRead)
					r_Valid <= 1;
				else
					r_CRCError <= 1;
				r_State <= WAIT_SYNC;
			end
			if (r_Valid)
				r_Valid <= 0;
			if (r_CRCError)
				r_CRCError <= 0;
		end

	end

	assign o_Track = r_Track;
	assign o_Side = r_Side;
	assign o_Sector = r_Sector;
	assign o_SectorSize = r_SectorSize;
	assign o_CRC = r_CRCRead;
	assign o_CRCError = r_CRCError;
	assign o_Valid = r_Valid;
	assign o_State = r_State;

endmodule

