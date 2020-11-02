// SystemVerilog module for reading and parsing files
// Inputs: Takes plusarg from user to specify file name
// Outputs: Displays error checking for all operations to user
// Copyright Tiffani Shilts 10/2020
// ECE 485/585 Fall 2020 with Professor Mark Faust 
// Final Project

module fileOperations;

timeunit 1ns/1ns;
    
	initial begin

        string file;                                                            // string variable for file name

        int fd_r, clocks, operation, hexAddr, errorCheck;                       // file descriptor for read operation, cpu clock cycles, operation, hexadecimal address

        if ($value$plusargs ("ERRORCHECK=%d", errorCheck))                      // attempt to error preference from command line
                                                                                // user must specify input as: +ERRORCHECK=0/1 exactly; 0 no, 1 yes
            $display ("Error check preference is: %d", errorCheck);             // display preference if retrieved successfully
        else
            $display ("Error preference retrieval unsuccessful");               // else tell user retrieval was unsuccessful

                                               
        if(errorCheck == 1)
        begin
            if ($value$plusargs ("FILENAME=%s", file))                              // attempt to get file name from command line
                                                                                    // user must specify input as: +FILENAME=filename OR +FILENAME="filename" exactly
                $display ("Filename is: %s", file);                                 // display file name if retrieved successfully
            else
                $display ("File name retrieval unsuccessful");                      // else tell user retrieval was unsuccessful

            fd_r = $fopen(file, "r");                                               // attempt to open file
            
            if (fd_r)                                                               // display error code from file descriptor to determine file operation success
                $display ("File was opened successfully: %0d", fd_r);               // some negative number will display if success
            else
                $display ("File was NOT opened successfully: %0d", fd_r);           // 0 will display if failure

            while ($fscanf (fd_r, "%d %d %x", clocks, operation, hexAddr) == 2)     // continue to read file until conversion failure or eof whichever is first
                begin
                    $display("%d %d %x", clocks, operation, hexaddr);               // display each line to ensure proper parsing
                end

            $fclose(fd_r);
        end
        else
        begin
            $value$plusargs ("FILENAME=%s", file);                                  // attempt to get file name from command line

            fd_r = $fopen(file, "r");                                               // attempt to open file

            while ($fscanf (fd_r, "%d %d %x", clocks, operation, hexAddr) == 2);    // continue to read file until conversion failure or eof whichever is first

            $fclose(fd_r);
        end
    end

endmodule
