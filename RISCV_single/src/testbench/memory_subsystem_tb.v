`timescale 1ns/1ps

module tb;

reg clk;
reg rst;

reg MemRead;
reg MemWrite;

reg [31:0] address;
reg [31:0] write_data;

wire [31:0] read_data;
wire stall;

memory_subsystem dut(
    .clk(clk),
    .rst(rst),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .address(address),
    .write_data(write_data),
    .read_data(read_data),
    .stall(stall)
);

//-------------------------------------
// Clock
//-------------------------------------

always #5 clk = ~clk;

//-------------------------------------
// Waveform
//-------------------------------------

initial begin
    $dumpfile("memory_subsystem.vcd");
    $dumpvars(0,tb);
end

//-------------------------------------
// Monitor
//-------------------------------------

always @(posedge clk) begin
    $display("t=%0t  Stall=%b  CacheState=%0d  ICState=%0d  MCState=%0d  MR=%b MW=%b Addr=%h Read=%h",
        $time,
        stall,
        dut.cache_inst.state,
        dut.interconnect_ctrl_inst.state,
        dut.memory_ctrl_inst.state,
        MemRead,
        MemWrite,
        address,
        read_data
    );
    $display("   cache_read_req(cache side)=%b cache_write_req=%b  |  IC sees cache_read_req=%b cache_write_req=%b cache_address=%h",
        dut.cache_read_req, dut.cache_write_req,
        dut.interconnect_ctrl_inst.cache_read_req, dut.interconnect_ctrl_inst.cache_write_req,
        dut.interconnect_ctrl_inst.cache_address);
    $display("   IC: ARVALID=%b ARREADY=%b RVALID=%b RREADY=%b  |  AXI mem-side: ARVALID=%b ARREADY=%b RVALID=%b RREADY=%b",
        dut.interconnect_ctrl_inst.master_read_addr_valid, dut.interconnect_ctrl_inst.master_read_addr_ready,
        dut.interconnect_ctrl_inst.master_read_data_valid, dut.interconnect_ctrl_inst.master_read_data_ready,
        dut.mem_slave_read_addr_valid, dut.mem_slave_read_addr_ready,
        dut.mem_slave_read_data_valid, dut.mem_slave_read_data_ready);
end

initial begin
    #1000;
    $display("*** TIMEOUT: hung waiting for something ***");
    $finish;
end

//-------------------------------------
// Test
//-------------------------------------

initial begin

    clk = 0;
    rst = 1;

    MemRead  = 0;
    MemWrite = 0;

    address = 0;
    write_data = 0;

    #20;
    rst = 0;

    //----------------------------------------------------
    // WRITE
    //----------------------------------------------------

    @(posedge clk);

    address    = 32'd100;
    write_data = 32'd20;
    MemWrite   = 1;

    // Hold the request for one real clock edge (so the FSM actually
    // samples it -- not released based on the zero-time combinational
    // `stall` wire alone), then wait for `stall` to clear. This works
    // whether the access is a miss (stall pulses for many cycles) or,
    // in principle, a hit (stall never rises at all).
    @(posedge clk);
    while (stall) begin
        @(posedge clk);
    end

    MemWrite = 0;

    $display("WRITE COMPLETE @ %0t", $time);

    //----------------------------------------------------
    // READ
    //----------------------------------------------------

    @(posedge clk);

    address = 32'd100;
    MemRead = 1;

    @(posedge clk);
    while (stall) begin
        @(posedge clk);
    end

    MemRead = 0;

    $display("READ COMPLETE @ %0t", $time);
    $display("READ DATA = %0d", read_data);

    #20;

    $finish;

end

endmodule