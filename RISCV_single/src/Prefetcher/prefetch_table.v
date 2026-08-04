// module prefetch_table(
//     input clk,
//     input rst,

//     // Observation Interface
//     input access_valid,
//     input observe_enable,
//     input [31:0] pc,
//     input [31:0] memory_address,

//     // Cache Controller Interface
//     input prefetch_accept,

//     // Prefetch Request
//     output reg prefetch_valid,
//     output reg [31:0] prefetch_address
// );

// // Table Storage: 32 entries, 80 bits wide
// reg [79:0] prefetch_table [0:31];

// // Pending registers (Global Prediction Buffer)
// reg [31:0] pending_addr1;
// reg [31:0] pending_addr2;
// reg [1:0] pending_count;

// // Combinational variables
// wire [4:0] index = pc[6:2]; 

// reg signed [11:0] new_stride;
// reg [31:0] sign_ext_stride;
// reg stride_match;
// reg signed [31:0] addr_diff; 
// reg [31:0] next_pred;
// reg [31:0] next_pred_2;

// // Field Mappings
// localparam VALID_BIT      = 79;
// localparam PC_MSB         = 78;
// localparam PC_LSB         = 47;
// localparam ADDR_MSB       = 46;
// localparam ADDR_LSB       = 15;
// localparam STRIDE_MSB     = 14;
// localparam STRIDE_LSB     = 3;
// localparam CONF_MSB       = 2;
// localparam CONF_LSB       = 1;

// localparam TABLE_SIZE = 32;

// // Confidence FSM States
// localparam CONF_0 = 2'b00;
// localparam CONF_1 = 2'b01;
// localparam CONF_2 = 2'b10;
// localparam CONF_3 = 2'b11;

// integer i;

// // ---------------------------------------------------------
// // Combinational Block 1: Stride & Prediction Calculations
// // ---------------------------------------------------------
// always @(*) begin
//     if (prefetch_table[index][VALID_BIT]) begin
//         addr_diff = memory_address - prefetch_table[index][ADDR_MSB:ADDR_LSB];
//         new_stride = addr_diff[11:0];
//         stride_match = (new_stride == prefetch_table[index][STRIDE_MSB:STRIDE_LSB]);
        
//         sign_ext_stride = {{20{prefetch_table[index][STRIDE_MSB]}}, prefetch_table[index][STRIDE_MSB:STRIDE_LSB]};
//     end else begin
//         addr_diff = 32'd0;
//         new_stride = 12'd0;
//         stride_match = 1'b0;
//         sign_ext_stride = 32'd0;
//     end

//     next_pred = memory_address + sign_ext_stride;
//     next_pred_2 = next_pred + sign_ext_stride;
// end

// // ---------------------------------------------------------
// // Combinational Block 2: Pure Prediction Emission
// // ---------------------------------------------------------
// always @(*) begin
//     if (pending_count == 2) begin
//         prefetch_valid = 1'b1;
//         prefetch_address = pending_addr1; // No longer masking bits here
//     end else if (pending_count == 1) begin
//         prefetch_valid = 1'b1;
//         prefetch_address = pending_addr2; // No longer masking bits here
//     end else begin
//         prefetch_valid = 1'b0;
//         prefetch_address = 32'd0;
//     end
// end

// // ---------------------------------------------------------
// // Sequential Block: Table Updates & Prediction Generation
// // ---------------------------------------------------------
// always @(posedge clk or posedge rst) begin
//     if (rst) begin
//         for (i = 0; i < TABLE_SIZE; i = i + 1) begin
//             prefetch_table[i] <= 80'd0;
//         end
//         pending_addr1 <= 32'd0;
//         pending_addr2 <= 32'd0;
//         pending_count <= 2'd0;
//     end
//     else begin
//         // 1. Process Cache Controller Acceptance 
//         if (prefetch_accept && pending_count > 0) begin
//             $display("------------------------------------------");
// $display("PC              = %h", pc);
// $display("Index           = %0d", index);
// $display("Mem Addr        = %h", memory_address);

// $display("VALID           = %b", prefetch_table[index][VALID_BIT]);
// $display("Stored PC       = %h", prefetch_table[index][PC_MSB:PC_LSB]);
// $display("Stored Addr     = %h", prefetch_table[index][ADDR_MSB:ADDR_LSB]);
// $display("Stored Stride   = %0d",
//           $signed(prefetch_table[index][STRIDE_MSB:STRIDE_LSB]));
// $display("Confidence      = %0d",
//           prefetch_table[index][CONF_MSB:CONF_LSB]);

// $display("New Stride      = %0d", new_stride);
// $display("Stride Match    = %b", stride_match);
//             if (pending_count == 2) begin
//                 pending_addr1 <= 32'd0; 
//             end else if (pending_count == 1) begin
//                 pending_addr2 <= 32'd0; 
//             end
//             pending_count <= pending_count - 1'b1;
//         end

