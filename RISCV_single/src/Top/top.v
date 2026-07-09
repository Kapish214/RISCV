// module top(
//     input clk,
//     input rst
// );

//     // --- Memory Interface Wires ---
//     wire        MemRead;
//     wire        MemWrite;
//     wire [31:0] address;
//     wire [31:0] write_data;
//     wire [31:0] read_data;
//     wire        stall;

//     // --- Systolic Array Interface Wires ---
//     wire [1:0]  SystolicOp;         // 2-bit opcode from the CPU
//     wire [4:0]  result_index;
//     wire        systolic_busy;
//     wire [31:0] systolic_read_data;
    
//     // Decoded control signals for the controller
//     wire        SystolicStart;
//     wire        SystolicRead;

//     // --- Decode Logic ---
//     assign SystolicStart = (SystolicOp == 2'b01);
//     assign SystolicRead  = (SystolicOp == 2'b10);

//     // --- Module Instantiations ---

//     processor_pipeline processor_inst(
//         .clk(clk),
//         .rst(rst),
        
//         // Memory connections
//         .MemRead(MemRead),
//         .MemWrite(MemWrite),
//         .mem_address(address),
//         .mem_write_data(write_data),
//         .mem_read_data(read_data),
//         .mem_stall(stall),
        
//         // Systolic Controller connections
//         .SystolicOp(SystolicOp),
//         .result_index(result_index),
//         .systolic_busy(systolic_busy),
//         .systolic_read_data(systolic_read_data)
//     );

//     systolic_controller systolic_inst(
//         .clk(clk),
//         .rst(rst),
//         .SystolicStart(SystolicStart), // Driven by decode logic
//         .SystolicRead(SystolicRead),   // Driven by decode logic
//         .result_index(result_index),
//         .busy(systolic_busy),
//         .read_data(systolic_read_data)
//     );

//     memory_subsystem memory_subsystem_inst(
//         .clk(clk),
//         .rst(rst),
//         .MemRead(MemRead),
//         .MemWrite(MemWrite),
//         .address(address),
//         .write_data(write_data),
//         .read_data(read_data),
//         .stall(stall)
//     );

// endmodule
module top(
    input clk,
    input rst
);

    // --- Memory Interface Wires ---
    wire        MemRead;
    wire        MemWrite;
    wire [31:0] address;
    wire [31:0] write_data;
    wire [31:0] read_data;
    wire        stall;

    // --- Systolic Array Interface Wires ---
    wire [1:0]  SystolicOp;         // 2-bit opcode from the CPU (WB stage -- used for the read/data mux timing)
    wire [1:0]  SystolicOpEarly;    // 2-bit opcode from the CPU (EX/MEM stage -- used only to start the FSM early)
    wire [4:0]  result_index;
    wire        systolic_busy;
    wire [31:0] systolic_read_data;
    
    // Decoded control signals for the controller
    wire        SystolicStart;
    wire        SystolicRead;

    // --- Decode Logic ---
    // SystolicStart is driven from the EARLIER (EX/MEM) pipeline stage, not the WB
    // stage. If it were driven from the WB-stage SystolicOp, `busy` would only turn
    // on once the SMAT instruction reaches WB -- by which point a closely-following
    // SMRD (read) instruction could already have raced past the EX/MEM stall check
    // (which looks at ex_mem_SystolicOp) and reached WB itself with stale/garbage
    // data, since the stall never had anything to catch. Starting two stages
    // earlier gives `busy` time to actually assert before SMRD gets there.
    assign SystolicStart = (SystolicOpEarly == 2'b01);
    assign SystolicRead  = (SystolicOp == 2'b10);

    // --- Module Instantiations ---

    processor_pipeline processor_inst(
        .clk(clk),
        .rst(rst),
        
        // Memory connections
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .mem_address(address),
        .mem_write_data(write_data),
        .mem_read_data(read_data),
        .mem_stall(stall),
        
        // Systolic Controller connections
        .SystolicOp(SystolicOp),
        .SystolicOpEarly(SystolicOpEarly),
        .result_index(result_index),
        .systolic_busy(systolic_busy),
        .systolic_read_data(systolic_read_data)
    );

    systolic_controller systolic_inst(
        .clk(clk),
        .rst(rst),
        .SystolicStart(SystolicStart), // Driven by decode logic
        .SystolicRead(SystolicRead),   // Driven by decode logic
        .result_index(result_index),
        .busy(systolic_busy),
        .read_data(systolic_read_data)
    );

    memory_subsystem memory_subsystem_inst(
        .clk(clk),
        .rst(rst),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(address),
        .write_data(write_data),
        .read_data(read_data),
        .stall(stall)
    );

endmodule