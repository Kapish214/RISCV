// module cache_controller(

//     input clk,
//     input rst,

//     input MemRead,
//     input MemWrite,

//     input [31:0] address,
//     input [31:0] write_data,

//     output reg [31:0] read_data,
//     output cache_hit,

//     output hit_way0,
//     output hit_way1,
//     output miss,
//     output cache_stall,

//     output reg cache_read_req,
//     output reg cache_write_req,
    
//     output reg [31:0] cache_req_addr,
//     output reg [31:0] cache_req_data,
//     output reg [3:0]  cache_req_strb,
    
//     input [31:0] cache_resp_data,
//     input        cache_resp_done,
//     input        cache_busy

// );

// assign cache_stall =
//     (state != IDLE) ||
//     (state == IDLE && miss && (MemRead || MemWrite));

// reg [1:0] state;
// reg [1:0] next_state;

// reg [31:0] pending_address;
// reg [31:0] pending_write_data;

// reg pending_memread;
// reg pending_memwrite;

// parameter IDLE       = 2'b00;
// parameter WRITE_BACK = 2'b01;
// parameter ALLOCATE   = 2'b10;
// parameter FILL       = 2'b11;

// always @(posedge clk or posedge rst)
// begin
//     if(rst)
//         state <= IDLE;
//     else
//         state <= next_state;
// end

// always @(posedge clk or posedge rst)
// begin
//     if(rst)
//     begin
//         pending_address    <= 0;
//         pending_write_data <= 0;
//         pending_memread    <= 0;
//         pending_memwrite   <= 0;
//     end
//     else if(state == FILL)
//     begin
//         pending_memread    <= 0;
//         pending_memwrite   <= 0;
//     end
//     else if(state == IDLE &&
//             miss &&
//             (MemRead || MemWrite))
//     begin
//         pending_address    <= address;
//         pending_write_data <= write_data;
//         pending_memread    <= MemRead;
//         pending_memwrite   <= MemWrite;
//     end
// end

// always @(*)
// begin
//     next_state = state;

//     case(state)
//         IDLE:
//         begin
//             if(miss && (MemRead || MemWrite))
//             begin
//                 if(dirty_evict_way0 || dirty_evict_way1)
//                     next_state = WRITE_BACK;
//                 else
//                     next_state = ALLOCATE;
//             end
//         end
//         WRITE_BACK:
//         begin
//             // CPU
//             //  |
//             //  v
//             // Cache issues WRITE request
//             //  |
//             //  v
//             // Interconnect Controller handles transaction
//             //  |
//             //  v
//             // cache_resp_done
            
//             if(cache_resp_done)
//                 next_state = ALLOCATE;
//         end
//         ALLOCATE:
//         begin
//             // CPU
//             //  |
//             //  v
//             // Cache issues READ request
//             //  |
//             //  v
//             // Interconnect Controller handles transaction
//             //  |
//             //  v
//             // cache_resp_done
            
//             if(cache_resp_done)
//                 next_state = FILL;
//         end
//         FILL:
//         begin
//             next_state = IDLE;
//         end
//         default:
//         begin
//             next_state = IDLE;
//         end
//     endcase
// end

// wire fill_cache;
// assign fill_cache = (state == FILL);

// wire [7:0] index;
// wire [21:0] tag;
// wire [1:0] offset;

// wire [55:0] way0_line;
// wire [55:0] way1_line;

// assign tag    = address[31:10];
// assign index  = address[9:2];
// assign offset = address[1:0];

// wire [21:0] active_tag;
// wire [7:0] active_index;

// assign active_tag =
//     (state == IDLE) ?
//     address[31:10] :
//     pending_address[31:10];

// assign active_index =
//     (state == IDLE) ?
//     address[9:2] :
//     pending_address[9:2];

// wire write_way0;
// wire write_way1;

// wire [55:0] way0_new_line;
// wire [55:0] way1_new_line;

// wire lru_write;
// wire lru_new_value;
// wire lru_value;

// wire valid0;
// wire dirty0;
// wire [21:0] tag0;
// wire [31:0] data0;

// wire valid1;
// wire dirty1;
// wire [21:0] tag1;
// wire [31:0] data1;

// assign valid0 = way0_line[55];
// assign dirty0 = way0_line[54];
// assign tag0   = way0_line[53:32];
// assign data0  = way0_line[31:0];

// assign valid1 = way1_line[55];
// assign dirty1 = way1_line[54];
// assign tag1   = way1_line[53:32];
// assign data1  = way1_line[31:0];

