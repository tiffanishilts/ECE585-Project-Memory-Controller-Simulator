class DRAM;
  
typedef struct packed {
  int CPU_clock;
  int DRAM_clock;
  } clocks_t;

bit[9:0] column;

function clocks_t ACT(int DRAM_clock,int bank_group,int bank,int row_address);
clocks_t clocks;

$fdisplay(out,"%0d ACT %0h %0h %0h",DRAM_clock*2, bank_group, bank,row_address);
clocks.DRAM_clock = DRAM_clock+24;
clocks.CPU_clock  = clocks.DRAM_clock*2;

return clocks;
endfunction: ACT

function clocks_t READ(int DRAM_clock,int bank_group,int bank,bit[6:0] high_column_address,bit[2:0] low_column_address);
clocks_t clocks;

column = {high_column_address, low_column_address};

$fdisplay(out,"%0d RD %0h %0h %0h",DRAM_clock*2,bank_group, bank, column);
clocks.DRAM_clock = DRAM_clock+28;
clocks.CPU_clock=clocks.DRAM_clock*2;
return clocks;
endfunction: READ

function clocks_t PRE(int DRAM_clock,int bank_group,int bank);
clocks_t clocks;

$fdisplay(out,"%0d PRE %0h %0h",DRAM_clock*2,bank_group, bank);
clocks.DRAM_clock = DRAM_clock+24;
clocks.CPU_clock=clocks.DRAM_clock*2;
return clocks;
endfunction: PRE

function clocks_t WRITE(int DRAM_clock,int bank_group,int bank,bit[6:0] high_column_address,bit[2:0] low_column_address);
clocks_t clocks;

column = {high_column_address, low_column_address};

$fdisplay(out,"%0d WR %0h %0h %0h",DRAM_clock*2,bank_group, bank, column);
clocks.DRAM_clock = DRAM_clock+20;
clocks.CPU_clock=clocks.DRAM_clock*2;
return clocks;
endfunction: WRITE

function clocks_t IFETCH(int DRAM_clock);
clocks_t clocks;

$fdisplay(out,"%0d REF", DRAM_clock*2);

clocks.DRAM_clock = DRAM_clock+28;
clocks.CPU_clock = clocks.DRAM_clock*2;

return clocks;
endfunction: IFETCH

endclass;
