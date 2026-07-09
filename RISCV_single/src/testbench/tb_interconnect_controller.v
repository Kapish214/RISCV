`timescale 1ns / 1ps

module tb_interconnect_controller;

reg clk;
reg rst;

//==================================================
// CACHE SIDE
//==================================================

reg         cache_read_req;
reg         cache_write_req;

reg [31:0]  cache_address;
reg [31:0]  cache_write_data;
reg [3:0]   cache_write_strb;

wire [31:0] cache_read_data;
wire        cache_read_done;
wire        cache_write_done;
wire        cache_busy;


//==================================================
// INTERCONNECT SIDE
//==================================================

wire [31:0] master_read_addr;
wire        master_read_addr_valid;
reg         master_read_addr_ready;

reg [31:0]  master_read_data;
reg [1:0]   master_read_resp;
reg         master_read_data_valid;
wire        master_read_data_ready;


wire [31:0] master_write_addr;
wire        master_write_addr_valid;
reg         master_write_addr_ready;

wire [31:0] master_write_data;
wire [3:0]  master_write_strb;
wire        master_write_data_valid;
reg         master_write_data_ready;

reg  [1:0]  master_write_resp;
reg         master_write_resp_valid;
wire        master_write_resp_ready;


//==================================================
// DUT
//==================================================

interconnect_controller dut(

    .clk(clk),
    .rst(rst),

    .cache_read_req(cache_read_req),
    .cache_write_req(cache_write_req),
    .cache_address(cache_address),
    .cache_write_data(cache_write_data),
    .cache_write_strb(cache_write_strb),

    .cache_read_data(cache_read_data),
    .cache_read_done(cache_read_done),
    .cache_write_done(cache_write_done),
    .cache_busy(cache_busy),

    .master_read_addr(master_read_addr),
    .master_read_addr_valid(master_read_addr_valid),
    .master_read_addr_ready(master_read_addr_ready),

    .master_read_data(master_read_data),
    .master_read_resp(master_read_resp),
    .master_read_data_valid(master_read_data_valid),
    .master_read_data_ready(master_read_data_ready),

    .master_write_addr(master_write_addr),
    .master_write_addr_valid(master_write_addr_valid),
    .master_write_addr_ready(master_write_addr_ready),

    .master_write_data(master_write_data),
    .master_write_strb(master_write_strb),
    .master_write_data_valid(master_write_data_valid),
    .master_write_data_ready(master_write_data_ready),

    .master_write_resp(master_write_resp),
    .master_write_resp_valid(master_write_resp_valid),
    .master_write_resp_ready(master_write_resp_ready)

);


//==================================================
// CLOCK
//==================================================

always #5 clk = ~clk;


//==================================================
// TEST
//==================================================

initial begin

    clk = 0;
    rst = 1;

    cache_read_req = 0;
    cache_write_req = 0;

    cache_address = 0;
    cache_write_data = 0;
    cache_write_strb = 0;

    master_read_addr_ready = 0;
    master_read_data = 0;
    master_read_resp = 2'b00;
    master_read_data_valid = 0;

    master_write_addr_ready = 0;
    master_write_data_ready = 0;
    master_write_resp = 2'b00;
    master_write_resp_valid = 0;

    //-------------------
    // RESET
    //-------------------

    #20;
    rst = 0;

    //-------------------
    // READ TEST
    //-------------------

    $display("==================================");
    $display("READ TEST");
    $display("==================================");

    cache_address = 32'h00000100;
    cache_read_req = 1;

    #10;

    cache_read_req = 0;

    // Wait a cycle
    #10;

    // Interconnect accepts address
    master_read_addr_ready = 1;

    #10;

    master_read_addr_ready = 0;

    // Wait 2 cycles (memory delay)
    #20;

    // Return read data
    master_read_data = 32'h12345678;
    master_read_resp = 2'b00;
    master_read_data_valid = 1;

    #10;

    master_read_data_valid = 0;

    #20;

    //-------------------
    // WRITE TEST
    //-------------------

    $display("==================================");
    $display("WRITE TEST");
    $display("==================================");

    cache_address = 32'h00000200;
    cache_write_data = 32'hDEADBEEF;
    cache_write_strb = 4'b1111;

    cache_write_req = 1;

    #10;

    cache_write_req = 0;

    // Interconnect accepts address/data
    #10;

    master_write_addr_ready = 1;
    master_write_data_ready = 1;

    #10;

    master_write_addr_ready = 0;
    master_write_data_ready = 0;

    // Memory takes time
    #20;

    master_write_resp = 2'b00;
    master_write_resp_valid = 1;

    #10;

    master_write_resp_valid = 0;

    #30;

    $display("Simulation Finished");

    $finish;

end


//==================================================
// MONITOR
//==================================================

initial begin

$monitor(
"Time=%0t | State=%d | Busy=%b | ReadReq=%b | WriteReq=%b | ReadDone=%b | WriteDone=%b | RAddr=%h | WAddr=%h | WData=%h",
$time,
dut.state,
cache_busy,
cache_read_req,
cache_write_req,
cache_read_done,
cache_write_done,
master_read_addr,
master_write_addr,
master_write_data
);

end


//==================================================
// WAVES
//==================================================

initial begin

    $dumpfile("interconnect_controller.vcd");
    $dumpvars(0,tb_interconnect_controller);

end

endmodule