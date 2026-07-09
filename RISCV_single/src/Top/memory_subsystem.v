// module memory_subsystem(
//     input         clk,
//     input         rst,
    
//     // Core Processor Interface
//     input         MemRead,
//     input         MemWrite,
//     input  [31:0] address,
//     input  [31:0] write_data,
//     output [31:0] read_data,
//     output        stall
// );

//     //======================================================
//     // CACHE <-> INTERCONNECT CONTROLLER
//     //======================================================
//     wire        cache_read_req;
//     wire        cache_write_req;
//     wire [31:0] cache_req_addr;
//     wire [31:0] cache_req_data;
//     wire [3:0]  cache_req_strb;
    
//     wire [31:0] cache_resp_data;
//     wire        cache_read_done;
//     wire        cache_write_done;
//     wire        cache_resp_done;
    
//     // Debug/Status signals (Internal)
//     wire        cache_hit;
//     wire        hit_way0;
//     wire        hit_way1;
//     wire        cache_miss;
//     wire        cache_busy;

//     assign cache_resp_done = cache_read_done || cache_write_done;

//     //======================================================
//     // INTERCONNECT CONTROLLER <-> INTERCONNECT
//     //======================================================
//     wire [31:0] ic_master_read_addr;
//     wire        ic_master_read_addr_valid;
//     wire        ic_master_read_addr_ready;

//     wire [31:0] ic_master_read_data;
//     wire [1:0]  ic_master_read_resp;
//     wire        ic_master_read_data_valid;
//     wire        ic_master_read_data_ready;

//     wire [31:0] ic_master_write_addr;
//     wire        ic_master_write_addr_valid;
//     wire        ic_master_write_addr_ready;

//     wire [31:0] ic_master_write_data;
//     wire [3:0]  ic_master_write_strb;
//     wire        ic_master_write_data_valid;
//     wire        ic_master_write_data_ready;

//     wire [1:0]  ic_master_write_resp;
//     wire        ic_master_write_resp_valid;
//     wire        ic_master_write_resp_ready;

//     //======================================================
//     // INTERCONNECT <-> MEMORY CONTROLLER
//     //======================================================
//     wire [31:0] mem_slave_read_addr;
//     wire        mem_slave_read_addr_valid;
//     wire        mem_slave_read_addr_ready;

//     wire [31:0] mem_slave_read_data;
//     wire [1:0]  mem_slave_read_resp;
//     wire        mem_slave_read_data_valid;
//     wire        mem_slave_read_data_ready;

//     wire [31:0] mem_slave_write_addr;
//     wire        mem_slave_write_addr_valid;
//     wire        mem_slave_write_addr_ready;

//     wire [31:0] mem_slave_write_data;
//     wire [3:0]  mem_slave_write_strb;
//     wire        mem_slave_write_data_valid;
//     wire        mem_slave_write_data_ready;

//     wire [1:0]  mem_slave_write_resp;
//     wire        mem_slave_write_resp_valid;
//     wire        mem_slave_write_resp_ready;
    
//     wire        memory_busy;

//     // ==========================================
//     // MODULE INSTANTIATIONS
//     // ==========================================

//     cache_controller cache_inst(
//         .clk(clk),
//         .rst(rst),
//         .MemRead(MemRead),
//         .MemWrite(MemWrite),
//         .address(address),
//         .write_data(write_data),
//         .read_data(read_data),
        
//         .cache_hit(cache_hit),
//         .hit_way0(hit_way0),
//         .hit_way1(hit_way1),
//         .miss(cache_miss),
//         .cache_stall(stall),
        
//         .cache_read_req(cache_read_req),
//         .cache_write_req(cache_write_req),
//         .cache_req_addr(cache_req_addr),
//         .cache_req_data(cache_req_data),
//         .cache_req_strb(cache_req_strb),
        
//         .cache_resp_data(cache_resp_data),
//         .cache_resp_done(cache_resp_done),
//         .cache_busy(cache_busy)
//     );

//     interconnect_controller interconnect_ctrl_inst(
//         .clk(clk),
//         .rst(rst),
        
//         .cache_read_req(cache_read_req),
//         .cache_write_req(cache_write_req),
//         .cache_address(cache_req_addr),
//         .cache_write_data(cache_req_data),
//         .cache_write_strb(cache_req_strb),
        
//         .cache_read_data(cache_resp_data),
//         .cache_read_done(cache_read_done), 
//         .cache_write_done(cache_write_done), 
//         .cache_busy(cache_busy),
        
//         .master_read_addr(ic_master_read_addr),
//         .master_read_addr_valid(ic_master_read_addr_valid),
//         .master_read_addr_ready(ic_master_read_addr_ready),
        
//         .master_read_data(ic_master_read_data),
//         .master_read_resp(ic_master_read_resp),
//         .master_read_data_valid(ic_master_read_data_valid),
//         .master_read_data_ready(ic_master_read_data_ready),
        
