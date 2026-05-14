

//`include "Write_FIFO.v"
//`include "AXI_Write_channel.v"
//`include "AXI_B_channel.v"

module Top_Write_Transaction (
  // Clock & Reset
  input  wire         clk,
  input  wire         rst_n,

  // AXI Write Address Channel (Master → Core)
  input  wire         aw_valid,
  input  wire [31:0]  aw_addr,
  input  wire [5:0]   aw_id,
  input  wire [7:0]   aw_len,
  input  wire [2:0]   aw_size,
  input  wire [1:0]   aw_burst,
  input  wire [2:0]   aw_prot,
  output wire         aw_ready,

  // AXI Write Data Channel (Master → Core)
  input  wire         w_valid,
  input  wire [31:0]  w_data,
  input  wire         w_last,
  input  wire [3:0]   w_strb,
  output wire         w_ready,

  // AXI Write Response Channel (Core → Master)
  output wire         b_valid,
  output wire [5:0]   b_id,
  output wire [1:0]   b_resp,
  input  wire         b_ready,

  // Slave Interface
  output wire [31:0]  slave_aw_addr,
  output wire [2:0]   slave_aw_prot,
  output wire [31:0]  slave_w_data,
  output wire [3:0]   slave_w_strb,
  output wire         write_trans_valid,
  input  wire         slave_write_ready
);

  // Internal signals
  wire aw_fifo_wr_en;
  wire w_fifo_wr_en;
  wire addr_full_flag;
  wire data_full_flag;
  wire data_empty_flag;
  wire strt_addr_transfer;
  wire strt_data_transfer;
  wire write_transfer_done;
  wire addr_burst_busy;
  wire data_burst_busy;
  wire slave_w_last;
  wire [`ADDR_WIDTH:0] w_data_count;

  // FIFO outputs
  wire [5:0]  b_fifo_id;
  wire [31:0] aw_fifo_addr;
  wire [7:0]  aw_fifo_len;
  wire [2:0]  aw_fifo_size;
  wire [1:0]  aw_fifo_burst;
  wire [2:0]  aw_fifo_prot;
  wire [31:0] w_fifo_data;
  wire [3:0]  w_fifo_strb;
  wire        w_fifo_last;
  wire [`ADDR_WIDTH-1:0] aw_rd_ptr;
  wire [`ADDR_WIDTH-1:0]   w_rd_ptr;

  // B channel pointers
  wire [`ADDR_WIDTH-1:0] b_aw_rd_ptr;
  wire [`ADDR_WIDTH:0]   b_w_rd_ptr;

  // Submodule instantiations
  Write_FIFO u_write_fifo (
    .clk(clk),
    .rst_n(rst_n),

    // AW channel inputs
    .aw_fifo_wr_en(aw_fifo_wr_en),
    .aw_id(aw_id),
    .aw_addr(aw_addr),
    .aw_len(aw_len),
    .aw_size(aw_size),
    .aw_burst(aw_burst),
    .aw_prot(aw_prot),
    .slave_write_ready(slave_write_ready),
    .write_trans_valid(write_trans_valid),
    .addr_burst_busy(addr_burst_busy),

    .b_aw_rd_ptr(b_aw_rd_ptr),

    // AW channel outputs
    .b_fifo_id(b_fifo_id),
    .aw_fifo_addr(aw_fifo_addr),
    .aw_fifo_len(aw_fifo_len),
    .aw_fifo_size(aw_fifo_size),
    .aw_fifo_burst(aw_fifo_burst),
    .aw_fifo_prot(aw_fifo_prot),
    // B channel inputs
    .b_ready(b_ready),
    .b_valid(b_valid),
    .w_data_count(w_data_count),
    // W channel inputs
    .w_fifo_wr_en(w_fifo_wr_en),
    .w_data(w_data),
    .w_last(w_last),
    .w_strb(w_strb),
    .data_burst_busy(data_burst_busy),

    .b_w_rd_ptr(b_w_rd_ptr),

    // W channel outputs
    .w_fifo_data(w_fifo_data),
    .w_fifo_last(w_fifo_last),
    .w_fifo_strb(w_fifo_strb),

    // Flags
    .addr_full_flag(addr_full_flag),
    .strt_addr_transfer(strt_addr_transfer),
    .aw_rd_ptr(aw_rd_ptr),

    .data_full_flag(data_full_flag),
    .data_empty_flag(data_empty_flag),
    .w_rd_ptr(w_rd_ptr),
    .strt_data_transfer(strt_data_transfer)
  );

  AXI_Write_channel u_axi_write_channel (
    .clk(clk),
    .rst_n(rst_n),

    // Data channel
    .fifo_w_data(w_fifo_data),
    .fifo_w_strb(w_fifo_strb),
    .data_full_flag(data_full_flag),
    .data_empty_flag(data_empty_flag),
    .w_ready(w_ready),

    .slave_write_ready(slave_write_ready),
    .slave_w_data(slave_w_data),
    .slave_w_strb(slave_w_strb),
    .w_data_count(w_data_count),

    // Address channel
    .fifo_aw_addr(aw_fifo_addr),
    .fifo_aw_burst(aw_fifo_burst),
    .fifo_aw_size(aw_fifo_size),
    .fifo_aw_prot(aw_fifo_prot),
    .fifo_aw_len(aw_fifo_len),
    .addr_full_flag(addr_full_flag),
    .aw_ready(aw_ready),

    .slave_aw_addr(slave_aw_addr),
    .slave_aw_prot(slave_aw_prot),

    // Control flags
    .strt_addr_transfer(strt_addr_transfer),
    .strt_data_transfer(strt_data_transfer),
    .write_transfer_done(write_transfer_done),
    .addr_burst_busy(addr_burst_busy),
    .data_burst_busy(data_burst_busy),
    .write_trans_valid(write_trans_valid)
  );

  AXI_B_channel u_axi_b_channel (
    .clk(clk),
    .rst_n(rst_n),

    .b_ready(b_ready),
    .fifo_aw_size(aw_fifo_size),
    .slave_w_last(w_fifo_last),
    .write_transfer_done(write_transfer_done),
    .b_fifo_id(b_fifo_id),
    .aw_rd_ptr(aw_rd_ptr),
    .w_rd_ptr(w_rd_ptr),

    .b_w_rd_ptr(b_w_rd_ptr),
    .b_aw_rd_ptr(b_aw_rd_ptr),
    .b_id(b_id),
    .b_resp(b_resp),
    .b_valid(b_valid)
  );

  // Control logic
  assign aw_fifo_wr_en = aw_valid;
  assign w_fifo_wr_en = w_valid;


endmodule
