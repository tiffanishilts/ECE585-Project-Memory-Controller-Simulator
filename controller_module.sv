`include "header/parser.sv"
Parser parser = new();
// Type of trace reference
typedef enum logic [1:0] {
DATA_READ	= 0,
DATA_WRITE	= 1,
INSTR_FETCH	= 2
} trace_t;
typedef int  que[];
parameter ADDR_W 	= 33;
typedef logic [ADDR_W-1		: 0]	address_t;
int CPU_clock = 0;		// current CPU clock time
int DRAM_clock = 0;		// DRAM clock
int que_size;			//queue size
int requestTime; 	
que queue [$:15];	//queue
que pop ;
module controller_module(input logic clk);

	
initial begin
parser.pasrseFileName();
parser.openFile();

end
always_ff@(posedge clk) begin

do begin



while(parser.getInput)begin

	
   automatic que operationQueue = '{parser.reference,trace_t'(parser.reference_type),address_t'(parser.address)};
  $display("PUSHING IN QUEUE");
if (queue.size()<=16) begin
queue.push_back(operationQueue);
$display("%p",queue);
end

	
end

que_size = queue.size();

requestTime = queue[0][0];
$display ("Request = %0d",requestTime);
$display ("Current Time = %0d", CPU_clock);
$display ("DRAM time = %0d",DRAM_clock);



	while(CPU_clock >= requestTime ) begin
	$display("\n\n-----------------");
	$display("POPPING FROM QUEUE");
	$display("-----------------\n");

	
	
	if(CPU_clock == requestTime)begin
	$display("executing instruction at %0d current time", CPU_clock);
	$display("request time %0d Operation= %0s address= %0h",queue[0][0],trace_t'(queue[0][1]),queue[0][2]);
	pop = queue.pop_front;
  	$display("queue after pop:%p",queue);
  	$display("instructions_in_queue= %0d\n",queue.size());
	que_size = queue.size();
	requestTime = queue[0][0];
	end
	else if(que_size==0)
	$stop;
	
end 	
CPU_clock++;
if(CPU_clock%2==0)begin
DRAM_clock++;
end

end while(que_size!=0);

end

endmodule:controller_module
