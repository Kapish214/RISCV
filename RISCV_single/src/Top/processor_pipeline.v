// module processor_pipeline(
//     input clk,
//     input rst,

//     // Memory Interface
//     output        MemRead,
//     output        MemWrite,
//     output [31:0] mem_address,
//     output [31:0] mem_write_data,
//     input  [31:0] mem_read_data,
//     input         mem_stall,

//     //----------------------------
//     // Systolic Controller Interface
//     //----------------------------
//     output [1:0]  SystolicOp,
//     output [4:0]  result_index,
//     input         systolic_busy,
//     input  [31:0] systolic_read_data
// );

// wire bp_prediction_taken;
// wire [31:0] bp_predicted_target;
// wire bp_btb_hit;
// wire bp_prediction_flush;
// wire [1:0] bp_prediction;

// wire if_id_prediction_taken;
// wire [31:0] if_id_predicted_target;

// wire id_ex_prediction_taken;
// wire [31:0] id_ex_predicted_target;

// wire [31:0] current_pc;
// wire [31:0] next_pc;
// wire [31:0] pc_increment;
// wire compressed;
// wire [31:0] instr_code;

// wire [31:0] if_id_pc;
// wire [31:0] if_id_instr;
// wire if_id_compressed;

// wire [6:0] opcode;
// wire [4:0] rs1;
// wire [4:0] rs2;
// wire [4:0] rd;
// wire [2:0] funct3;
// wire [6:0] funct7;

// // Control Unit Wires
// wire ctrl_RegWrite, ctrl_MemRead, ctrl_MemWrite, ctrl_MemToReg;
// wire ctrl_ALUSrc, ctrl_ALUSrcA, ctrl_Jump, ctrl_Jalr;
// wire [1:0] ctrl_SystolicOp; // Replaces SystolicStart/Read

// wire [2:0] ctrl_BranchType;
// wire [3:0] ctrl_ALUOp;
// wire [31:0] read_data1, read_data2, immediate;

// // ID/EX Wires
// wire [31:0] id_ex_pc, id_ex_read_data1, id_ex_read_data2, id_ex_imm;
// wire [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
// wire [2:0] id_ex_funct3, id_ex_BranchType;
// wire [6:0] id_ex_funct7;
// wire [3:0] id_ex_ALUOp;
// wire id_ex_RegWrite, id_ex_MemRead, id_ex_MemWrite, id_ex_MemToReg;
// wire id_ex_ALUSrc, id_ex_ALUSrcA, id_ex_Jump, id_ex_Jalr;
// wire id_ex_compressed;
// wire [1:0] id_ex_SystolicOp;

// // EX/MEM Wires
// wire [31:0] ex_mem_alu_result, ex_mem_write_data, ex_mem_pc_plus_4;
// wire [4:0] ex_mem_rd;
// wire ex_mem_RegWrite, ex_mem_MemRead, ex_mem_MemWrite, ex_mem_MemToReg, ex_mem_Jump;
// wire [1:0] ex_mem_SystolicOp;
// wire [4:0] ex_mem_rs1;

// // MEM/WB Wires
// wire [31:0] mem_wb_memory_data, mem_wb_alu_result, mem_wb_pc_plus_4, wb_data;
// wire [4:0] mem_wb_rd;
// wire mem_wb_RegWrite, mem_wb_MemToReg, mem_wb_Jump;
// wire [1:0] mem_wb_SystolicOp;
// wire [4:0] mem_wb_rs1;

// wire [1:0] ForwardA, ForwardB;
// wire [31:0] forward_a_data, forward_b_data;
// wire flush, hazard_stall, global_stall; 

// // Freeze Logic
// wire systolic_stall = (ex_mem_SystolicOp == 2'b10) && systolic_busy; // Catch it in EX/MEM!
// wire freeze_pipeline = mem_stall || systolic_stall;
// assign global_stall = hazard_stall || freeze_pipeline; // Simplified stall logic

// wire [4:0] if_id_rs1 = if_id_instr[19:15];
// wire [4:0] if_id_rs2 = if_id_instr[24:20];

