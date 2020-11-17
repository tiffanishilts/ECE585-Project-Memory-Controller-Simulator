timeunit 1ns/1ns; 
module tb;
int CPU_clock = 0;		// current CPU clock time
int DRAM_clock = 0;		// DRAM clock
logic clk;

controller_module m1(.*);
initial begin
	clk = 0;
	forever #0.3125 clk=~clk;
	end
endmodule
