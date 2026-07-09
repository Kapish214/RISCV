// module memory_controller(
//     input clk,
//     input rst,

//     // Interconnect Master Side (AXI-Lite Slave Interface)
//     input  [31:0] mem_read_addr,
//     input         mem_read_addr_valid,
//     output reg    mem_read_addr_ready,

//     output reg [31:0] mem_read_data,
//     output reg [1:0]  mem_read_resp,
//     output reg        mem_read_data_valid,
//     input             mem_read_data_ready,
    
//     input  [31:0] mem_write_addr,
//     input         mem_write_addr_valid,
//     output reg    mem_write_addr_ready,

//     input  [31:0] mem_write_data,
//     input  [3:0]  mem_write_strb,
//     input         mem_write_data_valid,
//     output reg    mem_write_data_ready,

//     output reg [1:0] mem_write_resp,
//     output reg       mem_write_resp_valid,
//     input            mem_write_resp_ready,
    
//     // Status
//     output       memory_busy
// );

// reg        MemRead;
// reg        MemWrite;
// reg [31:0] mem_address;
// reg [31:0] mem_write_value;

// wire [31:0] mem_read_value;

// data_memory data_mem_inst(
//     .clk(clk),
//     .address(mem_address), 
//     .write_data(mem_write_value),
//     .read_data(mem_read_value),
//     .MemRead(MemRead),
//     .MemWrite(MemWrite)
// );

// reg [31:0] req_address;
// reg [31:0] req_write_data;
// reg [3:0]  req_write_strb;
// reg [31:0] read_buffer;   // latches data_memory's output while it's still valid

// parameter IDLE       = 3'b000;
// parameter READ       = 3'b001;
// parameter READ_RESP  = 3'b010;
// parameter WRITE      = 3'b011;
// parameter WRITE_RESP = 3'b100;

// reg [2:0] state;
// reg [2:0] next_state;

// assign memory_busy = (state != IDLE);

// always @(posedge clk or posedge rst) begin
//     if(rst) begin
//         state          <= IDLE;
//         req_address    <= 32'b0;
//         req_write_data <= 32'b0;
//         req_write_strb <= 4'b0;
//         read_buffer    <= 32'b0;
//     end
//     else begin
//         state <= next_state;
//         if(state == IDLE) begin
//             if(mem_read_addr_valid) begin
//                 req_address <= mem_read_addr;
//         end
//             else if(mem_write_addr_valid &&
//          mem_write_data_valid) begin
//                 req_address    <= mem_write_addr;
//                 req_write_data <= mem_write_data;
//                 req_write_strb <= mem_write_strb;
//             end
//         end

//         // Capture data_memory's combinational output while it's still valid
//         // (MemRead is only asserted during the READ state; by READ_RESP it
//         // has fallen back to 0 and mem_read_value would revert to 0 too).
//         if (state == READ) begin
//             read_buffer <= mem_read_value;
//         end
//     end
// end

// always @(*) begin
//     next_state           = state;
    
//     mem_read_addr_ready  = 1'b0;
//     mem_read_data_valid  = 1'b0;
//     mem_read_data        = 32'b0;
//     mem_read_resp        = 2'b00;
    
//     mem_write_addr_ready = 1'b0;
//     mem_write_data_ready = 1'b0;
//     mem_write_resp_valid = 1'b0;
//     mem_write_resp       = 2'b00;

//     MemRead              = 1'b0;
//     MemWrite             = 1'b0;
//     mem_address          = req_address; 
//     mem_write_value      = req_write_data;



//     case(state)
//         IDLE:
//         begin
//             if(mem_read_addr_valid) begin
//                 mem_read_addr_ready = 1'b1;
//                 next_state = READ; 
//             end
//             else if(mem_write_addr_valid && mem_write_data_valid) begin
//                 mem_write_addr_ready = 1'b1;
//                 mem_write_data_ready = 1'b1;
//                 next_state = WRITE;
//             end
//         end

//         READ:
//         begin
//             MemRead = 1'b1;
//             next_state = READ_RESP;
//         end

//         READ_RESP:
//         begin
//             mem_read_data = read_buffer;
//             mem_read_data_valid = 1'b1;
//             mem_read_resp = 2'b00;
            
//             if(mem_read_data_ready) begin
//                 next_state = IDLE;
//             end
//         end

//         WRITE:
//         begin
//             MemWrite = 1'b1;
//             next_state = WRITE_RESP;
//         end

//         WRITE_RESP:
//         begin
//             mem_write_resp_valid = 1'b1;
//             mem_write_resp = 2'b00;
            
//             if(mem_write_resp_ready) begin
//                 next_state = IDLE;
//             end
//         end

//         default:
//         begin
//             next_state = IDLE;
//         end
//     endcase
// end

// always @(posedge clk) begin
//     $display("MC t=%0t state=%0d next=%0d ARVALID=%b ARREADY=%b",
//         $time,
//         state,
//         next_state,
//         mem_read_addr_valid,
//         mem_read_addr_ready
//     );
// end

