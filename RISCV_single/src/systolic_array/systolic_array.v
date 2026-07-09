module systolic_array(
    input clk,
    input rst,
    // i/p from top.v (updated to 8-bit)
    input [7:0] A0,
    input [7:0] A1,
    input [7:0] A2,
    input [7:0] A3,

    input [7:0] B0,
    input [7:0] B1,
    input [7:0] B2,
    input [7:0] B3,

    // o/p to top.v (updated to 18-bit)
    output [17:0] C11,
    output [17:0] C12,
    output [17:0] C13,
    output [17:0] C14,

    output [17:0] C21,
    output [17:0] C22,
    output [17:0] C23,
    output [17:0] C24,

    output [17:0] C31,
    output [17:0] C32,
    output [17:0] C33,
    output [17:0] C34,

    output [17:0] C41,
    output [17:0] C42,
    output [17:0] C43,
    output [17:0] C44
);

// Horizontal (A) wires (updated to 8-bit)
wire [7:0] a11_12, a12_13, a13_14;
wire [7:0] a21_22, a22_23, a23_24;
wire [7:0] a31_32, a32_33, a33_34;
wire [7:0] a41_42, a42_43, a43_44;

// Vertical (B) wires (updated to 8-bit)
wire [7:0] b11_21, b21_31, b31_41;
wire [7:0] b12_22, b22_32, b32_42;
wire [7:0] b13_23, b23_33, b33_43;
wire [7:0] b14_24, b24_34, b34_44;

// dummy wires, for edges (updated to 8-bit)
wire [7:0] a14_dummy, a24_dummy, a34_dummy, a44_dummy;
wire [7:0] b41_dummy, b42_dummy, b43_dummy, b44_dummy;

// --- Instantiations remain the same, 
//     but will now pass 8-bit data and 18-bit results ---

pe pe11(.clk(clk), .rst(rst), .a_in(A0), .b_in(B0), .a_out(a11_12), .b_out(b11_21), .partial_sum(C11));
pe pe12(.clk(clk), .rst(rst), .a_in(a11_12), .b_in(B1), .a_out(a12_13), .b_out(b12_22), .partial_sum(C12));
pe pe13(.clk(clk), .rst(rst), .a_in(a12_13), .b_in(B2), .a_out(a13_14), .b_out(b13_23), .partial_sum(C13));
pe pe14(.clk(clk), .rst(rst), .a_in(a13_14), .b_in(B3), .a_out(a14_dummy), .b_out(b14_24), .partial_sum(C14));

pe pe21(.clk(clk), .rst(rst), .a_in(A1), .b_in(b11_21), .a_out(a21_22), .b_out(b21_31), .partial_sum(C21));
pe pe22(.clk(clk), .rst(rst), .a_in(a21_22), .b_in(b12_22), .a_out(a22_23), .b_out(b22_32), .partial_sum(C22));
pe pe23(.clk(clk), .rst(rst), .a_in(a22_23), .b_in(b13_23), .a_out(a23_24), .b_out(b23_33), .partial_sum(C23));
pe pe24(.clk(clk), .rst(rst), .a_in(a23_24), .b_in(b14_24), .a_out(a24_dummy), .b_out(b24_34), .partial_sum(C24));

pe pe31(.clk(clk), .rst(rst), .a_in(A2), .b_in(b21_31), .a_out(a31_32), .b_out(b31_41), .partial_sum(C31));
pe pe32(.clk(clk), .rst(rst), .a_in(a31_32), .b_in(b22_32), .a_out(a32_33), .b_out(b32_42), .partial_sum(C32));
pe pe33(.clk(clk), .rst(rst), .a_in(a32_33), .b_in(b23_33), .a_out(a33_34), .b_out(b33_43), .partial_sum(C33));
pe pe34(.clk(clk), .rst(rst), .a_in(a33_34), .b_in(b24_34), .a_out(a34_dummy), .b_out(b34_44), .partial_sum(C34));

pe pe41(.clk(clk), .rst(rst), .a_in(A3), .b_in(b31_41), .a_out(a41_42), .b_out(b41_dummy), .partial_sum(C41));
pe pe42(.clk(clk), .rst(rst), .a_in(a41_42), .b_in(b32_42), .a_out(a42_43), .b_out(b42_dummy), .partial_sum(C42));
pe pe43(.clk(clk), .rst(rst), .a_in(a42_43), .b_in(b33_43), .a_out(a43_44), .b_out(b43_dummy), .partial_sum(C43));
pe pe44(.clk(clk), .rst(rst), .a_in(a43_44), .b_in(b34_44), .a_out(a44_dummy), .b_out(b44_dummy), .partial_sum(C44));

endmodule