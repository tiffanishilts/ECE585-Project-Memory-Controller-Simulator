`include "header/parser.sv"

Parser parser = new();
// Type of trace reference
typedef enum logic [1:0] {
DATA_READ	= 0,
DATA_WRITE	= 1,
INSTR_FETCH	= 2
} trace_t;
typedef int  que[];

typedef struct packed {
bit[15:0] row_address;
bit [6:0] high_column_address;
bit [1:0] bank;
bit [1:0] bank_group;
bit [2:0] low_column_address;
bit [2:0] unused;
}address_t;
address_t address;
int CPU_clock = 0;		// current CPU clock time
int adt;			// Advance Time 
int DRAM_clock = 0;		// DRAM clock
int que_size;			//queue size
int requestTime;
logic pendingRequest = 0;
int operationEnable = 0;
int  request;
int delayTime = 0;			// delay for each DRAM command
int out;			//variable for output file descriptor handle			
que queue [$:15];	//queue
que pop ;
module controller_module(input logic clk);


initial begin
parser.pasrseFileName();
parser.openFile();

end
always_ff@(posedge clk) begin:ff
while(queue.size()!=0 || !$feof(parser.input_trace_file) ) begin:loop
		if (queue.size()!=16)begin:full
			//if (!pendingRequest)begin
			// get next request
		if (parser.getInput())begin
		automatic que operationQueue = '{parser.reference,trace_t'(parser.reference_type),address_t'(parser.address)};
		queue.push_back(operationQueue);
		end			
		//end
			//if (pendingRequest) begin:pending
				/*if (queue.size()==0) begin
				//advance time
				adt = parser.reference - CPU_clock; 
				CPU_clock = parser.reference;
				DRAM_clock = DRAM_clock + adt/2;
				end*/
			requestTime = queue[0][0];
				if(CPU_clock >= requestTime) begin:req
		request = queue[0][1];	
		address = queue[0][2];
		operationEnable = 1;
				end:req
				
				
				//end:pending
		end:full

		
			if (CPU_clock%2==0)begin:process
			if (operationEnable==1)begin:en
			//$display("queue size: %d",queue.size());
			//Read
			if(request == 0)begin
			delayTime = 0;
			
				out = $fopen("output.txt", "a");
				/*while(delayTime <=20 ) begin // delay time for ACT command 
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end*/
				
				$fdisplay(out,"data read operation");
				$fdisplay(out,"%0d ACT %0h %0h %0h",CPU_clock, address.bank_group, address.bank, address.row_address);
				delayTime = 0;
				while(delayTime <24 ) begin //  tRCD
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end
				$fdisplay(out,"%0d RD %0h %0h %0h",CPU_clock, address.bank_group, address.bank, address.high_column_address);
				delayTime = 0;
				while(delayTime <24 ) begin // CL
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end
				delayTime = 0;
				while(delayTime <4 ) begin // tBurst
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end
				delayTime = 0;
				while(delayTime <24 ) begin // tRP 
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end
				$fdisplay(out,"%0d PRE %0h %0h ",CPU_clock, address.bank_group, address.bank);
				$fclose(out);
				pop = queue.pop_front;
			end
			//Write
			else if(request == 1)begin
			delayTime = 0;
			
				out = $fopen("output.txt", "a");
				/*while(delayTime <=20 ) begin // delay time for ACT command 
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end*/
				
				$fdisplay(out,"data write operation");
				$fdisplay(out,"%0d ACT %0h %0h %0h",CPU_clock, address.bank_group, address.bank, address.row_address);
				delayTime = 0;
				while(delayTime <24 ) begin // delay time for RD command 
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end
				$fdisplay(out,"%0d WD %0h %0h %0h",CPU_clock, address.bank_group, address.bank,address.high_column_address);
				delayTime = 0;
				while(delayTime <24 ) begin // CL
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end
				delayTime = 0;
				while(delayTime <4 ) begin // tBurst
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end
				delayTime = 0;
				while(delayTime <24 ) begin // tRP 
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end
				$fdisplay(out,"%0d PRE %0h %0h",CPU_clock, address.bank_group, address.bank);
				$fclose(out);
				pop = queue.pop_front;
			end
			//Instruction Fetch
			else if(request == 2)begin
				delayTime = 0;
				out = $fopen("output.txt", "a");
				/*while(delayTime <=24 ) begin // delay time for ACT command 
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end*/
				$fdisplay(out,"Instruction fetch operation");
				$fdisplay(out,"%0d ACT %0h %0h %0h",CPU_clock, address.bank_group, address.bank, address.row_address);
				delayTime = 0;
				while(delayTime <24 ) begin // delay time for RD command 
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end
				$fdisplay(out,"%0d RD %0h %0h %0h",CPU_clock, address.bank_group, address.bank,address.high_column_address);
				delayTime = 0;
				while(delayTime <24 ) begin // CL
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end
				delayTime = 0;
				while(delayTime <4 ) begin // tBurst
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end
				delayTime = 0;
				while(delayTime <24 ) begin // tRP 
				DRAM_clock++;
				CPU_clock=CPU_clock +2;
				delayTime++;
				end
				$fdisplay(out,"%0d PRE %0h %0h",CPU_clock, address.bank_group, address.bank);
				$fclose(out);
				pop = queue.pop_front;
			end
			else begin
			`ifdef DEBUG
			$display("Invalid Operation");
			`endif 
			pop = queue.pop_front;
			end
  		end:en
		end:process	
	
		CPU_clock++;
		end:loop 	
end:ff
endmodule:controller_module











/*
while(!$feof(parser.input_trace_file)|| queue.size()>0)begin
	if (queue.size()<16) begin
	$display("Queue is not full");
		if (parser.getInput())begin
		automatic que operationQueue = '{parser.reference,trace_t'(parser.reference_type),address_t'(parser.address)};
		$display("\n\n-----------------");
		$display("PUSHING IN QUEUE");
		$display("-----------------\n");
		queue.push_back(operationQueue);
		$display("%p",queue);
		end


	end

requestTime = queue[0][0];
$display ("Request = %0d",requestTime);
$display ("Current Time = %0d", CPU_clock);
$display ("DRAM time = %0d",DRAM_clock);
$display ("queue Size = %0d", queue.size());

// advancing time block
	//if (CPU_clock < requestTime ) begin
	//CPU_clock = requestTime;
	//end

if(CPU_clock > requestTime || CPU_clock==requestTime) begin
$display("\n\n-----------------");
$display("POPPING FROM QUEUE");
$display("-----------------\n");

$display("executing instruction at %0d current time", CPU_clock);
address = queue[0][2];
request = queue[0][1];
$display("request time = %0d Operation = %0s Row address=%h High Column address=%h bank=%h bank group=%h low column address=%h unused=%h  ",queue[0][0],trace_t'(queue[0][1]),address.row_address, address.high_column_address, address.bank, address.bank_group, address.low_column_address, address.unused);
$display("request=%d",request);
pop = queue.pop_front;
	if(CPU_clock%2==0)begin
	DRAM_clock++;
		//Read
		if(request == 0)begin
		$display("data read operation");
		$display("ACT Bank Group=%h Bank=%h Row=%h",address.bank_group, address.bank, address.row_address);
		$display("RD Bank Group=%h Bank=%h Column=%h",address.bank_group, address.bank,address.high_column_address);
		$display("PRE Bank Group=%h Bank=%h ",address.bank_group, address.bank);
		end
		//Write
		else if(request == 1)begin
		$display("data write operation");
		$display("ACT Bank Group=%h Bank=%h Row=%h",address.bank_group, address.bank, address.row_address);
		$display("WR Bank Group=%h Bank=%h Column=%h",address.bank_group, address.bank,address.high_column_address);
		$display("PRE Bank Group=%h Bank=%h ",address.bank_group, address.bank);
		end
		//Instruction Fetch
		else if(request == 2)begin
		$display("instruct fetch operation");
		$display("ACT Bank Group=%h Bank=%h Row=%h",address.bank_group, address.bank, address.row_address);
		$display("RD Bank Group=%h Bank=%h Column=%h",address.bank_group, address.bank,address.high_column_address);
		$display("PRE Bank Group=%h Bank=%h ",address.bank_group, address.bank);
		end
	end
end
	else begin
	if(CPU_clock%2==0)begin
	DRAM_clock++;

	end

$display("queue after pop:%p",queue);
$display("instructions_in_queue= %0d\n",queue.size());


//requestTime = queue[0][0];
end

CPU_clock++;
end
*/