//         // 2. Process Incoming Memory 
        
//         if (access_valid && observe_enable) begin

//             if (prefetch_table[index][VALID_BIT] == 1'b0) begin
//                 prefetch_table[index][VALID_BIT]         <= 1'b1; 
//                 prefetch_table[index][PC_MSB:PC_LSB]     <= pc;
//                 prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;
//                 prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= 12'd0;
//                 prefetch_table[index][CONF_MSB:CONF_LSB] <= CONF_0;
//             end

//             else if (prefetch_table[index][PC_MSB:PC_LSB] != pc) begin
//                 if (prefetch_table[index][CONF_MSB:CONF_LSB] == CONF_0) begin
//                     prefetch_table[index][PC_MSB:PC_LSB]     <= pc;
//                     prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;
//                     prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= 12'd0;
//                     prefetch_table[index][CONF_MSB:CONF_LSB] <= CONF_0; 
//                 end else begin
//                     prefetch_table[index][CONF_MSB:CONF_LSB] <= prefetch_table[index][CONF_MSB:CONF_LSB] - 1'b1;
//                 end
//             end
            
//             else begin
//                 if (stride_match) begin
//                     if (prefetch_table[index][CONF_MSB:CONF_LSB] != CONF_3) begin
//                         prefetch_table[index][CONF_MSB:CONF_LSB] <= prefetch_table[index][CONF_MSB:CONF_LSB] + 1'b1;
//                     end
                    
//                     // PREDICTION GENERATION
//                     if (prefetch_table[index][CONF_MSB:CONF_LSB] >= CONF_2 && pending_count == 0) begin
//                         if (next_pred != pending_addr1 && next_pred != pending_addr2 &&
//                             next_pred_2 != pending_addr1 && next_pred_2 != pending_addr2) begin
//                             pending_addr1 <= next_pred;
//                             pending_addr2 <= next_pred_2;
//                             pending_count <= 2'd2;
//                         end
//                     end

//                 end else begin
//                     if (prefetch_table[index][CONF_MSB:CONF_LSB] == CONF_0) begin
//                         prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= new_stride;
//                     end else begin
//                         prefetch_table[index][CONF_MSB:CONF_LSB] <= prefetch_table[index][CONF_MSB:CONF_LSB] - 1'b1;
//                     end
//                 end

//                 prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;
//             end
//         end
//     end
//     $display("After Update");
// $display("VALID       = %b", prefetch_table[index][VALID_BIT]);
// $display("ADDR        = %h", prefetch_table[index][ADDR_MSB:ADDR_LSB]);
// $display("STRIDE      = %0d",
//           $signed(prefetch_table[index][STRIDE_MSB:STRIDE_LSB]));
// $display("CONF        = %0d",
//           prefetch_table[index][CONF_MSB:CONF_LSB]);

// $display("PendingCnt  = %0d", pending_count);
// $display("PrefValid   = %b", prefetch_valid);
// $display("PrefAddr    = %h", prefetch_address);
// end

// endmodule

// module prefetch_table(
//     input clk,
//     input rst,

//     // Observation Interface
//     input access_valid,
//     input observe_enable,
//     input [31:0] pc,
//     input [31:0] memory_address,

//     // Cache Controller Interface
//     input prefetch_accept,

//     // Prefetch Request
//     output reg prefetch_valid,
//     output reg [31:0] prefetch_address
// );

// // Table Storage: 32 entries, 80 bits wide
// reg [79:0] prefetch_table [0:31];

// // Pending registers (Global Prediction Buffer)
// reg [31:0] pending_addr1;
// reg [31:0] pending_addr2;
// reg [1:0] pending_count;

// // Combinational variables
// wire [4:0] index = pc[6:2]; 

// reg signed [11:0] new_stride;
// reg [31:0] sign_ext_stride;
// reg stride_match;
// reg signed [31:0] addr_diff; 
// reg [31:0] next_pred;
// reg [31:0] next_pred_2;
// reg [1:0] next_conf; // combinational "confidence after this access" -- used so the
//                       // prediction threshold check below doesn't read a stale,
//                       // pre-increment confidence value (see fix notes)

// // Field Mappings
// localparam VALID_BIT      = 79;
// localparam PC_MSB         = 78;
// localparam PC_LSB         = 47;
// localparam ADDR_MSB       = 46;
// localparam ADDR_LSB       = 15;
// localparam STRIDE_MSB     = 14;
// localparam STRIDE_LSB     = 3;
// localparam CONF_MSB       = 2;
// localparam CONF_LSB       = 1;

// localparam TABLE_SIZE = 32;

// // Confidence FSM States
// localparam CONF_0 = 2'b00;
// localparam CONF_1 = 2'b01;
// localparam CONF_2 = 2'b10;
// localparam CONF_3 = 2'b11;

// integer i;

