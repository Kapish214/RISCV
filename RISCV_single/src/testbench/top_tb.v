`timescale 1ns/1ps

module tb;

reg clk;
reg rst;

top dut(
    .clk(clk),
    .rst(rst)
);


//-------------------------------------
// Clock
//-------------------------------------
always #5 clk = ~clk;


//-------------------------------------
// Reset
//-------------------------------------
initial begin
    clk = 0;
    rst = 1;
    cycle = 0; // Initialized cycle counter

    #20;
    rst = 0;
end


//-------------------------------------
// Timeout
//-------------------------------------
initial begin
    #2000;

    $display("\n=================================");
    $display("TIMEOUT");
    $display("=================================");

    $finish;
end


//-------------------------------------
// Waveforms
//-------------------------------------
initial begin
    $dumpfile("processor_system.vcd");
    $dumpvars(0,tb);
end


//-------------------------------------
// Cycle Monitor
//-------------------------------------

integer cycle;

initial
begin
    #200
    cycle = cycle + 1;

    // $display("\n====================================================");
    // $display("Cycle %0d", cycle);
    // $display("====================================================");

    // //------------------------------------------------
    // // Processor Pipeline State
    // //------------------------------------------------

    // $display("PC=%h  Instr=%h  Stall=%b",
    //          dut.processor_inst.current_pc,
    //          dut.processor_inst.instr_code,
    //          dut.memory_subsystem_inst.stall);

    // $display("IF/ID PC=%h  ID/EX PC=%h  EX/MEM ALU=%h",
    //          dut.processor_inst.if_id_pc,
    //          dut.processor_inst.id_ex_pc,
    //          dut.processor_inst.ex_mem_alu_result);

    // //------------------------------------------------
    // // Memory Interface
    // //------------------------------------------------

    // $display("MemRead     = %b",
    //     dut.processor_inst.MemRead);

    // $display("MemWrite    = %b",
    //     dut.processor_inst.MemWrite);

    // $display("Address     = %h",
    //     dut.processor_inst.ex_mem_alu_result);

    // $display("WriteData   = %h",
    //     dut.processor_inst.ex_mem_write_data);

    // $display("ReadData    = %h",
    //     dut.processor_inst.mem_read_data);

    //------------------------------------------------
    // Registers
    //------------------------------------------------

    $display(
"x0=%h x1=%h x2=%h x3=%h",
dut.processor_inst.reg_file_inst.registers[0],
dut.processor_inst.reg_file_inst.registers[1],
dut.processor_inst.reg_file_inst.registers[2],
dut.processor_inst.reg_file_inst.registers[3]);

    $display(
"x4=%h x5=%h x6=%h x7=%h",
dut.processor_inst.reg_file_inst.registers[4],
dut.processor_inst.reg_file_inst.registers[5],
dut.processor_inst.reg_file_inst.registers[6],
dut.processor_inst.reg_file_inst.registers[7]);

    $display(
"x8=%h x9=%h x10=%h x11=%h",
dut.processor_inst.reg_file_inst.registers[8],
dut.processor_inst.reg_file_inst.registers[9],
dut.processor_inst.reg_file_inst.registers[10],
dut.processor_inst.reg_file_inst.registers[11]);

    $display(
"x12=%h x13=%h x14=%h x15=%h",
dut.processor_inst.reg_file_inst.registers[12],
dut.processor_inst.reg_file_inst.registers[13],
dut.processor_inst.reg_file_inst.registers[14],
dut.processor_inst.reg_file_inst.registers[15]);

end

endmodule