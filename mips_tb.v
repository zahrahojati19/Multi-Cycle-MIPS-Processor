module mips_tb;
  
  wire [31:0] adr, inst, data_in;
  wire mem_read, mem_write;
  reg clk, rst;
 
  mips_multi_cycle MIPS(rst, clk, mem_write, mem_read, adr, inst, data_in);
  mainMem MEMORY(adr, data_in, mem_read, mem_write, clk, inst);
  initial
  begin
    rst = 1'b1;
    clk = 1'b0;
    #4 rst = 1'b0;
    #3000 $stop;
  end
  
  always
  begin
    #2 clk = ~clk;
  end
  
endmodule
