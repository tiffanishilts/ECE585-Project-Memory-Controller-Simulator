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
