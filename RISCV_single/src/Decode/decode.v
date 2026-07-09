module instr_decode(
    input [31:0] instr,
    output reg [6:0] opcode,
    output reg [4:0] rd,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [2:0] funct3,
    output reg [6:0] funct7,
    output reg [31:0] expanded_instruction
);

wire [1:0] last_2;
reg [31:0] expanded_instr;

assign last_2 = instr[1:0];

always @(*) begin


    if(last_2 == 2'b11) begin
        expanded_instr = instr;
    end
    else begin

        expanded_instr = 32'd0;

        case({instr[15:13], instr[1:0]})

            5'b10010: begin
                if(instr[12] == 1'b0) begin
                    if(instr[6:2] == 5'b00000) begin
                        expanded_instr[6:0]   = 7'b1100111;
                        expanded_instr[11:7]  = 5'd0;
                        expanded_instr[14:12] = 3'b000;
                        expanded_instr[19:15] = instr[11:7];
                        expanded_instr[24:20] = 5'd0;
                        expanded_instr[31:25] = 7'b0000000;
                    end
                    else begin
                        expanded_instr[6:0]   = 7'b0110011;
                        expanded_instr[11:7]  = instr[11:7];
                        expanded_instr[14:12] = 3'b000;
                        expanded_instr[19:15] = 5'd0;
                        expanded_instr[24:20] = instr[6:2];
                        expanded_instr[31:25] = 7'b0000000;
                    end
                end
                else begin
                    if(instr[6:2] == 5'b00000) begin
                        if(instr[11:7] == 5'b00000) begin
                            expanded_instr = 32'h00100073;
                        end
                        else begin
                            expanded_instr[6:0]   = 7'b1100111;
                            expanded_instr[11:7]  = 5'd1;
                            expanded_instr[14:12] = 3'b000;
                            expanded_instr[19:15] = instr[11:7];
                            expanded_instr[24:20] = 5'd0;
                            expanded_instr[31:25] = 7'b0000000;
                        end
                    end
                    else begin
                        expanded_instr[6:0]   = 7'b0110011;
                        expanded_instr[11:7]  = instr[11:7];
                        expanded_instr[14:12] = 3'b000;
                        expanded_instr[19:15] = instr[11:7];
                        expanded_instr[24:20] = instr[6:2];
                        expanded_instr[31:25] = 7'b0000000;
                    end
                end
            end

            5'b00001: begin
                if((instr[11:7] == 5'd0) && ({instr[12], instr[6:2]} == 6'd0)) begin
                    expanded_instr = 32'h00000013;
                end
                else begin
                    expanded_instr[6:0]   = 7'b0010011;
                    expanded_instr[11:7]  = instr[11:7];
                    expanded_instr[14:12] = 3'b000;
                    expanded_instr[19:15] = instr[11:7];
                    expanded_instr[31:20] = {{6{instr[12]}}, instr[12], instr[6:2]};
                end
            end

            5'b01001: begin
                expanded_instr[6:0]   = 7'b0010011;
                expanded_instr[11:7]  = instr[11:7];
                expanded_instr[14:12] = 3'b000;
                expanded_instr[19:15] = 5'd0;
                expanded_instr[31:20] = {{6{instr[12]}}, instr[12], instr[6:2]};
            end

            5'b01101: begin
                if(instr[11:7] == 5'd2) begin
                    expanded_instr[6:0]   = 7'b0010011;
                    expanded_instr[11:7]  = 5'd2;
                    expanded_instr[14:12] = 3'b000;
                    expanded_instr[19:15] = 5'd2;
                    expanded_instr[31:20] = {{2{instr[12]}}, instr[12], instr[4:3], instr[5], instr[2], instr[6], 4'd0};
                end
                else begin
                    expanded_instr[6:0]   = 7'b0110111;
                    expanded_instr[11:7]  = instr[11:7];
                    expanded_instr[14:12] = 3'b000;
                    expanded_instr[19:15] = 5'd0;
                    expanded_instr[24:20] = 5'd0;
                    expanded_instr[31:12] = {{14{instr[12]}}, instr[12], instr[6:2]};
                end
            end

            5'b00010: begin
                expanded_instr[6:0]   = 7'b0010011;
                expanded_instr[11:7]  = instr[11:7];
                expanded_instr[14:12] = 3'b001;
                expanded_instr[19:15] = instr[11:7];
                expanded_instr[31:20] = {6'd0, instr[12], instr[6:2]};
            end

            5'b01000: begin
                expanded_instr[6:0]   = 7'b0000011;
                expanded_instr[11:7]  = {2'b01, instr[4:2]};
                expanded_instr[14:12] = 3'b010;
                expanded_instr[19:15] = {2'b01, instr[9:7]};
                expanded_instr[31:20] = {6'd0, instr[5], instr[12:10], instr[6], 2'd0};
            end

            5'b11000: begin
                begin : cs_block
                    reg [11:0] simm;
                    simm                  = {6'd0, instr[5], instr[12:10], instr[6], 2'd0};
                    expanded_instr[6:0]   = 7'b0100011;
                    expanded_instr[11:7]  = simm[4:0];
                    expanded_instr[14:12] = 3'b010;
                    expanded_instr[19:15] = {2'b01, instr[9:7]};
                    expanded_instr[24:20] = {2'b01, instr[4:2]};
                    expanded_instr[31:25] = simm[11:5];
                end
            end

            5'b11001: begin
                begin : beqz_block
                    reg [8:0] bimm;
                    bimm                  = {instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0};
                    expanded_instr[6:0]   = 7'b1100011;
                    expanded_instr[7]     = bimm[1];
                    expanded_instr[11:8]  = bimm[4:1];
                    expanded_instr[14:12] = 3'b000;
                    expanded_instr[19:15] = {2'b01, instr[9:7]};
                    expanded_instr[24:20] = 5'd0;
                    expanded_instr[30:25] = bimm[6:5];
                    expanded_instr[31]    = bimm[8];
                end
            end

            5'b11101: begin
                begin : bnez_block
                    reg [8:0] bimm;
                    bimm                  = {instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0};
                    expanded_instr[6:0]   = 7'b1100011;
                    expanded_instr[7]     = bimm[1];
                    expanded_instr[11:8]  = bimm[4:1];
                    expanded_instr[14:12] = 3'b001;
                    expanded_instr[19:15] = {2'b01, instr[9:7]};
                    expanded_instr[24:20] = 5'd0;
                    expanded_instr[30:25] = bimm[6:5];
                    expanded_instr[31]    = bimm[8];
                end
            end

            5'b10101: begin
                begin : cj_block
                    reg [11:0] jimm;
                    jimm                  = {instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0};
                    expanded_instr[6:0]   = 7'b1101111;
                    expanded_instr[11:7]  = 5'd0;
                    expanded_instr[19:12] = {jimm[11], jimm[10:3]};
                    expanded_instr[20]    = jimm[2];
                    expanded_instr[30:21] = jimm[11:2];
                    expanded_instr[31]    = jimm[11];
                end
            end

            5'b00101: begin
                begin : cjal_block
                    reg [11:0] jimm;
                    jimm                  = {instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0};
                    expanded_instr[6:0]   = 7'b1101111;
                    expanded_instr[11:7]  = 5'd1;
                    expanded_instr[19:12] = {jimm[11], jimm[10:3]};
                    expanded_instr[20]    = jimm[2];
                    expanded_instr[30:21] = jimm[11:2];
                    expanded_instr[31]    = jimm[11];
                end
            end

            default: begin
                expanded_instr = 32'd0;
            end

        endcase

    end

    opcode = expanded_instr[6:0];
    rd     = expanded_instr[11:7];
    funct3 = expanded_instr[14:12];
    rs1    = expanded_instr[19:15];
    rs2    = expanded_instr[24:20];
    funct7 = expanded_instr[31:25];
    expanded_instruction = expanded_instr;
end

endmodule