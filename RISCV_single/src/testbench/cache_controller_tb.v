`timescale 1ns/1ps

module cache_controller_tb;

reg clk;
reg rst;

reg MemRead;
reg MemWrite;

reg [31:0] address;
reg [31:0] write_data;

wire [31:0] read_data;

wire cache_hit;
wire hit_way0;
wire hit_way1;
wire miss;

wire mem_read;
wire mem_write;

wire [31:0] mem_address;
wire [31:0] mem_write_data;

wire cache_stall;

reg [31:0] mem_read_data;

cache_controller dut(

    .clk(clk),
    .rst(rst),

    .MemRead(MemRead),
    .MemWrite(MemWrite),

    .address(address),
    .write_data(write_data),

    .read_data(read_data),

    .cache_hit(cache_hit),
    .hit_way0(hit_way0),
    .hit_way1(hit_way1),
    .miss(miss),

    .mem_read(mem_read),
    .mem_write(mem_write),

    .mem_address(mem_address),
    .mem_write_data(mem_write_data),

    .cache_stall(cache_stall),

    .mem_read_data(mem_read_data)

);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
rst=1;
#20;
rst = 0;
 //--------------------------------
// Fill Way0
//--------------------------------

mem_read_data = 32'd50;

address = 32'h00000064;

MemRead = 1;
MemWrite = 0;

#40;


//--------------------------------
// Fill Way1
//--------------------------------

mem_read_data = 32'd100;

address = 32'h00000464;

MemRead = 1;
MemWrite = 0;

#40;


//--------------------------------
// Make Way0 dirty
//--------------------------------

address = 32'h00000064;

write_data = 32'd777;

MemRead = 0;
MemWrite = 1;

#20;


//--------------------------------
// Force replacement
//--------------------------------

mem_read_data = 32'd999;

address = 32'h00000864;

MemRead = 1;
MemWrite = 0;

#80;

//--------------------------------
// Touch Way1 so Way0 becomes LRU
//--------------------------------

address = 32'h00000464;

MemRead  = 1;
MemWrite = 0;

#20;


//--------------------------------
// Force replacement
//--------------------------------

mem_read_data = 32'd999;

address = 32'h00000864;

MemRead  = 1;
MemWrite = 0;

#80;

$finish;

$finish;
    $finish;

end
always @(posedge clk)
begin

    $display("--------------------------------");

    $display("STATE=%0d", dut.state);

    $display("STALL=%b",
        cache_stall);

    $display("Hit=%b Miss=%b",
        cache_hit,
        miss);




    $display("Address=%h",
        address);

    $display("ReadData=%0d",
        read_data);



    $display("LRU=%b",
        dut.lru_value);

    $display("STATE=%0d", dut.state);

$display("STALL=%b", cache_stall);

$display("mem_read=%b mem_write=%b",
    mem_read,
    mem_write);

$display("mem_address=%h",
    mem_address);

$display("mem_write_data=%0d",
    mem_write_data);

$display("Way0: Valid=%b Dirty=%b Data=%0d",
    dut.valid0,
    dut.dirty0,
    dut.data0);

$display("Way1: Valid=%b Dirty=%b Data=%0d",
    dut.valid1,
    dut.dirty1,
    dut.data1);


end
endmodule