// wire ex_branch_taken;
// wire [31:0] ex_branch_target, ex_jump_target;
// wire ex_actual_taken = ex_branch_taken || id_ex_Jump || id_ex_Jalr;
// wire [31:0] ex_actual_target = (id_ex_Jump || id_ex_Jalr) ? ex_jump_target : ex_branch_target;
// wire bp_update_enable = (id_ex_BranchType != 3'b000) || id_ex_Jump || id_ex_Jalr;

// wire [3:0] alu_control_res;
// wire [31:0] operand_a, operand_b, alu_result;
// wire zero_flag;
// wire [31:0] ex_pc_plus_imm, ex_rs1_plus_imm;
// wire [31:0] expanded_instruction;

// // Expose memory signals to the outside subsystem
// assign MemRead        = ex_mem_MemRead;
// assign MemWrite       = ex_mem_MemWrite;
// assign mem_address    = ex_mem_alu_result;
// assign mem_write_data = ex_mem_write_data;

// // Drive the Systolic Controller outputs from WB Stage
// assign SystolicOp   = mem_wb_SystolicOp;
// assign result_index = mem_wb_rs1;

// PC pc_inst(
//     .clk(clk),
//     .rst(rst),
//     .next_pc(next_pc),
//     .current_pc(current_pc),
//     .stall(global_stall) 
// );

// instr_mem instr_mem_inst(
//     .pc(current_pc),
//     .instr_code(instr_code)
// );

// branch_predictor bp_inst(
//     .clk(clk),
//     .rst(rst),
//     .next_pc(current_pc), 
//     .actual_taken(ex_actual_taken),
//     .ex_pc(id_ex_pc),
//     .update_enable(bp_update_enable),
//     .actual_target(ex_actual_target),
//     .id_ex_prediction_taken(id_ex_prediction_taken),
//     .id_ex_predicted_target(id_ex_predicted_target),
//     .predicted_target(bp_predicted_target),
//     .prediction(bp_prediction),
//     .prediction_taken(bp_prediction_taken),
//     .btb_hit(bp_btb_hit),
//     .prediction_flush(bp_prediction_flush)
// );

// if_id if_id_inst(
//     .clk(clk),
//     .rst(rst),
//     .pc_in(current_pc),
//     .instr_in(instr_code),
//     .pc_out(if_id_pc),
//     .instr_out(if_id_instr),
//     .flush(flush),
//     .stall(hazard_stall),      
//     .cache_stall(freeze_pipeline),
//     .prediction_taken_in(bp_prediction_taken),
//     .predicted_target_in(bp_predicted_target),
//     .prediction_taken_out(if_id_prediction_taken),
//     .predicted_target_out(if_id_predicted_target),
//     .compressed_in(compressed),
//     .compressed_out(if_id_compressed)
// );

// instr_decode decode_inst(
//     .instr(if_id_instr),
//     .opcode(opcode),
//     .rd(rd),
//     .rs1(rs1),
//     .rs2(rs2),
//     .funct3(funct3),
//     .funct7(funct7),
//     .expanded_instruction(expanded_instruction)
// );

// control_unit control_unit_inst(
//     .opcode(opcode),
//     .RegWrite(ctrl_RegWrite),
//     .MemRead(ctrl_MemRead),
//     .MemWrite(ctrl_MemWrite),
//     .MemToReg(ctrl_MemToReg),
//     .ALUSrc(ctrl_ALUSrc),
//     .BranchType(ctrl_BranchType),
//     .Jump(ctrl_Jump),
//     .ALUOp(ctrl_ALUOp),
//     .ALUSrcA(ctrl_ALUSrcA),
//     .Jalr(ctrl_Jalr),
//     .funct3(funct3),
//     .SystolicOp(ctrl_SystolicOp) // Fixed to Option A
// );

// reg_file reg_file_inst(
//     .clk(clk),
//     .rst(rst),
//     .rs1(rs1),
//     .rs2(rs2),
//     .rd(mem_wb_rd),
//     .RegWrite(mem_wb_RegWrite),
//     .write_data(wb_data),
//     .read_data1(read_data1),
//     .read_data2(read_data2)
// );

// imm_gen imm_gen_inst(
//     .instruction(expanded_instruction),
//     .immediate(immediate)
// );

