// module systolic_controller(
//     input clk,
//     input rst,

//     // Inputs updated to 8-bit
//     // input [7:0] A00, input [7:0] A01, input [7:0] A02, input [7:0] A03,
//     // input [7:0] A10, input [7:0] A11, input [7:0] A12, input [7:0] A13,
//     // input [7:0] A20, input [7:0] A21, input [7:0] A22, input [7:0] A23,
//     // input [7:0] A30, input [7:0] A31, input [7:0] A32, input [7:0] A33,

//     // input [7:0] B00, input [7:0] B01, input [7:0] B02, input [7:0] B03,
//     // input [7:0] B10, input [7:0] B11, input [7:0] B12, input [7:0] B13,
//     // input [7:0] B20, input [7:0] B21, input [7:0] B22, input [7:0] B23,
//     // input [7:0] B30, input [7:0] B31, input [7:0] B32, input [7:0] B33
// );

// reg [3:0] clock_counter;

// // Registers updated to 8-bit
// reg [7:0] A0, A1, A2, A3;
// reg [7:0] B0, B1, B2, B3;

// // Wires updated to 18-bit
// wire [17:0] C11, C12, C13, C14;
// wire [17:0] C21, C22, C23, C24;
// wire [17:0] C31, C32, C33, C34;
// wire [17:0] C41, C42, C43, C44;

// systolic_array syst(
//     .clk(clk),
//     .rst(rst),
//     .A0(A0), .A1(A1), .A2(A2), .A3(A3),
//     .B0(B0), .B1(B1), .B2(B2), .B3(B3),
//     .C11(C11), .C12(C12), .C13(C13), .C14(C14),
//     .C21(C21), .C22(C22), .C23(C23), .C24(C24),
//     .C31(C31), .C32(C32), .C33(C33), .C34(C34),
//     .C41(C41), .C42(C42), .C43(C43), .C44(C44)
// );

// always @(posedge clk or posedge rst)
// begin
//     if(rst) begin
//         A0 <= 8'd0; A1 <= 8'd0; A2 <= 8'd0; A3 <= 8'd0;
//         B0 <= 8'd0; B1 <= 8'd0; B2 <= 8'd0; B3 <= 8'd0;
//         clock_counter <= 4'd0;
//     end
//     else begin
//         if(clock_counter < 4'd10)
//             clock_counter <= clock_counter + 1;

//         case(clock_counter)
//             4'd0: begin
//                 A0 <= 8'd0; A1 <= 8'd0; A2 <= 8'd0; A3 <= 8'd0;
//                 B0 <= 8'd0; B1 <= 8'd0; B2 <= 8'd0; B3 <= 8'd0;
//             end
//             4'd1: begin
//                 A0 <= A00; A1 <= 8'd0; A2 <= 8'd0; A3 <= 8'd0;
//                 B0 <= B00; B1 <= 8'd0; B2 <= 8'd0; B3 <= 8'd0;
//             end
//             4'd2: begin
//                 A0 <= A01; A1 <= A10; A2 <= 8'd0; A3 <= 8'd0;
//                 B0 <= B10; B1 <= B01; B2 <= 8'd0; B3 <= 8'd0;
//             end
//             4'd3: begin
//                 A0 <= A02; A1 <= A11; A2 <= A20; A3 <= 8'd0;
//                 B0 <= B20; B1 <= B11; B2 <= B02; B3 <= 8'd0;
//             end
//             4'd4: begin
//                 A0 <= A03; A1 <= A12; A2 <= A21; A3 <= A30;
//                 B0 <= B30; B1 <= B21; B2 <= B12; B3 <= B03;
//             end
//             4'd5: begin
//                 A0 <= 8'd0; A1 <= A13; A2 <= A22; A3 <= A31;
//                 B0 <= 8'd0; B1 <= B31; B2 <= B22; B3 <= B13;
//             end
//             4'd6: begin
//                 A0 <= 8'd0; A1 <= 8'd0; A2 <= A23; A3 <= A32;
//                 B0 <= 8'd0; B1 <= 8'd0; B2 <= B32; B3 <= B23;
//             end
//             4'd7: begin
//                 A0 <= 8'd0; A1 <= 8'd0; A2 <= 8'd0; A3 <= A33;
//                 B0 <= 8'd0; B1 <= 8'd0; B2 <= 8'd0; B3 <= B33;
//             end
//             default: begin
//                 A0 <= 8'd0; A1 <= 8'd0; A2 <= 8'd0; A3 <= 8'd0;
//                 B0 <= 8'd0; B1 <= 8'd0; B2 <= 8'd0; B3 <= 8'd0;
//             end
//         endcase
//     end
// end

// endmodule

