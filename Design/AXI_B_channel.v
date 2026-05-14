  // `define ADDR_WIDTH 8

module AXI_B_channel (

  input                           clk,
  input                           rst_n,

  input                           b_ready,
  input       [2:0]               fifo_aw_size,
  input                           slave_w_last,
  input                           write_transfer_done,
  input       [5:0]               b_fifo_id,
  input       [`ADDR_WIDTH -1 :0] aw_rd_ptr,
  input       [`ADDR_WIDTH -1 :0] w_rd_ptr,

  output  reg [`ADDR_WIDTH -1:0]  b_aw_rd_ptr,
  output  reg [`ADDR_WIDTH :0]    b_w_rd_ptr,
  output  reg [5:0]               b_id,
  output  reg [1:0]               b_resp,
  output  reg                     b_valid
);

  //BRESP VALUES
  localparam [1:0]  SLVERR = 2'b10,
                    EXOKAY = 2'b01, // detecting wlast not equal one
                    OKAY = 2'b00;

  reg size_err;
  always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      b_resp  <= 2'b0;
      b_valid <= 1'b0;
      b_id <= 'b0;
      b_aw_rd_ptr <= 0;
      b_w_rd_ptr <=0;
      size_err <=0;
    end

    else if (write_transfer_done) begin
        b_valid <= 1'b1;
        b_id  <= b_fifo_id;
        b_resp  <= fifo_aw_size > 2 ? SLVERR : slave_w_last ? OKAY : EXOKAY;

      end

    else if (b_ready && b_valid) begin // handshake now completed now deassert b_valid
        b_valid <= 1'b0;
        b_aw_rd_ptr <= aw_rd_ptr;
        b_w_rd_ptr <= w_rd_ptr;
      end

  end


endmodule
