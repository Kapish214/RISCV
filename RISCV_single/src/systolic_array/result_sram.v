module result_sram(
    input clk,
    input rst,
    // CPU Read Port (SMRD)
    input  [3:0]  read_addr,
    output [17:0] read_data,
    
    // Systolic Array Bulk Write Port
    input         bulk_we,
    input  [17:0] C11, input [17:0] C12, input [17:0] C13, input [17:0] C14,
    input  [17:0] C21, input [17:0] C22, input [17:0] C23, input [17:0] C24,
    input  [17:0] C31, input [17:0] C32, input [17:0] C33, input [17:0] C34,
    input  [17:0] C41, input [17:0] C42, input [17:0] C43, input [17:0] C44
);
    reg [17:0] mem [0:15];
    
    // Continuous assignment for CPU scalar reads
    assign read_data = mem[read_addr];
    
    integer i;

    // Bulk parallel write from the Systolic Array
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            for(i=0;i<16;i++) begin
                mem[i] <=0;
            end
        end
        else begin
            if (bulk_we) begin
                mem[0]  <= C11; mem[1]  <= C12; mem[2]  <= C13; mem[3]  <= C14;
                mem[4]  <= C21; mem[5]  <= C22; mem[6]  <= C23; mem[7]  <= C24;
                mem[8]  <= C31; mem[9]  <= C32; mem[10] <= C33; mem[11] <= C34;
                mem[12] <= C41; mem[13] <= C42; mem[14] <= C43; mem[15] <= C44;
            end
        end
    end
endmodule