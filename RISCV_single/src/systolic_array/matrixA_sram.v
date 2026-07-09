module matrixA_sram(
    input clk,
    output [127:0] bulk_data_out // 16 elements * 8 bits
);
    reg [7:0] mem [0:15];
    
    initial begin
        $readmemh("systolic_array/matrixA.mem", mem);
    end
    
    // Flatten the memory array into a single bus for 1-cycle bulk loading
    assign bulk_data_out = {
        mem[15], mem[14], mem[13], mem[12], 
        mem[11], mem[10], mem[9],  mem[8], 
        mem[7],  mem[6],  mem[5],  mem[4], 
        mem[3],  mem[2],  mem[1],  mem[0]
    };
endmodule