// // ---------------------------------------------------------
// // Combinational Block 1: Stride & Prediction Calculations
// // ---------------------------------------------------------
// always @(*) begin
//     if (prefetch_table[index][VALID_BIT]) begin
//         addr_diff = memory_address - prefetch_table[index][ADDR_MSB:ADDR_LSB];
//         new_stride = addr_diff[11:0];
//         stride_match = (new_stride == prefetch_table[index][STRIDE_MSB:STRIDE_LSB]);
        
//         sign_ext_stride = {{20{prefetch_table[index][STRIDE_MSB]}}, prefetch_table[index][STRIDE_MSB:STRIDE_LSB]};
//     end else begin
//         addr_diff = 32'd0;
//         new_stride = 12'd0;
//         stride_match = 1'b0;
//         sign_ext_stride = 32'd0;
//     end

//     next_pred = memory_address + sign_ext_stride;
//     next_pred_2 = next_pred + sign_ext_stride;

//     // What confidence WILL become this cycle if there's a stride match --
//     // computed here so the prediction-threshold check in the sequential
//     // block can use it instead of the stale pre-increment value.
//     if (prefetch_table[index][CONF_MSB:CONF_LSB] != CONF_3)
//         next_conf = prefetch_table[index][CONF_MSB:CONF_LSB] + 1'b1;
//     else
//         next_conf = CONF_3;
// end

// // ---------------------------------------------------------
// // Combinational Block 2: Pure Prediction Emission
// // ---------------------------------------------------------
// always @(*) begin
//     if (pending_count == 2) begin
//         prefetch_valid = 1'b1;
//         prefetch_address = pending_addr1; // No longer masking bits here
//     end else if (pending_count == 1) begin
//         prefetch_valid = 1'b1;
//         prefetch_address = pending_addr2; // No longer masking bits here
//     end else begin
//         prefetch_valid = 1'b0;
//         prefetch_address = 32'd0;
//     end
// end

// // ---------------------------------------------------------
// // Sequential Block: Table Updates & Prediction Generation
// // ---------------------------------------------------------
// always @(posedge clk or posedge rst) begin
//     if (rst) begin
//         for (i = 0; i < TABLE_SIZE; i = i + 1) begin
//             prefetch_table[i] <= 80'd0;
//         end
//         pending_addr1 <= 32'd0;
//         pending_addr2 <= 32'd0;
//         pending_count <= 2'd0;
//     end
//     else begin
//         // 1. Process Cache Controller Acceptance 
//         if (prefetch_accept && pending_count > 0) begin
//             $display("------------------------------------------");
// $display("PC              = %h", pc);
// $display("Index           = %0d", index);
// $display("Mem Addr        = %h", memory_address);

// $display("VALID           = %b", prefetch_table[index][VALID_BIT]);
// $display("Stored PC       = %h", prefetch_table[index][PC_MSB:PC_LSB]);
// $display("Stored Addr     = %h", prefetch_table[index][ADDR_MSB:ADDR_LSB]);
// $display("Stored Stride   = %0d",
//           $signed(prefetch_table[index][STRIDE_MSB:STRIDE_LSB]));
// $display("Confidence      = %0d",
//           prefetch_table[index][CONF_MSB:CONF_LSB]);

// $display("New Stride      = %0d", new_stride);
// $display("Stride Match    = %b", stride_match);
//             if (pending_count == 2) begin
//                 pending_addr1 <= 32'd0; 
//             end else if (pending_count == 1) begin
//                 pending_addr2 <= 32'd0; 
//             end
//             pending_count <= pending_count - 1'b1;
//         end

//         // 2. Process Incoming Memory 
        
//         if (access_valid && observe_enable) begin

//             if (prefetch_table[index][VALID_BIT] == 1'b0) begin
//                 prefetch_table[index][VALID_BIT]         <= 1'b1; 
//                 prefetch_table[index][PC_MSB:PC_LSB]     <= pc;
//                 prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;
//                 prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= 12'd0;
//                 prefetch_table[index][CONF_MSB:CONF_LSB] <= CONF_0;
//             end

//             else if (prefetch_table[index][PC_MSB:PC_LSB] != pc) begin
//                 if (prefetch_table[index][CONF_MSB:CONF_LSB] == CONF_0) begin
//                     prefetch_table[index][PC_MSB:PC_LSB]     <= pc;
//                     prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;
//                     prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= 12'd0;
//                     prefetch_table[index][CONF_MSB:CONF_LSB] <= CONF_0; 
//                 end else begin
//                     prefetch_table[index][CONF_MSB:CONF_LSB] <= prefetch_table[index][CONF_MSB:CONF_LSB] - 1'b1;
//                 end
//             end
            
//             else begin
//                 if (stride_match) begin
//                     if (prefetch_table[index][CONF_MSB:CONF_LSB] != CONF_3) begin
//                         prefetch_table[index][CONF_MSB:CONF_LSB] <= next_conf;
//                     end
                    
