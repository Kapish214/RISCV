module reg_file(
    input clk,
    input rst,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input RegWrite,
    input [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);

reg [31:0] registers [0:31];
integer i;

assign read_data1 =
    (RegWrite && rd!=0 && rd==rs1) ?
        write_data :
        registers[rs1];

assign read_data2 =
    (RegWrite && rd!=0 && rd==rs2) ?
        write_data :
        registers[rs2];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 32'b0;
        end
    end 
    else begin
        if (RegWrite) begin
            if (rd != 0) begin
                registers[rd] <= write_data;
            end
        end
    end
end


always @(posedge clk) begin
    if (RegWrite && rd != 0) begin
        $display(
            "WRITE x%0d <= %h  OLD=%h",
            rd,
            write_data,
            registers[rd]
        );

        #1;

        $display(
            "AFTER x%0d = %h",
            rd,
            registers[rd]
        );
    end
end

always @(posedge clk) begin
    $display(
"x1=%0d x2=%0d x3=%0d x4=%0d x5=%0d x6=%0d x7=%0d x8=%0d x9=%0d x10=%0d x11=%0d x12=%0d x13=%0d",
        registers[1],
        registers[2],
        registers[3],
        registers[4],
        registers[5],
        registers[6],
        registers[7],
        registers[8],
        registers[9],
        registers[10],
        registers[11],
        registers[12],
        registers[13]
    );
end

endmodule