`timescale 1ns/1ps

module sa_tb;

reg clk;
reg rst;

reg [4:0] A_mem [0:15];
reg [4:0] B_mem [0:15];

reg [4:0] A00,A01,A02,A03;
reg [4:0] A10,A11,A12,A13;
reg [4:0] A20,A21,A22,A23;
reg [4:0] A30,A31,A32,A33;

reg [4:0] B00,B01,B02,B03;
reg [4:0] B10,B11,B12,B13;
reg [4:0] B20,B21,B22,B23;
reg [4:0] B30,B31,B32,B33;

top dut(
    .clk(clk),
    .rst(rst),

    .A00(A00), .A01(A01), .A02(A02), .A03(A03),
    .A10(A10), .A11(A11), .A12(A12), .A13(A13),
    .A20(A20), .A21(A21), .A22(A22), .A23(A23),
    .A30(A30), .A31(A31), .A32(A32), .A33(A33),

    .B00(B00), .B01(B01), .B02(B02), .B03(B03),
    .B10(B10), .B11(B11), .B12(B12), .B13(B13),
    .B20(B20), .B21(B21), .B22(B22), .B23(B23),
    .B30(B30), .B31(B31), .B32(B32), .B33(B33)
);

always #5 clk = ~clk;

initial begin

    clk = 0;
    rst = 1;

    $readmemh("matrixA.mem",A_mem);
    $readmemh("matrixB.mem",B_mem);

    A00=A_mem[0];   A01=A_mem[1];   A02=A_mem[2];   A03=A_mem[3];
    A10=A_mem[4];   A11=A_mem[5];   A12=A_mem[6];   A13=A_mem[7];
    A20=A_mem[8];   A21=A_mem[9];   A22=A_mem[10];  A23=A_mem[11];
    A30=A_mem[12];  A31=A_mem[13];  A32=A_mem[14];  A33=A_mem[15];

    B00=B_mem[0];   B01=B_mem[1];   B02=B_mem[2];   B03=B_mem[3];
    B10=B_mem[4];   B11=B_mem[5];   B12=B_mem[6];   B13=B_mem[7];
    B20=B_mem[8];   B21=B_mem[9];   B22=B_mem[10];  B23=B_mem[11];
    B30=B_mem[12];  B31=B_mem[13];  B32=B_mem[14];  B33=B_mem[15];

    $dumpfile("systolic.vcd");
    $dumpvars(0,sa_tb);

    #20;
    rst = 0;

    #150;

    $display("\nResult Matrix");
    $display("%d %d %d %d", dut.C11, dut.C12, dut.C13, dut.C14);
    $display("%d %d %d %d", dut.C21, dut.C22, dut.C23, dut.C24);
    $display("%d %d %d %d", dut.C31, dut.C32, dut.C33, dut.C34);
    $display("%d %d %d %d", dut.C41, dut.C42, dut.C43, dut.C44);

    $finish;

end

endmodule