//                     // PREDICTION GENERATION -- use next_conf (the value CONF is
//                     // about to become this cycle), not the stale current value.
//                     if (next_conf >= CONF_2 && pending_count == 0) begin
//                         if (next_pred != pending_addr1 && next_pred != pending_addr2 &&
//                             next_pred_2 != pending_addr1 && next_pred_2 != pending_addr2) begin
//                             pending_addr1 <= next_pred;
//                             pending_addr2 <= next_pred_2;
//                             pending_count <= 2'd2;
//                         end
//                     end

//                 end else begin
//                     if (prefetch_table[index][CONF_MSB:CONF_LSB] == CONF_0) begin
//                         prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= new_stride;
//                     end else begin
//                         prefetch_table[index][CONF_MSB:CONF_LSB] <= prefetch_table[index][CONF_MSB:CONF_LSB] - 1'b1;
//                     end
//                 end

//                 prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;
//             end
//         end
//     end
//     $display("After Update");
// $display("VALID       = %b", prefetch_table[index][VALID_BIT]);
// $display("ADDR        = %h", prefetch_table[index][ADDR_MSB:ADDR_LSB]);
// $display("STRIDE      = %0d",
//           $signed(prefetch_table[index][STRIDE_MSB:STRIDE_LSB]));
// $display("CONF        = %0d",
//           prefetch_table[index][CONF_MSB:CONF_LSB]);

// $display("PendingCnt  = %0d", pending_count);
// $display("PrefValid   = %b", prefetch_valid);
// $display("PrefAddr    = %h", prefetch_address);
// end

// endmodule

// // module prefetch_table(
// //     input clk,
// //     input rst,
// //     input [31:0] pc,
// //     input [31:0] memory_address,
// //     input observe_enable,
// //     input access_valid,
// //     input prefetch_accept,
// //     output reg prefetch_valid,
// //     output reg [31:0] prefetch_address
// // );

// // // Field Mappings
// // localparam VALID_BIT      = 79;
// // localparam PC_MSB         = 78;
// // localparam PC_LSB         = 47;
// // localparam ADDR_MSB       = 46;
// // localparam ADDR_LSB       = 15;
// // localparam STRIDE_MSB     = 14;
// // localparam STRIDE_LSB     = 3;
// // localparam CONF_MSB       = 2;
// // localparam CONF_LSB       = 1;

// // localparam TABLE_SIZE = 32;

// // // Confidence FSM States
// // localparam CONF_0 = 2'b00;
// // localparam CONF_1 = 2'b01;
// // localparam CONF_2 = 2'b10;
// // localparam CONF_3 = 2'b11;

// // reg [79:0] prefetch_table [31:0];

// // reg [31:0] pending_addr1;
// // reg [31:0] pending_addr2;
// // reg [1:0] pending_count;

// // wire [4:0] index = pc[6:2]; 

// // reg signed [11:0] new_stride;
// // reg [31:0] sign_ext_stride;
// // reg stride_match;
// // reg signed [31:0] addr_diff; 
// // reg [31:0] next_pred;
// // reg [31:0] next_pred_2; // STEP 1: Ensure second prediction variable is active
// // reg [1:0] next_conf;

// // // Stride calculation
// // always @(*) begin

// //     addr_diff        = 32'd0;
// //     new_stride       = 12'd0;
// //     sign_ext_stride  = 32'd0;
// //     stride_match     = 1'b0;
// //     next_pred        = 32'd0;
// //     next_pred_2      = 32'd0;
// //     // next_conf        = CONF_0;

// //     if(prefetch_table[index][VALID_BIT]) begin
// //         addr_diff = memory_address - prefetch_table[index][ADDR_MSB:ADDR_LSB];
// //         new_stride = addr_diff[11:0];
// //         sign_ext_stride = {{20{prefetch_table[index][STRIDE_MSB]}}, prefetch_table[index][STRIDE_MSB:STRIDE_LSB]};
// //         stride_match = (new_stride == prefetch_table[index][STRIDE_MSB:STRIDE_LSB]);
        
// //         // STEP 2: Compute both predictions
// //         next_pred   = memory_address + sign_ext_stride;
// //         next_pred_2 = next_pred + sign_ext_stride;
// //     end
// //     else begin
// //         addr_diff = 32'd0;
// //         new_stride = 12'd0;
// //         stride_match = 1'b0;
// //         sign_ext_stride = 32'd0;
// //         next_pred = 32'b0;
// //         next_pred_2 = 32'b0;
// //     end
// // end

// // // STEP 4: Output Mux (pending_addr1 is now always the head of the queue)
// // always @(*) begin
// //     if(pending_count == 2) begin
// //         prefetch_valid = 1'b1;
// //         prefetch_address = pending_addr1;
// //     end
// //     else if(pending_count == 1) begin
// //         prefetch_valid = 1'b1;
// //         prefetch_address = pending_addr1; // Always output addr1
// //     end
// //     else begin
// //         prefetch_valid = 1'b0;
// //         prefetch_address = 32'b0;
// //     end
// // end

