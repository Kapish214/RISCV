module branch_predictor(
    input clk,
    input rst,
    input [31:0] next_pc,
    input actual_taken,
    input [31:0] ex_pc,
    input update_enable,
    input [31:0] actual_target,
    input id_ex_prediction_taken,
    input [31:0] id_ex_predicted_target,
    output reg [31:0] predicted_target,
    output wire [1:0] prediction,
    output wire prediction_taken,
    output reg btb_hit,
    output reg prediction_flush 
);

reg [1:0] bht [0:255];
reg [32:0] btb[0:255];

integer i;

parameter SNT = 2'b00;
parameter WNT = 2'b01;
parameter WT  = 2'b10;
parameter ST  = 2'b11;

wire [7:0] index;
assign index = next_pc[9:2];

assign prediction = bht[index];
assign prediction_taken = prediction[1];

wire valid;
assign valid = btb[index][32];

always @(*) begin
    if(prediction_taken) begin
        if(valid) begin
            predicted_target = btb[index][31:0];
            btb_hit = 1;
        end
        else begin
            predicted_target = next_pc+ 32'd4; 
            btb_hit = 0;
        end
    end
    else begin
        predicted_target = next_pc+ 32'd4;
        btb_hit = 0;
    end
end

always @(*) begin
    prediction_flush = 0;
    
    if (update_enable) begin
        if(actual_taken!=id_ex_prediction_taken) begin
            prediction_flush=1;
        end
        else if(actual_taken && id_ex_predicted_target!=actual_target) begin
            prediction_flush=1;
        end
        else begin
            prediction_flush=0;
        end
    end
end

wire [7:0] ex_index;
assign ex_index = ex_pc[9:2];
wire [1:0] current_state = bht[ex_index];

always @(posedge clk or posedge rst) begin
    if(rst) begin
        for(i=0; i<256; i=i+1) begin
            bht[i] <= 0;
            btb[i] <= 0;
        end
    end
    else begin
         if(update_enable) begin
            btb[ex_index] <= {1'b1, actual_target[31:0]};
            
            if(current_state==SNT) begin
                if(actual_taken) begin
                    bht[ex_index]<=WNT;
                end
                else begin
                    bht[ex_index]<=SNT;
                end
            end 
            else if(current_state==WNT) begin
                 if(actual_taken) begin
                    bht[ex_index]<=WT;
                end
                else begin
                    bht[ex_index]<=SNT;
                end
            end
            else if(current_state==WT) begin
                 if(actual_taken) begin
                    bht[ex_index]<=ST;
                end
                else begin
                    bht[ex_index]<=WNT;
                end
            end
            else if(current_state==ST) begin
                 if(actual_taken) begin
                    bht[ex_index]<=ST;
                end
                else begin
                    bht[ex_index]<=WT;
                end
            end
         end 
    end
end

endmodule