// id_ex id_ex_inst(
//     .clk(clk),
//     .rst(rst),
//     .pc_in(if_id_pc),
//     .read_data1_in(read_data1),
//     .read_data2_in(read_data2),
//     .imm_in(immediate),
//     .rs1_in(rs1),
//     .rs2_in(rs2),
//     .rd_in(rd),
//     .stall(hazard_stall),      
//     .cache_stall(freeze_pipeline), 
//     .flush(flush),
//     .RegWrite_in(ctrl_RegWrite),
//     .MemRead_in(ctrl_MemRead),
//     .MemWrite_in(ctrl_MemWrite),
//     .MemToReg_in(ctrl_MemToReg),
//     .ALUSrc_in(ctrl_ALUSrc),
//     .Jump_in(ctrl_Jump),
//     .Jalr_in(ctrl_Jalr),
//     .funct3_in(funct3),
//     .funct7_in(funct7),
//     .ALUSrcA_in(ctrl_ALUSrcA),
//     .BranchType_in(ctrl_BranchType),
//     .ALUOp_in(ctrl_ALUOp),
//     .SystolicOp_in(ctrl_SystolicOp), // Pipelined Opcode
//     .pc_out(id_ex_pc),
//     .read_data1_out(id_ex_read_data1),
//     .read_data2_out(id_ex_read_data2),
//     .imm_out(id_ex_imm),
//     .rs1_out(id_ex_rs1),
//     .rs2_out(id_ex_rs2),
//     .rd_out(id_ex_rd),
//     .funct3_out(id_ex_funct3),
//     .funct7_out(id_ex_funct7),
//     .RegWrite_out(id_ex_RegWrite),
//     .MemRead_out(id_ex_MemRead),
//     .MemWrite_out(id_ex_MemWrite),
//     .MemToReg_out(id_ex_MemToReg),
//     .ALUSrc_out(id_ex_ALUSrc),
//     .Jump_out(id_ex_Jump),
//     .Jalr_out(id_ex_Jalr),
//     .ALUSrcA_out(id_ex_ALUSrcA),
//     .BranchType_out(id_ex_BranchType),
//     .ALUOp_out(id_ex_ALUOp),
//     .SystolicOp_out(id_ex_SystolicOp), // Pipelined Opcode
//     .prediction_taken_in(if_id_prediction_taken),
//     .predicted_target_in(if_id_predicted_target),
//     .prediction_taken_out(id_ex_prediction_taken),
//     .predicted_target_out(id_ex_predicted_target),
//     .compressed_in(if_id_compressed),
//     .compressed_out(id_ex_compressed)
// );

// alu_control alu_control_inst(
//     .ALUOp(id_ex_ALUOp),
//     .funct3(id_ex_funct3),
//     .funct7(id_ex_funct7),
//     .alu_control_res(alu_control_res)
// );

// assign forward_a_data = (ForwardA == 2'b10) ? (ex_mem_MemToReg ? mem_read_data : ex_mem_alu_result) :
//                         (ForwardA == 2'b01) ? wb_data : id_ex_read_data1;

// assign forward_b_data = (ForwardB == 2'b10) ? (ex_mem_MemToReg ? mem_read_data : ex_mem_alu_result) :
//                         (ForwardB == 2'b01) ? wb_data : id_ex_read_data2;

// assign operand_a = id_ex_ALUSrcA ? id_ex_pc : forward_a_data;
// assign operand_b = id_ex_ALUSrc ? id_ex_imm : forward_b_data;
 
// assign ex_pc_plus_imm = id_ex_pc + id_ex_imm;
// assign ex_rs1_plus_imm = forward_a_data + id_ex_imm;

// alu alu_inst(
//     .operand_a(operand_a),
//     .operand_b(operand_b),
//     .alu_control(alu_control_res),
//     .alu_result(alu_result),
//     .zero_flag(zero_flag)
// );

// assign ex_branch_taken =
//     (id_ex_BranchType == 3'b001) ? zero_flag :
//     (id_ex_BranchType == 3'b010) ? ~zero_flag :
//     (id_ex_BranchType == 3'b011) ? alu_result[0] :
//     (id_ex_BranchType == 3'b100) ? ~alu_result[0] :
//     1'b0;

// assign ex_branch_target = ex_pc_plus_imm;
// assign ex_jump_target = id_ex_Jalr ? ex_rs1_plus_imm : ex_pc_plus_imm;

