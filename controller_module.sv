`include "header/parser.sv"
`include "header/dram_operation.sv"
Parser parser = new();
DRAM dram= new();
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
typedef struct packed {
  int CPU_clock;
  int DRAM_clock;
  } clocks_t ;
clocks_t clocks;
address_t address;
longint CPU_clock = 0;		// current CPU clock time
int adt;			// Advance Time
longint DRAM_clock = 0;		// DRAM clock
int que_size;			//queue size
int requestTime;
logic pendingRequest = 0;
int operationEnable = 0;
int  request;
int delayTime = 0;			// delay for each DRAM command
int out;			//variable for output file descriptor handle
que queue [$:15];	//queue
que pop ;
module controller_module;


initial begin
parser.parserFileName();
parser.openFile();

while(queue.size()!=0 || !$feof(parser.input_trace_file) || pendingRequest ) begin:loop
		if (queue.size()<=16)begin:full
			
			if (parser.getInput()) begin
			
    			pendingRequest=1;
    			end
		
			if (pendingRequest) begin:pending
				
			
				if (queue.size()==0 && CPU_clock<parser.reference) begin:advancing
					
				
       					if(parser.reference%2==0)begin
					
					CPU_clock = parser.reference;
        				DRAM_clock=CPU_clock/2;
        				
					end
        				else begin
         			 	
					CPU_clock = parser.reference+1;
          				DRAM_clock = CPU_clock/2;
          				//$display("timing is adavnace by 1 %d %d", CPU_clock,DRAM_clock);
        				
					end

        			$display("Time is advanced to %d",CPU_clock);

      				end:advancing

      				

      				if(CPU_clock>= parser.reference)begin
				
      				automatic que operationQueue = '{parser.reference,trace_t'(parser.reference_type),address_t'(parser.address)};
				$display("request Time: %d",parser.reference);
  				queue.push_back(operationQueue);
      				//$display("pushed in queue at %d",CPU_clock);
      				pendingRequest=0;
      				operationEnable = 1;
				
				$display("queue= %0d", queue.size());
				end
      			end:pending
		
		end:full

			if (CPU_clock%2==0)begin:process
				
        
				if(operationEnable) begin:en
        			request = queue[0][1];
        			address = queue[0][2];
			
			if(request == 0)begin
			// delayTime = 0;
				out = $fopen("output.txt", "a");
							
				clocks=dram.ACT(DRAM_clock,address.bank_group, address.bank, address.row_address);
				CPU_clock=clocks.CPU_clock;
				DRAM_clock=clocks.DRAM_clock;
				
				clocks =dram.READ(DRAM_clock,address.bank_group, address.bank,  address.high_column_address);
				CPU_clock=clocks.CPU_clock;
				DRAM_clock=clocks.DRAM_clock;
				
				clocks =dram.PRE(DRAM_clock,address.bank_group, address.bank);
				CPU_clock=clocks.CPU_clock;
				DRAM_clock=clocks.DRAM_clock;
				
				$fclose(out);
				pop = queue.pop_front;
				$display("pop : %p",queue);
			end
			//Write
			else if(request == 1)begin
			delayTime = 0;

				out = $fopen("output.txt", "a");
							
				clocks=dram.ACT(DRAM_clock,address.bank_group, address.bank, address.row_address);
				CPU_clock=clocks.CPU_clock;
				DRAM_clock=clocks.DRAM_clock;
				
				clocks =dram.WRITE(DRAM_clock,address.bank_group, address.bank,  address.high_column_address);
				CPU_clock=clocks.CPU_clock;
				DRAM_clock=clocks.DRAM_clock;
				
				clocks =dram.PRE(DRAM_clock,address.bank_group, address.bank);
				CPU_clock=clocks.CPU_clock;
				DRAM_clock=clocks.DRAM_clock;
				
				$fclose(out);
				pop = queue.pop_front;
				$display("pop : %p",queue);
			end
			//Instruction Fetch
			else if(request == 2)begin
				delayTime = 0;
				out = $fopen("output.txt", "a");
				
				clocks=dram.ACT(DRAM_clock,address.bank_group, address.bank, address.row_address);
				CPU_clock=clocks.CPU_clock;
				DRAM_clock=clocks.DRAM_clock;
				
				clocks =dram.READ(DRAM_clock,address.bank_group, address.bank,  address.high_column_address);
				CPU_clock=clocks.CPU_clock;
				DRAM_clock=clocks.DRAM_clock;
				
				clocks =dram.PRE(DRAM_clock,address.bank_group, address.bank);
				CPU_clock=clocks.CPU_clock;
				DRAM_clock=clocks.DRAM_clock;
				
				$fclose(out);
				pop = queue.pop_front;
				$display("pop : %p",queue);
			end
			else begin
			`ifdef DEBUG
			$display("Invalid Operation");
			`endif
			pop = queue.pop_front;
			end
  			end:en
			DRAM_clock++;
	
		end:process
		
		CPU_clock++;
		$display("time:%d",CPU_clock);
		end:loop
	end
endmodule:controller_module