//         .master_write_addr(ic_master_write_addr),
//         .master_write_addr_valid(ic_master_write_addr_valid),
//         .master_write_addr_ready(ic_master_write_addr_ready),
        
//         .master_write_data(ic_master_write_data),
//         .master_write_strb(ic_master_write_strb),
//         .master_write_data_valid(ic_master_write_data_valid),
//         .master_write_data_ready(ic_master_write_data_ready),
        
//         .master_write_resp(ic_master_write_resp),
//         .master_write_resp_valid(ic_master_write_resp_valid),
//         .master_write_resp_ready(ic_master_write_resp_ready)
//     );

//     axi_interconnect axi_interconnect_inst(
//         // Master Inputs (from interconnect_controller)
//         .master_read_addr(ic_master_read_addr),
//         .master_read_addr_valid(ic_master_read_addr_valid),
//         .master_read_addr_ready(ic_master_read_addr_ready),
        
//         .master_read_data(ic_master_read_data),
//         .master_read_resp(ic_master_read_resp),
//         .master_read_data_valid(ic_master_read_data_valid),
//         .master_read_data_ready(ic_master_read_data_ready),
        
//         .master_write_addr(ic_master_write_addr),
//         .master_write_addr_valid(ic_master_write_addr_valid),
//         .master_write_addr_ready(ic_master_write_addr_ready),
        
//         .master_write_data(ic_master_write_data),
//         .master_write_strb(ic_master_write_strb),
//         .master_write_data_valid(ic_master_write_data_valid),
//         .master_write_data_ready(ic_master_write_data_ready),
        
//         .master_write_resp(ic_master_write_resp),
//         .master_write_resp_valid(ic_master_write_resp_valid),
//         .master_write_resp_ready(ic_master_write_resp_ready),
        
//         // Slave 0 Outputs (to memory_controller)
//         .mem_read_addr(mem_slave_read_addr),
//         .mem_read_addr_valid(mem_slave_read_addr_valid),
//         .mem_read_addr_ready(mem_slave_read_addr_ready),
        
//         .mem_read_data(mem_slave_read_data),
//         .mem_read_resp(mem_slave_read_resp),
//         .mem_read_data_valid(mem_slave_read_data_valid),
//         .mem_read_data_ready(mem_slave_read_data_ready),
        
//         .mem_write_addr(mem_slave_write_addr),
//         .mem_write_addr_valid(mem_slave_write_addr_valid),
//         .mem_write_addr_ready(mem_slave_write_addr_ready),
        
//         .mem_write_data(mem_slave_write_data),
//         .mem_write_strb(mem_slave_write_strb),
//         .mem_write_data_valid(mem_slave_write_data_valid),
//         .mem_write_data_ready(mem_slave_write_data_ready),
        
//         .mem_write_resp(mem_slave_write_resp),
//         .mem_write_resp_valid(mem_slave_write_resp_valid),
//         .mem_write_resp_ready(mem_slave_write_resp_ready)
//     );

//     memory_controller memory_ctrl_inst(
//         .clk(clk),
//         .rst(rst),
        
//         .mem_read_addr(mem_slave_read_addr),
//         .mem_read_addr_valid(mem_slave_read_addr_valid),
//         .mem_read_addr_ready(mem_slave_read_addr_ready),
        
//         .mem_read_data(mem_slave_read_data),
//         .mem_read_resp(mem_slave_read_resp),
//         .mem_read_data_valid(mem_slave_read_data_valid),
//         .mem_read_data_ready(mem_slave_read_data_ready),
        
//         .mem_write_addr(mem_slave_write_addr),
//         .mem_write_addr_valid(mem_slave_write_addr_valid),
//         .mem_write_addr_ready(mem_slave_write_addr_ready),
        
//         .mem_write_data(mem_slave_write_data),
//         .mem_write_strb(mem_slave_write_strb),
//         .mem_write_data_valid(mem_slave_write_data_valid),
//         .mem_write_data_ready(mem_slave_write_data_ready),
        
//         .mem_write_resp(mem_slave_write_resp),
//         .mem_write_resp_valid(mem_slave_write_resp_valid),
//         .mem_write_resp_ready(mem_slave_write_resp_ready),
        
//         .memory_busy(memory_busy)
//     );

// endmodule

