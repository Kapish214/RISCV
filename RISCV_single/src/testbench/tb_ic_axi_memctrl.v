`timescale 1ns/1ps

module tb_ic_axi_memctrl;

    reg clk;
    reg rst;

    //==================================================
    // Hand-driven "cache" side
    //==================================================
    reg         cache_read_req;
    reg         cache_write_req;
    reg  [31:0] cache_address;
    reg  [31:0] cache_write_data;
    reg  [3:0]  cache_write_strb;

    wire [31:0] cache_read_data;
    wire        cache_read_done;
    wire        cache_write_done;
    wire        cache_busy;

    //==================================================
    // Interconnect Controller <-> AXI
    //==================================================
    wire [31:0] ic_master_read_addr;
    wire        ic_master_read_addr_valid;
    wire        ic_master_read_addr_ready;

    wire [31:0] ic_master_read_data;
    wire [1:0]  ic_master_read_resp;
    wire        ic_master_read_data_valid;
    wire        ic_master_read_data_ready;

    wire [31:0] ic_master_write_addr;
    wire        ic_master_write_addr_valid;
    wire        ic_master_write_addr_ready;

    wire [31:0] ic_master_write_data;
    wire [3:0]  ic_master_write_strb;
    wire        ic_master_write_data_valid;
    wire        ic_master_write_data_ready;

    wire [1:0]  ic_master_write_resp;
    wire        ic_master_write_resp_valid;
    wire        ic_master_write_resp_ready;

    //==================================================
    // AXI <-> Memory Controller (Signals)
    //==================================================
    wire [31:0] mem_read_addr;
    wire        mem_read_addr_valid;
    wire        mem_read_addr_ready;

    wire [31:0] mem_read_data;
    wire [1:0]  mem_read_resp;
    wire        mem_read_data_valid;
    wire        mem_read_data_ready;

    wire [31:0] mem_write_addr;
    wire        mem_write_addr_valid;
    wire        mem_write_addr_ready;

    wire [31:0] mem_write_data;
    wire [3:0]  mem_write_strb;
    wire        mem_write_data_valid;
    wire        mem_write_data_ready;

    wire [1:0]  mem_write_resp;
    wire        mem_write_resp_valid;
    wire        mem_write_resp_ready;

    wire        memory_busy;

    //==================================================
    // DUT: Interconnect Controller
    //==================================================
    interconnect_controller ic_inst(
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

        .master_read_addr(ic_master_read_addr),
        .master_read_addr_valid(ic_master_read_addr_valid),
        .master_read_addr_ready(ic_master_read_addr_ready),

        .master_read_data(ic_master_read_data),
        .master_read_resp(ic_master_read_resp),
        .master_read_data_valid(ic_master_read_data_valid),
        .master_read_data_ready(ic_master_read_data_ready),

        .master_write_addr(ic_master_write_addr),
        .master_write_addr_valid(ic_master_write_addr_valid),
        .master_write_addr_ready(ic_master_write_addr_ready),

        .master_write_data(ic_master_write_data),
        .master_write_strb(ic_master_write_strb),
        .master_write_data_valid(ic_master_write_data_valid),
        .master_write_data_ready(ic_master_write_data_ready),

        .master_write_resp(ic_master_write_resp),
        .master_write_resp_valid(ic_master_write_resp_valid),
        .master_write_resp_ready(ic_master_write_resp_ready)
    );

    // Pass-through assignments (acting as interconnect wiring)
    assign mem_read_addr              = ic_master_read_addr;
    assign mem_read_addr_valid        = ic_master_read_addr_valid;
    assign ic_master_read_addr_ready  = mem_read_addr_ready;

    assign ic_master_read_data        = mem_read_data;
    assign ic_master_read_resp        = mem_read_resp;
    assign ic_master_read_data_valid  = mem_read_data_valid;
    assign mem_read_data_ready        = ic_master_read_data_ready;

    assign mem_write_addr             = ic_master_write_addr;
    assign mem_write_addr_valid       = ic_master_write_addr_valid;
    assign ic_master_write_addr_ready = mem_write_addr_ready;

    assign mem_write_data             = ic_master_write_data;
    assign mem_write_strb             = ic_master_write_strb;
    assign mem_write_data_valid       = ic_master_write_data_valid;
    assign ic_master_write_data_ready = mem_write_data_ready;

    assign ic_master_write_resp       = mem_write_resp;
    assign ic_master_write_resp_valid = mem_write_resp_valid;
    assign mem_write_resp_ready       = ic_master_write_resp_ready;

    //==================================================
    // FAKE MEMORY SLAVE RESPONSES
    //==================================================
    reg mem_read_data_valid_r;
    reg mem_write_resp_valid_r;

    // READ CHANNEL
    assign mem_read_addr_ready = 1'b1;
    assign mem_read_data       = 32'h12345678;
    assign mem_read_resp       = 2'b00;
    assign mem_read_data_valid = mem_read_data_valid_r;

    // WRITE CHANNEL
    assign mem_write_addr_ready = 1'b1;
    assign mem_write_data_ready = 1'b1;
    assign mem_write_resp       = 2'b00;
    assign mem_write_resp_valid = mem_write_resp_valid_r;

    //==================================================
    // Clock
    //==================================================
    always #5 clk = ~clk;

    //==================================================
    // Waveform dump
    //==================================================
    initial begin
        $dumpfile("ic_axi_mc.vcd");
        $dumpvars(0, tb_ic_axi_memctrl);
    end

    //==================================================
    // Monitor
    //==================================================
    always @(posedge clk) begin
        $display("t=%0t | IC=%0d | creq=%b cwreq=%b cdone=%b cwdone=%b | ARV=%b ARR=%b RV=%b RR=%b | AWV=%b AWR=%b WV=%b WR=%b BV=%b BR=%b",
            $time, ic_inst.state, 
            cache_read_req, cache_write_req, cache_read_done, cache_write_done,
            ic_master_read_addr_valid, ic_master_read_addr_ready,
            ic_master_read_data_valid, ic_master_read_data_ready,
            ic_master_write_addr_valid, ic_master_write_addr_ready,
            ic_master_write_data_valid, ic_master_write_data_ready,
            ic_master_write_resp_valid, ic_master_write_resp_ready);
    end

    //==================================================
    // Timeout
    //==================================================
    initial begin
        #1000;
        $display("*** TIMEOUT ***");
        $finish;
    end

    //==================================================
    // Test Sequence
    //==================================================
    initial begin
        clk = 0;
        rst = 1;

        cache_read_req   = 0;
        cache_write_req  = 0;
        cache_address    = 0;
        cache_write_data = 0;
        cache_write_strb = 0;

        mem_read_data_valid_r  = 0;
        mem_write_resp_valid_r = 0;

        #20;
        rst = 0;
        @(negedge clk);

        //--------------------------------------------------
        // READ TEST
        //--------------------------------------------------
        cache_read_req = 1;
        cache_address  = 32'h100;

        // Wait for IC to output ARVALID to the bus
        wait(ic_master_read_addr_valid);
        @(posedge clk); 

        cache_read_req = 0; // <-- Moved up: Emulating true cache pulse behavior

        // Fake slave answers with valid data
        mem_read_data_valid_r = 1;

        // Wait for the IC to tell the cache it's done
        wait(cache_read_done);
        @(posedge clk); 

        // Deassert signals
        mem_read_data_valid_r = 0;

        $display("READ DONE @ %0t, data=%h", $time, cache_read_data);

        // Small delay between tests
        repeat(5) @(posedge clk);

        //--------------------------------------------------
        // WRITE TEST
        //--------------------------------------------------
        cache_write_req  = 1;
        cache_address    = 32'h200;
        cache_write_data = 32'hDEADBEEF;
        cache_write_strb = 4'b1111;

        // Wait for IC to output AWVALID and WVALID to the bus
        wait(ic_master_write_addr_valid && ic_master_write_data_valid);
        @(posedge clk); 

        cache_write_req = 0; // <-- Moved up: Emulating true cache pulse behavior

        // Fake slave answers with valid write response
        mem_write_resp_valid_r = 1;

        // Wait for the IC to tell the cache it's done
        wait(cache_write_done);
        @(posedge clk); 

        // Deassert signals
        mem_write_resp_valid_r = 0;

        $display("WRITE DONE @ %0t", $time);

        #20;
        $display("SIMULATION FINISHED CLEANLY");
        $finish;
    end

endmodule