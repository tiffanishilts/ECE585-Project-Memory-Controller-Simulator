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
module controller_module;

initial begin
que queue [$:15];	//queue
que pop ;
int que_size;			//queue size

int requestTime; 		// Request time for operation
parser.pasrseFileName();
parser.openFile();


$display("----------------");
$display("PUSHING IN QUEUE");
$display("----------------");
for(int i=0; i<16 ; i++) begin
if(parser.getInput())begin
   automatic que mn = '{parser.reference,trace_t'(parser.reference_type),address_t'(parser.address)};
  queue.push_back(mn);
  $display("request time %0d Operation= %0s address= %0h",queue[i][0],trace_t'(queue[i][1]),queue[i][2]);
  que_size = queue.size();
	
end
end
$display("\nAfter pushing all the data in queue\n");
$display("%p\n",queue);
requestTime = queue[0][0];
$display ("Request time = %0d",requestTime);
$display("-----------------");
$display("POPPING FROM QUEUE");
$display("-----------------\n");

while(1) begin

CPU_clock++;
if(CPU_clock%2==0)begin
DRAM_clock++;
end

for(int i=0; i<=que_size ; i++) begin
	
	if(CPU_clock == requestTime)begin
	$display("executing instruction at %0d current time", CPU_clock);
	$display("request time %0d Operation= %0s address= %0h",queue[i][0],trace_t'(queue[i][1]),queue[i][2]);
	pop = queue.pop_front;
  	$display("queue after pop:%p",queue);
  	$display("instructions_in_queue= %0d\n",queue.size());
	que_size = queue.size();
	requestTime = queue[0][0];
	end
	else if(que_size==0)
	$stop; 
end
end

//parser.parseFile();



end
endmodule:controller_module
