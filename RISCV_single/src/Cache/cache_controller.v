// module cache_controller(
//     input  wire        clk,
//     input  wire        rst,

//     input  wire        MemRead,
//     input  wire        MemWrite,

//     input  wire [31:0] address,
//     input  wire [31:0] write_data,

//     output reg  [31:0] read_data,
//     output wire        cache_hit,

//     output wire        hit_way0,
//     output wire        hit_way1,
//     output wire        miss,
//     output wire        cache_stall,

//     output reg         cache_read_req,
//     output reg         cache_write_req,
    
//     output reg  [31:0] cache_req_addr,
//     output reg  [31:0] cache_req_data,
//     output reg  [3:0]  cache_req_strb,
    
//     input  wire [31:0] cache_resp_data,
//     input  wire        cache_resp_done
// );

//     // --- State Definitions ---
//     parameter IDLE       = 2'b00;
//     parameter WRITE_BACK = 2'b01;
//     parameter ALLOCATE   = 2'b10;
//     parameter FILL       = 2'b11;

//     reg [1:0] state;
//     reg [1:0] next_state;

//     // --- Pending Requests ---
//     reg [31:0] pending_address;
//     reg [31:0] pending_write_data;
//     reg        pending_memread;
//     reg        pending_memwrite;
//     reg [31:0] cache_resp_data_reg;

//     // --- Forward Declarations for FSM ---
//     wire dirty_evict_way0;
//     wire dirty_evict_way1;
//     wire [31:0] evict_addr_way0;
//     wire [31:0] evict_addr_way1;

//     // --- Miss & Stall Logic ---
//     wire request_active;

//     assign request_active = 
//         (state == IDLE) ? 
//             (MemRead || MemWrite) : 
//             (pending_memread || pending_memwrite);

//     assign miss = request_active && !cache_hit;

//     assign cache_stall = (state != IDLE) || miss;

//     // --- Sequential Logic ---
//     always @(posedge clk or posedge rst) begin
//         if(rst)
//             state <= IDLE;
//         else
//             state <= next_state;
//     end

// always @(posedge clk or posedge rst) begin
//     if(rst) begin
//         pending_address    <= 0;
//         pending_write_data <= 0;
//         pending_memread    <= 0;
//         pending_memwrite   <= 0;
//         cache_resp_data_reg <= 32'b0;
//     end
//     else begin

//         // Capture memory response immediately
//         if(cache_resp_done)
//             cache_resp_data_reg <= cache_resp_data;

//         if(state == FILL) begin
//             pending_memread    <= 0;
//             pending_memwrite   <= 0;
//         end
//         else if(state == IDLE && miss && (MemRead || MemWrite)) begin
//             pending_address    <= address;
//             pending_write_data <= write_data;
//             pending_memread    <= MemRead;
//             pending_memwrite   <= MemWrite;
//         end
//     end
// end

//     // --- Next State Logic ---
//     always @(*) begin
//         next_state = state;
//         // $display("[CACHE next_state eval] t=%0t state=%0d miss=%b cache_resp_done=%b pending_memread=%b pending_memwrite=%b",
//         //     $time, state, miss, cache_resp_done, pending_memread, pending_memwrite);

//         case(state)
//             IDLE: begin
//                 if(miss && (MemRead || MemWrite)) begin
//                     if(dirty_evict_way0 || dirty_evict_way1)
//                         next_state = WRITE_BACK;
//                     else
//                         next_state = ALLOCATE;
//                 end
//             end
//             WRITE_BACK: begin
//                 if(cache_resp_done)
//                     next_state = ALLOCATE;
//             end
//             ALLOCATE: begin
//                 if(cache_resp_done)
//                     next_state = FILL; 
//             end
//             FILL: begin
//                 next_state = IDLE;
//             end
//             default: begin
//                 next_state = IDLE;
//             end
//         endcase
//     end

//     // --- Cache Line & Tag/Index Logic (Updated for Robustness) ---
//     wire fill_cache;
//     assign fill_cache = (state == FILL);

//     wire [21:0] compare_tag;
//     wire [7:0]  compare_index;

//     assign compare_tag = 
//         (pending_memread || pending_memwrite) ? 
//             pending_address[31:10] : 
//             address[31:10];

//     assign compare_index = 
//         (pending_memread || pending_memwrite) ? 
//             pending_address[9:2] : 
//             address[9:2];

//     wire [55:0] way0_line;
//     wire [55:0] way1_line;
    
//     wire write_way0;
//     wire write_way1;

//     wire [55:0] way0_new_line;
//     wire [55:0] way1_new_line;

//     wire valid0, dirty0;
//     wire [21:0] tag0;
//     wire [31:0] data0;

//     wire valid1, dirty1;
//     wire [21:0] tag1;
//     wire [31:0] data1;

//     assign valid0 = way0_line[55];
//     assign dirty0 = way0_line[54];
//     assign tag0   = way0_line[53:32];
//     assign data0  = way0_line[31:0];

//     assign valid1 = way1_line[55];
//     assign dirty1 = way1_line[54];
//     assign tag1   = way1_line[53:32];
//     assign data1  = way1_line[31:0];

//     // --- Hit Logic ---
//     assign hit_way0 = valid0 && (tag0 == compare_tag);
//     assign hit_way1 = valid1 && (tag1 == compare_tag);
//     assign cache_hit = hit_way0 || hit_way1;

//     always @(*) begin
//         if(hit_way0)
//             read_data = data0;
//         else if(hit_way1)
//             read_data = data1;
//         else
//             read_data = 32'b0; 
//     end

//     wire write_hit_way0;
//     wire write_hit_way1;

//     assign write_hit_way0 = MemWrite && hit_way0;
//     assign write_hit_way1 = MemWrite && hit_way1;

//     wire write_hit;
//     assign write_hit = write_hit_way0 || write_hit_way1;

//     // --- Line Updates (Updated for Clarity) ---
//     wire [55:0] write_hit_line0;
//     wire [55:0] write_hit_line1;

//     assign write_hit_line0 = {1'b1, 1'b1, tag0, write_data};
//     assign write_hit_line1 = {1'b1, 1'b1, tag1, write_data};

//     wire [55:0] fill_line;

//     assign fill_line =
//         pending_memwrite ?
//         {
//             1'b1,
//             1'b1,
//             pending_address[31:10],
//             pending_write_data
//         }
//         :
//         {
//             1'b1,
//             1'b0,
//             pending_address[31:10],
//             cache_resp_data_reg
//         };

//     // --- Replacement Logic (LRU) ---
//     wire lru_write;
//     wire lru_new_value;
//     wire lru_value;

//     wire way0_invalid;
//     wire way1_invalid;

//     assign way0_invalid = ~valid0;
//     assign way1_invalid = ~valid1;

//     wire replace_way0;
//     wire replace_way1;

//     assign replace_way0 = 
//         way0_invalid || 
//         (~way1_invalid && (lru_value == 1'b0));

//     assign replace_way1 = 
//         (~way0_invalid && way1_invalid) || 
//         (~way0_invalid && ~way1_invalid && (lru_value == 1'b1));

//     // Refactored for Readability
//     wire fill_way0 = fill_cache && replace_way0;
//     wire fill_way1 = fill_cache && replace_way1;

//     assign write_way0 = write_hit_way0 || fill_way0; 
//     assign write_way1 = write_hit_way1 || fill_way1;