// // integer i;

// // // Sequential updates 
// // always @(posedge clk or posedge rst) begin

// //     if(rst) begin
// //         for(i=0;i<TABLE_SIZE;i=i+1)
// //             prefetch_table[i] <= 80'd0;

// //         pending_addr1 <= 32'd0;
// //         pending_addr2 <= 32'd0;
// //         pending_count <= 2'd0;
// //     end
// //     else begin
        
// //         // STEP 5: prefetch_accept logic (Shift Register behavior)
// //         if(prefetch_accept) begin
// //             //---------------------------------
// //             // Two entries
// //             //---------------------------------
// //             if(pending_count == 2) begin
// //                 pending_addr1 <= pending_addr2; // Shift slot 2 down to slot 1
// //                 pending_addr2 <= 32'd0;
// //                 pending_count <= 2'd1;
// //             end
// //             //---------------------------------
// //             // One entry
// //             //---------------------------------
// //             else if(pending_count == 1) begin
// //                 pending_addr1 <= 32'd0;
// //                 pending_addr2 <= 32'd0;
// //                 pending_count <= 2'd0;
// //             end
           
// //         end

// //         // Only if access given, run
// //         if(access_valid && observe_enable) begin

// //             // If not valid, write new entry into the index
// //             if(prefetch_table[index][VALID_BIT] == 1'b0) begin
// //                 prefetch_table[index][PC_MSB:PC_LSB] <= pc;
// //                 prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;
// //                 prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= 12'b0;
// //                 prefetch_table[index][CONF_MSB:CONF_LSB] <= 2'b00;
// //                 prefetch_table[index][VALID_BIT] <=1'b1;
// //             end
// //             // If pc mismatch, update confidence fsm
// //             else if(prefetch_table[index][PC_MSB:PC_LSB] != pc) begin
// //                 // Conf 0, write new entry
// //                 if(prefetch_table[index][CONF_MSB:CONF_LSB] == CONF_0) begin
// //                     prefetch_table[index][PC_MSB:PC_LSB] <= pc;
// //                     prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;
// //                     prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= 12'b0;
// //                     prefetch_table[index][CONF_MSB:CONF_LSB] <= 2'b00;
// //                 end
// //                 else begin
// //                     prefetch_table[index][CONF_MSB:CONF_LSB] <= prefetch_table[index][CONF_MSB:CONF_LSB] - 1'b1;
// //                 end
// //                 prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;
// //             end
// //             // PC match, check if stride matched
            
// //             else begin
                
// //                 if(stride_match) begin
                    
// //                     next_conf = prefetch_table[index][CONF_MSB:CONF_LSB];
// //                     if(next_conf != CONF_3) begin
// //                         next_conf = next_conf + 1'b1;
// //                     end

// //                     prefetch_table[index][CONF_MSB:CONF_LSB] <= next_conf;

// //                     // Gen prediction
// //                     if(next_conf >= CONF_2) begin

// //                         // STEP 3: Change queue insertion
// //                         //------------------------------------------------
// //                         // Queue Empty
// //                         //------------------------------------------------
// //                         if(pending_count == 0) begin
// //                             if(next_pred != next_pred_2) begin
// //                                 pending_addr1 <= next_pred;
// //                                 pending_addr2 <= next_pred_2;
// //                                 pending_count <= 2'd2;
// //                             end else begin
// //                                 pending_addr1 <= next_pred;
// //                                 pending_addr2 <= 32'd0;
// //                                 pending_count <= 2'd1;
// //                             end
// //                         end
// //                         //------------------------------------------------
// //                         // One entry present
// //                         //------------------------------------------------
// //                         else if(pending_count == 1) begin
// //                             if(next_pred != pending_addr1) begin
// //                                 pending_addr2 <= next_pred; // Append to slot 2
// //                                 pending_count <= 2'd2;
// //                             end
// //                             else if(next_pred_2 != pending_addr1) begin
// //                                 pending_addr2 <= next_pred_2;
// //                                 pending_count <= 2;
// //                             end
// //                         end
// //                     end
// //                 end
// //                 // Stride mismatch
// //                 else begin
// //                     if(prefetch_table[index][CONF_MSB:CONF_LSB] == CONF_0) begin
// //                         prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= new_stride;
// //                     end
// //                     else begin
// //                         prefetch_table[index][CONF_MSB:CONF_LSB] <= prefetch_table[index][CONF_MSB:CONF_LSB] - 1'b1;
// //                     end
// //                 end 
// //             end
// //             prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;

// //         end
// //     end
// // end

// // endmodule

// module prefetch_table(
//     input clk,
//     input rst,

//     // Observation Interface
//     input access_valid,
//     input observe_enable,
//     input [31:0] pc,
//     input [31:0] memory_address,

