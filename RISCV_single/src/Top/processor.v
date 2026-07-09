module processor(
    input clk,
    input rst
);

wire [31:0] current_pc;
wire [31:0] next_pc;
wire [31:0] pc_plus_4;

wire [31:0] instr_code;

wire [6:0] opcode;
wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;
wire [2:0] funct3;
wire [6:0] funct7;
wire RegWrite;
wire MemRead;
wire MemWrite;
wire MemToReg;
wire ALUSrc;
wire ALUSrcA;     
wire [2:0] BranchType;
wire Jump;
wire [3:0] ALUOp;
wire [31:0] read_data1;
wire [31:0] read_data2;
wire [31:0] write_data;
wire [31:0] immediate;
wire [3:0] alu_control_res;
wire [31:0] operand_a;
wire [31:0] operand_b;
wire [31:0] alu_result;
wire zero_flag;
wire [31:0] memory_read_data;
wire [31:0] branch_target;
wire [31:0] jump_target;
wire branch_taken;
wire [31:0] rs1_plus_imm;
wire [31:0] pc_plus_imm;
wire [31:0] wb_data;

PC pc_inst(
    .clk(clk),
    .rst(rst),
    .next_pc(next_pc),
    .current_pc(current_pc)
);

instr_mem instr_mem_inst(
    .pc(current_pc),
    .instr_code(instr_code)
);

instr_decode decoder_inst(
    .instr(instr_code),
    .opcode(opcode),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .funct3(funct3),
    .funct7(funct7)
);

control_unit control_unit_inst(
    .opcode(opcode),
    .RegWrite(RegWrite),
    .MemRead(MemRead),
    .MemToReg(MemToReg),
    .MemWrite(MemWrite),
    .BranchType(BranchType),
    .Jump(Jump),
    .ALUSrc(ALUSrc),
    .ALUSrcA(ALUSrcA),
    .ALUOp(ALUOp),
    .funct3(funct3)
);

reg_file reg_file_inst(
    .clk(clk),
    .rst(rst),
    .rs1(rs1),
    .rs2(rs2),
    .RegWrite(RegWrite),
    .rd(rd),
    .read_data1(read_data1),
    .read_data2(read_data2),
    .write_data(wb_data)
);

imm_gen imm_gen_inst(
    .instruction(instr_code),
    .immediate(immediate)
);

alu_control alu_control_inst(
    .ALUOp(ALUOp),
    .funct3(funct3),
    .funct7(funct7),
    .alu_control_res(alu_control_res)
);

assign operand_a = ALUSrcA ? current_pc : read_data1;
assign operand_b = ALUSrc ? immediate : read_data2;
assign pc_plus_4   = current_pc + 32'd4;
assign pc_plus_imm = current_pc + immediate;
assign rs1_plus_imm = read_data1 + immediate;

alu alu_inst(
    .operand_a(operand_a),
    .operand_b(operand_b),
    .alu_control(alu_control_res),
    .alu_result(alu_result),
    .zero_flag(zero_flag)
);



data_memory data_mem_inst(
    .alu_result(alu_result),
    .clk(clk),
    .write_data(read_data2),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .read_data(memory_read_data)
);

assign wb_data =
    RegWrite ?
        (Jump ? pc_plus_4 :
         (MemToReg ? memory_read_data : alu_result))
    : 32'b0;
assign branch_taken =
    (BranchType == 3'b001) ? zero_flag :
    (BranchType == 3'b010) ? ~zero_flag :
    (BranchType == 3'b011) ? alu_result[0] :
    (BranchType == 3'b100) ? ~alu_result[0] :
    1'b0;
assign branch_target = pc_plus_imm;
assign next_pc = Jump ? jump_target : (branch_taken ? branch_target : pc_plus_4);
assign jump_target = (opcode == 7'b1100111) ? rs1_plus_imm : pc_plus_imm;
endmodule