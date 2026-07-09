module lru_memory(

    input clk,
    input rst,

    input [7:0] index,

    input lru_write,
    input lru_new_value,

    output lru_value

);

reg lru [0:255];

integer i;

assign lru_value=lru[index];

always @(posedge clk or posedge rst) begin
    if(rst) begin
        for(i=0;i<256;i++) begin
            lru[i]<=0;
        end 
    end
    else if(lru_write) begin
        lru[index]<=lru_new_value;
    end

end


endmodule