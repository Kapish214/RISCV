module mem_wb(
    input clk,
    input rst,
    input [31:0] mem_data_in,
    input [31:0] alu_result_in,
    input [4:0] rd_in,
    input RegWrite_in,
    input MemToReg_in,
    output reg [31:0] mem_data_out,
    output reg [31:0] alu_result_out,
    output reg [4:0] rd_out,
    output reg RegWrite_out,
    output reg MemToReg_out,
    input [31:0] pc_plus_4_in,
    output reg [31:0] pc_plus_4_out,
    input Jump_in,
    output reg Jump_out,
    input stall, // BUG FIX: Restored the stall port

    // --- Systolic Array ---
    input [1:0] SystolicOp_in,
    input [31:0] rs1_in,      // UPDATED: Now 32-bit to hold resolved data
    output reg [1:0] SystolicOp_out,
    output reg [31:0] rs1_out // UPDATED: Now 32-bit to hold resolved data
);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        mem_data_out <= 0;
        alu_result_out <= 0;
        rd_out <= 0;
        RegWrite_out <= 0;
        MemToReg_out <= 0;
        Jump_out <= 0;
        pc_plus_4_out <= 0;
        SystolicOp_out <= 2'b00;
        rs1_out <= 32'd0;    // UPDATED: Reset to 32-bit zero
    end
    else if(stall) begin
        // BUG FIX: Strictly freeze MEM/WB! 
        // This prevents pipeline tearing (keeps forwarding active) 
        // and stops it from slurping duplicate loads from EX/MEM.
        mem_data_out <= mem_data_out;
        alu_result_out <= alu_result_out;
        rd_out <= rd_out;
        RegWrite_out <= RegWrite_out;
        MemToReg_out <= MemToReg_out;
        pc_plus_4_out <= pc_plus_4_out;
        Jump_out <= Jump_out;
        SystolicOp_out <= SystolicOp_out;
        rs1_out <= rs1_out;
    end
    else begin
        // NORMAL EXECUTION
        mem_data_out <= mem_data_in;
        alu_result_out <= alu_result_in;
        rd_out <= rd_in;
        RegWrite_out <= RegWrite_in;
        MemToReg_out <= MemToReg_in;
        pc_plus_4_out <= pc_plus_4_in;
        Jump_out <= Jump_in;
        SystolicOp_out <= SystolicOp_in;
        rs1_out <= rs1_in;
    end
end

// always @(posedge clk)
// begin
//     $display(
//       "MEMWB rd=%0d mem_data_in=%0d MemToReg=%b",
//       rd_in,
//       mem_data_in,
//       MemToReg_in
//     );
// end

endmodule