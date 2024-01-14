#include <stdlib.h>

#include <iostream>
#include <fstream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop.h"

#define MAX_SIM_TIME 20000000
vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
	Vtop *dut = new Vtop;

	Verilated::traceEverOn(true);
	Verilated::timeunit(9);
	std::cout << Verilated::timeunitString() << "/" << Verilated::timeprecisionString() << std::endl;
	VerilatedVcdC *m_trace = new VerilatedVcdC;
	dut->trace(m_trace, 5);
	m_trace->open("waveform.vcd");

	if( std::ifstream file{ "WFM01.BIN", std::ios::binary } )
	{
		uint8_t v;
		while ((sim_time < MAX_SIM_TIME) && (file>>v)) {
			dut->io_PMOD_1 = !!(v & 2);
			dut->i_Clk ^= 1;
			dut->eval();
			m_trace->dump(sim_time);
			sim_time++;
			dut->i_Clk ^= 1;
			dut->eval();
			m_trace->dump(sim_time);
			sim_time++;
		}
	}

	m_trace->close();
	delete dut;
	exit(EXIT_SUCCESS);
}

double sc_time_stamp() { return 0; }

/*
module mfm;
	reg [7:0] A; //register declaration for storing each line of file.
	integer datafile; //file descriptors
	reg r_data;
	wire w_test;

	decode_mfm UUT (
		.data(r_data),
		.test(w_test)
	);

	initial
	begin
		datafile=$fopen("WFM01.BIN","r");   //"r" means reading and "w" means writing
		while (! $feof(datafile)) //read until an "end of file" is reached.
		begin
			$fscanf(datafile,"%h\n",A); //scan each line and get the value as an hexadecimal
			r_data = A[1];
		end
		$display("Hello World");
		$finish;
	end
endmodule
*/
