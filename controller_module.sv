`include "header/parser.sv"
`include "header/dram_operation.sv"
Parser parser = new();
DRAM dram= new();
// Type of trace reference
typedef enum logic [1:0]
{
    DATA_READ	= 0,
    DATA_WRITE	= 1,
    INSTR_FETCH	= 2
} trace_t;
typedef int  que[];

typedef struct packed
{
    bit[15:0] row_address;
    bit [6:0] high_column_address;
    bit [1:0] bank;
    bit [1:0] bank_group;
    bit [2:0] low_column_address;
    bit [2:0] unused;
} address_t;
typedef struct packed
{
    int CPU_clock;
    int DRAM_clock;
} clocks_t ;
clocks_t clocks;
address_t address;

typedef struct packed{
	bit prevAccess;
	bit[31:0] lastUsedRow;
} bank;

bank bankHistory[4][4] = {
{'{1'b0, 32'd65536}, '{1'b0, 32'd65536}, '{1'b0, 32'd65536}, {1'b0, 32'd65536}},
{'{1'b0, 32'd65536}, '{1'b0, 32'd65536}, '{1'b0, 32'd65536}, {1'b0, 32'd65536}},
{'{1'b0, 32'd65536}, '{1'b0, 32'd65536}, '{1'b0, 32'd65536}, {1'b0, 32'd65536}},
{'{1'b0, 32'd65536}, '{1'b0, 32'd65536}, '{1'b0, 32'd65536}, {1'b0, 32'd65536}}
};

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

while(queue.size()!=0 || !$feof(parser.input_trace_file) || pendingRequest )
begin:
    loop
    // To check the queue is full or not and push into the que
    if (queue.size()<=16)
begin:
        full
        if (!pendingRequest)
            begin
            if (parser.getInput())
                begin
                pendingRequest=1;
end
end

if (pendingRequest)
begin:
    pending
    $display("requesttttttime:%d",parser.reference);
if (queue.size()==0 && CPU_clock<parser.reference)
begin:
    advancing
    if(parser.reference%2==0)
        begin
        CPU_clock = parser.reference;
DRAM_clock=CPU_clock/2;
end
else
    begin
    CPU_clock = parser.reference+1;
DRAM_clock = CPU_clock/2;

end
$display("Time is advanced to %d",CPU_clock);
end:
advancing
if(CPU_clock>= parser.reference)
    begin
    automatic que operationQueue = '{parser.reference,trace_t'(parser.reference_type),address_t'(parser.address)};
                                   $display("request Time: %d",parser.reference);
queue.push_back(operationQueue);
$display("pushed in queue at %p",queue);
pendingRequest=0;
operationEnable = 1;
$display("queue= %0d", queue.size());
end
end:
pending
end:
full

if (CPU_clock%2==0)
begin:process

if(operationEnable)
begin:en

request = queue[0][1];
address = queue[0][2];

// Read
if(request == 0)
begin:read

out = $fopen("t6output.txt", "a");

if(bankHistory[address.bank_group][address.bank].prevAccess != 1) begin

clocks=dram.ACT(DRAM_clock,address.bank_group, address.bank, address.row_address);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

clocks =dram.READ(DRAM_clock,address.bank_group, address.bank,  address.high_column_address, address.low_column_address);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

bankHistory[address.bank_group][address.bank].prevAccess = 1;
bankHistory[address.bank_group][address.bank].lastUsedRow = address.row_address;

$fclose(out);
pop = queue.pop_front;
$display("pop : %p",queue);

end

else if(bankHistory[address.bank_group][address.bank].lastUsedRow == address.row_address) begin

clocks =dram.READ(DRAM_clock,address.bank_group, address.bank, address.high_column_address, address.low_column_address);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

bankHistory[address.bank_group][address.bank].lastUsedRow = address.row_address;

$fclose(out);
pop = queue.pop_front;
$display("pop : %p",queue);

end

else if(bankHistory[address.bank_group][address.bank].lastUsedRow != address.row_address) begin

clocks =dram.PRE(DRAM_clock,address.bank_group, address.bank);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

clocks=dram.ACT(DRAM_clock,address.bank_group, address.bank, address.row_address);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

clocks =dram.READ(DRAM_clock,address.bank_group, address.bank,  address.high_column_address, address.low_column_address);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

bankHistory[address.bank_group][address.bank].lastUsedRow = address.row_address;

$fclose(out);
pop = queue.pop_front;
$display("pop : %p",queue);

end

end:read

//Write
else if(request == 1)
begin:write

out = $fopen("t6output.txt", "a");

if(bankHistory[address.bank_group][address.bank].prevAccess != 1) begin

clocks=dram.ACT(DRAM_clock,address.bank_group, address.bank, address.row_address);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

clocks=dram.WRITE(DRAM_clock,address.bank_group, address.bank,  address.high_column_address, address.low_column_address);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

bankHistory[address.bank_group][address.bank].prevAccess = 1;
bankHistory[address.bank_group][address.bank].lastUsedRow = address.row_address;

$fclose(out);
pop = queue.pop_front;
$display("pop : %p",queue);

end

else if(bankHistory[address.bank_group][address.bank].lastUsedRow == address.row_address) begin

clocks =dram.WRITE(DRAM_clock,address.bank_group, address.bank,  address.high_column_address, address.low_column_address);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

bankHistory[address.bank_group][address.bank].lastUsedRow = address.row_address;

$fclose(out);
pop = queue.pop_front;
$display("pop : %p",queue);

end

else if(bankHistory[address.bank_group][address.bank].lastUsedRow != address.row_address) begin

clocks=dram.PRE(DRAM_clock,address.bank_group, address.bank);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

clocks=dram.ACT(DRAM_clock,address.bank_group, address.bank, address.row_address);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

clocks=dram.WRITE(DRAM_clock,address.bank_group, address.bank,  address.high_column_address, address.low_column_address);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

bankHistory[address.bank_group][address.bank].lastUsedRow = address.row_address;

$fclose(out);
pop = queue.pop_front;
$display("pop : %p",queue);

end

end:write

//Instruction Fetch
else if(request == 2)
begin:instructionFetch

out = $fopen("t6output.txt", "a");

if(bankHistory[address.bank_group][address.bank].prevAccess != 1) begin

clocks=dram.ACT(DRAM_clock,address.bank_group, address.bank, address.row_address);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

clocks =dram.IFETCH(DRAM_clock);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

bankHistory[address.bank_group][address.bank].prevAccess = 1;
bankHistory[address.bank_group][address.bank].lastUsedRow = address.row_address;

$fclose(out);
pop = queue.pop_front;
$display("pop");

end

else if(bankHistory[address.bank_group][address.bank].lastUsedRow == address.row_address) begin

clocks =dram.IFETCH(DRAM_clock);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

bankHistory[address.bank_group][address.bank].lastUsedRow = address.row_address;

$fclose(out);
pop = queue.pop_front;
$display("pop");

end

else if(bankHistory[address.bank_group][address.bank].lastUsedRow != address.row_address) begin

clocks =dram.PRE(DRAM_clock,address.bank_group, address.bank);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

clocks=dram.ACT(DRAM_clock,address.bank_group, address.bank, address.row_address);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

clocks =dram.IFETCH(DRAM_clock);
CPU_clock=clocks.CPU_clock;
DRAM_clock=clocks.DRAM_clock;

bankHistory[address.bank_group][address.bank].lastUsedRow = address.row_address;

$fclose(out);
pop = queue.pop_front;
$display("pop");

end

end:instructionFetch

else
    begin
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
$display("Queue Size checking : %p", queue);
end:loop
end
endmodule:controller_module

//vlog +define+DEBUG controller_module.sv
//vsim -gui work.controller_module +TRACE=trace.txt