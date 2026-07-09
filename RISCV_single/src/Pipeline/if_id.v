module if_id(
    input clk,
    input rst,
    input flush,
    input [31:0] pc_in,
    input [31:0] instr_in,
    output reg [31:0] pc_out,
    output reg [31:0] instr_out,
    input stall,        // Used for load-use hazard
    input cache_stall,   // Used for cache miss
    input prediction_taken_in,//from the branch predictor
    input [31:0] predicted_target_in,
    input compressed_in,
    output reg prediction_taken_out,//to branch predictor
    output reg [31:0] predicted_target_out,
    output reg compressed_out

);

wire pred_flush=(predicted_target_in==predicted_target_out) ? 0 : 1;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        pc_out    <= 32'b0;
        instr_out <= 32'b0;
        prediction_taken_out <= 0;
        predicted_target_out <= 0;
        compressed_out <= 1'b0;
    end
    else if(cache_stall) begin
        // CACHE MISS: Absolute priority. Freeze the register.
        pc_out    <= pc_out;
        instr_out <= instr_out;
        prediction_taken_out <= prediction_taken_out;
        predicted_target_out <= predicted_target_out;
        compressed_out <= compressed_out;
    end
    else if(flush) begin
        // BRANCH/JUMP: Flush fetched instruction (wrong path)
        pc_out    <= 0;
        instr_out <= 32'b0; // NOP
        prediction_taken_out <= 0;
        predicted_target_out <= 0;
        compressed_out <= 1'b0;

    end
    else if(stall) begin
        // HAZARD STALL: Freeze the register so ID/EX can inject a bubble
        pc_out    <= pc_out;
        instr_out <= instr_out;
        prediction_taken_out <= prediction_taken_out;
        predicted_target_out <= predicted_target_out;
        compressed_out <= compressed_out ;
    end
    else begin
        // NORMAL EXECUTION
        pc_out    <= pc_in;
        instr_out <= instr_in;
        prediction_taken_out <= prediction_taken_in;
        predicted_target_out <= predicted_target_in;
        compressed_out <= compressed_in;
    end
end

endmodule