// always @(posedge clk)
// begin
//     $display("MC: state=%0d next=%0d ARVALID=%b ARREADY=%b RVALID=%b RREADY=%b",
//         state,next_state,
//         mem_read_addr_valid,
//         mem_read_addr_ready,
//         mem_read_data_valid,
//         mem_read_data_ready);
// end

// endmodule

module memory_controller(
    input  wire        clk,
    input  wire        rst,

    // Interconnect Master Side (AXI-Lite Slave Interface)
    input  wire [31:0] mem_read_addr,
    input  wire        mem_read_addr_valid,
    output reg         mem_read_addr_ready,

    output reg  [31:0] mem_read_data,
    output reg  [1:0]  mem_read_resp,
    output reg         mem_read_data_valid,
    input  wire        mem_read_data_ready,
    
    input  wire [31:0] mem_write_addr,
    input  wire        mem_write_addr_valid,
    output reg         mem_write_addr_ready,

    input  wire [31:0] mem_write_data,
    input  wire [3:0]  mem_write_strb,
    input  wire        mem_write_data_valid,
    output reg         mem_write_data_ready,

    output reg  [1:0]  mem_write_resp,
    output reg         mem_write_resp_valid,
    input  wire        mem_write_resp_ready,
    
    // Status
    output wire        memory_busy
);

    //======================================================
    // INTERNAL SIGNALS
    //======================================================
    reg         MemRead;
    reg         MemWrite;
    reg  [31:0] mem_address;
    reg  [31:0] mem_write_value;
    wire [31:0] mem_read_value;

    reg  [31:0] req_address;
    reg  [31:0] req_write_data;
    reg  [3:0]  req_write_strb;
    reg  [31:0] read_buffer;   // latches data_memory's output while it's still valid

    //======================================================
    // STATE DEFINITIONS
    //======================================================
    parameter IDLE       = 3'b000;
    parameter READ       = 3'b001;
    parameter READ_RESP  = 3'b010;
    parameter WRITE      = 3'b011;
    parameter WRITE_RESP = 3'b100;

    reg [2:0] state;
    reg [2:0] next_state;

    assign memory_busy = (state != IDLE);

    //======================================================
    // MODULE INSTANTIATIONS
    //======================================================
    data_memory data_mem_inst(
        .clk(clk),
        .address(mem_address), 
        .write_data(mem_write_value),
        .read_data(mem_read_value),
        .MemRead(MemRead),
        .MemWrite(MemWrite)
    );

    //======================================================
    // SEQUENTIAL LOGIC (STATE & DATA LATCHING)
    //======================================================
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state          <= IDLE;
            req_address    <= 32'b0;
            req_write_data <= 32'b0;
            req_write_strb <= 4'b0;
            read_buffer    <= 32'b0;
        end
        else begin
            state <= next_state;
            
            if(state == IDLE) begin
                if(mem_read_addr_valid) begin
                    req_address <= mem_read_addr;
                end
                else if(mem_write_addr_valid && mem_write_data_valid) begin
                    req_address    <= mem_write_addr;
                    req_write_data <= mem_write_data;
                    req_write_strb <= mem_write_strb;
                end
            end

            // Explicit state-transition timing for capture
            if (state == READ && next_state == READ_RESP) begin
                read_buffer <= mem_read_value;
            end
        end
    end

    //======================================================
    // COMBINATIONAL LOGIC (NEXT STATE & OUTPUTS)
    //======================================================
    always @(*) begin

        // Defaults to prevent latches
        next_state           = state;
        
        mem_read_addr_ready  = 1'b0;
        mem_read_data_valid  = 1'b0;
        mem_read_data        = 32'b0;
        mem_read_resp        = 2'b00;
        
        mem_write_addr_ready = 1'b0;
        mem_write_data_ready = 1'b0;
        mem_write_resp_valid = 1'b0;
        mem_write_resp       = 2'b00;

        MemRead              = 1'b0;
        MemWrite             = 1'b0;
        mem_address          = req_address; 
        mem_write_value      = req_write_data;

        // FSM Logic
        case(state)
            IDLE: begin
                if(mem_read_addr_valid) begin
                    mem_read_addr_ready = 1'b1;
                    next_state = READ; 
                end
                else if(mem_write_addr_valid && mem_write_data_valid) begin
                    mem_write_addr_ready = 1'b1;
                    mem_write_data_ready = 1'b1;
                    next_state = WRITE;
                end
            end

            READ: begin
                MemRead = 1'b1;
                next_state = READ_RESP;
            end

            READ_RESP: begin
                mem_read_data = read_buffer;
                mem_read_data_valid = 1'b1;
                mem_read_resp = 2'b00;
                
                // Strict AXI handshake
                if(mem_read_data_ready && mem_read_data_valid) begin
                    next_state = IDLE;
                end
            end

            WRITE: begin
                MemWrite = 1'b1;
                next_state = WRITE_RESP;
            end

            WRITE_RESP: begin
                mem_write_resp_valid = 1'b1;
                mem_write_resp = 2'b00;
                
                // Strict AXI handshake
                if(mem_write_resp_ready && mem_write_resp_valid) begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    //======================================================
    // DEBUG MONITORING
    //======================================================


endmodule