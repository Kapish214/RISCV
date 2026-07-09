module instr_mem(
    input [31:0] pc,
    output [31:0] instr_code
);

reg [7:0] instr_mem [0:255];


initial begin
    $readmemh("program.mem", instr_mem);
end

assign instr_code = {
    instr_mem[pc+3],
    instr_mem[pc+2],
    instr_mem[pc+1],
    instr_mem[pc]
};

endmodule