// assign hit_way0 = valid0 && (tag0 == active_tag);
// assign hit_way1 = valid1 && (tag1 == active_tag);

// assign cache_hit = hit_way0 || hit_way1;

// assign miss = (MemRead || MemWrite) && ~cache_hit;

// data_cache data_cache_inst(
//     .clk(clk),
//     .rst(rst),
//     .index(active_index), 
//     .write_way0(write_way0),
//     .write_way1(write_way1),
//     .way0_new_line(way0_new_line),
//     .way1_new_line(way1_new_line),
//     .way0_line(way0_line),
//     .way1_line(way1_line)
// );

// lru_memory lru_memory_inst(
//     .clk(clk),
//     .rst(rst),
//     .index(active_index), 
//     .lru_write(lru_write),
//     .lru_new_value(lru_new_value),
//     .lru_value(lru_value)
// );

// wire way0_invalid;
// wire way1_invalid;

// assign way0_invalid = ~valid0;
// assign way1_invalid = ~valid1;

// wire replace_way0;
// wire replace_way1;

// assign replace_way0 =
//     way0_invalid ||
//     (~way1_invalid && (lru_value == 1'b0));

// assign replace_way1 =
//     (~way0_invalid && way1_invalid) ||
//     (~way0_invalid && ~way1_invalid && (lru_value == 1'b1));

// wire [55:0] fill_line;

// assign fill_line =
//     pending_memwrite ?
//     {
//         1'b1,               
//         1'b1,               
//         active_tag,
//         pending_write_data  
//     }
//     :
//     {
//         1'b1,               
//         1'b0,               
//         active_tag,
//         cache_resp_data       
//     };

// assign write_way0 = write_hit_way0 || (fill_cache && replace_way0); 
// assign write_way1 = write_hit_way1 || (fill_cache && replace_way1);

// assign way0_new_line =
//     write_hit_way0 ? write_hit_line0 :               
//     (fill_cache && replace_way0) ? fill_line :       
//     56'b0; 

// assign way1_new_line =
//     write_hit_way1 ? write_hit_line1 :
//     (fill_cache && replace_way1) ? fill_line :
//     56'b0;

// assign lru_write = write_hit || fill_cache; 

// assign lru_new_value =
//     (replace_way0 || write_hit_way0) ? 1'b1 :
//     (replace_way1 || write_hit_way1) ? 1'b0 :
//     lru_value;




// always @(*)
// begin

//     cache_read_req = 0;
//     cache_write_req = 0;
//     cache_req_addr = 0;
//     cache_req_data = 0;
//     cache_req_strb = 4'b0000;

//     case(state)
//         WRITE_BACK:
//         begin
//             cache_write_req = 1;
//             cache_req_strb = 4'b1111;

//             if(dirty_evict_way0)
//             begin
//                 cache_req_addr = evict_addr_way0;
//                 cache_req_data = data0;
//             end
//             else
//             begin
//                 cache_req_addr = evict_addr_way1;
//                 cache_req_data = data1;
//             end
//         end
//         ALLOCATE:
//         begin
//             cache_read_req = 1;
//             cache_req_addr = pending_address;
//         end
//     endcase
// end
 
// always @(*) begin
//     if(hit_way0)
//         read_data = data0;
//     else if(hit_way1)
//         read_data = data1;
//     else
//         read_data = 32'b0; 
// end

// wire write_hit_way0;
// wire write_hit_way1;

// assign write_hit_way0 = MemWrite && hit_way0;
// assign write_hit_way1 = MemWrite && hit_way1;

// wire write_hit;
// assign write_hit = write_hit_way0 || write_hit_way1;

// wire [55:0] write_hit_line0;
// wire [55:0] write_hit_line1;

// assign write_hit_line0 = {1'b1, 1'b1, tag0, write_data};
// assign write_hit_line1 = {1'b1, 1'b1, tag1, write_data};

// wire write_miss;
// assign write_miss = MemWrite && miss;

// assign dirty_evict_way0 =
//     replace_way0 &&
//     valid0 &&
//     dirty0 &&
//     (pending_memread || pending_memwrite);

// assign dirty_evict_way1 =
//     replace_way1 &&
//     valid1 &&
//     dirty1 &&
//     (pending_memread || pending_memwrite);

// wire [31:0] evict_addr_way0;
// wire [31:0] evict_addr_way1;

// assign evict_addr_way0 = {tag0, active_index, 2'b00};
// assign evict_addr_way1 = {tag1, active_index, 2'b00};


// endmodule

