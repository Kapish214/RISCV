// module interconnect_controller(

//     input clk,
//     input rst,

//     //=========================================
//     // CACHE CONTROLLER SIDE
//     //=========================================

//     input         cache_read_req,
//     input         cache_write_req,

//     input  [31:0] cache_address,
//     input  [31:0] cache_write_data,
//     input  [3:0]  cache_write_strb,

//     output reg [31:0] cache_read_data,
//     output reg        cache_read_done,
//     output reg        cache_write_done,
//     output reg        cache_busy,


//     //=========================================
//     // INTERCONNECT MASTER SIDE
//     //=========================================

//     output reg [31:0] master_read_addr,
//     output reg        master_read_addr_valid,
//     input             master_read_addr_ready,

//     input      [31:0] master_read_data,
//     input      [1:0]  master_read_resp,
//     input             master_read_data_valid,
//     output reg        master_read_data_ready,


//     output reg [31:0] master_write_addr,
//     output reg        master_write_addr_valid,
//     input             master_write_addr_ready,

//     output reg [31:0] master_write_data,
//     output reg [3:0]  master_write_strb,
//     output reg        master_write_data_valid,
//     input             master_write_data_ready,

//     input      [1:0]  master_write_resp,
//     input             master_write_resp_valid,
//     output reg        master_write_resp_ready

// );

// reg [2:0] state;
// reg [2:0] next_state;

// reg        req_is_read;
// reg        req_is_write;

// reg [31:0] req_address;
// reg [31:0] req_write_data;
// reg [3:0]  req_write_strb;

// parameter IDLE       = 3'b000;
// parameter READ_ADDR  = 3'b001;
// parameter READ_DATA  = 3'b010;
// parameter WRITE      = 3'b011;
// parameter WRITE_RESP = 3'b100;


// //======================================================
// // STATE REGISTER
// //======================================================

// // always @(posedge clk or posedge rst) begin

// //     if(rst)
// //         state <= IDLE;
// //     else
// //         state <= next_state;

// // end

// always @(posedge clk or posedge rst) begin
//     $display("STATE REG: t=%0t rst=%b state=%0d next=%0d",
//              $time, rst, state, next_state);

//     if (rst)
//         state <= IDLE;
//     else
//         state <= next_state;
// end

// //internal reg to make sure no inconsistencies,latch onto o/p
// always @(posedge clk or posedge rst) begin

//     if(rst) begin

//         req_is_read    <= 1'b0;
//         req_is_write   <= 1'b0;

//         req_address    <= 32'b0;
//         req_write_data <= 32'b0;
//         req_write_strb <= 4'b0;

//     end

//     else if(state == IDLE) begin

//         if(cache_read_req) begin

//             req_is_read    <= 1'b1;
//             req_is_write   <= 1'b0;

//             req_address    <= cache_address;

//         end

//         else if(cache_write_req) begin

//             req_is_read    <= 1'b0;
//             req_is_write   <= 1'b1;

//             req_address    <= cache_address;
//             req_write_data <= cache_write_data;
//             req_write_strb <= cache_write_strb;

//         end

//     end

// end

// //======================================================
// // NEXT STATE + OUTPUT LOGIC
// //======================================================




// // always @(*) begin

// //     //-------------------------------
// //     // Defaults
// //     //-------------------------------

// //     next_state = state;

// //     cache_busy       = (state != IDLE);

// //     cache_read_done  = 1'b0;
// //     cache_write_done = 1'b0;

// //     cache_read_data  = 32'b0;

// //     master_read_addr       = 32'b0;
// //     master_read_addr_valid = 1'b0;
// //     master_read_data_ready = 1'b0;

// //     master_write_addr       = 32'b0;
// //     master_write_addr_valid = 1'b0;
// //     master_write_data       = 32'b0;
// //     master_write_strb       = 4'b0;
// //     master_write_data_valid = 1'b0;
// //     master_write_resp_ready = 1'b0;

// //     //--------------------------------
// //     // FSM
// //     //--------------------------------

// //     case(state)

// //     //--------------------------------
// //     // IDLE
// //     //--------------------------------

// //     IDLE:
// //     begin

// //         if(cache_read_req)
// //             next_state = READ_ADDR;

// //         else if(cache_write_req)
// //             next_state = WRITE;

// //     end


// //     //--------------------------------
// //     // SEND READ ADDRESS
// //     //--------------------------------

// //     READ_ADDR:
// //     begin

       

// //         master_read_addr = req_address;
// //         master_read_addr_valid = 1'b1;

// //         if(master_read_addr_ready)
// //             next_state = READ_DATA;

// //     end



// //     //--------------------------------
// //     // WAIT FOR READ DATA
// //     //--------------------------------

// //     READ_DATA:
// //     begin

// //         master_read_data_ready = 1'b1;

// //         if(master_read_data_valid) begin

// //             if(master_read_resp == 2'b00) begin

// //                 cache_read_done = 1'b1;
// //                 cache_read_data = master_read_data;

// //             end

// //             next_state = IDLE;

// //         end

// //     end


// //     //--------------------------------
// //     // SEND WRITE
// //     //--------------------------------

// //     WRITE:
// //     begin

// //         master_write_addr = req_address;
// //         master_write_addr_valid = 1'b1;

// //         master_write_data = req_write_data;
// //         master_write_strb = req_write_strb;
// //         master_write_data_valid = 1'b1;

// //         if(master_write_addr_ready &&
// //            master_write_data_ready)

// //             next_state = WRITE_RESP;

// //     end


// //     //--------------------------------
// //     // WAIT FOR WRITE RESPONSE
// //     //--------------------------------