//     assign way0_new_line = 
//         write_hit_way0 ? write_hit_line0 :                
//         fill_way0      ? fill_line :        
//         56'b0; 

//     assign way1_new_line = 
//         write_hit_way1 ? write_hit_line1 :
//         fill_way1      ? fill_line :
//         56'b0;

//     assign lru_write = write_hit || fill_cache; 

//     assign lru_new_value = 
//         (replace_way0 || write_hit_way0) ? 1'b1 :
//         (replace_way1 || write_hit_way1) ? 1'b0 :
//         lru_value;

//     // --- Eviction Logic ---
//     assign dirty_evict_way0 = 
//         replace_way0 && 
//         valid0 && 
//         dirty0 && 
//         (pending_memread || pending_memwrite);

//     assign dirty_evict_way1 = 
//         replace_way1 && 
//         valid1 && 
//         dirty1 && 
//         (pending_memread || pending_memwrite);

//     assign evict_addr_way0 = {tag0, compare_index, 2'b00};
//     assign evict_addr_way1 = {tag1, compare_index, 2'b00};

//     // --- Bus Request Output Logic ---
//     always @(*) begin
//         cache_read_req  = 0;
//         cache_write_req = 0;
//         cache_req_addr  = 0;
//         cache_req_data  = 0;
//         cache_req_strb  = 4'b0000;
//         // $display("[CACHE bus_req eval] t=%0t state=%0d", $time, state);

//         case(state)
//             WRITE_BACK: begin
//                 cache_write_req = 1;
//                 cache_req_strb  = 4'b1111;

//                 if(dirty_evict_way0) begin
//                     cache_req_addr = evict_addr_way0;
//                     cache_req_data = data0;
//                 end
//                 else begin
//                     cache_req_addr = evict_addr_way1;
//                     cache_req_data = data1;
//                 end
//             end
//             ALLOCATE: begin
//                 cache_read_req = 1;
//                 cache_req_addr = pending_address;
//             end
//         endcase
//     end

//     // --- Module Instantiations ---
//     data_cache data_cache_inst(
//         .clk(clk),
//         .rst(rst),
//         .index(compare_index), 
//         .write_way0(write_way0),
//         .write_way1(write_way1),
//         .way0_new_line(way0_new_line),
//         .way1_new_line(way1_new_line),
//         .way0_line(way0_line),
//         .way1_line(way1_line)
//     );

//     lru_memory lru_memory_inst(
//         .clk(clk),
//         .rst(rst),
//         .index(compare_index), 
//         .lru_write(lru_write),
//         .lru_new_value(lru_new_value),
//         .lru_value(lru_value)
//     );

             
// endmodule

//last working model without prefetcher
// module cache_controller(
//     input  wire        clk,
//     input  wire        rst,

//     // --- Inputs for Prefetcher ---
//     input  wire [31:0] pc,
//     input  wire        observe_enable,

//     // --- CPU Interface ---
//     input  wire        MemRead,
//     input  wire        MemWrite,
//     input  wire [31:0] address,
//     input  wire [31:0] write_data,

//     output reg  [31:0] read_data,
//     output wire        cache_hit,

//     output wire        hit_way0,
//     output wire        hit_way1,
//     output wire        miss,
//     output wire        cache_stall,

//     // --- Memory/Interconnect Interface ---
//     output reg         cache_read_req,
//     output reg         cache_write_req,
//     output reg  [31:0] cache_req_addr,
//     output reg  [31:0] cache_req_data,
//     output reg  [3:0]  cache_req_strb,
    
//     input  wire [31:0] cache_resp_data,
//     input  wire        cache_resp_done
// );

//     parameter IDLE       = 2'b00;
//     parameter WRITE_BACK = 2'b01;
//     parameter ALLOCATE   = 2'b10;
//     parameter FILL       = 2'b11;

//     reg [1:0] state;
//     reg [1:0] next_state;

//     // --- Prefetch Table Instantiation ---
//     wire        prefetch_valid;
//     wire [31:0] prefetch_address;
//     wire        prefetch_accept;
    
//     // ---------------------------------------------------------
//     // Bulletproof 1-Cycle Training Logic (Fix for Point 2 & 15)
//     // ---------------------------------------------------------
//     reg request_trained;
    
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             request_trained <= 1'b0;
//         end else begin
//             // Reset the lock when the CPU drops the read request
//             if (!MemRead) begin
//                 request_trained <= 1'b0;
//             end 
//             // Lock it out after the first cycle the request is accepted in IDLE
//             else if (MemRead && state == IDLE) begin
//                 request_trained <= 1'b1;
//             end
//         end
//     end

//     // Only pulses high for exactly ONE cycle when the cache accepts the load
//     wire train_prefetch = MemRead && (state == IDLE) && !request_trained;

//     always @(posedge clk) begin
//     if(train_prefetch) begin
//         $display(
//             "TRAIN  PC=%h  ADDR=%h",
//             pc,
//             address
//         );
//     end
// end

//     prefetch_table prefetch_table_inst (
//         .clk(clk),
//         .rst(rst),
//         .access_valid(train_prefetch),
//         .observe_enable(observe_enable),
//         .pc(pc),
//         .memory_address(address),
//         .prefetch_accept(prefetch_accept),
//         .prefetch_valid(prefetch_valid),
//         .prefetch_address(prefetch_address)
//     );

//     // --- Cache Geometry Alignment ---
//     // Align prefetch requests to 32-byte cache lines
//     wire [31:0] aligned_pref_addr = {prefetch_address[31:5], 5'b00000};

//     // --- Pending Requests ---
//     reg [31:0] pending_address;
//     reg [31:0] pending_write_data;
//     reg        pending_memread;
//     reg        pending_memwrite;
//     reg [31:0] cache_resp_data_reg;
//     reg        is_prefetch;

//     wire dirty_evict_way0;
//     wire dirty_evict_way1;
//     wire [31:0] evict_addr_way0;
//     wire [31:0] evict_addr_way1;

//     // --- Active Address Routing ---
//     wire [31:0] active_address;
    
//     assign active_address = 
//         (state != IDLE)         ? pending_address :  
//         (MemRead || MemWrite)   ? address :          
//         (prefetch_valid)        ? aligned_pref_addr : 
//         address;                                     

//     // --- Miss & Stall Logic ---
//     wire cpu_req = (MemRead || MemWrite);
//     wire pref_req = !(MemRead || MemWrite) && prefetch_valid;

//     assign miss = cpu_req && !cache_hit && (state == IDLE);
//     wire pref_miss = pref_req && !cache_hit && (state == IDLE);

//     assign cache_stall = (state != IDLE) || miss;
    
//     // Cache consumes the prediction (Hit or Miss) when IDLE and CPU is quiet
//     assign prefetch_accept = (state == IDLE) && pref_req;

//     // --- Sequential Logic ---
//     always @(posedge clk or posedge rst) begin
//         if(rst)
//             state <= IDLE;
//         else
//             state <= next_state;
//     end

//     always @(posedge clk or posedge rst) begin
//         if(rst) begin
//             pending_address    <= 0;
//             pending_write_data <= 0;
//             pending_memread    <= 0;
//             pending_memwrite   <= 0;
//             cache_resp_data_reg <= 32'b0;
//             is_prefetch    <= 1'b0;
//         end
//         else begin
//             if(cache_resp_done)
//                 cache_resp_data_reg <= cache_resp_data;

