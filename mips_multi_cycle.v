
module mips_multi_cycle (rst, clk, memwrite, memread, adr, inst, writedata);

  input rst, clk;
  output [31:0] adr, writedata;
  input [31:0] inst;
  output memread, memwrite;

  wire [31:0] data_adr, wdata;
  wire reg_write,zero, PCsig, lord, IRwrite, alu_srca;
  wire [1:0] reg_dst, mem_to_reg, pc_src, alu_srcb;
  wire [2:0] alu_ctrl;
  wire [31:0] instt;
  
  datapath DP( clk, rst, data_adr, inst, wdata, reg_dst, mem_to_reg, pc_src, alu_ctrl, reg_write,zero,
                  PCsig, lord, IRwrite, alu_srca, alu_srcb, instt);
            
  controller CU( clk, rst, instt[31:26], instt[5:0], zero, reg_dst, mem_to_reg, reg_write, 
                   pc_src, alu_ctrl, PCsig, lord, IRwrite, memread, memwrite, alu_srca, alu_srcb);

  assign adr = data_adr;
  assign writedata = wdata;

endmodule