//     // Cache Controller Interface
//     input prefetch_accept,

//     // Prefetch Request
//     output reg prefetch_valid,
//     output reg [31:0] prefetch_address
// );

// // Table Storage: 32 entries, 80 bits wide
// reg [79:0] prefetch_table [0:31];

// // Pending registers (Global Prediction Buffer)
// reg [31:0] pending_addr1;
// reg [31:0] pending_addr2;
// reg [1:0] pending_count;

// // Combinational variables
// wire [4:0] index = pc[6:2]; 

// reg signed [11:0] new_stride;
// reg [31:0] sign_ext_stride;
// reg stride_match;
// reg signed [31:0] addr_diff; 
// reg [31:0] next_pred;
// reg [31:0] next_pred_2;
// reg [1:0] next_conf; // Combinational "confidence after this access" 

// // Field Mappings
// localparam VALID_BIT      = 79;
// localparam PC_MSB         = 78;
// localparam PC_LSB         = 47;
// localparam ADDR_MSB       = 46;
// localparam ADDR_LSB       = 15;
// localparam STRIDE_MSB     = 14;
// localparam STRIDE_LSB     = 3;
// localparam CONF_MSB       = 2;
// localparam CONF_LSB       = 1;

// localparam TABLE_SIZE = 32;

// // Confidence FSM States
// localparam CONF_0 = 2'b00;
// localparam CONF_1 = 2'b01;
// localparam CONF_2 = 2'b10;
// localparam CONF_3 = 2'b11;

// integer i;

// // ---------------------------------------------------------
// // Combinational Block 1: Stride & Prediction Calculations
// // ---------------------------------------------------------
// always @(*) begin
//     if (prefetch_table[index][VALID_BIT]) begin
//         addr_diff = memory_address - prefetch_table[index][ADDR_MSB:ADDR_LSB];
//         new_stride = addr_diff[11:0];
//         stride_match = (new_stride == prefetch_table[index][STRIDE_MSB:STRIDE_LSB]);
        
//         sign_ext_stride = {{20{prefetch_table[index][STRIDE_MSB]}}, prefetch_table[index][STRIDE_MSB:STRIDE_LSB]};
//     end else begin
//         addr_diff = 32'd0;
//         new_stride = 12'd0;
//         stride_match = 1'b0;
//         sign_ext_stride = 32'd0;
//     end

//     next_pred = memory_address + sign_ext_stride;
//     next_pred_2 = next_pred + sign_ext_stride;

// end

// // ---------------------------------------------------------
// // Combinational Block 2: Pure Prediction Emission
// // ---------------------------------------------------------
// always @(*) begin
//     if (pending_count == 2) begin
//         prefetch_valid = 1'b1;
//         prefetch_address = pending_addr1; 
//     end else if (pending_count == 1) begin
//         prefetch_valid = 1'b1;
//         prefetch_address = pending_addr1; // Always output the head of the queue
//     end else begin
//         prefetch_valid = 1'b0;
//         prefetch_address = 32'd0;
//     end
// end

// // ---------------------------------------------------------
// // Sequential Block: Table Updates & Prediction Generation
// // ---------------------------------------------------------
// always @(posedge clk or posedge rst) begin
//     if (rst) begin
//         for (i = 0; i < TABLE_SIZE; i = i + 1) begin
//             prefetch_table[i] <= 80'd0;
//         end
//         pending_addr1 <= 32'd0;
//         pending_addr2 <= 32'd0;
//         pending_count <= 2'd0;
//     end
//     else begin
//         // 1. Process Cache Controller Acceptance 
//         if (prefetch_accept && pending_count > 0) begin
//             if (pending_count == 2) begin
//                 pending_addr1 <= pending_addr2; // Shift down
//                 pending_addr2 <= 32'd0;
//                 pending_count <= 2'd1;
//             end else if (pending_count == 1) begin
//                 pending_addr1 <= 32'd0;
//                 pending_addr2 <= 32'd0; 
//                 pending_count <= 2'd0;
//             end
//         end

//         // 2. Process Incoming Memory 
//         if (access_valid && observe_enable) begin

//             if (prefetch_table[index][VALID_BIT] == 1'b0) begin
//                 prefetch_table[index][VALID_BIT]         <= 1'b1; 
//                 prefetch_table[index][PC_MSB:PC_LSB]     <= pc;
//                 prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;
//                 prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= 12'd0;
//                 prefetch_table[index][CONF_MSB:CONF_LSB] <= CONF_0;
//             end

//             else if (prefetch_table[index][PC_MSB:PC_LSB] != pc) begin
//                 if (prefetch_table[index][CONF_MSB:CONF_LSB] == CONF_0) begin
//                     prefetch_table[index][PC_MSB:PC_LSB]     <= pc;
//                     prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;
//                     prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= 12'd0;
//                     prefetch_table[index][CONF_MSB:CONF_LSB] <= CONF_0; 
//                 end else begin
//                     prefetch_table[index][CONF_MSB:CONF_LSB] <= prefetch_table[index][CONF_MSB:CONF_LSB] - 1'b1;
//                 end
//             end
            
