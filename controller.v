module controller( clk, rst, opcode, func, zero, reg_dst, mem_to_reg, reg_write, 
                   pc_src, operation, PCsig, lord, IRwrite, mem_read,
                  mem_write, alu_srca, alu_srcb);

    input [5:0] opcode;
    input [5:0] func;
    input clk, rst, zero;
    output  reg_write, mem_write, mem_read, PCsig, lord, IRwrite, alu_srca;
    output [1:0] reg_dst, mem_to_reg, pc_src, alu_srcb;
    output [2:0] operation;

    reg     reg_write, mem_write, lord, IRwrite, mem_read, alu_srca, pcwrite, pcwritecond;
    reg [1:0] reg_dst, mem_to_reg, pc_src, alu_srcb;         
    reg [1:0] alu_op;       
    reg [3:0] ps, ns;

   parameter [3:0] IF=4'b0000, ID=4'b0001, memadr=4'b0010, memlw=4'b0011, lw=4'b0100, sw=4'b0101, exe=4'b0110,
		 rt=4'b0111, beq=4'b1000, J=4'b1001, addi=4'b1010 ,  slti=4'b1011, rti=4'b1100, Jr=4'b1101, Jal=4'b1110;
    
    alu_controller ALU_CTRL(alu_op, func, operation);

    always @(ps, opcode)begin
	case(ps)
		IF: ns = ID;
		ID: ns = (opcode==6'b001001) ? addi :
			 (opcode==6'b000010) ? J:
			 (opcode==6'b000100) ? beq :
			 (opcode==6'b000000) ? exe :
		         (opcode==6'b000110) ? Jr :
			 (opcode==6'b001010) ? slti :
			 (opcode==6'b100011) ? memadr : 
			 (opcode==6'b101011) ? memadr:
			 (opcode==6'b000011) ? Jal :  1'bx;

		memadr: ns = (opcode==6'b101011) ? sw : memlw;
		memlw: ns = lw;
		lw: ns = IF;
		sw: ns = IF; 
		exe: ns = rt; 
		rt: ns = IF; 
		beq: ns = IF; 
		J: ns = IF;
		addi: ns = rti;
		slti: ns = rti;
		rti: ns = IF;
		Jr: ns = IF; 
		Jal: ns = IF; 
	endcase
    end


    always @(ps)begin
	{reg_dst, mem_to_reg, reg_write, mem_write, mem_read, lord, IRwrite, alu_srca, alu_srcb, pcwrite, pcwritecond, pc_src}=20'b0;
	case (ps)
		IF: begin //0
			mem_read = 1'b1; alu_srca = 1'b0; lord = 1'b0; IRwrite=1'b1; alu_srcb = 2'b01; alu_op = 2'b00; pcwrite = 1'b1; pc_src = 2'b00;
			end
		ID: begin //1
			{alu_srca,alu_srcb,alu_op}=5'b01100; end
		memadr: begin //2
			{alu_srca,alu_srcb,alu_op}=5'b11000; end
		memlw: begin //3
			mem_read = 1'b1; lord = 1'b1;end
		lw: begin //4
			{reg_dst,reg_write,mem_to_reg}=5'b00101;end
		sw: begin //5
			mem_write = 1'b1; lord = 1'b1;end
		exe: begin //6
			{alu_srca,alu_srcb, alu_op}=5'b10010; end
		rt: begin //7
			{reg_dst,reg_write,mem_to_reg}=5'b01100; end 
		beq: begin //8
			{alu_srca,alu_srcb,alu_op,pcwritecond,pc_src}=8'b10001110; end
		J: begin //9
			{pcwrite,pc_src}=3'b101; end 
		addi: begin //10
			{alu_srca, alu_srcb, alu_op}=5'b11000; end
		slti: begin //13
			{alu_op, alu_srcb, alu_srca}=5'b11101;end
		rti: begin //14
			{reg_dst,reg_write,mem_to_reg}=5'b00100; end
		Jr: begin //11
			{pcwrite, pc_src}=3'b111; end
		Jal: begin //12
			{reg_dst, mem_to_reg, reg_write, pc_src, pcwrite}= 8'b10101011; end
			
	endcase
    end
    always @(posedge clk, posedge rst)begin
	if(rst) ps<=IF;
	else ps<=ns;
    end

    assign PCsig = (zero & pcwritecond) | pcwrite;

endmodule