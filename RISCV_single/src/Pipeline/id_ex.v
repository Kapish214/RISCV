module id_ex (
    input clk,
    input rst,
    input flush,
    input stall,         // Used for load-use hazard (inserts bubble)
    input cache_stall,   // Used for cache miss (freezes register)
    
    // --- Existing Inputs ---
    input [31:0] pc_in,
    input [31:0] read_data1_in,
    input [31:0] read_data2_in,
    input [31:0] imm_in,
    input [4:0] rs1_in,
    input [4:0] rs2_in,
    input [4:0] rd_in,
    input RegWrite_in,
    input MemRead_in,
    input MemWrite_in,
    input MemToReg_in,
    input ALUSrc_in,
    input Jump_in,
    input Jalr_in,
    input [2:0] funct3_in,
    input [6:0] funct7_in,
    input ALUSrcA_in,
    input [2:0] BranchType_in,
    input [3:0] ALUOp_in,

    // --- NEW: Cargo from IF/ID ---
    input prediction_taken_in, 
    input [31:0] predicted_target_in,
    input compressed_in,

    // --- Existing Outputs ---
    output reg [31:0] pc_out,
    output reg [31:0] read_data1_out,
    output reg [31:0] read_data2_out,
    output reg [31:0] imm_out,
    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,
    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg MemToReg_out,
    output reg ALUSrc_out,
    output reg Jump_out,
    output reg Jalr_out,
    output reg ALUSrcA_out,
    output reg [2:0] BranchType_out,
    output reg [3:0] ALUOp_out,

    // --- NEW: Cargo to EX Stage ---
    output reg prediction_taken_out,
    output reg [31:0] predicted_target_out,
    output reg compressed_out,

    // --- Systolic Array ---
    input [1:0] SystolicOp_in,
    output reg [1:0] SystolicOp_out
);
    
always @(posedge clk or posedge rst) begin
    if(rst || flush) begin
        pc_out <= 0;
        read_data1_out <= 0;
        read_data2_out <= 0;
        imm_out <= 0;
        rs1_out <= 0;
        rs2_out <= 0;
        rd_out <= 0;
        funct3_out <= 0;
        funct7_out <= 0;
        RegWrite_out <= 0;
        MemRead_out <= 0;
        MemWrite_out <= 0;
        MemToReg_out <= 0;
        ALUSrc_out <= 0;
        Jump_out <= 0;
        Jalr_out <= 0;
        ALUSrcA_out <= 0;
        BranchType_out <= 0;
        ALUOp_out <= 0;
        SystolicOp_out <= 2'b00;
        
        // Kill the new signals on a flush!
        prediction_taken_out <= 0;
        predicted_target_out <= 0;
        compressed_out <= 1'b0;
    end
    else if(cache_stall) begin
        // CACHE MISS: Freeze everything. Keep the current values intact.
        pc_out <= pc_out;
        read_data1_out <= read_data1_out;
        read_data2_out <= read_data2_out;
        imm_out <= imm_out;
        rs1_out <= rs1_out;
        rs2_out <= rs2_out;
        rd_out <= rd_out;
        funct3_out <= funct3_out;
        funct7_out <= funct7_out;
        RegWrite_out <= RegWrite_out;
        MemRead_out <= MemRead_out;
        MemWrite_out <= MemWrite_out;
        MemToReg_out <= MemToReg_out;
        ALUSrc_out <= ALUSrc_out;
        Jump_out <= Jump_out;
        Jalr_out <= Jalr_out;
        ALUSrcA_out <= ALUSrcA_out;
        BranchType_out <= BranchType_out;
        ALUOp_out <= ALUOp_out;
        
        // Freeze the new signals
        prediction_taken_out <= prediction_taken_out;
        predicted_target_out <= predicted_target_out;
        compressed_out <= compressed_out;
        SystolicOp_out <= SystolicOp_out;
    end
    else if(stall) begin
        // HAZARD STALL: Insert a bubble (turn instruction into a NOP)
        pc_out <= 0;
        read_data1_out <= 0;
        read_data2_out <= 0;
        imm_out <= 0;
        rs1_out <= 0;
        rs2_out <= 0;
        rd_out  <= 0;
        funct3_out <= 0;
        funct7_out <= 0;
        RegWrite_out <= 0;
        MemRead_out  <= 0;
        MemWrite_out <= 0;
        MemToReg_out <= 0;
        Jump_out <= 0;
        Jalr_out <= 0;
        BranchType_out <= 0;
        ALUSrc_out <= 0;
        ALUSrcA_out <= 0;
        ALUOp_out <= 0;
        
        // Turn the new signals into NOPs (kill them)
        prediction_taken_out <= 0;
        predicted_target_out <= 0;
        compressed_out <= 1'b0;
        SystolicOp_out <= 2'b00;
    end
    else begin
        // NORMAL EXECUTION: Advance pipeline safely
        pc_out <= pc_in;
        read_data1_out <= read_data1_in;
        read_data2_out <= read_data2_in;
        imm_out <= imm_in;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out <= rd_in;
        funct3_out <= funct3_in;
        funct7_out <= funct7_in;
        RegWrite_out <= RegWrite_in;
        MemRead_out <= MemRead_in;
        MemWrite_out <= MemWrite_in;
        MemToReg_out <= MemToReg_in;
        ALUSrc_out <= ALUSrc_in;
        Jump_out <= Jump_in;
        Jalr_out <= Jalr_in;
        ALUSrcA_out <= ALUSrcA_in;
        BranchType_out <= BranchType_in;
        ALUOp_out <= ALUOp_in;
        
        // Pass the new signals forward!
        prediction_taken_out <= prediction_taken_in;
        predicted_target_out <= predicted_target_in;
        compressed_out <= compressed_in;
        SystolicOp_out <= SystolicOp_in;
    end
end

endmodule