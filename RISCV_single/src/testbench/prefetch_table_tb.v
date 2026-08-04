// `timescale 1ns/1ps

// module prefetch_table_tb;

// reg clk;
// reg rst;

// reg access_valid;
// reg observe_enable;
// reg [31:0] pc;
// reg [31:0] memory_address;

// reg prefetch_accept;

// wire prefetch_valid;
// wire [31:0] prefetch_address;

// //--------------------------------------------------
// // DUT
// //--------------------------------------------------

// prefetch_table dut(
//     .clk(clk),
//     .rst(rst),

//     .access_valid(access_valid),
//     .observe_enable(observe_enable),

//     .pc(pc),
//     .memory_address(memory_address),

//     .prefetch_accept(prefetch_accept),

//     .prefetch_valid(prefetch_valid),
//     .prefetch_address(prefetch_address)
// );

// //--------------------------------------------------
// // Clock
// //--------------------------------------------------

// initial clk = 0;
// always #5 clk = ~clk;

// //--------------------------------------------------
// // Access Task
// //--------------------------------------------------

// task automatic access;

// input [31:0] addr;

// begin

//     // Drive BEFORE the active edge
//     @(negedge clk);

//     memory_address = addr;
//     access_valid   = 1;
//     observe_enable = 1;

//     // Sampled here
//     @(posedge clk);

//     // Remove request
//     @(negedge clk);

//     access_valid   = 0;
//     observe_enable = 0;

// end

// endtask

// //--------------------------------------------------
// // Accept Task
// //--------------------------------------------------

// task automatic accept_prefetch;

// begin

//     @(negedge clk);

//     prefetch_accept = 1;

//     @(posedge clk);

//     @(negedge clk);

//     prefetch_accept = 0;

// end

// endtask

// //--------------------------------------------------
// // Stimulus
// //--------------------------------------------------

// initial begin

//     rst = 1;

//     access_valid = 0;
//     observe_enable = 0;

//     prefetch_accept = 0;

//     pc = 32'h00000100;

//     memory_address = 0;

//     repeat(3) @(posedge clk);

//     rst = 0;

//     $display("\n===============================");
//     $display(" Constant +4 Stride Test");
//     $display("===============================\n");

//     access(100);
//     access(104);
//     access(108);
//     access(112);
//     access(116);

//     repeat(2) @(posedge clk);

//     accept_prefetch();

//     repeat(2) @(posedge clk);

//     accept_prefetch();

//     repeat(2) @(posedge clk);

//     access(120);

//     repeat(10) @(posedge clk);

//     $finish;

// end

// //--------------------------------------------------
// // Monitor
// //--------------------------------------------------

// always @(negedge clk) begin

//     $display("\n------------------------------------------------");

//     $display("TIME              : %0t",$time);

//     $display("Input Address     : %0d",memory_address);

//     $display("Index             : %0d",dut.index);

//     $display("Valid             : %0d",
//         dut.prefetch_table[dut.index][79]);

//     $display("Stored PC         : %0h",
//         dut.prefetch_table[dut.index][78:47]);

//     $display("Stored Address    : %0d",
//         dut.prefetch_table[dut.index][46:15]);

//     $display("Addr Diff         : %0d",
//         dut.addr_diff);

//     $display("New Stride        : %0d",
//         dut.new_stride);

//     $display("Stored Stride     : %0d",
//         $signed(dut.prefetch_table[dut.index][14:3]));

//     $display("Stride Match      : %0b",
//         dut.stride_match);

//     $display("Confidence        : %0d",
//         dut.prefetch_table[dut.index][2:1]);

//     $display("Pending Count     : %0d",
//         dut.pending_count);

//     $display("Pending Addr1     : %0d",
//         dut.pending_addr1);

//     $display("Pending Addr2     : %0d",
//         dut.pending_addr2);

//     $display("Prefetch Valid    : %0b",
//         prefetch_valid);

//     $display("Prefetch Address  : %0d",
//         prefetch_address);

// end

// //--------------------------------------------------
// // VCD
// //--------------------------------------------------

// initial begin
//     $dumpfile("prefetch_table.vcd");
//     $dumpvars(0,prefetch_table_tb);
// end