module cache_controller(
    input  wire        clk,
    input  wire        rst,

    input  wire        MemRead,
    input  wire        MemWrite,

    input  wire [31:0] address,
    input  wire [31:0] write_data,

    output reg  [31:0] read_data,
    output wire        cache_hit,

    output wire        hit_way0,
    output wire        hit_way1,
    output wire        miss,
    output wire        cache_stall,

    output reg         cache_read_req,
    output reg         cache_write_req,
    
    output reg  [31:0] cache_req_addr,
    output reg  [31:0] cache_req_data,
    output reg  [3:0]  cache_req_strb,
    
    input  wire [31:0] cache_resp_data,
    input  wire        cache_resp_done
);

    // --- State Definitions ---
    parameter IDLE       = 2'b00;
    parameter WRITE_BACK = 2'b01;
    parameter ALLOCATE   = 2'b10;
    parameter FILL       = 2'b11;

    reg [1:0] state;
    reg [1:0] next_state;

    // --- Pending Requests ---
    reg [31:0] pending_address;
    reg [31:0] pending_write_data;
    reg        pending_memread;
    reg        pending_memwrite;
    reg [31:0] cache_resp_data_reg;

    // --- Forward Declarations for FSM ---
    wire dirty_evict_way0;
    wire dirty_evict_way1;
    wire [31:0] evict_addr_way0;
    wire [31:0] evict_addr_way1;

    // --- Miss & Stall Logic ---
    wire request_active;

    assign request_active = 
        (state == IDLE) ? 
            (MemRead || MemWrite) : 
            (pending_memread || pending_memwrite);

    assign miss = request_active && !cache_hit;

    assign cache_stall = (state != IDLE) || miss;

    // --- Sequential Logic ---
    always @(posedge clk or posedge rst) begin
        if(rst)
            state <= IDLE;
        else
            state <= next_state;
    end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        pending_address    <= 0;
        pending_write_data <= 0;
        pending_memread    <= 0;
        pending_memwrite   <= 0;
        cache_resp_data_reg <= 32'b0;
    end
    else begin

        // Capture memory response immediately
        if(cache_resp_done)
            cache_resp_data_reg <= cache_resp_data;

        if(state == FILL) begin
            pending_memread    <= 0;
            pending_memwrite   <= 0;
        end
        else if(state == IDLE && miss && (MemRead || MemWrite)) begin
            pending_address    <= address;
            pending_write_data <= write_data;
            pending_memread    <= MemRead;
            pending_memwrite   <= MemWrite;
        end
    end