// ex_mem ex_mem_inst(
//     .clk(clk),
//     .rst(rst),
//     .alu_result_in(alu_result),
//     .write_data_in(forward_b_data),
//     .rd_in(id_ex_rd),
//     .RegWrite_in(id_ex_RegWrite),
//     .MemRead_in(id_ex_MemRead),
//     .MemWrite_in(id_ex_MemWrite),
//     .MemToReg_in(id_ex_MemToReg),
//     .pc_plus_4_in(id_ex_pc + (id_ex_compressed ? 32'd2 : 32'd4)),
//     .Jump_in(id_ex_Jump),
//     .SystolicOp_in(id_ex_SystolicOp), // Incoming from EX
//     .rs1_in(id_ex_rs1),               // Incoming from EX
//     .alu_result_out(ex_mem_alu_result),
//     .write_data_out(ex_mem_write_data),
//     .rd_out(ex_mem_rd),
//     .stall(freeze_pipeline), 
//     .RegWrite_out(ex_mem_RegWrite),
//     .MemRead_out(ex_mem_MemRead),
//     .MemWrite_out(ex_mem_MemWrite),
//     .MemToReg_out(ex_mem_MemToReg),
//     .pc_plus_4_out(ex_mem_pc_plus_4),
//     .Jump_out(ex_mem_Jump),
//     .SystolicOp_out(ex_mem_SystolicOp), // Emitting to MEM
//     .rs1_out(ex_mem_rs1)                // Emitting to MEM
// );

// mem_wb mem_wb_inst(
//     .clk(clk),
//     .rst(rst),
//     .mem_data_in(mem_read_data),
//     .alu_result_in(ex_mem_alu_result),
//     .rd_in(ex_mem_rd),
//     .RegWrite_in(ex_mem_RegWrite),
//     .MemToReg_in(ex_mem_MemToReg),
//     .pc_plus_4_in(ex_mem_pc_plus_4),
//     .Jump_in(ex_mem_Jump),
//     .SystolicOp_in(ex_mem_SystolicOp), // Incoming from MEM
//     .rs1_in(ex_mem_rs1),               // Incoming from MEM
//     .mem_data_out(mem_wb_memory_data),
//     .alu_result_out(mem_wb_alu_result),
//     .rd_out(mem_wb_rd),
//     .stall(freeze_pipeline), 
//     .RegWrite_out(mem_wb_RegWrite),
//     .MemToReg_out(mem_wb_MemToReg),
//     .pc_plus_4_out(mem_wb_pc_plus_4),
//     .Jump_out(mem_wb_Jump),
//     .SystolicOp_out(mem_wb_SystolicOp), // Emitting to WB
//     .rs1_out(mem_wb_rs1)                // Emitting to WB
// );

// forwarding_unit forwarding_unit_inst(
//     .id_ex_rs1(id_ex_rs1),
//     .id_ex_rs2(id_ex_rs2),
//     .ex_mem_rd(ex_mem_rd),
//     .ex_mem_RegWrite(ex_mem_RegWrite),
//     .mem_wb_rd(mem_wb_rd),
//     .mem_wb_RegWrite(mem_wb_RegWrite),
//     .ForwardA(ForwardA),
//     .ForwardB(ForwardB)
// );

// hazard_detection_unit hazard_unit_inst(
//     .id_ex_MemRead(id_ex_MemRead),
//     .id_ex_rd(id_ex_rd),
//     .if_id_rs1(if_id_rs1),
//     .if_id_rs2(if_id_rs2),
//     .stall(hazard_stall)
// );

// // Write-back Mux: Selects between Jump PC, Systolic Array Data, Memory Data, or ALU Result
// assign wb_data = mem_wb_Jump                  ? mem_wb_pc_plus_4 :
//                  (mem_wb_SystolicOp == 2'b10) ? systolic_read_data :
//                  mem_wb_MemToReg              ? mem_wb_memory_data : 
//                                                 mem_wb_alu_result;

// assign compressed = (instr_code[1:0] != 2'b11);
// assign pc_increment = compressed ? 32'd2 : 32'd4;

// assign flush = bp_prediction_flush;

// wire [31:0] recovery_pc = ex_actual_taken ? ex_actual_target : (id_ex_pc + (id_ex_compressed ? 32'd2 : 32'd4));