module memory_subsystem(
    input  wire        clk,
    input  wire        rst,
    
    // Core Processor Interface
    input  wire        MemRead,
    input  wire        MemWrite,
    input  wire [31:0] address,
    input  wire [31:0] write_data,
    output wire [31:0] read_data,
    output wire        stall
);

    //======================================================
    // CACHE <-> INTERCONNECT CONTROLLER
    //======================================================
    wire        cache_read_req;
    wire        cache_write_req;
    wire [31:0] cache_req_addr;
    wire [31:0] cache_req_data;
    wire [3:0]  cache_req_strb;
    
    wire [31:0] cache_resp_data;
    wire        cache_read_done;
    wire        cache_write_done;
    wire        cache_resp_done;
    
    // Debug/Status signals (Internal)
    wire        cache_hit;
    wire        hit_way0;
    wire        hit_way1;
    wire        cache_miss;
    wire        cache_busy_ic; 

    assign cache_resp_done = cache_read_done || cache_write_done;

    //======================================================
    // INTERCONNECT CONTROLLER <-> INTERCONNECT
    //======================================================
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

    //======================================================
    // INTERCONNECT <-> MEMORY CONTROLLER
    //======================================================
    wire [31:0] mem_slave_read_addr;
    wire        mem_slave_read_addr_valid;
    wire        mem_slave_read_addr_ready;

    wire [31:0] mem_slave_read_data;
    wire [1:0]  mem_slave_read_resp;
    wire        mem_slave_read_data_valid;
    wire        mem_slave_read_data_ready;

    wire [31:0] mem_slave_write_addr;
    wire        mem_slave_write_addr_valid;
    wire        mem_slave_write_addr_ready;

    wire [31:0] mem_slave_write_data;
    wire [3:0]  mem_slave_write_strb;
    wire        mem_slave_write_data_valid;
    wire        mem_slave_write_data_ready;

    wire [1:0]  mem_slave_write_resp;
    wire        mem_slave_write_resp_valid; // Fixed to match naming convention
    wire        mem_slave_write_resp_ready;
    
    wire        memory_busy;

    // ==========================================
    // MODULE INSTANTIATIONS
    // ==========================================

    cache_controller cache_inst(
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
        .miss(cache_miss),
        .cache_stall(stall),
        
        .cache_read_req(cache_read_req),
        .cache_write_req(cache_write_req),
        .cache_req_addr(cache_req_addr),
        .cache_req_data(cache_req_data),
        .cache_req_strb(cache_req_strb),
        
        .cache_resp_data(cache_resp_data),
        .cache_resp_done(cache_resp_done)
    );

    interconnect_controller interconnect_ctrl_inst(
        .clk(clk),
        .rst(rst),
        
        .cache_read_req(cache_read_req),
        .cache_write_req(cache_write_req),
        .cache_address(cache_req_addr),
        .cache_write_data(cache_req_data),
        .cache_write_strb(cache_req_strb),
        
        .cache_read_data(cache_resp_data),
        .cache_read_done(cache_read_done), 
        .cache_write_done(cache_write_done), 
        .cache_busy(cache_busy_ic), 
        
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

    // Fixed module name
    axi_interconnect axi_interconnect_inst(
        .clk(clk),
        .rst(rst),
        // Master Inputs (from interconnect_controller)
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
        .master_write_resp_ready(ic_master_write_resp_ready),
        
        // Slave 0 Outputs (to memory_controller)
        .mem_read_addr(mem_slave_read_addr),
        .mem_read_addr_valid(mem_slave_read_addr_valid),
        .mem_read_addr_ready(mem_slave_read_addr_ready),
        
        .mem_read_data(mem_slave_read_data),
        .mem_read_resp(mem_slave_read_resp),
        .mem_read_data_valid(mem_slave_read_data_valid),
        .mem_read_data_ready(mem_slave_read_data_ready),
        
        .mem_write_addr(mem_slave_write_addr),
        .mem_write_addr_valid(mem_slave_write_addr_valid),
        .mem_write_addr_ready(mem_slave_write_addr_ready),
        
        .mem_write_data(mem_slave_write_data),
        .mem_write_strb(mem_slave_write_strb),
        .mem_write_data_valid(mem_slave_write_data_valid),
        .mem_write_data_ready(mem_slave_write_data_ready),
        
        .mem_write_resp(mem_slave_write_resp),
        .mem_write_resp_valid(mem_slave_write_resp_valid), // Fixed connection
        .mem_write_resp_ready(mem_slave_write_resp_ready)
    );

    memory_controller memory_ctrl_inst(
        .clk(clk),
        .rst(rst),
        
        .mem_read_addr(mem_slave_read_addr),
        .mem_read_addr_valid(mem_slave_read_addr_valid),
        .mem_read_addr_ready(mem_slave_read_addr_ready),
        
        .mem_read_data(mem_slave_read_data),
        .mem_read_resp(mem_slave_read_resp),
        .mem_read_data_valid(mem_slave_read_data_valid),
        .mem_read_data_ready(mem_slave_read_data_ready),
        
        .mem_write_addr(mem_slave_write_addr),
        .mem_write_addr_valid(mem_slave_write_addr_valid),
        .mem_write_addr_ready(mem_slave_write_addr_ready),
        
        .mem_write_data(mem_slave_write_data),
        .mem_write_strb(mem_slave_write_strb),
        .mem_write_data_valid(mem_slave_write_data_valid),
        .mem_write_data_ready(mem_slave_write_data_ready),
        
        .mem_write_resp(mem_slave_write_resp),
        .mem_write_resp_valid(mem_slave_write_resp_valid), // Fixed connection
        .mem_write_resp_ready(mem_slave_write_resp_ready),
        
        .memory_busy(memory_busy)
    );



endmodule