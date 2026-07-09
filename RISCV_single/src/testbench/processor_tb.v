module processor_tb;

reg clk;
reg rst;

processor dut(
    .clk(clk),
    .rst(rst)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst = 1;
    #20;

    rst = 0;

    #200;

    $finish;
end

initial begin
    $dumpfile("processor.vcd");
    $dumpvars(0, processor_tb);
end

initial begin
$monitor(
"T=%0t | PC=%h Instr=%h | IFID_PC=%h IFID_Instr=%h | opcode=%b rs1=%d rs2=%d rd=%d | RD1=%d RD2=%d IMM=%d | ID_EX_RD1=%d ID_EX_RD2=%d ID_EX_IMM=%d",
$time,
dut.current_pc,
dut.instr_code,

dut.if_id_pc,
dut.if_id_instr,

dut.opcode,
dut.rs1,
dut.rs2,
dut.rd,

dut.read_data1,
dut.read_data2,
dut.immediate,

dut.id_ex_read_data1,
dut.id_ex_read_data2,
dut.id_ex_imm
);
end

endmodule