//             else begin
//                 if (stride_match) begin
//                     // Compute next_conf cleanly only on a match
//                     if (prefetch_table[index][CONF_MSB:CONF_LSB] != CONF_3) begin
//                         next_conf = prefetch_table[index][CONF_MSB:CONF_LSB] + 1'b1;
//                     end else begin
//                         next_conf = CONF_3;
//                     end

//                     prefetch_table[index][CONF_MSB:CONF_LSB] <= next_conf;
                    
//                     // PREDICTION GENERATION
//                     if (next_conf >= CONF_2) begin
//                         // Queue Empty
//                         if (pending_count == 0) begin
//                             if (next_pred != next_pred_2) begin
//                                 pending_addr1 <= next_pred;
//                                 pending_addr2 <= next_pred_2;
//                                 pending_count <= 2'd2;
//                             end else begin
//                                 pending_addr1 <= next_pred;
//                                 pending_addr2 <= 32'd0;
//                                 pending_count <= 2'd1;
//                             end
//                         end
//                         // One Entry Present
//                         else if (pending_count == 1) begin
//                             if (next_pred != pending_addr1) begin
//                                 pending_addr2 <= next_pred;
//                                 pending_count <= 2'd2;
//                             end else if (next_pred_2 != pending_addr1) begin
//                                 pending_addr2 <= next_pred_2;
//                                 pending_count <= 2'd2;
//                             end
//                         end
//                     end

//                 end else begin
//                     if (prefetch_table[index][CONF_MSB:CONF_LSB] == CONF_0) begin
//                         prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= new_stride;
//                     end else begin
//                         prefetch_table[index][CONF_MSB:CONF_LSB] <= prefetch_table[index][CONF_MSB:CONF_LSB] - 1'b1;
//                     end
//                 end
//             end
            
//             prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;

//             // Debug Print placed safely inside access_valid
//             $display("------------------------------------------");
//             $display("PC              = %h", pc);
//             $display("Index           = %0d", index);
//             $display("Mem Addr        = %h", memory_address);
//             $display("VALID           = %b", prefetch_table[index][VALID_BIT]);
//             $display("Stored PC       = %h", prefetch_table[index][PC_MSB:PC_LSB]);
//             $display("Stored Addr     = %h", prefetch_table[index][ADDR_MSB:ADDR_LSB]);
//             $display("Stored Stride   = %0d", $signed(prefetch_table[index][STRIDE_MSB:STRIDE_LSB]));
//             $display("Current Conf    = %0d", prefetch_table[index][CONF_MSB:CONF_LSB]);
//             $display("New Stride      = %0d", new_stride);
//             $display("Stride Match    = %b", stride_match);
//             $display("Next Conf       = %0d", next_conf);
//             $display("PendingCnt      = %0d", pending_count);
//             $display("PrefValid       = %b", prefetch_valid);
//             $display("PrefAddr        = %h", prefetch_address);
//         end
//     end
// end
// endmodule

module prefetch_table(
    input clk,
    input rst,

    // Observation Interface
    input access_valid,
    input observe_enable,
    input [31:0] pc,
    input [31:0] memory_address,

    // Cache Controller Interface
    input prefetch_accept,

    // Prefetch Request
    output wire prefetch_valid,
    output wire [31:0] prefetch_address
);

// Table Storage: 32 entries, 80 bits wide
reg [79:0] prefetch_table [0:31];

// SINGLE Pending Register
reg        pending_valid;
reg [31:0] pending_addr;

assign prefetch_valid = pending_valid;
assign prefetch_address = pending_addr;

// Combinational variables
wire [4:0] index = pc[6:2]; 

reg signed [11:0] new_stride;
reg [31:0] sign_ext_stride;
reg stride_match;
reg signed [31:0] addr_diff; 
reg [31:0] next_pred;

// Scratch variable for sequential confidence update
reg [1:0] updated_conf;

// Field Mappings
localparam VALID_BIT      = 79;
localparam PC_MSB         = 78;
localparam PC_LSB         = 47;
localparam ADDR_MSB       = 46;
localparam ADDR_LSB       = 15;
localparam STRIDE_MSB     = 14;
localparam STRIDE_LSB     = 3;
localparam CONF_MSB       = 2;
localparam CONF_LSB       = 1;

localparam TABLE_SIZE = 32;

// Confidence FSM States
localparam CONF_0 = 2'b00;
localparam CONF_1 = 2'b01;
localparam CONF_2 = 2'b10;
localparam CONF_3 = 2'b11;

integer i;

