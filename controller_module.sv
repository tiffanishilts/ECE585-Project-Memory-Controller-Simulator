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
int lastUsedRow;
int lastUsedBank;
int lastUsedBankGroup;
module controller_module;


initial begin
parser.parserFileName();
parser.openFile();

while(queue.size()!=0 || !$feof(parser.input_trace_file) || pendingRequest ) begin:loop
  // To check the queue is full or not and push into the que
		if (queue.size()<=16)begin:full
			if (!pendingRequest) begin
        if (parser.getInput()) begin
          			pendingRequest=1;
        end
    	end

			if (pendingRequest) begin:pending
			$display("requesttttttime:%d",parser.reference);
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
      				$display("pushed in queue at %p",queue);
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
			       // Read
          if(request == 0)begin: read
		          out = $fopen("output.txt", "a");
		            if((lastUsedRow == address.row_address) && (lastUsedBank == address.bank) && (lastUsedBankGroup == address.bank_group))begin: recentlyAccessedRead
                  clocks =dram.READ(DRAM_clock,address.bank_group, address.bank,  address.high_column_address);
				          CPU_clock=clocks.CPU_clock;
				          DRAM_clock=clocks.DRAM_clock;
                  // two keep the track of previously accessed row
                  lastUsedRow = address.row_address;
                  lastUsedBank = address.bank;
                  lastUsedBankGroup = address.bank_group;
				          $fclose(out);
				          pop = queue.pop_front;
				          $display("pop : %p",queue);
                end: recentlyAccessedRead
		            else begin: notRecentlyAccessedRead
                  clocks =dram.PRE(DRAM_clock,address.bank_group, address.bank);
				          CPU_clock=clocks.CPU_clock;
				          DRAM_clock=clocks.DRAM_clock;

				           clocks=dram.ACT(DRAM_clock,address.bank_group, address.bank, address.row_address);
				           CPU_clock=clocks.CPU_clock;
				           DRAM_clock=clocks.DRAM_clock;

			             clocks =dram.READ(DRAM_clock,address.bank_group, address.bank,  address.high_column_address);
				           CPU_clock=clocks.CPU_clock;
				           DRAM_clock=clocks.DRAM_clock;
                   //To keep track of previously accessed row
                   lastUsedRow = address.row_address;
                   lastUsedBank = address.bank;
                   lastUsedBankGroup = address.bank_group;
				           $fclose(out);
				           pop = queue.pop_front;
				           $display("pop : %p",queue);
                end: notRecentlyAccessedRead
			    end: read

			       //Write
			    else if(request == 1)begin: write
            out = $fopen("output.txt", "a");
            if((lastUsedRow == address.row_address) && (lastUsedBank == address.bank) && (lastUsedBankGroup == address.bank_group))begin: recentlyAccessedWrite
                clocks =dram.WRITE(DRAM_clock,address.bank_group, address.bank,  address.high_column_address);
				        CPU_clock=clocks.CPU_clock;
				        DRAM_clock=clocks.DRAM_clock;

                lastUsedRow = address.row_address;
                lastUsedBank = address.bank;
                lastUsedBankGroup = address.bank_group;
				        $fclose(out);
				        pop = queue.pop_front;
				        $display("pop : %p",queue);
				        $display("inside if");
            end: recentlyAccessedWrite
		        else begin: notRecentlyAccessedWrite
              clocks=dram.PRE(DRAM_clock,address.bank_group, address.bank);
				      CPU_clock=clocks.CPU_clock;
				      DRAM_clock=clocks.DRAM_clock;

				      clocks=dram.ACT(DRAM_clock,address.bank_group, address.bank, address.row_address);
              CPU_clock=clocks.CPU_clock;
              DRAM_clock=clocks.DRAM_clock;

              clocks=dram.WRITE(DRAM_clock,address.bank_group, address.bank,  address.high_column_address);
              CPU_clock=clocks.CPU_clock;
				      DRAM_clock=clocks.DRAM_clock;
              lastUsedRow = address.row_address;
              lastUsedBank = address.bank;
              lastUsedBankGroup = address.bank_group;

				      $fclose(out);
				      pop = queue.pop_front;
				      $display("pop : %p",queue);
				      $display("inside else");
            end: notRecentlyAccessedWrite
			    end: write
			       //Instruction Fetch
			   else if(request == 2)begin: instructionFetch
           out = $fopen("output.txt", "a");
           if((lastUsedRow == address.row_address) && (lastUsedBank == address.bank) && (lastUsedBankGroup == address.bank_group)) begin: recentlyAccessedInstructionFetch
				        clocks =dram.READ(DRAM_clock,address.bank_group, address.bank,  address.high_column_address);
				        CPU_clock=clocks.CPU_clock;
				        DRAM_clock=clocks.DRAM_clock;

                lastUsedRow = address.row_address;
                lastUsedBank = address.bank;
                lastUsedBankGroup = address.bank_group;
				        $fclose(out);
				        pop = queue.pop_front;
				        $display("pop");
                end: recentlyAccessedInstructionFetch
		        else begin: notRecentlyAccessedInstructionFetch
              clocks =dram.PRE(DRAM_clock,address.bank_group, address.bank);
				      CPU_clock=clocks.CPU_clock;
				      DRAM_clock=clocks.DRAM_clock;

              clocks=dram.ACT(DRAM_clock,address.bank_group, address.bank, address.row_address);
				      CPU_clock=clocks.CPU_clock;
				      DRAM_clock=clocks.DRAM_clock;

				      clocks =dram.READ(DRAM_clock,address.bank_group, address.bank,  address.high_column_address);
				      CPU_clock=clocks.CPU_clock;
				      DRAM_clock=clocks.DRAM_clock;

              lastUsedRow = address.row_address;
              lastUsedBank = address.bank;
              lastUsedBankGroup = address.bank_group;

				      $fclose(out);
				      pop = queue.pop_front;
				      $display("pop");
            end: notRecentlyAccessedInstructionFetch
			   end: instructionFetch
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
		//$display("queue size: %d", queue.size());
		$display("last used row:%h, Bank:%h, BankGroup:%h",lastUsedRow,lastUsedBankGroup,lastUsedBank);
    $display("Queue Size checking : %p", queue);
  end:loop
	end
endmodule:controller_module
//vlog +define+DEBUG controller_module.sv
//vsim -gui work.controller_module +TRACE=trace.txt