//             if(state == FILL) begin
//                 pending_memread    <= 1'b0;
//                 pending_memwrite   <= 1'b0;
//                 is_prefetch    <= 1'b0; // Clears after fill completes
//             end
//             else if(state == IDLE) begin
//                 if (miss) begin
//                     pending_address    <= address;
//                     pending_write_data <= write_data;
//                     pending_memread    <= MemRead;
//                     pending_memwrite   <= MemWrite;
//                     is_prefetch    <= 1'b0;
//                 end
//                 else if (pref_miss) begin
//                     pending_address    <= aligned_pref_addr; 
//                     pending_write_data <= 32'b0;
//                     pending_memread    <= 1'b1;  
//                     pending_memwrite   <= 1'b0;
//                     is_prefetch    <= 1'b1; // Flag this transaction as a silent prefetch
//                 end
//             end
//         end
//     end

//     // --- Next State Logic ---
//     always @(*) begin
//         next_state = state;

//         case(state)
//             IDLE: begin
//                 if(miss || pref_miss) begin
//                     if(dirty_evict_way0 || dirty_evict_way1)
//                         next_state = WRITE_BACK;
//                     else
//                         next_state = ALLOCATE;
//                 end
//             end
//             WRITE_BACK: begin
//                 if(cache_resp_done)
//                     next_state = ALLOCATE;
//             end
//             ALLOCATE: begin
//                 if(cache_resp_done)
//                     next_state = FILL; 
//             end
//             FILL: begin
//                 next_state = IDLE;
//             end
//             default: begin
//                 next_state = IDLE;
//             end
//         endcase
//     end

//     // --- Cache Line & Tag/Index Logic ---
//     wire fill_cache = (state == FILL);

//     wire [21:0] compare_tag   = active_address[31:10];
//     wire [7:0]  compare_index = active_address[9:2];

//     wire [55:0] way0_line;
//     wire [55:0] way1_line;
    
//     wire write_way0;
//     wire write_way1;

//     wire [55:0] way0_new_line;
//     wire [55:0] way1_new_line;

//     wire valid0, dirty0;
//     wire [21:0] tag0;
//     wire [31:0] data0;

//     wire valid1, dirty1;
//     wire [21:0] tag1;
//     wire [31:0] data1;

//     assign valid0 = way0_line[55];
//     assign dirty0 = way0_line[54];
//     assign tag0   = way0_line[53:32];
//     assign data0  = way0_line[31:0];

//     assign valid1 = way1_line[55];
//     assign dirty1 = way1_line[54];
//     assign tag1   = way1_line[53:32];
//     assign data1  = way1_line[31:0];

//     // --- Hit Logic ---
//     assign hit_way0 = valid0 && (tag0 == compare_tag);
//     assign hit_way1 = valid1 && (tag1 == compare_tag);
//     assign cache_hit = hit_way0 || hit_way1;

//     // --- Read Data Emission ---
//     always @(*) begin
//         if (is_prefetch && state != IDLE) 
//             read_data = 32'b0; // Isolate CPU from returning prefetch data
//         else if(hit_way0)
//             read_data = data0;
//         else if(hit_way1)
//             read_data = data1;
//         else
//             read_data = 32'b0; 
//     end

//     wire write_hit_way0 = MemWrite && hit_way0;
//     wire write_hit_way1 = MemWrite && hit_way1;
//     wire write_hit = write_hit_way0 || write_hit_way1;

//     // --- Line Updates ---
//     wire [55:0] write_hit_line0 = {1'b1, 1'b1, tag0, write_data};
//     wire [55:0] write_hit_line1 = {1'b1, 1'b1, tag1, write_data};

//     wire [55:0] fill_line =
//         pending_memwrite ?
//         {1'b1, 1'b1, pending_address[31:10], pending_write_data} :
//         {1'b1, 1'b0, pending_address[31:10], cache_resp_data_reg};

//     // --- Replacement Logic (LRU) ---
//     wire lru_write;
//     wire lru_new_value;
//     wire lru_value;

//     wire way0_invalid = ~valid0;
//     wire way1_invalid = ~valid1;

//     wire replace_way0 = way0_invalid || (~way1_invalid && (lru_value == 1'b0));
//     wire replace_way1 = (~way0_invalid && way1_invalid) || (~way0_invalid && ~way1_invalid && (lru_value == 1'b1));

//     wire fill_way0 = fill_cache && replace_way0;
//     wire fill_way1 = fill_cache && replace_way1;

//     assign write_way0 = write_hit_way0 || fill_way0; 
//     assign write_way1 = write_hit_way1 || fill_way1;

//     assign way0_new_line = 
//         write_hit_way0 ? write_hit_line0 :                
//         fill_way0      ? fill_line :        
//         56'b0; 

//     assign way1_new_line = 
//         write_hit_way1 ? write_hit_line1 :
//         fill_way1      ? fill_line :
//         56'b0;

//     assign lru_write = write_hit || fill_cache; 

//     assign lru_new_value = 
//         (replace_way0 || write_hit_way0) ? 1'b1 :
//         (replace_way1 || write_hit_way1) ? 1'b0 :
//         lru_value;

//     // --- Eviction Logic ---
//     assign dirty_evict_way0 = replace_way0 && valid0 && dirty0 && (pending_memread || pending_memwrite);
//     assign dirty_evict_way1 = replace_way1 && valid1 && dirty1 && (pending_memread || pending_memwrite);

//     assign evict_addr_way0 = {tag0, compare_index, 2'b00};
//     assign evict_addr_way1 = {tag1, compare_index, 2'b00};

//     // --- Bus Request Output Logic ---
//     always @(*) begin
//         cache_read_req  = 0;
//         cache_write_req = 0;
//         cache_req_addr  = 0;
//         cache_req_data  = 0;
//         cache_req_strb  = 4'b0000;

//         case(state)
//             WRITE_BACK: begin
//                 cache_write_req = 1;
//                 cache_req_strb  = 4'b1111;

//                 if(dirty_evict_way0) begin
//                     cache_req_addr = evict_addr_way0;
//                     cache_req_data = data0;
//                 end
//                 else begin
//                     cache_req_addr = evict_addr_way1;
//                     cache_req_data = data1;
//                 end
//             end
//             ALLOCATE: begin
//                 cache_read_req = 1;
//                 cache_req_addr = pending_address;
//             end
//         endcase
//     end

//     // --- Module Instantiations ---
//     data_cache data_cache_inst(
//         .clk(clk),
//         .rst(rst),
//         .index(compare_index), 
//         .write_way0(write_way0),
//         .write_way1(write_way1),
//         .way0_new_line(way0_new_line),
//         .way1_new_line(way1_new_line),
//         .way0_line(way0_line),
//         .way1_line(way1_line)
//     );

//     lru_memory lru_memory_inst(
//         .clk(clk),
//         .rst(rst),
//         .index(compare_index), 
//         .lru_write(lru_write),
//         .lru_new_value(lru_new_value),
//         .lru_value(lru_value)
//     );

//     // ---------------------------------------------------------
//     // DEBUG: Check whether prefetched lines actually produce
//     // a hit later, when the CPU issues a real demand access.
//     // ---------------------------------------------------------
//     always @(posedge clk) begin
//         if (cpu_req && state == IDLE) begin
//             $display("[HITCHECK] t=%0t addr=%h index=%0d compare_tag=%h | valid0=%b tag0=%h | valid1=%b tag1=%h | cache_hit=%b (miss=%b)",
//                 $time, address, compare_index, compare_tag,
//                 valid0, tag0, valid1, tag1, cache_hit, miss);
//         end
//     end
             
