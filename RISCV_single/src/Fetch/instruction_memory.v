module instr_mem(
    input [31:0] pc,
    output [31:0] instr_code
);

reg [7:0] instr_mem [0:255];

integer i;

initial begin
    for(i=0; i<256; i=i+4) begin
        instr_mem[i]   = 8'h13;
        instr_mem[i+1] = 8'h00;
        instr_mem[i+2] = 8'h00;
        instr_mem[i+3] = 8'h00;
    end
    $readmemh("program.mem", instr_mem);
end

assign instr_code = {
    instr_mem[pc+3],
    instr_mem[pc+2],
    instr_mem[pc+1],
    instr_mem[pc]
};

endmodule