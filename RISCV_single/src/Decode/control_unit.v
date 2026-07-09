module control_unit(
    input [6:0] opcode,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemToReg,
    output reg ALUSrc,
    output reg [2:0] BranchType,
    output reg Jump,
    output reg [3:0] ALUOp,
    output reg ALUSrcA,
    output reg Jalr,
    input [2:0] funct3,
    output reg [1:0] SystolicOp
);

always @(*) begin
    // Default initializations
    RegWrite   = 1'b0;
    MemRead    = 1'b0;
    MemWrite   = 1'b0;
    MemToReg   = 1'b0;
    ALUSrc     = 1'b0;
    BranchType = 3'b000;
    Jump       = 1'b0;
    ALUOp      = 4'b0000;
    ALUSrcA    = 1'b0;
    Jalr       = 1'b0;
    
    // Systolic operation defaults to NONE
    SystolicOp = 2'b00; 

    case(opcode)
        7'b0110011: begin // R-Type
            RegWrite = 1'b1;
            ALUOp    = 4'b0011;
        end
        7'b0010011: begin // I-Type
            RegWrite = 1'b1;
            ALUSrc   = 1'b1;
            ALUOp    = 4'b0100;
        end
        7'b0000011: begin // Loads
            RegWrite = 1'b1;
            MemRead  = 1'b1;
            MemToReg = 1'b1;
            ALUSrc   = 1'b1;
            ALUOp    = 4'b0000;
        end
        7'b0100011: begin // Stores
            MemWrite = 1'b1;
            ALUSrc   = 1'b1;
            ALUOp    = 4'b0001;
        end
        7'b1100011: begin // Branches
            ALUOp = 4'b0010;

            case(funct3)
                3'b000: BranchType = 3'b001; // BEQ
                3'b001: BranchType = 3'b010; // BNE
                3'b100: BranchType = 3'b011; // BLT
                3'b101: BranchType = 3'b100; // BGE
                default: BranchType = 3'b000;
            endcase
        end
        7'b1101111: begin // JAL
            RegWrite = 1'b1;
            ALUSrc   = 1'b1;
            Jump     = 1'b1;
            ALUOp    = 4'b0101;
            ALUSrcA  = 1'b1;
        end
        7'b1100111: begin // JALR
            RegWrite = 1'b1;
            ALUSrc   = 1'b1;
            Jump     = 1'b1;
            ALUOp    = 4'b0110;
            Jalr     = 1'b1;
        end
        7'b0110111: begin // LUI
            RegWrite = 1'b1;
            ALUSrc   = 1'b1;
            ALUOp    = 4'b0111;
        end
        7'b0010111: begin // AUIPC
            RegWrite = 1'b1;
            ALUSrc   = 1'b1;
            ALUOp    = 4'b1000;
            ALUSrcA  = 1'b1;
        end
        
        // --- CUSTOM OPCODES ---
        7'b0001011: begin
            case(funct3)
                3'b000: begin
                    SystolicOp = 2'b01; // START (smat)
                end
                
                3'b001: begin
                    SystolicOp   = 2'b10; // READ (smrd)
                    RegWrite     = 1'b1;
                    
                    // Explicitly asserting zeroes for self-documentation
                    MemRead      = 1'b0;
                    MemWrite     = 1'b0;
                    MemToReg     = 1'b0;
                    ALUSrc       = 1'b0;
                end
            endcase
        end
    endcase
end

endmodule