module systolic_controller(
    //==========================================
    // Clock & Reset
    //==========================================
    input               clk,
    input               rst,

    //==========================================
    // Processor Interface
    //==========================================
    input               SystolicStart,     // SMAT
    input               SystolicRead,      // SMRD
    
    // WARNING: Software must only provide indices 0-15. 
    // Hardware masks to [3:0] for safety, but software should not rely on this wraparound.
    input      [4:0]    result_index,      
    
    output wire [31:0]  read_data,         // Combinational read data back to CPU

    //==========================================
    // Status
    //==========================================
    output wire         busy
);

    //==========================================
    // Edge Detector for Safety
    //==========================================
    // Prevents the array from looping if the CPU stalls and holds SystolicStart HIGH.
    reg SystolicStart_prev;
    always @(posedge clk or posedge rst) begin
        if(rst) SystolicStart_prev <= 1'b0;
        else    SystolicStart_prev <= SystolicStart;
    end
    wire start_pulse = SystolicStart && !SystolicStart_prev;

    //==========================================
    // State Encoding
    //==========================================
    localparam IDLE         = 2'b00;
    localparam LOAD_MATRIX  = 2'b01;
    localparam COMPUTE      = 2'b10;
    localparam WRITE_RESULT = 2'b11;

    //==========================================
    // Internal Registers
    //==========================================
    reg [7:0] A_reg [0:15];
    reg [7:0] B_reg [0:15];
    
    reg [3:0] inject_counter;
    
    reg [1:0] state;
    reg [1:0] next_state;
    
    reg result_we;

    // Systolic array active inputs
    reg [7:0] A0, A1, A2, A3;
    reg [7:0] B0, B1, B2, B3;

    // Systolic array active outputs
    wire [17:0] C11, C12, C13, C14;
    wire [17:0] C21, C22, C23, C24;
    wire [17:0] C31, C32, C33, C34;
    wire [17:0] C41, C42, C43, C44;

    //==========================================
    // Instantiate Matrix SRAMs
    //==========================================
    wire [127:0] matA_bulk_in;
    wire [127:0] matB_bulk_in;

    matrixA_sram sram_A (
        .clk(clk),
        .bulk_data_out(matA_bulk_in)
    );

    matrixB_sram sram_B (
        .clk(clk),
        .bulk_data_out(matB_bulk_in)
    );

    //==========================================
    // Instantiate Result SRAM
    //==========================================
    wire [17:0] result_sram_dout;

    result_sram sram_RES (
        .clk(clk),
        .rst(rst),
        .read_addr(result_index[3:0]), // Maps 5-bit rs1 safely to 4-bit space
        .read_data(result_sram_dout),
        .bulk_we(result_we),
        .C11(C11), .C12(C12), .C13(C13), .C14(C14),
        .C21(C21), .C22(C22), .C23(C23), .C24(C24),
        .C31(C31), .C32(C32), .C33(C33), .C34(C34),
        .C41(C41), .C42(C42), .C43(C43), .C44(C44)
    );

    //==========================================
    // Instantiate Systolic Array
    //==========================================
    systolic_array syst(
        .clk(clk),
        .rst(rst),
        .A0(A0), .A1(A1), .A2(A2), .A3(A3),
        .B0(B0), .B1(B1), .B2(B2), .B3(B3),
        .C11(C11), .C12(C12), .C13(C13), .C14(C14),
        .C21(C21), .C22(C22), .C23(C23), .C24(C24),
        .C31(C31), .C32(C32), .C33(C33), .C34(C34),
        .C41(C41), .C42(C42), .C43(C43), .C44(C44)
    );

    //==========================================
    // State Register
    //==========================================
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    //==========================================
    // Next State Logic & Busy Assignment
    //==========================================
    // Busy is completely deterministic and tied to the FSM.
    assign busy = (state != IDLE) || result_we;

    always @(*) begin
        next_state = state; 
        
        case(state)
            IDLE: begin
                // Use the pulse, not the raw signal, to prevent accidental loops
                if (start_pulse)
                    next_state = LOAD_MATRIX;
            end
            LOAD_MATRIX: begin
                next_state = COMPUTE;
            end
            COMPUTE: begin
                // Because non-blocking assignments update at the clock edge, 
                // hitting 10 here means the FSM stays in COMPUTE for cycle 10, 
                // and transitions to WRITE_RESULT on cycle 11. (11 cycles total).
                if (inject_counter == 4'd10)
                    next_state = WRITE_RESULT;
            end
            WRITE_RESULT: begin
                next_state = IDLE;
            end
        endcase
    end

    //==========================================
    // Datapath & Scheduler Logic
    //==========================================
    always @(posedge clk or posedge rst) begin
        integer i; 

        if(rst) begin
            inject_counter <= 4'd0;
            result_we <= 1'b0;
            A0 <= 8'd0; A1 <= 8'd0; A2 <= 8'd0; A3 <= 8'd0;
            B0 <= 8'd0; B1 <= 8'd0; B2 <= 8'd0; B3 <= 8'd0;
            
            for (i = 0; i < 16; i = i + 1) begin
                A_reg[i] <= 8'd0;
                B_reg[i] <= 8'd0;
            end
        end else begin
            
            result_we <= 1'b0; // Default off

            case(state)
                IDLE: begin
                    // Explicitly reset the counter for determinism
                    inject_counter <= 4'd0; 
                    
                    A0 <= 8'd0; A1 <= 8'd0; A2 <= 8'd0; A3 <= 8'd0;
                    B0 <= 8'd0; B1 <= 8'd0; B2 <= 8'd0; B3 <= 8'd0;
                end

                LOAD_MATRIX: begin
                    inject_counter <= 4'd0; 
                    
                    // 1-cycle bulk wire extraction
                    for (i = 0; i < 16; i = i + 1) begin
                        A_reg[i] <= matA_bulk_in[i*8 +: 8];
                        B_reg[i] <= matB_bulk_in[i*8 +: 8];
                    end
                end

                COMPUTE: begin
                    inject_counter <= inject_counter + 1;
                    
                    case(inject_counter)
                        4'd0: begin
                            A0 <= 8'd0; A1 <= 8'd0; A2 <= 8'd0; A3 <= 8'd0;
                            B0 <= 8'd0; B1 <= 8'd0; B2 <= 8'd0; B3 <= 8'd0;
                        end
                        4'd1: begin
                            A0 <= A_reg[0]; A1 <= 8'd0;     A2 <= 8'd0;     A3 <= 8'd0;
                            B0 <= B_reg[0]; B1 <= 8'd0;     B2 <= 8'd0;     B3 <= 8'd0;
                        end
                        4'd2: begin
                            A0 <= A_reg[1]; A1 <= A_reg[4]; A2 <= 8'd0;     A3 <= 8'd0;
                            B0 <= B_reg[4]; B1 <= B_reg[1]; B2 <= 8'd0;     B3 <= 8'd0;
                        end
                        4'd3: begin
                            A0 <= A_reg[2]; A1 <= A_reg[5]; A2 <= A_reg[8]; A3 <= 8'd0;
                            B0 <= B_reg[8]; B1 <= B_reg[5]; B2 <= B_reg[2]; B3 <= 8'd0;
                        end
                        4'd4: begin
                            A0 <= A_reg[3]; A1 <= A_reg[6]; A2 <= A_reg[9]; A3 <= A_reg[12];
                            B0 <= B_reg[12];B1 <= B_reg[9]; B2 <= B_reg[6]; B3 <= B_reg[3];
                        end
                        4'd5: begin
                            A0 <= 8'd0;     A1 <= A_reg[7]; A2 <= A_reg[10];A3 <= A_reg[13];
                            B0 <= 8'd0;     B1 <= B_reg[13];B2 <= B_reg[10];B3 <= B_reg[7];
                        end
                        4'd6: begin
                            A0 <= 8'd0;     A1 <= 8'd0;     A2 <= A_reg[11];A3 <= A_reg[14];
                            B0 <= 8'd0;     B1 <= 8'd0;     B2 <= B_reg[14];B3 <= B_reg[11];
                        end
                        4'd7: begin
                            A0 <= 8'd0;     A1 <= 8'd0;     A2 <= 8'd0;     A3 <= A_reg[15];
                            B0 <= 8'd0;     B1 <= 8'd0;     B2 <= 8'd0;     B3 <= B_reg[15];
                        end
                        
                        // Flush cycles (8, 9, 10)
                        default: begin
                            A0 <= 8'd0; A1 <= 8'd0; A2 <= 8'd0; A3 <= 8'd0;
                            B0 <= 8'd0; B1 <= 8'd0; B2 <= 8'd0; B3 <= 8'd0;
                        end
                    endcase
                end

                WRITE_RESULT: begin
                    result_we <= 1'b1;
                    
                    A0 <= 8'd0; A1 <= 8'd0; A2 <= 8'd0; A3 <= 8'd0;
                    B0 <= 8'd0; B1 <= 8'd0; B2 <= 8'd0; B3 <= 8'd0;
                end
            endcase
        end
    end

    //==========================================
    // SMRD Read Logic (Combinational)
    //==========================================
    // CPU contract: Stall the pipeline if a SMRD instruction is fetched and busy == 1.
    // Zero-extends the 18-bit SRAM payload into a standard 32-bit CPU register width.
    assign read_data = {14'd0, result_sram_dout};

endmodule