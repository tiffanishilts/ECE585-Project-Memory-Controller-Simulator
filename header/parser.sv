import "DPI-C" function string getenv(input string env_name);
class Parser;
typedef struct packed {
bit[15:0] row_address;
bit [6:0] hight_column_address;
bit [1:0] bank;
bit [1:0] bank_group;
bit [2:0] colum;
bit [2:0] unused;
}	address_t;
string trace_file_name, input_trace_path;
int input_trace_file;
address_t address;
int reference;
int operation;
string add;
int 	reference_type;
int 	reference_count[9:0];

task parserFileName();
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