// endmodule

// module cache_controller(
//     input  wire        clk,
//     input  wire        rst,

//     // --- Inputs for Prefetcher ---
//     input  wire [31:0] pc,
//     input  wire        observe_enable,

//     // --- CPU Interface ---
//     input  wire        MemRead,
//     input  wire        MemWrite,
//     input  wire [31:0] address,
//     input  wire [31:0] write_data,

//     output reg  [31:0] read_data,
//     output wire        cache_hit,

//     output wire        hit_way0,
//     output wire        hit_way1,
//     output wire        miss,
//     output wire        cache_stall,

//     // --- Memory/Interconnect Interface ---
//     output reg         cache_read_req,
//     output reg         cache_write_req,
//     output reg  [31:0] cache_req_addr,
//     output reg  [31:0] cache_req_data,
//     output reg  [3:0]  cache_req_strb,
    
//     input  wire [31:0] cache_resp_data,
//     input  wire        cache_resp_done
// );

//     parameter IDLE       = 2'b00;
//     parameter WRITE_BACK = 2'b01;
//     parameter ALLOCATE   = 2'b10;
//     parameter FILL       = 2'b11;

//     reg [1:0] state;
//     reg [1:0] next_state;

//     // --- Prefetch Table Instantiation ---
//     wire        prefetch_valid;
//     wire [31:0] prefetch_address;
//     wire        prefetch_accept;
//     wire [31:0] aligned_pref_addr = {prefetch_address[31:5], 5'b00000};
    
//     // ---------------------------------------------------------
//     // CYCLE STEALING LOGIC (Fixes Priority 1 & Starvation)
//     // ---------------------------------------------------------
//     reg pref_check_active;
    
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             pref_check_active <= 1'b0;
//         end else if (state == IDLE) begin
//             // If there's a valid prefetch, we haven't stolen a cycle for it yet,
//             // and the CPU isn't currently missing (CPU miss takes absolute priority)
//             if (prefetch_valid && !pref_check_active && !miss)
//                 pref_check_active <= 1'b1;
//             else
//                 pref_check_active <= 1'b0;
//         end else begin
//             pref_check_active <= 1'b0;
//         end
//     end

//     // ---------------------------------------------------------
//     // Bulletproof 1-Cycle Training Logic
//     // ---------------------------------------------------------
//     reg request_trained;
    
//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             request_trained <= 1'b0;
//         end else begin
//             if (!MemRead) begin
//                 request_trained <= 1'b0;
//             end 
//             // Only train when we are actively checking the CPU's address
//             else if (MemRead && state == IDLE && !pref_check_active) begin
//                 request_trained <= 1'b1;
//             end
//         end
//     end

//     wire train_prefetch = MemRead && (state == IDLE) && !request_trained && !pref_check_active;

//     always @(posedge clk) begin
//         if(train_prefetch) begin
//             $display("TRAIN  PC=%h  ADDR=%h", pc, address);
//         end
//     end

//     prefetch_table prefetch_table_inst (
//         .clk(clk),
//         .rst(rst),
//         .access_valid(train_prefetch),
//         .observe_enable(observe_enable),
//         .pc(pc),
//         .memory_address(address),
//         .prefetch_accept(prefetch_accept),
//         .prefetch_valid(prefetch_valid),
//         .prefetch_address(prefetch_address)
//     );

//     // --- Pending Requests ---
//     reg [31:0] pending_address;
//     reg [31:0] pending_write_data;
//     reg        pending_memread;
//     reg        pending_memwrite;
//     reg [31:0] cache_resp_data_reg;
//     reg        is_prefetch;

//     wire dirty_evict_way0;
//     wire dirty_evict_way1;
//     wire [31:0] evict_addr_way0;
//     wire [31:0] evict_addr_way1;

//     // ---------------------------------------------------------
//     // Active Address Routing (No Combinational Loops)
//     // ---------------------------------------------------------
//     wire [31:0] active_address;
//     wire cpu_req = (MemRead || MemWrite);
    
//     assign active_address = 
//         (state != IDLE)     ? pending_address :  
//         (pref_check_active) ? aligned_pref_addr : // Steal the SRAM port for 1 cycle
//         address;                                  // Otherwise, CPU gets the port

//     // ---------------------------------------------------------
//     // Miss, Stall, & Accept Logic
//     // ---------------------------------------------------------
    
//     // CPU miss only evaluates when we are actually checking the CPU address
//     assign miss = cpu_req && !cache_hit && (state == IDLE) && !pref_check_active;
    
//     // Prefetch miss only evaluates when we are checking the prefetch address
//     wire pref_miss = pref_check_active && !cache_hit && (state == IDLE);

//     // Stall CPU if cache is busy, CPU missed, OR we are stealing a cycle to check a prefetch
//     assign cache_stall = (state != IDLE) || miss || pref_check_active;
    
//     // Fix Priority 2 & 3: Acknowledge the prefetch ONLY when the transaction is complete:
//     // Case A: It was already in the cache (Hit during the stolen check cycle)
//     // Case B: We fetched it from main memory and are now filling the cache
//     assign prefetch_accept = (pref_check_active && cache_hit && state == IDLE) || 
//                              (state == FILL && is_prefetch);


//     // --- Sequential Logic ---
//     always @(posedge clk or posedge rst) begin
//         if(rst)
//             state <= IDLE;
//         else
//             state <= next_state;
//     end

//     always @(posedge clk or posedge rst) begin
//         if(rst) begin
//             pending_address    <= 0;
//             pending_write_data <= 0;
//             pending_memread    <= 0;
//             pending_memwrite   <= 0;
//             cache_resp_data_reg <= 32'b0;
//             is_prefetch    <= 1'b0;
//         end
//         else begin
//             if(cache_resp_done)
//                 cache_resp_data_reg <= cache_resp_data;

//             if(state == FILL) begin
//                 pending_memread    <= 1'b0;
//                 pending_memwrite   <= 1'b0;
//                 is_prefetch    <= 1'b0; 
//             end
//             else if(state == IDLE) begin
//                 if (miss) begin
//                     pending_address    <= address;
//                     pending_write_data <= write_data;
//                     pending_memread    <= MemRead;
//                     pending_memwrite   <= MemWrite;
//                     is_prefetch    <= 1'b0;
//                 end
//                 else if (pref_miss) begin
//                     pending_address    <= aligned_pref_addr; 
//                     pending_write_data <= 32'b0;
//                     pending_memread    <= 1'b1;  
//                     pending_memwrite   <= 1'b0;
//                     is_prefetch    <= 1'b1; 
//                 end
//             end
//         end
//     end

//     // --- Next State Logic ---
//     always @(*) begin
//         next_state = state;

//         case(state)
//             IDLE: begin
//                 if(miss || pref_miss) begin
//                     if(dirty_evict_way0 || dirty_evict_way1)
//                         next_state = WRITE_BACK;
//                     else
//                         next_state = ALLOCATE;
//                 end
//             end
//             WRITE_BACK: begin
//                 if(cache_resp_done)
//                     next_state = ALLOCATE;
//             end
//             ALLOCATE: begin
//                 if(cache_resp_done)
//                     next_state = FILL; 
//             end
//             FILL: begin
//                 next_state = IDLE;
//             end
//             default: begin
//                 next_state = IDLE;
//             end
//         endcase
//     end

//     // --- Cache Line & Tag/Index Logic ---
//     wire fill_cache = (state == FILL);