// endmodule
`timescale 1ns/1ps

module prefetch_table_tb;

reg clk;
reg rst;

reg [31:0] pc;
reg [31:0] memory_address;

reg observe_enable;
reg access_valid;
reg prefetch_accept;

wire prefetch_valid;
wire [31:0] prefetch_address;

prefetch_table dut(
    .clk(clk),
    .rst(rst),
    .pc(pc),
    .memory_address(memory_address),
    .observe_enable(observe_enable),
    .access_valid(access_valid),
    .prefetch_accept(prefetch_accept),
    .prefetch_valid(prefetch_valid),
    .prefetch_address(prefetch_address)
);

//-----------------------------------------
// Clock
//-----------------------------------------

initial clk = 0;
always #5 clk = ~clk;

//-----------------------------------------
// Tasks
//-----------------------------------------

task access;
input [31:0] pc_in;
input [31:0] addr;
begin
    @(negedge clk);
    pc             = pc_in;
    memory_address = addr;
    observe_enable = 1;
    access_valid   = 1;

    @(posedge clk);
    @(negedge clk);

    observe_enable = 0;
    access_valid   = 0;
end
endtask

task accept_prefetch;
begin
    @(negedge clk);
    prefetch_accept = 1;

    @(posedge clk);
    @(negedge clk);

    prefetch_accept = 0;
end
endtask

//-----------------------------------------
// Stimulus
//-----------------------------------------

initial begin
    rst = 1;

    pc = 0;
    memory_address = 0;
    observe_enable = 0;
    access_valid = 0;
    prefetch_accept = 0;

    repeat(3) @(posedge clk);

    rst = 0;

    $display("\n==========================================");
    $display("Stride Prefetcher Queue Shift Test");
    $display("==========================================");

    access(32'h08, 100);
    access(32'h08, 104);
    access(32'h08, 108);
    access(32'h08, 112);
    
    // Expecting 116 and 120 in the queue here
    accept_prefetch();
    
    // Expecting 116 to pop, queue holds 120
    access(32'h08, 116);
    
    // Expecting generation of 124, queue holds 120 and 124
    accept_prefetch();
    
    // Expecting 120 to pop, queue holds 124
    access(32'h08, 120);

    repeat(5) @(posedge clk);

    $finish;
end

//-----------------------------------------
// Monitor
//-----------------------------------------

// Monitor accesses
always @(posedge clk) begin
    #1
    if(access_valid) begin
        $display("\n[ACCESS] --------------------------------");
        $display("TIME              : %0t", $time);
        $display("PC                : %h", pc);
        $display("Memory Address    : %0d", memory_address);
        $display("Index             : %0d", dut.index);
        $display("Valid             : %0b", dut.prefetch_table[dut.index][79]);
        $display("Stored PC         : %h", dut.prefetch_table[dut.index][78:47]);
        $display("Stored Address    : %0d", dut.prefetch_table[dut.index][46:15]);
        $display("Addr Diff         : %0d", dut.addr_diff);
        $display("New Stride        : %0d", dut.new_stride);
        $display("Stored Stride     : %0d", $signed(dut.prefetch_table[dut.index][14:3]));
        $display("Stride Match      : %0b", dut.stride_match);
        $display("Confidence        : %0d", dut.prefetch_table[dut.index][2:1]);
        $display("Next Prediction   : %0d", dut.next_pred);
        $display("Pending Count     : %0d", dut.pending_count);
        $display("Pending Addr1     : %0d", dut.pending_addr1);
        $display("Pending Addr2     : %0d", dut.pending_addr2);
        $display("Prefetch Valid    : %0b", prefetch_valid);
        $display("Prefetch Address  : %0d", prefetch_address);
    end
end

// Monitor Accepts separately so you can see the queue shift
always @(posedge clk) begin
    #1
    if(prefetch_accept) begin
        $display("\n[ACCEPT] --------------------------------");
        $display("TIME              : %0t", $time);
        $display("Action            : Cache Accepted Prefetch");
        $display("Pending Count     : %0d", dut.pending_count);
        $display("Pending Addr1     : %0d", dut.pending_addr1);
        $display("Pending Addr2     : %0d", dut.pending_addr2);
        $display("Outputting        : %0d", prefetch_address);
    end
end

//-----------------------------------------
// Waveform
//-----------------------------------------

initial begin
    $dumpfile("prefetch_table.vcd");
    $dumpvars(0, prefetch_table_tb);
end

endmodule