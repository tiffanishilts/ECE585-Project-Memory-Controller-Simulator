import "DPI-C" function string getenv(input string env_name);
class Parser;
parameter ADDR_W 	= 33;
typedef logic [ADDR_W-1		: 0]	address_t;
string trace_file_name, input_trace_path;
int input_trace_file;
address_t address;
int reference;
int operation;
int 	reference_type;
int 	reference_count[9:0];

task pasrseFileName();
	if(!$value$plusargs("TRACE=%s",trace_file_name))begin
	  $error("No input trace file specified");
	  $stop;
	end
endtask

task openFile();
input_trace_path = {getenv("PWD"),"/input/",trace_file_name};
input_trace_file = $fopen(input_trace_path, "r");
	if(input_trace_file) begin
	`ifdef DEBUG
	$display("file is opened");
	`endif
	end
	else begin
		$error("Unable to open input trace file: %s", input_trace_path);
		$stop;
	end
endtask

function int getInput();
	if($fscanf(input_trace_file, "%0d %0d %0h", reference, reference_type, address) == 3) begin
		reference_count[reference_type]++;
		return 1;
	end
	return 0;
endfunction :  getInput

task parseFile();
	while($fscanf(input_trace_file,"%0d %0d %0h", reference, operation, address)==3) begin
		`ifdef DEBUG
			$display("Time=%d Operation=%d Address=%h", reference, operation, address);
		`endif
		end
endtask

endclass