//     wire [21:0] compare_tag   = active_address[31:10];
//     wire [7:0]  compare_index = active_address[9:2];

//     wire [55:0] way0_line;
//     wire [55:0] way1_line;
    
//     wire write_way0;
//     wire write_way1;

//     wire [55:0] way0_new_line;
//     wire [55:0] way1_new_line;

//     wire valid0, dirty0;
//     wire [21:0] tag0;
//     wire [31:0] data0;

//     wire valid1, dirty1;
//     wire [21:0] tag1;
//     wire [31:0] data1;

//     assign valid0 = way0_line[55];
//     assign dirty0 = way0_line[54];
//     assign tag0   = way0_line[53:32];
//     assign data0  = way0_line[31:0];

//     assign valid1 = way1_line[55];
//     assign dirty1 = way1_line[54];
//     assign tag1   = way1_line[53:32];
//     assign data1  = way1_line[31:0];

//     // --- Hit Logic ---
//     assign hit_way0 = valid0 && (tag0 == compare_tag);
//     assign hit_way1 = valid1 && (tag1 == compare_tag);
//     assign cache_hit = hit_way0 || hit_way1;

//     // --- Read Data Emission ---
//     always @(*) begin
//         if (is_prefetch && state != IDLE) 
//             read_data = 32'b0; 
//         else if(hit_way0 && !pref_check_active) // Do not return data if we are checking a prefetch
//             read_data = data0;
//         else if(hit_way1 && !pref_check_active)
//             read_data = data1;
//         else
//             read_data = 32'b0; 
//     end

//     wire write_hit_way0 = MemWrite && hit_way0;
//     wire write_hit_way1 = MemWrite && hit_way1;
//     wire write_hit = write_hit_way0 || write_hit_way1;

//     // --- Line Updates ---
//     wire [55:0] write_hit_line0 = {1'b1, 1'b1, tag0, write_data};
//     wire [55:0] write_hit_line1 = {1'b1, 1'b1, tag1, write_data};

//     wire [55:0] fill_line =
//         pending_memwrite ?
//         {1'b1, 1'b1, pending_address[31:10], pending_write_data} :
//         {1'b1, 1'b0, pending_address[31:10], cache_resp_data_reg};

//     // --- Replacement Logic (LRU) ---
//     wire lru_write;
//     wire lru_new_value;
//     wire lru_value;

//     wire way0_invalid = ~valid0;
//     wire way1_invalid = ~valid1;

//     wire replace_way0 = way0_invalid || (~way1_invalid && (lru_value == 1'b0));
//     wire replace_way1 = (~way0_invalid && way1_invalid) || (~way0_invalid && ~way1_invalid && (lru_value == 1'b1));

//     wire fill_way0 = fill_cache && replace_way0;
//     wire fill_way1 = fill_cache && replace_way1;

//     assign write_way0 = write_hit_way0 || fill_way0; 
//     assign write_way1 = write_hit_way1 || fill_way1;

//     assign way0_new_line = 
//         write_hit_way0 ? write_hit_line0 :                
//         fill_way0      ? fill_line :        
//         56'b0; 

//     assign way1_new_line = 
//         write_hit_way1 ? write_hit_line1 :
//         fill_way1      ? fill_line :
//         56'b0;

//     assign lru_write = write_hit || fill_cache; 

//     assign lru_new_value = 
//         (replace_way0 || write_hit_way0) ? 1'b1 :
//         (replace_way1 || write_hit_way1) ? 1'b0 :
//         lru_value;

//     // --- Eviction Logic ---
//     assign dirty_evict_way0 = replace_way0 && valid0 && dirty0 && (pending_memread || pending_memwrite);
//     assign dirty_evict_way1 = replace_way1 && valid1 && dirty1 && (pending_memread || pending_memwrite);

//     assign evict_addr_way0 = {tag0, compare_index, 2'b00};
//     assign evict_addr_way1 = {tag1, compare_index, 2'b00};

//     // --- Bus Request Output Logic ---
//     always @(*) begin
//         cache_read_req  = 0;
//         cache_write_req = 0;
//         cache_req_addr  = 0;
//         cache_req_data  = 0;
//         cache_req_strb  = 4'b0000;

//         case(state)
//             WRITE_BACK: begin
//                 cache_write_req = 1;
//                 cache_req_strb  = 4'b1111;

//                 if(dirty_evict_way0) begin
//                     cache_req_addr = evict_addr_way0;
//                     cache_req_data = data0;
//                 end
//                 else begin
//                     cache_req_addr = evict_addr_way1;
//                     cache_req_data = data1;
//                 end
//             end
//             ALLOCATE: begin
//                 cache_read_req = 1;
//                 cache_req_addr = pending_address;
//             end
//         endcase
//     end

//     // --- Module Instantiations ---
//     data_cache data_cache_inst(
//         .clk(clk),
//         .rst(rst),
//         .index(compare_index), 
//         .write_way0(write_way0),
//         .write_way1(write_way1),
//         .way0_new_line(way0_new_line),
//         .way1_new_line(way1_new_line),
//         .way0_line(way0_line),
//         .way1_line(way1_line)
//     );

//     lru_memory lru_memory_inst(
//         .clk(clk),
//         .rst(rst),
//         .index(compare_index), 
//         .lru_write(lru_write),
//         .lru_new_value(lru_new_value),
//         .lru_value(lru_value)
//     );
             
// always @(posedge clk) begin
//     $display(
//         "CPU=%h ACTIVE=%h PREFCHK=%b HIT=%b MISS=%b PREFMISS=%b",
//         address,
//         active_address,
//         pref_check_active,
//         cache_hit,
//         miss,
//         pref_miss
//     );
// end

// always @(posedge clk) begin
//     if(pref_check_active)
//         $display("CHECKING PREFETCH %h", aligned_pref_addr);
// end

// endmodule

// module cache_controller(
//     input  wire        clk,
//     input  wire        rst,

//     // --- Inputs for Prefetcher ---
//     input  wire [31:0] pc,
//     input  wire        observe_enable,

//     // --- CPU Interface ---
//     input  wire        MemRead,
//     input  wire        MemWrite,
//     input  wire [31:0] address,
//     input  wire [31:0] write_data,

//     output reg  [31:0] read_data,
//     output wire        cache_hit,

//     output wire        hit_way0,
//     output wire        hit_way1,
//     output wire        miss,
//     output wire        cache_stall,

//     // --- Memory/Interconnect Interface ---
//     output reg         cache_read_req,
//     output reg         cache_write_req,
//     output reg  [31:0] cache_req_addr,
//     output reg  [31:0] cache_req_data,
//     output reg  [3:0]  cache_req_strb,
    
//     input  wire [31:0] cache_resp_data,
//     input  wire        cache_resp_done
// );

//     parameter IDLE       = 2'b00;
//     parameter WRITE_BACK = 2'b01;
//     parameter ALLOCATE   = 2'b10;
//     parameter FILL       = 2'b11;

//     reg [1:0] state;
//     reg [1:0] next_state;

//     // --- Prefetch Table Instantiation ---
//     wire        prefetch_valid;
//     wire [31:0] prefetch_address;
//     wire        prefetch_accept;
//     wire [31:0] aligned_pref_addr = {prefetch_address[31:5], 5'b00000};
//     wire access_valid;
    
//     assign access_valid = (MemWrite || MemRead) && (state == IDLE) && !request_trained;

//     reg request_trained;