// assign next_pc =
//     bp_prediction_flush ? recovery_pc :
//     (bp_prediction_taken ? bp_predicted_target :
//                            current_pc + pc_increment);

// endmodule
module processor_pipeline(
    input clk,
    input rst,

    // Memory Interface
    output        MemRead,
    output        MemWrite,
    output [31:0] mem_address,
    output [31:0] mem_write_data,
    input  [31:0] mem_read_data,
    input         mem_stall,

    //----------------------------
    // Systolic Controller Interface
    //----------------------------
    output [1:0]  SystolicOp,
    output [1:0]  SystolicOpEarly,   // ex_mem-stage copy, for triggering SystolicStart early
    output [4:0]  result_index,
    input         systolic_busy,
    input  [31:0] systolic_read_data
);

wire bp_prediction_taken;
wire [31:0] bp_predicted_target;
wire bp_btb_hit;
wire bp_prediction_flush;
wire [1:0] bp_prediction;

wire if_id_prediction_taken;
wire [31:0] if_id_predicted_target;

wire id_ex_prediction_taken;
wire [31:0] id_ex_predicted_target;

wire [31:0] current_pc;
wire [31:0] next_pc;
wire [31:0] pc_increment;
wire compressed;
wire [31:0] instr_code;

wire [31:0] if_id_pc;
wire [31:0] if_id_instr;
wire if_id_compressed;

wire [6:0] opcode;
wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;
wire [2:0] funct3;
wire [6:0] funct7;

// Control Unit Wires
wire ctrl_RegWrite, ctrl_MemRead, ctrl_MemWrite, ctrl_MemToReg;
wire ctrl_ALUSrc, ctrl_ALUSrcA, ctrl_Jump, ctrl_Jalr;
wire [1:0] ctrl_SystolicOp; // Replaces SystolicStart/Read

wire [2:0] ctrl_BranchType;
wire [3:0] ctrl_ALUOp;
wire [31:0] read_data1, read_data2, immediate;

