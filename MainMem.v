module mainMem(adr, d_inData, mrd, mwr, clk, d_out);

    input clk, mwr, mrd;
    input [31:0] adr, d_inData;
    output reg[31:0] d_out;
    reg [31:0] mem[0:699];
    
    initial $readmemb("memory1.txt", mem, 0);
    assign d_out = mrd ? mem[adr>>2] : d_out;
    always @(posedge clk) begin
        if(mwr)
            mem[adr>>2] = d_inData;
    end
endmodule