// always @(posedge clk or posedge rst) begin

//     if(rst) begin
//         request_trained <= 1'b0;
//     end
//     else if(!(MemRead || MemWrite)) begin
//         request_trained <= 1'b0;
//     end
//     else if((MemRead || MemWrite) && state == IDLE && !request_trained) begin
//         request_trained <=1'b1;
//     end
// end
  
// prefetch_table prefetch_table_inst(
//     .clk(clk),
//     .rst(rst),
//     .pc(pc),
//     .observe_enable(observe_enable),
//     .access_valid(access_valid),
//     .prefetch_accept(prefetch_accept),
//     .prefetch_valid(prefetch_valid),
//     .prefetch_address(prefetch_address),
//     .memory_address(address)
// );

// assign prefetch_accept = 1'b0;


// always @(posedge clk) begin
//     if (access_valid)
//         $display("[TRAIN] PC=%h ADDR=%h", pc, address);

//     if (prefetch_valid)
//         $display("[PREDICT] PREFETCH=%h", prefetch_address);
// end

// endmodule

// module cache_controller(
//     input  wire        clk,
//     input  wire        rst,

//     // --- Inputs for Prefetcher ---
//     input  wire [31:0] pc,
//     input  wire        observe_enable,

//     // --- CPU Interface ---
//     input  wire        MemRead,
//     input  wire        MemWrite,
//     input  wire [31:0] address,
//     input  wire [31:0] write_data,

//     output reg  [31:0] read_data,
//     output wire        cache_hit,

//     output wire        hit_way0,
//     output wire        hit_way1,
//     output wire        miss,
//     output wire        cache_stall,

//     // --- Memory/Interconnect Interface ---
//     output reg         cache_read_req,
//     output reg         cache_write_req,
//     output reg  [31:0] cache_req_addr,
//     output reg  [31:0] cache_req_data,
//     output reg  [3:0]  cache_req_strb,
    
//     input  wire [31:0] cache_resp_data,
//     input  wire        cache_resp_done
// );

//     parameter IDLE       = 2'b00;
//     parameter WRITE_BACK = 2'b01;
//     parameter ALLOCATE   = 2'b10;
//     parameter FILL       = 2'b11;

//     reg [1:0] state;
//     reg [1:0] next_state;

//     // --- Prefetch Table Instantiation ---
//     wire        prefetch_valid;
//     wire [31:0] prefetch_address;
//     reg         prefetch_accept;
    
//     // ---------------------------------------------------------
//     // Address-Edge Training Logic (Fixes the GTKWave 0 bug)
//     // ---------------------------------------------------------
//     reg [31:0] last_trained_addr;
    
//     // Train if it's a valid access in IDLE, and the address has changed since last time
//     wire train_prefetch = (MemRead || MemWrite) && (state == IDLE) && (address != last_trained_addr);

//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             last_trained_addr <= 32'hFFFF_FFFF; // Start with dummy address
//         end else if (train_prefetch) begin
//             last_trained_addr <= address;       // Lock out until CPU asks for a new address
//         end
//     end

//     always @(posedge clk) begin
//         if(train_prefetch) begin
//             $display("TRAIN  PC=%h  ADDR=%h", pc, address);
//         end
//     end

//     prefetch_table prefetch_table_inst (
//         .clk(clk),
//         .rst(rst),
//         .access_valid(train_prefetch),
//         .observe_enable(observe_enable),
//         .pc(pc),
//         .memory_address(address),
//         .prefetch_accept(prefetch_accept),
//         .prefetch_valid(prefetch_valid),
//         .prefetch_address(prefetch_address)
//     );

//     // --- Cache Geometry Alignment ---
//     // Align prefetch requests to 32-byte cache lines
//     wire [31:0] aligned_pref_addr = {prefetch_address[31:5], 5'b00000};

//     // --- Pending Requests ---
//     reg [31:0] pending_address;
//     reg [31:0] pending_write_data;
//     reg        pending_memread;
//     reg        pending_memwrite;
//     reg [31:0] cache_resp_data_reg;
//     reg        is_prefetch;

//     wire dirty_evict_way0;
//     wire dirty_evict_way1;
//     wire [31:0] evict_addr_way0;
//     wire [31:0] evict_addr_way1;

//     // --- Active Address Routing ---
//     wire [31:0] active_address;
    
//     assign active_address = 
//         (state != IDLE)         ? pending_address :  
//         (MemRead || MemWrite)   ? address :          
//         (prefetch_valid)        ? aligned_pref_addr : 
//         address;                                     

//     // --- Miss & Stall Logic ---
//     wire cpu_req = (MemRead || MemWrite);

//     // CPU Miss is the only combinatorial miss check
//     assign miss = cpu_req && !cache_hit && (state == IDLE);

//     // Stall if FSM is busy fetching, OR if CPU just missed
//     assign cache_stall = (state != IDLE) || miss;

//     // --- Sequential Logic ---
//     always @(posedge clk or posedge rst) begin
//         if(rst)
//             state <= IDLE;
//         else
//             state <= next_state;
//     end

//     always @(posedge clk or posedge rst) begin
//         if(rst) begin
//             pending_address    <= 0;
//             pending_write_data <= 0;
//             pending_memread    <= 0;
//             pending_memwrite   <= 0;
//             cache_resp_data_reg <= 32'b0;
//             is_prefetch        <= 1'b0;
//             prefetch_accept    <= 1'b0;
//             last_trained_addr  <= 32'hFFFF_FFFF;
//         end
//         else begin
//             // Default prefetch_accept
//             prefetch_accept <= 1'b0;

//             // When prefetch finishes filling the cache
//             if(state == FILL && cache_resp_done && is_prefetch)
//                 prefetch_accept <= 1'b1;

//             if(cache_resp_done)
//                 cache_resp_data_reg <= cache_resp_data;

//             if(state == FILL) begin
//                 pending_memread    <= 1'b0;
//                 pending_memwrite   <= 1'b0;
//                 is_prefetch        <= 1'b0; // Clears after fill completes
//             end
//             else if(state == IDLE) begin
//                 // Priority 1: CPU Miss
//                 if (miss) begin
//                     pending_address    <= address;
//                     pending_write_data <= write_data;
//                     pending_memread    <= MemRead;
//                     pending_memwrite   <= MemWrite;
//                     is_prefetch        <= 1'b0;
//                 end
//                 // Priority 2: Valid Prefetch (happens when CPU hits or is quiet)
//                 else if (prefetch_valid) begin
//                     pending_address    <= aligned_pref_addr; 
//                     pending_write_data <= 32'b0;
//                     pending_memread    <= 1'b1;  // Read only
//                     pending_memwrite   <= 1'b0;
//                     is_prefetch        <= 1'b1;  // Mark transaction as prefetch
//                 end
//             end
//         end
//     end

//     // --- Next State Logic ---
//     always @(*) begin
//         next_state = state;

//         case(state)
//             IDLE: begin
//                 if(miss) begin
//                     if(dirty_evict_way0 || dirty_evict_way1)
//                         next_state = WRITE_BACK;
//                     else
//                         next_state = ALLOCATE;
//                 end
//                 else if (prefetch_valid) begin
//                     next_state = ALLOCATE; // Immediately fetch the prefetch
//                 end
//             end
//             WRITE_BACK: begin
//                 if(cache_resp_done)
//                     next_state = ALLOCATE;
//             end
//             ALLOCATE: begin
//                 if(cache_resp_done)
//                     next_state = FILL; 
//             end
//             FILL: begin
//                 next_state = IDLE;
//             end
//             default: begin
//                 next_state = IDLE;
//             end
//         endcase
//     end

