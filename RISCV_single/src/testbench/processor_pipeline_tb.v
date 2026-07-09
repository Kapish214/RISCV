`timescale 1ns / 1ps

module tb();

    reg clk;
    reg rst;
    reg [31:0] mem_read_data;
reg mem_stall;

wire MemRead;
wire MemWrite;
wire [31:0] mem_address;
wire [31:0] mem_write_data;

    // Instantiate the Top-Level Processor
    processor_pipeline cpu(
    .clk(clk),
    .rst(rst),

    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .mem_address(mem_address),
    .mem_write_data(mem_write_data),

    .mem_read_data(mem_read_data),
    .mem_stall(mem_stall)
);

    // Generate a 10ns Clock
    always #5 clk = ~clk;

    initial begin
        // Initialize Signals
        clk = 0;
        rst = 1;

        // Load the Loop Machine Code into Instruction Memory
        // Note: Make sure your instr_mem module uses $readmemh("loop.hex", memory_array);
        // If not, you can load it here if the memory array is accessible.

        // Hold reset high for a few clock cycles to clear pipeline
        #20;
        rst = 0;

        // Let the CPU run for 150 clock cycles (long enough to finish the loop 5 times)
        #1500;
        
        $display("Simulation Complete.");
        $finish;
    end
    initial begin
    clk = 0;
    rst = 1;

    mem_read_data = 32'd0;
    mem_stall = 1'b0;

    #20;
    rst = 0;

    #1500;

    $display("Simulation Complete.");
    $finish;
end
    // Monitor the Predictor in Real-Time
    initial begin
        $monitor("Time: %4d | PC: %h | Predictor Flush: %b | ALU Actual Target: %h | x1 (Counter): %d | x2 (Sum): %d", 
                  $time, 
                  cpu.current_pc, 
                  cpu.bp_prediction_flush, 
                  cpu.ex_actual_target,
                  cpu.reg_file_inst.registers[1], // x1
                  cpu.reg_file_inst.registers[2]  // x2
                 );
    end

    // Optional: Dump waves for GTKWave/ModelSim
    initial begin
        $dumpfile("processor_pipeline.vcd");
        $dumpvars(0, tb);
    end
    always @(posedge clk) begin
    if(!rst) begin
        $display("------------------------------------------------------------");
        $display("Time = %0t", $time);
        $display("PC   = %h", cpu.current_pc);
        $display("ALU  = %h", cpu.alu_result);

        $display("x1 = %0d   x2 = %0d   x3 = %0d   x4 = %0d",
            cpu.reg_file_inst.registers[1],
            cpu.reg_file_inst.registers[2],
            cpu.reg_file_inst.registers[3],
            cpu.reg_file_inst.registers[4]);

        $display("x5 = %0d   x6 = %0d   x7 = %0d   x8 = %0d",
            cpu.reg_file_inst.registers[5],
            cpu.reg_file_inst.registers[6],
            cpu.reg_file_inst.registers[7],
            cpu.reg_file_inst.registers[8]);
    end
end

endmodule