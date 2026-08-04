module data_memory(
    input [31:0] address,
    input clk,
    input [31:0] write_data,
    input MemRead,
    input MemWrite,
    output reg [31:0] read_data
);

reg [31:0] data_mem [0:1023];
integer i;

initial begin
    for(i=0;i<1024;i=i+1)
        data_mem[i] = 32'b0;
    data_mem[25] = 101;
    data_mem[26] = 102;
    data_mem[27] = 103;
    data_mem[28] = 104;
    data_mem[29] = 105;
    data_mem[30] = 106;
    data_mem[31] = 107;
end
    

always @(*) begin
    if(MemRead) begin
        read_data=data_mem[address[11:2]];
    end 
    else begin
        read_data=32'd0;
    end 
end

always @(posedge clk) begin
    if(MemWrite) begin
       data_mem[address[11:2]]<=write_data;
    end
end
endmodule