end

    // --- Next State Logic ---
    always @(*) begin
        next_state = state;
        // $display("[CACHE next_state eval] t=%0t state=%0d miss=%b cache_resp_done=%b pending_memread=%b pending_memwrite=%b",
        //     $time, state, miss, cache_resp_done, pending_memread, pending_memwrite);

        case(state)
            IDLE: begin
                if(miss && (MemRead || MemWrite)) begin
                    if(dirty_evict_way0 || dirty_evict_way1)
                        next_state = WRITE_BACK;
                    else
                        next_state = ALLOCATE;
                end
            end
            WRITE_BACK: begin
                if(cache_resp_done)
                    next_state = ALLOCATE;
            end
            ALLOCATE: begin
                if(cache_resp_done)
                    next_state = FILL; 
            end
            FILL: begin
                next_state = IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // --- Cache Line & Tag/Index Logic (Updated for Robustness) ---
    wire fill_cache;
    assign fill_cache = (state == FILL);

    wire [21:0] compare_tag;
    wire [7:0]  compare_index;

    assign compare_tag = 
        (pending_memread || pending_memwrite) ? 
            pending_address[31:10] : 
            address[31:10];

    assign compare_index = 
        (pending_memread || pending_memwrite) ? 
            pending_address[9:2] : 
            address[9:2];

    wire [55:0] way0_line;
    wire [55:0] way1_line;
    
    wire write_way0;
    wire write_way1;

    wire [55:0] way0_new_line;
    wire [55:0] way1_new_line;

    wire valid0, dirty0;
    wire [21:0] tag0;
    wire [31:0] data0;

    wire valid1, dirty1;
    wire [21:0] tag1;
    wire [31:0] data1;

    assign valid0 = way0_line[55];
    assign dirty0 = way0_line[54];
    assign tag0   = way0_line[53:32];
    assign data0  = way0_line[31:0];

    assign valid1 = way1_line[55];
    assign dirty1 = way1_line[54];
    assign tag1   = way1_line[53:32];
    assign data1  = way1_line[31:0];

    // --- Hit Logic ---
    assign hit_way0 = valid0 && (tag0 == compare_tag);
    assign hit_way1 = valid1 && (tag1 == compare_tag);
    assign cache_hit = hit_way0 || hit_way1;

    always @(*) begin
        if(hit_way0)
            read_data = data0;
        else if(hit_way1)
            read_data = data1;
        else
            read_data = 32'b0; 
    end

    wire write_hit_way0;
    wire write_hit_way1;

    assign write_hit_way0 = MemWrite && hit_way0;
    assign write_hit_way1 = MemWrite && hit_way1;

    wire write_hit;
    assign write_hit = write_hit_way0 || write_hit_way1;

    // --- Line Updates (Updated for Clarity) ---
    wire [55:0] write_hit_line0;
    wire [55:0] write_hit_line1;

    assign write_hit_line0 = {1'b1, 1'b1, tag0, write_data};
    assign write_hit_line1 = {1'b1, 1'b1, tag1, write_data};

    wire [55:0] fill_line;

    assign fill_line =
        pending_memwrite ?
        {
            1'b1,
            1'b1,
            pending_address[31:10],
            pending_write_data
        }
        :
        {
            1'b1,
            1'b0,
            pending_address[31:10],
            cache_resp_data_reg
        };

    // --- Replacement Logic (LRU) ---
    wire lru_write;
    wire lru_new_value;
    wire lru_value;

    wire way0_invalid;
    wire way1_invalid;

    assign way0_invalid = ~valid0;
    assign way1_invalid = ~valid1;

    wire replace_way0;
    wire replace_way1;

    assign replace_way0 = 
        way0_invalid || 
        (~way1_invalid && (lru_value == 1'b0));

    assign replace_way1 = 
        (~way0_invalid && way1_invalid) || 
        (~way0_invalid && ~way1_invalid && (lru_value == 1'b1));

    // Refactored for Readability
    wire fill_way0 = fill_cache && replace_way0;
    wire fill_way1 = fill_cache && replace_way1;

    assign write_way0 = write_hit_way0 || fill_way0; 
    assign write_way1 = write_hit_way1 || fill_way1;

    assign way0_new_line = 
        write_hit_way0 ? write_hit_line0 :                
        fill_way0      ? fill_line :        
        56'b0; 

    assign way1_new_line = 
        write_hit_way1 ? write_hit_line1 :
        fill_way1      ? fill_line :
        56'b0;

    assign lru_write = write_hit || fill_cache; 

    assign lru_new_value = 
        (replace_way0 || write_hit_way0) ? 1'b1 :
        (replace_way1 || write_hit_way1) ? 1'b0 :
        lru_value;

    // --- Eviction Logic ---
    assign dirty_evict_way0 = 
        replace_way0 && 
        valid0 && 
        dirty0 && 
        (pending_memread || pending_memwrite);

    assign dirty_evict_way1 = 
        replace_way1 && 
        valid1 && 
        dirty1 && 
        (pending_memread || pending_memwrite);

    assign evict_addr_way0 = {tag0, compare_index, 2'b00};
    assign evict_addr_way1 = {tag1, compare_index, 2'b00};

    // --- Bus Request Output Logic ---
    always @(*) begin
        cache_read_req  = 0;
        cache_write_req = 0;
        cache_req_addr  = 0;
        cache_req_data  = 0;
        cache_req_strb  = 4'b0000;
        // $display("[CACHE bus_req eval] t=%0t state=%0d", $time, state);

        case(state)
            WRITE_BACK: begin
                cache_write_req = 1;
                cache_req_strb  = 4'b1111;

                if(dirty_evict_way0) begin
                    cache_req_addr = evict_addr_way0;
                    cache_req_data = data0;
                end
                else begin
                    cache_req_addr = evict_addr_way1;
                    cache_req_data = data1;
                end
            end
            ALLOCATE: begin
                cache_read_req = 1;
                cache_req_addr = pending_address;
            end
        endcase
    end

    // --- Module Instantiations ---
    data_cache data_cache_inst(
        .clk(clk),
        .rst(rst),
        .index(compare_index), 
        .write_way0(write_way0),
        .write_way1(write_way1),
        .way0_new_line(way0_new_line),
        .way1_new_line(way1_new_line),
        .way0_line(way0_line),
        .way1_line(way1_line)
    );

    lru_memory lru_memory_inst(
        .clk(clk),
        .rst(rst),
        .index(compare_index), 
        .lru_write(lru_write),
        .lru_new_value(lru_new_value),
        .lru_value(lru_value)
    );

             
endmodule