//     // --- Cache Line & Tag/Index Logic ---
//     wire fill_cache = (state == FILL);

//     wire [21:0] compare_tag   = active_address[31:10];
//     wire [7:0]  compare_index = active_address[9:2];

//     wire [55:0] way0_line;
//     wire [55:0] way1_line;
    
//     wire write_way0;
//     wire write_way1;

//     wire [55:0] way0_new_line;
//     wire [55:0] way1_new_line;

//     wire valid0, dirty0;
//     wire [21:0] tag0;
//     wire [31:0] data0;

//     wire valid1, dirty1;
//     wire [21:0] tag1;
//     wire [31:0] data1;

//     assign valid0 = way0_line[55];
//     assign dirty0 = way0_line[54];
//     assign tag0   = way0_line[53:32];
//     assign data0  = way0_line[31:0];

//     assign valid1 = way1_line[55];
//     assign dirty1 = way1_line[54];
//     assign tag1   = way1_line[53:32];
//     assign data1  = way1_line[31:0];

//     // --- Hit Logic ---
//     assign hit_way0 = valid0 && (tag0 == compare_tag);
//     assign hit_way1 = valid1 && (tag1 == compare_tag);
//     assign cache_hit = hit_way0 || hit_way1;

//     // --- Read Data Emission ---
//     always @(*) begin
//         if (is_prefetch && state != IDLE) 
//             read_data = 32'b0; // Isolate CPU from returning prefetch data
//         else if(hit_way0)
//             read_data = data0;
//         else if(hit_way1)
//             read_data = data1;
//         else
//             read_data = 32'b0; 
//     end

//     wire write_hit_way0 = MemWrite && hit_way0;
//     wire write_hit_way1 = MemWrite && hit_way1;
//     wire write_hit = write_hit_way0 || write_hit_way1;

//     // --- Line Updates ---
//     wire [55:0] write_hit_line0 = {1'b1, 1'b1, tag0, write_data};
//     wire [55:0] write_hit_line1 = {1'b1, 1'b1, tag1, write_data};

//     wire [55:0] fill_line =
//         pending_memwrite ?
//         {1'b1, 1'b1, pending_address[31:10], pending_write_data} :
//         {1'b1, 1'b0, pending_address[31:10], cache_resp_data_reg};

//     // --- Replacement Logic (LRU) ---
//     wire lru_write;
//     wire lru_new_value;
//     wire lru_value;

//     wire way0_invalid = ~valid0;
//     wire way1_invalid = ~valid1;

//     wire replace_way0 = way0_invalid || (~way1_invalid && (lru_value == 1'b0));
//     wire replace_way1 = (~way0_invalid && way1_invalid) || (~way0_invalid && ~way1_invalid && (lru_value == 1'b1));

//     wire fill_way0 = fill_cache && replace_way0;
//     wire fill_way1 = fill_cache && replace_way1;

//     assign write_way0 = write_hit_way0 || fill_way0; 
//     assign write_way1 = write_hit_way1 || fill_way1;

//     assign way0_new_line = 
//         write_hit_way0 ? write_hit_line0 :                
//         fill_way0      ? fill_line :        
//         56'b0; 

//     assign way1_new_line = 
//         write_hit_way1 ? write_hit_line1 :
//         fill_way1      ? fill_line :
//         56'b0;

//     assign lru_write = write_hit || fill_cache; 

//     assign lru_new_value = 
//         (replace_way0 || write_hit_way0) ? 1'b1 :
//         (replace_way1 || write_hit_way1) ? 1'b0 :
//         lru_value;

//     // --- Eviction Logic ---
//     assign dirty_evict_way0 = replace_way0 && valid0 && dirty0 && (pending_memread || pending_memwrite);
//     assign dirty_evict_way1 = replace_way1 && valid1 && dirty1 && (pending_memread || pending_memwrite);

//     assign evict_addr_way0 = {tag0, compare_index, 2'b00};
//     assign evict_addr_way1 = {tag1, compare_index, 2'b00};

//     // --- Bus Request Output Logic ---
//     always @(*) begin
//         cache_read_req  = 0;
//         cache_write_req = 0;
//         cache_req_addr  = 0;
//         cache_req_data  = 0;
//         cache_req_strb  = 4'b0000;

//         case(state)
//             WRITE_BACK: begin
//                 cache_write_req = 1;
//                 cache_req_strb  = 4'b1111;

//                 if(dirty_evict_way0) begin
//                     cache_req_addr = evict_addr_way0;
//                     cache_req_data = data0;
//                 end
//                 else begin
//                     cache_req_addr = evict_addr_way1;
//                     cache_req_data = data1;
//                 end
//             end
//             ALLOCATE: begin
//                 cache_read_req = 1;
//                 cache_req_addr = pending_address;
//             end
//         endcase
//     end

//     // --- Module Instantiations ---
//     data_cache data_cache_inst(
//         .clk(clk),
//         .rst(rst),
//         .index(compare_index), 
//         .write_way0(write_way0),
//         .write_way1(write_way1),
//         .way0_new_line(way0_new_line),
//         .way1_new_line(way1_new_line),
//         .way0_line(way0_line),
//         .way1_line(way1_line)
//     );

//     lru_memory lru_memory_inst(
//         .clk(clk),
//         .rst(rst),
//         .index(compare_index), 
//         .lru_write(lru_write),
//         .lru_new_value(lru_new_value),
//         .lru_value(lru_value)
//     );

//     // ---------------------------------------------------------
//     // DEBUG: Check whether prefetched lines actually produce
//     // a hit later, when the CPU issues a real demand access.
//     // ---------------------------------------------------------
//     always @(posedge clk) begin
//         if (cpu_req && state == IDLE) begin
//             $display("[HITCHECK] t=%0t addr=%h index=%0d compare_tag=%h | valid0=%b tag0=%h | valid1=%b tag1=%h | cache_hit=%b (miss=%b)",
//                 $time, address, compare_index, compare_tag,
//                 valid0, tag0, valid1, tag1, cache_hit, miss);
//         end
//     end

//     // ---------------------------------------------------------
//     // STEP 9: Prefetch Debug Prints
//     // ---------------------------------------------------------
//     always @(posedge clk) begin
//         if(prefetch_valid)
//             $display("[PREFETCH REQUEST] %h", prefetch_address);

//         if(prefetch_accept)
//             $display("[PREFETCH ACCEPTED]");
//     end
             
// endmodule

