module alu_control(
    input [3:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [3:0] alu_control_res
);

always @(*) begin
    case(ALUOp)

        4'b0000: alu_control_res = 4'b0000;

        4'b0001: alu_control_res = 4'b0000;

        4'b0010: begin
    case(funct3)
        3'b000: alu_control_res = 4'b0001; // BEQ
        3'b001: alu_control_res = 4'b0001; // BNE
        3'b100: alu_control_res = 4'b0101; // BLT
        3'b101: alu_control_res = 4'b0101; // BGE
        default: alu_control_res = 4'b0001;
    endcase
end

        4'b0011: begin
            if(funct7 == 7'b0000001) begin
                case(funct3)
                    3'b000: alu_control_res = 4'b1010;
                    3'b100: alu_control_res = 4'b1011;
                    default: alu_control_res = 4'b0000;
                endcase
            end
            else begin
                case(funct3)
                    3'b000: begin
                        if(funct7 == 7'b0100000)
                            alu_control_res = 4'b0001;
                        else
                            alu_control_res = 4'b0000;
                    end

                    3'b001: alu_control_res = 4'b0110;
                    3'b010: alu_control_res = 4'b0101;
                    3'b100: alu_control_res = 4'b0100;

                    3'b101: begin
                        if(funct7 == 7'b0100000)
                            alu_control_res = 4'b1000;
                        else
                            alu_control_res = 4'b0111;
                    end

                    3'b110: alu_control_res = 4'b0011;
                    3'b111: alu_control_res = 4'b0010;

                    default: alu_control_res = 4'b0000;
                endcase
            end
        end

        4'b0100: begin
            case(funct3)

                3'b000: alu_control_res = 4'b0000;

                3'b001: alu_control_res = 4'b0110;

                3'b010: alu_control_res = 4'b0101;

                3'b100: alu_control_res = 4'b0100;

                3'b101: begin
                    if(funct7 == 7'b0100000)
                        alu_control_res = 4'b1000;
                    else
                        alu_control_res = 4'b0111;
                end

                3'b110: alu_control_res = 4'b0011;

                3'b111: alu_control_res = 4'b0010;

                default: alu_control_res = 4'b0000;
            endcase
        end

        4'b0101: alu_control_res = 4'b0000;

        4'b0110: alu_control_res = 4'b0000;

        4'b0111: alu_control_res = 4'b1001;

        4'b1000: alu_control_res = 4'b0000;

        default: alu_control_res = 4'b0000;

    endcase
end

endmodule