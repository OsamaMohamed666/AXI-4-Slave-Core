// `define ADDR_WIDTH 8
// `define FIFO_DEPTH (1 << `ADDR_WIDTH)  // 256 entries


module Top_Read_Transaction (
  // Clock & Reset
  input  wire                    clk,
  input  wire                    rst_n,

  // AXI Read Address Channel (Master → Slave Core)
  input  wire                    ar_valid,
  input  wire [31:0]             ar_addr,
  input  wire [5:0]              ar_id,
  input  wire [7:0]              ar_len,
  input  wire [2:0]              ar_size,
  input  wire [1:0]              ar_burst,
  input  wire [2:0]              ar_prot,
  output wire                    ar_ready,

  // AXI Read Data Channel (Slave Core → Master)
  output wire                    r_valid,
  output wire [31:0]             r_data,
  output wire [5:0]              r_id,
  output wire /*[1:0]*/          r_resp,
  output wire                    r_last,
  input  wire                    r_ready,

  // Slave and Core Interface
  input                          slave_addr_ready,
  output wire [2:0]              slave_ar_prot,
  output wire                    slave_addr_valid,
  output wire [31:0]             slave_ar_addr,

  input                          slave_data_valid,
  input  wire [31:0]             slave_r_data
);

  // ============================================================================
  // INTERNAL SIGNALS
  // ============================================================================

  // FIFO signals
  wire                           ar_fifo_wr_en;
  wire                           ar_fifo_rd_en;
  wire                           fifo_full;
  wire                           fifo_empty;
  wire                           strt_rd_transaction;
  wire [`ADDR_WIDTH-1:0]         rd_fifo_ptr;  // Read ptr for r channel
  wire  [5:0]                     r_fifo_id;
  wire  [31:0]                    fifo_ar_addr;
  wire  [7:0]                     fifo_ar_len;
  wire  [2:0]                     fifo_ar_size;
  wire  [1:0]                     fifo_ar_burst;
  wire  [2:0]                     fifo_ar_prot;
  wire  [`ADDR_WIDTH-1:0]         r_rd_ptr;  // Read ptr when RLAST high

  // AR Channel signals
  wire [8:0]                     beats_no;
  wire                           ar_transfer_done;
  wire                           address_count_busy;

  // ============================================================================
  // SUBMODULE INSTANTIATIONS
  // ============================================================================

  // FIFO for read addresses
  Read_FIFO u_read_fifo (
    .clk                (clk),
    .rst_n              (rst_n),

    // AR Channel inputs
    .ar_fifo_wr_en      (ar_fifo_wr_en),
    .ar_id              (ar_id),
    .ar_addr            (ar_addr),
    .ar_len             (ar_len),
    .ar_size            (ar_size),
    .ar_burst           (ar_burst),
    .ar_prot            (ar_prot),

    // FIFO read control
    .ar_fifo_rd_en      (ar_fifo_rd_en),
    .r_rd_ptr           (r_rd_ptr),

    // FIFO outputs
    .r_fifo_id          (r_fifo_id),
    .ar_fifo_addr       (fifo_ar_addr),
    .ar_fifo_len        (fifo_ar_len),
    .ar_fifo_size       (fifo_ar_size),
    .ar_fifo_burst      (fifo_ar_burst),
    .ar_fifo_prot       (fifo_ar_prot),
    .rd_ptr        (rd_fifo_ptr),

    // Flags
    .full_flag          (fifo_full),
    .empty_flag         (fifo_empty),
    .strt_rd_transaction(strt_rd_transaction)
  );

  // AR Channel handler (address generator)
  AXI_AR_channel u_axi_ar_channel (
    .clk                (clk),
    .rst_n              (rst_n),

    // Inputs from FIFO
    .ar_valid           (strt_rd_transaction),
    .fifo_ar_addr       (fifo_ar_addr),
    .fifo_ar_len        (fifo_ar_len),
    .fifo_ar_size       (fifo_ar_size),
    .fifo_ar_prot       (fifo_ar_prot),
    .fifo_ar_burst      (fifo_ar_burst),
    .full_flag          (fifo_full),
    .strt_rd_transaction(strt_rd_transaction),

    // Outputs
    .beats_no           (beats_no),
    .ar_ready           (ar_ready),  // To master

    // To slave memory
    .slave_ar_prot      (slave_ar_prot),
    .slave_ar_addr      (slave_ar_addr),
    .slave_addr_valid   (slave_addr_valid),
    .slave_addr_ready   (slave_addr_ready),  // Added missing connection

    // Control flags
    .address_count_busy(address_count_busy),
    .ar_transfer_done   (ar_transfer_done)
  );

  // R Channel handler 
  AXI_R_channel u_axi_r_channel (
    .clk                (clk),
    .rst_n              (rst_n),

    .ar_transfer_done   (ar_transfer_done),
    .slave_data_valid   (slave_data_valid),
    .slave_r_data       (slave_r_data),

    .r_fifo_id          (r_fifo_id),
    .r_ready            (r_ready),
    .beats_no           (beats_no),
    .fifo_rd_ptr        (rd_fifo_ptr),

    .r_rd_ptr           (r_rd_ptr),  // To FIFO

    .r_resp             (r_resp),
    .r_valid            (r_valid),
    .r_id               (r_id),
    .r_data             (r_data),
    .r_last             (r_last)
  );

  // ============================================================================
  // CONTROL LOGIC
  // ============================================================================

  // FIFO write enable = AR handshake complete
  assign ar_fifo_wr_en = ar_valid && ar_ready;

  // FIFO read enable = Address generator ready + not busy
  assign ar_fifo_rd_en = slave_addr_ready && !address_count_busy;

endmodule
