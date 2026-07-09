module ex_mem (
    input clk,
    input rst,
    input [31:0] alu_result_in,
    input [31:0] write_data_in,
    input [4:0] rd_in,
    input RegWrite_in,
    input MemRead_in,
    input MemWrite_in,
    input MemToReg_in,
    output reg [31:0] alu_result_out,
    output reg [31:0] write_data_out,
    output reg [4:0] rd_out,
    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg MemToReg_out,
    input [31:0] pc_plus_4_in,
    output reg [31:0] pc_plus_4_out,
    input Jump_in,
    output reg Jump_out,
    input stall, // Added stall port back for Cache freeze
    
    // --- Systolic Array ---
    input [1:0] SystolicOp_in,
    input [31:0] rs1_in,
    output reg [1:0] SystolicOp_out,
    output reg [31:0] rs1_out
);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        alu_result_out <= 0;
        write_data_out <= 0;
        rd_out <= 0;
        RegWrite_out <= 0;
        MemRead_out <= 0;
        MemWrite_out <= 0;
        MemToReg_out <= 0;
        pc_plus_4_out <= 0;
        Jump_out <= 0;
        SystolicOp_out <= 2'b00;
        rs1_out <= 32'd0;
    end
    else if (stall) begin
        // FREEZE: Keep the instruction causing the miss trapped here
        alu_result_out <= alu_result_out;
        write_data_out <= write_data_out;
        rd_out <= rd_out;
        RegWrite_out <= RegWrite_out;
        MemRead_out <= MemRead_out;
        MemWrite_out <= MemWrite_out;
        MemToReg_out <= MemToReg_out;
        pc_plus_4_out <= pc_plus_4_out;
        Jump_out <= Jump_out;
        SystolicOp_out <= SystolicOp_out;
        rs1_out <= rs1_out;
    end
    else begin
        // NORMAL operation
        alu_result_out <= alu_result_in;
        write_data_out <= write_data_in;
        rd_out <= rd_in;
        RegWrite_out <= RegWrite_in;
        MemRead_out <= MemRead_in;
        MemWrite_out <= MemWrite_in;
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
//       "EXMEM stall=%b rd_in=%0d rd_out=%0d",
//       stall,
//       rd_in,
//       rd_out
//     );
//     $display(
//  "rd=%0d MemRead=%b MemToReg=%b RegWrite=%b",
//  rd_out,
//  MemRead_out,
//  MemToReg_out,
//  RegWrite_out
// );
// end

endmodule