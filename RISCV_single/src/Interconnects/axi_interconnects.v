module axi_interconnect (
    input  wire        clk,
    input  wire        rst,

    // Master Interface
    input  wire [31:0] master_read_addr,
    input  wire        master_read_addr_valid,
    output reg         master_read_addr_ready,
    output reg  [31:0] master_read_data,
    output reg  [1:0]  master_read_resp,
    output reg         master_read_data_valid,
    input  wire        master_read_data_ready,

    input  wire [31:0] master_write_addr,
    input  wire        master_write_addr_valid,
    output reg         master_write_addr_ready,
    input  wire [31:0] master_write_data,
    input  wire [3:0]  master_write_strb,
    input  wire        master_write_data_valid,
    output reg         master_write_data_ready,
    output reg  [1:0]  master_write_resp,
    output reg         master_write_resp_valid,
    input  wire        master_write_resp_ready,

    // Memory Interface
    output reg  [31:0] mem_read_addr,
    output reg         mem_read_addr_valid,
    input  wire        mem_read_addr_ready,
    input  wire [31:0] mem_read_data,
    input  wire [1:0]  mem_read_resp,
    input  wire        mem_read_data_valid,
    output reg         mem_read_data_ready,

    output reg  [31:0] mem_write_addr,
    output reg         mem_write_addr_valid,
    input  wire        mem_write_addr_ready,
    output reg  [31:0] mem_write_data,
    output reg  [3:0]  mem_write_strb,
    output reg         mem_write_data_valid,
    input  wire        mem_write_data_ready,
    input  wire [1:0]  mem_write_resp,
    input  wire        mem_write_resp_valid,
    output reg         mem_write_resp_ready
);

    // ------------------------------------------------------------------
    // This interconnect is now REGISTERED (1 clock of latency per hop)
    // instead of purely combinational pass-through.
    //
    // Reason: a purely combinational pass-through here forms a real
    // combinational ring across module boundaries:
    //   interconnect_controller -> axi -> memory_controller -> axi -> back
    // Even once that ring settles to a stable fixed point, this specific
    // Icarus build keeps re-triggering the always@(*) blocks in that ring
    // forever and simulation time never advances (confirmed: identical,
    // unchanging signal values re-printed indefinitely). Registering the
    // pass-through breaks the combinational cycle -- each hop now takes a
    // real clock edge, so there is no same-timestep feedback path left.
    // ------------------------------------------------------------------s
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_read_addr           <= 32'b0;
            mem_read_addr_valid     <= 1'b0;
            master_read_addr_ready  <= 1'b0;

            master_read_data        <= 32'b0;
            master_read_resp        <= 2'b0;
            master_read_data_valid  <= 1'b0;
            mem_read_data_ready     <= 1'b0;

            mem_write_addr          <= 32'b0;
            mem_write_addr_valid    <= 1'b0;
            master_write_addr_ready <= 1'b0;

            mem_write_data          <= 32'b0;
            mem_write_strb          <= 4'b0;
            mem_write_data_valid    <= 1'b0;
            master_write_data_ready <= 1'b0;

            master_write_resp       <= 2'b0;
            master_write_resp_valid <= 1'b0;
            mem_write_resp_ready    <= 1'b0;
        end
        else begin
            // Read address channel
            mem_read_addr           <= master_read_addr;
            mem_read_addr_valid     <= master_read_addr_valid;
            master_read_addr_ready  <= mem_read_addr_ready;

            // Read data channel
            master_read_data        <= mem_read_data;
            master_read_resp        <= mem_read_resp;
            master_read_data_valid  <= mem_read_data_valid;
            mem_read_data_ready     <= master_read_data_ready;

            // Write address channel
            mem_write_addr          <= master_write_addr;
            mem_write_addr_valid    <= master_write_addr_valid;
            master_write_addr_ready <= mem_write_addr_ready;

            // Write data channel
            mem_write_data          <= master_write_data;
            mem_write_strb          <= master_write_strb;
            mem_write_data_valid    <= master_write_data_valid;
            master_write_data_ready <= mem_write_data_ready;

            // Write response channel
            master_write_resp       <= mem_write_resp;
            master_write_resp_valid <= mem_write_resp_valid;
            mem_write_resp_ready    <= master_write_resp_ready;
        end
    end

endmodule