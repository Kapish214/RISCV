// Cache line format
// [55]    Valid
// [54]    Dirty
// [53:32] Tag
// [31:0]  Data
module data_cache(

    input clk,
    input rst,

    input [7:0] index,

    input write_way0,
    input write_way1,

    input [55:0] way0_new_line,
    input [55:0] way1_new_line,

    output [55:0] way0_line,
    output [55:0] way1_line

);

reg [55:0] way0 [0:255];
reg [55:0] way1 [0:255];

integer i;

//read from cache async
assign way0_line = way0[index];
assign way1_line = way1[index];

always @(posedge clk or posedge rst) begin
    if(rst) begin
        for(i=0;i<256;i++) begin
            way0[i] <=0;
            way1[i] <=0;
        end
    end
    //write sync into cache
    else begin
        if(write_way0) begin
            way0[index]<=way0_new_line;
        end
        if(write_way1) begin
            way1[index]<=way1_new_line;
        end
    end
end

endmodule