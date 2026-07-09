module pe(
    input [7:0] a_in,
    input [7:0] b_in,
    output reg [7:0] a_out,
    output reg [7:0] b_out,
    output reg [17:0] partial_sum,
    input clk,
    input rst
);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        a_out<=0;
        b_out<=0;
        partial_sum<=0;
    end    
    else begin
        a_out<=a_in;
        b_out<=b_in;
        partial_sum <= partial_sum + (a_in*b_in);  
    end
end

endmodule