// ---------------------------------------------------------
// Combinational Block: Stride & Prediction Calculations
// ---------------------------------------------------------
always @(*) begin
    if (prefetch_table[index][VALID_BIT]) begin
        addr_diff = memory_address - prefetch_table[index][ADDR_MSB:ADDR_LSB];
        new_stride = addr_diff[11:0];
        stride_match = (new_stride == prefetch_table[index][STRIDE_MSB:STRIDE_LSB]);
        sign_ext_stride = {{20{prefetch_table[index][STRIDE_MSB]}}, prefetch_table[index][STRIDE_MSB:STRIDE_LSB]};
    end else begin
        addr_diff = 32'd0;
        new_stride = 12'd0;
        stride_match = 1'b0;
        sign_ext_stride = 32'd0;
    end

    next_pred = memory_address + sign_ext_stride;
end

// ---------------------------------------------------------
// Sequential Block: Table Updates & Prediction Generation
// ---------------------------------------------------------
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < TABLE_SIZE; i = i + 1) begin
            prefetch_table[i] <= 80'd0;
        end
        pending_valid <= 1'b0;
        pending_addr  <= 32'd0;
        updated_conf  <= 2'b00;
    end
    else begin
        // 1. Process Cache Controller Acceptance 
        if (prefetch_accept) begin
            pending_valid <= 1'b0; // Clear the single request once accepted
        end

        // 2. Process Incoming Memory 
        if (access_valid && observe_enable) begin
            $display("\n******** NEW MEMORY ACCESS ********");
$display("Time=%0t", $time);

            if (prefetch_table[index][VALID_BIT] == 1'b0) begin
                prefetch_table[index][VALID_BIT]         <= 1'b1; 
                prefetch_table[index][PC_MSB:PC_LSB]     <= pc;
                prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;
                prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= 12'd0;
                prefetch_table[index][CONF_MSB:CONF_LSB] <= CONF_0;
            end

            else if (prefetch_table[index][PC_MSB:PC_LSB] != pc) begin
                if (prefetch_table[index][CONF_MSB:CONF_LSB] == CONF_0) begin
                    prefetch_table[index][PC_MSB:PC_LSB]     <= pc;
                    prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;
                    prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= 12'd0;
                    prefetch_table[index][CONF_MSB:CONF_LSB] <= CONF_0; 
                end else begin
                    prefetch_table[index][CONF_MSB:CONF_LSB] <= prefetch_table[index][CONF_MSB:CONF_LSB] - 1'b1;
                end
            end
            
            else begin
                if (stride_match) begin
                    
                    // Blocking assignment for temporary calculation
                    updated_conf = prefetch_table[index][CONF_MSB:CONF_LSB];
                    if (updated_conf != CONF_3) begin
                        updated_conf = updated_conf + 1'b1;
                    end
                    
                    // Write back to table
                    prefetch_table[index][CONF_MSB:CONF_LSB] <= updated_conf;
                    
                    // PREDICTION GENERATION (Single Entry, Non-Zero Stride)
                    if (updated_conf >= CONF_2 && new_stride != 12'd0 && !pending_valid) begin
                        pending_valid <= 1'b1;
                        pending_addr  <= next_pred;
                    end

                end else begin
                    if (prefetch_table[index][CONF_MSB:CONF_LSB] == CONF_0) begin
                        prefetch_table[index][STRIDE_MSB:STRIDE_LSB] <= new_stride;
                    end else begin
                        prefetch_table[index][CONF_MSB:CONF_LSB] <= prefetch_table[index][CONF_MSB:CONF_LSB] - 1'b1;
                    end
                end
            end
            
            prefetch_table[index][ADDR_MSB:ADDR_LSB] <= memory_address;

            // ---------------------------------------------------------
            // DEBUG: Minimal Stride & Confidence Monitor
            // ---------------------------------------------------------
            $display("\n==============================");
$display("Time              = %0t", $time);

$display("PC                = %h", pc);
$display("Index             = %0d", index);

$display("Memory Address    = %0d (%h)", memory_address, memory_address);

$display("Stored Address    = %0d (%h)",
    prefetch_table[index][ADDR_MSB:ADDR_LSB],
    prefetch_table[index][ADDR_MSB:ADDR_LSB]);

$display("Addr Diff         = %0d (%h)",
    addr_diff,
    addr_diff);

$display("New Stride        = %0d",
    $signed(new_stride));

$display("Stored Stride     = %0d",
    $signed(prefetch_table[index][STRIDE_MSB:STRIDE_LSB]));

$display("Stride Match      = %b", stride_match);

$display("Current Conf      = %0d",
    prefetch_table[index][CONF_MSB:CONF_LSB]);

$display("Updated Conf      = %0d", updated_conf);

$display("Next Prediction   = %0d (%h)",
    next_pred,
    next_pred);

$display("Pending Valid     = %b", pending_valid);
$display("Pending Address   = %0d (%h)",
    pending_addr,
    pending_addr);

$display("==============================");
        end
    end
end
endmodule