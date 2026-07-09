module PC(
    input clk,
    input rst,
    input [31:0] next_pc,
    output reg [31:0] current_pc,
    input stall
);


always @(posedge clk or posedge rst) begin
    if(rst)
        current_pc<=0;
    else if(!stall)
        current_pc<=next_pc;
end

endmodule