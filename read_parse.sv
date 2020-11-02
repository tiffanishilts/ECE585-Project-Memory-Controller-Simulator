<<<<<<< HEAD
module parse;
initial begin 

	int file;
	int a; //address

	int c;	  // clk
	int o;    // operation 
	

	file = $fopen("./trace.txt", "r");
	if(file)
	$display("file was opened successfully");
	else begin 
	$error("opening file was unsuccessful");
	end


	while($fscanf(file, "%d %d %h", c, o, a)==3)begin
	$display("%d %d %h", c, o, a);
	end
	
	$fclose(file);
end
endmodule
=======
import "DPI-C" function string getenv(input string env_name);

module read_parse;

initial begin 

	int file;
	int a; //address
	string path; // file path
	string file_name;
	int c;	  // clk
	int o;    // operation 
	
	
	if($value$plusargs("TRACE=%s", file_name))
		$display("Filename is: %s", file_name);
	else
	$display("File name retrieval unsuccessful");
		
	   

	path = {getenv("PWD"),"/input/",file_name};                 

	
	file = $fopen(path, "r");
	`ifdef DEBUG
	   if(file)begin
	      $display("file was opened successfully");
	   end
	   else	begin
	       $error("opening file was unsuccessful");
	   end
	`endif


	while($fscanf(file, "%d %d %h", c, o, a)==3)begin
	`ifdef DEBUG
	$display("Time=%d Operation=%d Address=%h", c, o, a);
	`endif
	end
	
	$fclose(file);
end
endmodule

>>>>>>> master
