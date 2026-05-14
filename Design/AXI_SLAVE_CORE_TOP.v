  `define ADDR_WIDTH 8
  `define FIFO_DEPTH (1 << `ADDR_WIDTH)

  // Read Transaction
  //-------------------------------------------
  `include"Read_FIFO.v"
  `include"AXI_AR_channel.v"
  `include"AXI_R_channel.v"
  `include"Top_Read_Transaction.v"

  // Write Transaction
  //-------------------------------------------
  `include"Write_FIFO.v"
  `include"AXI_Write_channel.v"
  `include"AXI_B_channel.v"
  `include"Top_Write_Transaction.v"

module AXI_SLAVE_CORE_TOP(
  // Clock & Reset
  input  wire         clk,
  input  wire         rst_n,

  //-------------------------------------------
  // FIRST WRITE TRANSACTION
  //-------------------------------------------

  // AXI Write Address Channel (Master → Slave Core)
  input  wire         AWVALID,
  input  wire [31:0]  AWADDR,
  input  wire [5:0]   AWID,
  input  wire [7:0]   AWLEN,
  input  wire [2:0]   AWSIZE,
  input  wire [1:0]   AWBURST,
  input  wire [2:0]   AWPROT,
  output wire         AWREADY,

  // AXI Write Data Channel (Master → Slave Core)
  input  wire         WVALID,
  input  wire [31:0]  WDATA,
  input  wire         WLAST,
  input  wire [3:0]   WSTRB,
  output wire         WREADY,

  // AXI Write Response Channel (Slave Core → Master)
  output wire         BVALID,
  output wire [5:0]   BID,
  output wire [1:0]   BRESP,
  input  wire         BREADY,

  // Slave Interface
  output wire [31:0]  slave_aw_addr,
  output wire [2:0]   slave_aw_prot,
  output wire [31:0]  slave_w_data,
  output wire [3:0]   slave_w_strb,
  output wire         write_aw_trans_valid,
  input  wire         slave_aw_write_ready,

  //-------------------------------------------
  // SECOND READ TRANSACTION
  //-------------------------------------------

  // AXI Read Address Channel (Master → Slave Core)
  input  wire                    ARVALID,
  input  wire [31:0]             ARADDR,
  input  wire [5:0]              ARID,
  input  wire [7:0]              ARLEN,
  input  wire [2:0]              ARSIZE,
  input  wire [1:0]              ARBURST,
  input  wire [2:0]              ARPROT,
  output wire                    ARREADY,

  // AXI Read Data Channel (Slave Core → Master)
  output wire                    RVALID,
  output wire [31:0]             RDATA,
  output wire [5:0]              RID,
  output wire /*[1:0]*/          RRESP,
  output wire                    RLAST,
  input  wire                    RREADY,

  // Slave and Core Interface
  input                          slave_ar_addr_ready,
  output wire [2:0]              slave_ar_prot,
  output wire                    slave_ar_addr_valid,
  output wire [31:0]             slave_ar_addr,

  input                          slave_r_data_valid,
  input  wire [31:0]             slave_r_data
);

//-------------------------------------------
// FIRST WRITE TRANSACTION INSTANTIATION
//-------------------------------------------
Top_Write_Transaction u_write_trans (
.clk(clk),
.rst_n(rst_n),
.aw_valid(AWVALID),
.aw_addr(AWADDR),
.aw_id(AWID),
.aw_len(AWLEN),
.aw_size(AWSIZE),
.aw_burst(AWBURST),
.aw_prot(AWPROT),
.aw_ready(AWREADY),
.w_valid(WVALID),
.w_data(WDATA),
.w_last(WLAST),
.w_strb(WSTRB),
.w_ready(WREADY),
.b_valid(BVALID),
.b_id(BID),
.b_resp(BRESP),
.b_ready(BREADY),
.slave_aw_addr(slave_aw_addr),
.slave_aw_prot(slave_aw_prot),
.slave_w_data(slave_w_data),
.slave_w_strb(slave_w_strb),
.write_trans_valid(write_aw_trans_valid),
.slave_write_ready(slave_aw_write_ready)
);



//-------------------------------------------
// SECOND READ TRANSACTION INSTANTIATION
//-------------------------------------------
Top_Read_Transaction u_read_trans (
.clk(clk),
.rst_n(rst_n),
.ar_valid(ARVALID),
.ar_addr(ARADDR),
.ar_id(ARID),
.ar_len(ARLEN),
.ar_size(ARSIZE),
.ar_burst(ARBURST),
.ar_prot(ARPROT),
.ar_ready(ARREADY),
.r_valid(RVALID),
.r_data(RDATA),
.r_id(RID),
.r_resp(RRESP),
.r_last(RLAST),
.r_ready(RREADY),
.slave_addr_ready(slave_ar_addr_ready),
.slave_ar_prot(slave_ar_prot),
.slave_addr_valid(slave_ar_addr_valid),
.slave_ar_addr(slave_ar_addr),
.slave_data_valid(slave_r_data_valid),
.slave_r_data(slave_r_data)
);

endmodule