module cache_controller(
    input  wire        clk,
    input  wire        rst,

    // --- Inputs for Prefetcher ---
    input  wire [31:0] pc,
    input  wire        observe_enable,

    // --- CPU Interface ---
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

    // --- Memory/Interconnect Interface ---
    output reg         cache_read_req,
    output reg         cache_write_req,
    output reg  [31:0] cache_req_addr,
    output reg  [31:0] cache_req_data,
    output reg  [3:0]  cache_req_strb,
    
    input  wire [31:0] cache_resp_data,
    input  wire        cache_resp_done
);

    parameter IDLE       = 2'b00;
    parameter WRITE_BACK = 2'b01;
    parameter ALLOCATE   = 2'b10;
    parameter FILL       = 2'b11;

    reg [1:0] state;
    reg [1:0] next_state;

    // --- Prefetch Table Instantiation ---
    wire        prefetch_valid;
    wire [31:0] prefetch_address;
    reg         prefetch_accept;
    
    // ---------------------------------------------------------
    // Bulletproof 1-Cycle Training Logic (Request Edge Detection)
    // ---------------------------------------------------------
    reg request_trained;
    always @(posedge clk or posedge rst) begin
        if(rst) 
            request_trained <= 1'b0;
        else if(!(MemRead||MemWrite)) 
            request_trained <= 1'b0;
        else if((MemRead||MemWrite) && state==IDLE) 
            request_trained <= 1'b1;
    end

    wire train_prefetch = (MemRead||MemWrite) && (state==IDLE) && !request_trained;

    // ---------------------------------------------------------
    // DEBUG: Monitor Training Filter
    // ---------------------------------------------------------
    always @(posedge clk) begin
        if(train_prefetch) begin
            $display("[TRAIN EVENT] Time: %0t | Addr: %h", $time, address);
        end
    end

    prefetch_table prefetch_table_inst (
        .clk(clk),
        .rst(rst),
        .access_valid(train_prefetch),
        .observe_enable(observe_enable),
        .pc(pc),
        .memory_address(address),
        .prefetch_accept(prefetch_accept),
        .prefetch_valid(prefetch_valid),
        .prefetch_address(prefetch_address)
    );

    // --- Cache Geometry Alignment ---
    // Align prefetch requests to 32-byte cache lines
    wire [31:0] aligned_pref_addr = {prefetch_address[31:5], 5'b00000};

    // --- Pending Requests ---
    reg [31:0] pending_address;
    reg [31:0] pending_write_data;
    reg        pending_memread;
    reg        pending_memwrite;
    reg [31:0] cache_resp_data_reg;
    reg        is_prefetch;

    wire dirty_evict_way0;
    wire dirty_evict_way1;
    wire [31:0] evict_addr_way0;
    wire [31:0] evict_addr_way1;

    // --- Active Address Routing ---
    wire [31:0] active_address;
    
    assign active_address = 
        (state != IDLE)         ? pending_address :  
        (MemRead || MemWrite)   ? address :          
        (prefetch_valid)        ? aligned_pref_addr : 
        address;                                     

    // --- Miss & Stall Logic ---
    wire cpu_req = (MemRead || MemWrite);

    // CPU Miss is the only combinatorial miss check
    assign miss = cpu_req && !cache_hit && (state == IDLE);

    // Stall if FSM is busy fetching, OR if CPU just missed
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
            cache_resp_data_reg<= 0;
            is_prefetch        <= 0;
            prefetch_accept    <= 0;
        end
        else begin
            // Default prefetch_accept
            prefetch_accept <= 1'b0;

            // When prefetch finishes filling the cache
            if(state == ALLOCATE && cache_resp_done && is_prefetch)
                prefetch_accept <= 1'b1;

            if(cache_resp_done)
                cache_resp_data_reg <= cache_resp_data;

            if(state == FILL) begin
                pending_memread    <= 1'b0;
                pending_memwrite   <= 1'b0;
                is_prefetch        <= 1'b0; // Clears after fill completes
            end
            else if(state == IDLE) begin
                // Priority 1: CPU Miss
                if (miss) begin
                    pending_address    <= address;
                    pending_write_data <= write_data;
                    pending_memread    <= MemRead;
                    pending_memwrite   <= MemWrite;
                    is_prefetch        <= 1'b0;
                end
                // Priority 2: Valid Prefetch (happens when CPU hits or is quiet)
                else if (prefetch_valid) begin
                    pending_address    <= aligned_pref_addr; 
                    pending_write_data <= 32'b0;
                    pending_memread    <= 1'b1;  // Read only
                    pending_memwrite   <= 1'b0;
                    is_prefetch        <= 1'b1;  // Mark transaction as prefetch
                end
            end
        end
    end

    // --- Next State Logic ---
    always @(*) begin
        next_state = state;

        case(state)
            IDLE: begin
                if(miss) begin
                    if(dirty_evict_way0 || dirty_evict_way1)
                        next_state = WRITE_BACK;
                    else
                        next_state = ALLOCATE;
                end
                else if (prefetch_valid) begin
                    next_state = ALLOCATE; // Immediately fetch the prefetch
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

    // --- Cache Line & Tag/Index Logic ---
    wire fill_cache = (state == FILL);

    wire [21:0] compare_tag   = active_address[31:10];
    wire [7:0]  compare_index = active_address[9:2];

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

    // --- Read Data Emission ---
    always @(*) begin
        if (is_prefetch && state != IDLE) 
            read_data = 32'b0; // Isolate CPU from returning prefetch data
        else if(hit_way0)
            read_data = data0;
        else if(hit_way1)
            read_data = data1;
        else
            read_data = 32'b0; 
    end

    wire write_hit_way0 = MemWrite && hit_way0;
    wire write_hit_way1 = MemWrite && hit_way1;
    wire write_hit = write_hit_way0 || write_hit_way1;

    // --- Line Updates ---
    wire [55:0] write_hit_line0 = {1'b1, 1'b1, tag0, write_data};
    wire [55:0] write_hit_line1 = {1'b1, 1'b1, tag1, write_data};

    wire [55:0] fill_line =
        pending_memwrite ?
        {1'b1, 1'b1, pending_address[31:10], pending_write_data} :
        {1'b1, 1'b0, pending_address[31:10], cache_resp_data_reg};

    // --- Replacement Logic (LRU) ---
    wire lru_write;
    wire lru_new_value;
    wire lru_value;

    wire way0_invalid = ~valid0;
    wire way1_invalid = ~valid1;

    wire replace_way0 = way0_invalid || (~way1_invalid && (lru_value == 1'b0));
    wire replace_way1 = (~way0_invalid && way1_invalid) || (~way0_invalid && ~way1_invalid && (lru_value == 1'b1));

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
    assign dirty_evict_way0 = replace_way0 && valid0 && dirty0 && (pending_memread || pending_memwrite);
    assign dirty_evict_way1 = replace_way1 && valid1 && dirty1 && (pending_memread || pending_memwrite);

    assign evict_addr_way0 = {tag0, compare_index, 2'b00};
    assign evict_addr_way1 = {tag1, compare_index, 2'b00};

    // --- Bus Request Output Logic ---
    always @(*) begin
        cache_read_req  = 0;
        cache_write_req = 0;
        cache_req_addr  = 0;
        cache_req_data  = 0;
        cache_req_strb  = 4'b0000;

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

    // ---------------------------------------------------------
    // DEBUG: Check whether prefetched lines actually produce
    // a hit later, when the CPU issues a real demand access.
    // ---------------------------------------------------------
    always @(posedge clk) begin
        if (cpu_req && state == IDLE) begin
            $display("[HITCHECK] t=%0t addr=%h index=%0d compare_tag=%h | valid0=%b tag0=%h | valid1=%b tag1=%h | cache_hit=%b (miss=%b)",
                $time, address, compare_index, compare_tag,
                valid0, tag0, valid1, tag1, cache_hit, miss);
        end
    end

    // ---------------------------------------------------------
    // DEBUG: Prefetch Event Prints
    // ---------------------------------------------------------
    always @(posedge clk) begin
        if(prefetch_valid)
            $display("[PREFETCH REQUEST] %h", prefetch_address);

        if(prefetch_accept)
            $display("[PREFETCH ACCEPTED]");
    end
             
endmodule