// //     WRITE_RESP:
// //     begin

// //         master_write_resp_ready = 1'b1;

// //         if(master_write_resp_valid) begin

// //             if(master_write_resp == 2'b00)
// //                 cache_write_done = 1'b1;

// //             next_state = IDLE;

// //         end

// //     end


// //     default:
// //     begin

// //         next_state = IDLE;

// //     end

// //     endcase

// // end

// always @(*) begin
//     next_state = state;

//     cache_busy = 0;
//     cache_read_done = 0;
//     cache_write_done = 0;
//     cache_read_data = 0;

//     master_read_addr = 0;
//     master_read_addr_valid = 0;
//     master_read_data_ready = 0;

//     master_write_addr = 0;
//     master_write_addr_valid = 0;
//     master_write_data = 0;
//     master_write_strb = 0;
//     master_write_data_valid = 0;
//     master_write_resp_ready = 0;
// end


// always @(posedge clk)
// begin
//     $display("IC: state=%0d next=%0d ARVALID=%b ARREADY=%b RVALID=%b RREADY=%b",
//         state,next_state,
//         master_read_addr_valid,
//         master_read_addr_ready,
//         master_read_data_valid,
//         master_read_data_ready);
// end

// endmodule

module interconnect_controller(
    input  wire        clk,
    input  wire        rst,

    //=========================================
    // CACHE CONTROLLER SIDE
    //=========================================
    input  wire        cache_read_req,
    input  wire        cache_write_req,
    input  wire [31:0] cache_address,
    input  wire [31:0] cache_write_data,
    input  wire [3:0]  cache_write_strb,

    output reg  [31:0] cache_read_data,
    output reg         cache_read_done,
    output reg         cache_write_done,
    output reg         cache_busy,

    //=========================================
    // INTERCONNECT MASTER SIDE
    //=========================================
    output reg  [31:0] master_read_addr,
    output reg         master_read_addr_valid,
    input  wire        master_read_addr_ready,

    input  wire [31:0] master_read_data,
    input  wire [1:0]  master_read_resp,
    input  wire        master_read_data_valid,
    output reg         master_read_data_ready,

    output reg  [31:0] master_write_addr,
    output reg         master_write_addr_valid,
    input  wire        master_write_addr_ready,

    output reg  [31:0] master_write_data,
    output reg  [3:0]  master_write_strb,
    output reg         master_write_data_valid,
    input  wire        master_write_data_ready,

    input  wire [1:0]  master_write_resp,
    input  wire        master_write_resp_valid,
    output reg         master_write_resp_ready
);

    //======================================================
    // STATE DEFINITIONS
    //======================================================
    parameter IDLE       = 3'b000;
    parameter READ_ADDR  = 3'b001;
    parameter READ_DATA  = 3'b010;
    parameter WRITE      = 3'b011;
    parameter WRITE_RESP = 3'b100;

    reg [2:0] state;
    reg [2:0] next_state;

    // Latched request parameters
    reg [31:0] req_address;
    reg [31:0] req_write_data;
    reg [3:0]  req_write_strb;

    //======================================================
    // STATE REGISTER
    //======================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
    end

end

    //======================================================
    // INPUT LATCHING
    //======================================================
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            req_address    <= 32'b0;
            req_write_data <= 32'b0;
            req_write_strb <= 4'b0;
        end
        else if(state == IDLE) begin
            if(cache_read_req) begin
                req_address    <= cache_address;
            end
            else if(cache_write_req) begin
                req_address    <= cache_address;
                req_write_data <= cache_write_data;
                req_write_strb <= cache_write_strb;
            end
        end
    end

    //======================================================
    // NEXT STATE + OUTPUT LOGIC (FSM)
    //======================================================
    always @(*) begin

        //-------------------------------
        // Defaults to prevent latches
        //-------------------------------
        next_state              = state;
        
        cache_busy              = (state != IDLE);
        cache_read_done         = 1'b0;
        cache_write_done        = 1'b0;
        cache_read_data         = 32'b0;

        master_read_addr        = 32'b0;
        master_read_addr_valid  = 1'b0;
        master_read_data_ready  = 1'b0;

        master_write_addr       = 32'b0;
        master_write_addr_valid = 1'b0;
        master_write_data       = 32'b0;
        master_write_strb       = 4'b0;
        master_write_data_valid = 1'b0;
        master_write_resp_ready = 1'b0;

        //--------------------------------
        // FSM Logic
        //--------------------------------
        case(state)
            IDLE: begin
                if(cache_read_req)
                    next_state = READ_ADDR;
                else if(cache_write_req)
                    next_state = WRITE;
            end

            READ_ADDR: begin
                master_read_addr = req_address;
                master_read_addr_valid = 1'b1;

                if(master_read_addr_ready)
                    next_state = READ_DATA;
            end

            READ_DATA: begin
                master_read_data_ready = 1'b1;

                if(master_read_data_valid) begin
                    if(master_read_resp == 2'b00) begin
                        cache_read_done = 1'b1;
                        cache_read_data = master_read_data;
                    end
                    next_state = IDLE;
                end
            end

            WRITE: begin
                master_write_addr = req_address;
                master_write_addr_valid = 1'b1;

                master_write_data = req_write_data;
                master_write_strb = req_write_strb;
                master_write_data_valid = 1'b1;

                if(master_write_addr_ready && master_write_data_ready)
                    next_state = WRITE_RESP;
            end

            WRITE_RESP: begin
                master_write_resp_ready = 1'b1;

                if(master_write_resp_valid) begin
                    if(master_write_resp == 2'b00)
                        cache_write_done = 1'b1;
                        
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