// ID/EX Wires
wire [31:0] id_ex_pc, id_ex_read_data1, id_ex_read_data2, id_ex_imm;
wire [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
wire [2:0] id_ex_funct3, id_ex_BranchType;
wire [6:0] id_ex_funct7;
wire [3:0] id_ex_ALUOp;
wire id_ex_RegWrite, id_ex_MemRead, id_ex_MemWrite, id_ex_MemToReg;
wire id_ex_ALUSrc, id_ex_ALUSrcA, id_ex_Jump, id_ex_Jalr;
wire id_ex_compressed;
wire [1:0] id_ex_SystolicOp;

// EX/MEM Wires
wire [31:0] ex_mem_alu_result, ex_mem_write_data, ex_mem_pc_plus_4;
wire [4:0] ex_mem_rd;
wire ex_mem_RegWrite, ex_mem_MemRead, ex_mem_MemWrite, ex_mem_MemToReg, ex_mem_Jump;
wire [1:0] ex_mem_SystolicOp;
wire [31:0] ex_mem_rs1; // UPDATED: Changed to 32 bits

// MEM/WB Wires
wire [31:0] mem_wb_memory_data, mem_wb_alu_result, mem_wb_pc_plus_4, wb_data;
wire [4:0] mem_wb_rd;
wire mem_wb_RegWrite, mem_wb_MemToReg, mem_wb_Jump;
wire [1:0] mem_wb_SystolicOp;
wire [31:0] mem_wb_rs1; // UPDATED: Changed to 32 bits

wire [1:0] ForwardA, ForwardB;
wire [31:0] forward_a_data, forward_b_data;
wire flush, hazard_stall, global_stall; 

// Freeze Logic
wire systolic_stall = (ex_mem_SystolicOp == 2'b10) && systolic_busy; // Catch it in EX/MEM!
wire freeze_pipeline = mem_stall || systolic_stall;
assign global_stall = hazard_stall || freeze_pipeline; // Simplified stall logic

wire [4:0] if_id_rs1 = if_id_instr[19:15];
wire [4:0] if_id_rs2 = if_id_instr[24:20];

wire ex_branch_taken;
wire [31:0] ex_branch_target, ex_jump_target;
wire ex_actual_taken = ex_branch_taken || id_ex_Jump || id_ex_Jalr;
wire [31:0] ex_actual_target = (id_ex_Jump || id_ex_Jalr) ? ex_jump_target : ex_branch_target;
wire bp_update_enable = (id_ex_BranchType != 3'b000) || id_ex_Jump || id_ex_Jalr;

wire [3:0] alu_control_res;
wire [31:0] operand_a, operand_b, alu_result;
wire zero_flag;
wire [31:0] ex_pc_plus_imm, ex_rs1_plus_imm;
wire [31:0] expanded_instruction;

// Expose memory signals to the outside subsystem
assign MemRead        = ex_mem_MemRead;
assign MemWrite       = ex_mem_MemWrite;
assign mem_address    = ex_mem_alu_result;
assign mem_write_data = ex_mem_write_data;

// Drive the Systolic Controller outputs from WB Stage
assign SystolicOp   = mem_wb_SystolicOp;
assign SystolicOpEarly = ex_mem_SystolicOp; // Used only to trigger SystolicStart sooner
assign result_index = mem_wb_rs1[4:0];      // UPDATED: Sliced lower 5 bits of the 32-bit resolved data

PC pc_inst(
    .clk(clk),
    .rst(rst),
    .next_pc(next_pc),
    .current_pc(current_pc),
    .stall(global_stall) 
);

instr_mem instr_mem_inst(
    .pc(current_pc),
    .instr_code(instr_code)
);

branch_predictor bp_inst(
    .clk(clk),
    .rst(rst),
    .next_pc(current_pc), 
    .actual_taken(ex_actual_taken),
    .ex_pc(id_ex_pc),
    .update_enable(bp_update_enable),
    .actual_target(ex_actual_target),
    .id_ex_prediction_taken(id_ex_prediction_taken),
    .id_ex_predicted_target(id_ex_predicted_target),
    .predicted_target(bp_predicted_target),
    .prediction(bp_prediction),
    .prediction_taken(bp_prediction_taken),
    .btb_hit(bp_btb_hit),
    .prediction_flush(bp_prediction_flush)
);

if_id if_id_inst(
    .clk(clk),
    .rst(rst),
    .pc_in(current_pc),
    .instr_in(instr_code),
    .pc_out(if_id_pc),
    .instr_out(if_id_instr),
    .flush(flush),
    .stall(hazard_stall),      
    .cache_stall(freeze_pipeline),
    .prediction_taken_in(bp_prediction_taken),
    .predicted_target_in(bp_predicted_target),
    .prediction_taken_out(if_id_prediction_taken),
    .predicted_target_out(if_id_predicted_target),
    .compressed_in(compressed),
    .compressed_out(if_id_compressed)
);

instr_decode decode_inst(
    .instr(if_id_instr),
    .opcode(opcode),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .funct3(funct3),
    .funct7(funct7),
    .expanded_instruction(expanded_instruction)
);

control_unit control_unit_inst(
    .opcode(opcode),
    .RegWrite(ctrl_RegWrite),
    .MemRead(ctrl_MemRead),
    .MemWrite(ctrl_MemWrite),
    .MemToReg(ctrl_MemToReg),
    .ALUSrc(ctrl_ALUSrc),
    .BranchType(ctrl_BranchType),
    .Jump(ctrl_Jump),
    .ALUOp(ctrl_ALUOp),
    .ALUSrcA(ctrl_ALUSrcA),
    .Jalr(ctrl_Jalr),
    .funct3(funct3),
    .SystolicOp(ctrl_SystolicOp) // Fixed to Option A
);

reg_file reg_file_inst(
    .clk(clk),
    .rst(rst),
    .rs1(rs1),
    .rs2(rs2),
    .rd(mem_wb_rd),
    .RegWrite(mem_wb_RegWrite),
    .write_data(wb_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

imm_gen imm_gen_inst(
    .instruction(expanded_instruction),
    .immediate(immediate)
);

id_ex id_ex_inst(
    .clk(clk),
    .rst(rst),
    .pc_in(if_id_pc),
    .read_data1_in(read_data1),
    .read_data2_in(read_data2),
    .imm_in(immediate),
    .rs1_in(rs1),
    .rs2_in(rs2),
    .rd_in(rd),
    .stall(hazard_stall),      
    .cache_stall(freeze_pipeline), 
    .flush(flush),
    .RegWrite_in(ctrl_RegWrite),
    .MemRead_in(ctrl_MemRead),
    .MemWrite_in(ctrl_MemWrite),
    .MemToReg_in(ctrl_MemToReg),
    .ALUSrc_in(ctrl_ALUSrc),
    .Jump_in(ctrl_Jump),
    .Jalr_in(ctrl_Jalr),
    .funct3_in(funct3),
    .funct7_in(funct7),
    .ALUSrcA_in(ctrl_ALUSrcA),
    .BranchType_in(ctrl_BranchType),
    .ALUOp_in(ctrl_ALUOp),
    .SystolicOp_in(ctrl_SystolicOp), // Pipelined Opcode
    .pc_out(id_ex_pc),
    .read_data1_out(id_ex_read_data1),
    .read_data2_out(id_ex_read_data2),
    .imm_out(id_ex_imm),
    .rs1_out(id_ex_rs1),
    .rs2_out(id_ex_rs2),
    .rd_out(id_ex_rd),
    .funct3_out(id_ex_funct3),
    .funct7_out(id_ex_funct7),
    .RegWrite_out(id_ex_RegWrite),
    .MemRead_out(id_ex_MemRead),
    .MemWrite_out(id_ex_MemWrite),
    .MemToReg_out(id_ex_MemToReg),
    .ALUSrc_out(id_ex_ALUSrc),
    .Jump_out(id_ex_Jump),
    .Jalr_out(id_ex_Jalr),
    .ALUSrcA_out(id_ex_ALUSrcA),
    .BranchType_out(id_ex_BranchType),
    .ALUOp_out(id_ex_ALUOp),
    .SystolicOp_out(id_ex_SystolicOp), // Pipelined Opcode
    .prediction_taken_in(if_id_prediction_taken),
    .predicted_target_in(if_id_predicted_target),
    .prediction_taken_out(id_ex_prediction_taken),
    .predicted_target_out(id_ex_predicted_target),
    .compressed_in(if_id_compressed),
    .compressed_out(id_ex_compressed)
);

alu_control alu_control_inst(
    .ALUOp(id_ex_ALUOp),
    .funct3(id_ex_funct3),
    .funct7(id_ex_funct7),
    .alu_control_res(alu_control_res)
);

assign forward_a_data = (ForwardA == 2'b10) ? (ex_mem_MemToReg ? mem_read_data : ex_mem_alu_result) :
                        (ForwardA == 2'b01) ? wb_data : id_ex_read_data1;

assign forward_b_data = (ForwardB == 2'b10) ? (ex_mem_MemToReg ? mem_read_data : ex_mem_alu_result) :
                        (ForwardB == 2'b01) ? wb_data : id_ex_read_data2;

assign operand_a = id_ex_ALUSrcA ? id_ex_pc : forward_a_data;
assign operand_b = id_ex_ALUSrc ? id_ex_imm : forward_b_data;
 
assign ex_pc_plus_imm = id_ex_pc + id_ex_imm;
assign ex_rs1_plus_imm = forward_a_data + id_ex_imm;

alu alu_inst(
    .operand_a(operand_a),
    .operand_b(operand_b),
    .alu_control(alu_control_res),
    .alu_result(alu_result),
    .zero_flag(zero_flag)
);

assign ex_branch_taken =
    (id_ex_BranchType == 3'b001) ? zero_flag :
    (id_ex_BranchType == 3'b010) ? ~zero_flag :
    (id_ex_BranchType == 3'b011) ? alu_result[0] :
    (id_ex_BranchType == 3'b100) ? ~alu_result[0] :
    1'b0;

assign ex_branch_target = ex_pc_plus_imm;
assign ex_jump_target = id_ex_Jalr ? ex_rs1_plus_imm : ex_pc_plus_imm;

ex_mem ex_mem_inst(
    .clk(clk),
    .rst(rst),
    .alu_result_in(alu_result),
    .write_data_in(forward_b_data),
    .rd_in(id_ex_rd),
    .RegWrite_in(id_ex_RegWrite),
    .MemRead_in(id_ex_MemRead),
    .MemWrite_in(id_ex_MemWrite),
    .MemToReg_in(id_ex_MemToReg),
    .pc_plus_4_in(id_ex_pc + (id_ex_compressed ? 32'd2 : 32'd4)),
    .Jump_in(id_ex_Jump),
    .SystolicOp_in(id_ex_SystolicOp), // Incoming from EX
    .rs1_in(forward_a_data),          // UPDATED: resolved VALUE of rs1 (for systolic result_index)
    .alu_result_out(ex_mem_alu_result),
    .write_data_out(ex_mem_write_data),
    .rd_out(ex_mem_rd),
    .stall(freeze_pipeline), 
    .RegWrite_out(ex_mem_RegWrite),
    .MemRead_out(ex_mem_MemRead),
    .MemWrite_out(ex_mem_MemWrite),
    .MemToReg_out(ex_mem_MemToReg),
    .pc_plus_4_out(ex_mem_pc_plus_4),
    .Jump_out(ex_mem_Jump),
    .SystolicOp_out(ex_mem_SystolicOp), // Emitting to MEM
    .rs1_out(ex_mem_rs1)                // Emitting to MEM
);

mem_wb mem_wb_inst(
    .clk(clk),
    .rst(rst),
    .mem_data_in(mem_read_data),
    .alu_result_in(ex_mem_alu_result),
    .rd_in(ex_mem_rd),
    .RegWrite_in(ex_mem_RegWrite),
    .MemToReg_in(ex_mem_MemToReg),
    .pc_plus_4_in(ex_mem_pc_plus_4),
    .Jump_in(ex_mem_Jump),
    .SystolicOp_in(ex_mem_SystolicOp), // Incoming from MEM
    .rs1_in(ex_mem_rs1),               // Incoming from MEM
    .mem_data_out(mem_wb_memory_data),
    .alu_result_out(mem_wb_alu_result),
    .rd_out(mem_wb_rd),
    .stall(freeze_pipeline), 
    .RegWrite_out(mem_wb_RegWrite),
    .MemToReg_out(mem_wb_MemToReg),
    .pc_plus_4_out(mem_wb_pc_plus_4),
    .Jump_out(mem_wb_Jump),
    .SystolicOp_out(mem_wb_SystolicOp), // Emitting to WB
    .rs1_out(mem_wb_rs1)                // Emitting to WB
);

forwarding_unit forwarding_unit_inst(
    .id_ex_rs1(id_ex_rs1),
    .id_ex_rs2(id_ex_rs2),
    .ex_mem_rd(ex_mem_rd),
    .ex_mem_RegWrite(ex_mem_RegWrite),
    .mem_wb_rd(mem_wb_rd),
    .mem_wb_RegWrite(mem_wb_RegWrite),
    .ForwardA(ForwardA),
    .ForwardB(ForwardB)
);

hazard_detection_unit hazard_unit_inst(
    .id_ex_MemRead(id_ex_MemRead),
    .id_ex_rd(id_ex_rd),
    .if_id_rs1(if_id_rs1),
    .if_id_rs2(if_id_rs2),
    .stall(hazard_stall)
);

// Write-back Mux: Selects between Jump PC, Systolic Array Data, Memory Data, or ALU Result
assign wb_data = mem_wb_Jump                  ? mem_wb_pc_plus_4 :
                 (mem_wb_SystolicOp == 2'b10) ? systolic_read_data :
                 mem_wb_MemToReg              ? mem_wb_memory_data : 
                                                mem_wb_alu_result;

assign compressed = (instr_code[1:0] != 2'b11);
assign pc_increment = compressed ? 32'd2 : 32'd4;

assign flush = bp_prediction_flush;

wire [31:0] recovery_pc = ex_actual_taken ? ex_actual_target : (id_ex_pc + (id_ex_compressed ? 32'd2 : 32'd4));

assign next_pc =
    bp_prediction_flush ? recovery_pc :
    (bp_prediction_taken ? bp_predicted_target :
                           current_pc + pc_increment);

always @(posedge clk) begin
$display(
"PC=%h Op=%b RD=%d RegWrite=%b WB=%h SysRead=%h",
current_pc,
mem_wb_SystolicOp,
mem_wb_rd,
mem_wb_RegWrite,
wb_data,
systolic_read_data
);
end

endmodule