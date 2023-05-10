module datapath ( clk, rst, data_adr, data, wdata, reg_dst, mem_to_reg, pc_src, alu_ctrl, reg_write,zero,
                  PCsig, lord, IRwrite, alu_srca, alu_srcb, instt);

  input  clk, rst;
  input  reg_write, PCsig, lord, IRwrite, alu_srca;
  input [1:0] reg_dst, mem_to_reg, pc_src, alu_srcb;
  input  [2:0] alu_ctrl;
  output [31:0]data_adr;
  output [31:0]wdata;
  output [31:0] instt;
  input [31:0]data;
  output zero;

  wire [31:0] pc_out;
  wire [31:0] read_data1, read_data2, A, B;
  wire [31:0] sgn_ext_out;
  wire [31:0] alu_out;
  wire [27:0] shl2_out;
  wire [31:0] shl22_out;
  wire [31:0] muxa_out;
  wire [31:0] muxb_out; 
  wire [31:0] mux3_out;
  wire [31:0] MemAdr;
  wire [31:0] ALU_out;
  wire [31:0] memout;
  wire [31:0] mdr;
  wire [31:0] inst;
  wire [31:0] instt;
  wire [4:0]  mux1_out;
  wire [31:0] mux12_out;


  reg_32b PC(mux3_out, rst, PCsig, clk, pc_out);
 
  mux2to1_32b MUX_11(pc_out , ALU_out, lord, MemAdr); 

  reg_32b IR(memout, rst, IRwrite, clk, inst); 

  shl26 SHIFT1(inst[25:0], shl2_out);

  reg_32b MDR(memout, rst, 1'b1, clk, mdr); 

  mux4to1_5b MUX_1(inst[20:16], inst[15:11], 5'd31,,reg_dst, mux1_out);

  mux4to1_32b MUX_12(ALU_out, mdr, pc_out,, mem_to_reg, mux12_out);

  reg_file  RF(mux12_out, inst[25:21], inst[20:16], mux1_out, reg_write, rst, clk, read_data1, read_data2);

  reg_32b Areg(read_data1, rst, 1'b1, clk, A);

  reg_32b Breg(read_data2, rst, 1'b1, clk, B);

  sign_ext SGN_EXT(inst[15:0], sgn_ext_out);

  shl2 SHIFT2(sgn_ext_out, shl22_out);

  mux2to1_32b MUX_A(pc_out, A, alu_srca, muxa_out);

  mux4to1_32b MUX_B(B, 32'd4, sgn_ext_out, shl22_out, alu_srcb, muxb_out);

  alu ALU(muxa_out, muxb_out, alu_ctrl, alu_out, zero);

  reg_32b aluout(alu_out, rst, 1'b1, clk, ALU_out);

  mux4to1_32b pcsrc(alu_out, {pc_out[31:28],shl2_out}, ALU_out, A, pc_src, mux3_out); //Jr

  assign data_adr = MemAdr;
  assign memout = data;
  assign wdata = B;
  assign instt = inst;
endmodule
