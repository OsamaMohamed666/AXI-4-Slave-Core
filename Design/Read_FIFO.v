module Read_FIFO(

  input                 clk,
  input                 rst_n,

  // AR-CHANNEL
  input                 ar_fifo_wr_en, // write enable for fifo (ARVALID && ARREADY HIGH)
  input [5:0]           ar_id,
  input [31:0]          ar_addr,
  input [7:0]           ar_len,
  input [2:0]           ar_size,
  input [1:0]           ar_burst,
  input [2:0]           ar_prot,
  input                 ar_fifo_rd_en, // slave ready to accept new addr (slave_addr_ready && !ar_addr_busy)

  input [`ADDR_WIDTH-1:0] r_rd_ptr,

  output  reg [5:0]     r_fifo_id,
  output  reg [31:0]    ar_fifo_addr,
  output  reg [7:0]     ar_fifo_len,
  output  reg [2:0]     ar_fifo_size,
  output  reg [1:0]     ar_fifo_burst,
  output  reg [2:0]     ar_fifo_prot,

  //FLAGS
  output                full_flag,
  output                empty_flag,
  output reg [`ADDR_WIDTH-1:0] rd_ptr, // Read pointer
  output reg            strt_rd_transaction
);

  // FIFO storage
  // Each entry is 54 bits: {ar_id,ar_len, ar_size, ar_burst, ar_prot,ar_addr}
  reg [53:0] fifo_r [`FIFO_DEPTH -1 :0];


  wire [53:0] fifo_wr_data;
  assign fifo_wr_data = {ar_id,ar_len,ar_size,ar_burst,ar_prot,ar_addr};

  //Pointers
  reg [`ADDR_WIDTH-1:0] wr_ptr; // Write pointer
  // reg [`ADDR_WIDTH-1:0] rd_ptr; // read pointer



  //Flags
  assign full_flag = (wr_ptr +1 == rd_ptr );
  assign empty_flag = (wr_ptr == rd_ptr);

  // Write logic
  integer i;
  always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      // for (i=0; i<`FIFO_DEPTH; i = i+1) begin
      //   fifo_r[i] <= 54'b0;
      // end
      wr_ptr <= 8'b0;
    end
    else if (ar_fifo_wr_en && !full_flag ) begin //once fifo not full and arvalid high write in it
      fifo_r[wr_ptr] <= fifo_wr_data;
      wr_ptr <= wr_ptr +1;
    end
  end

  // Read logic
  always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ar_fifo_addr <= 32'b0;
      ar_fifo_prot <= 3'b0;
      ar_fifo_burst <= 2'b0;
      ar_fifo_size <= 3'b0;
      ar_fifo_len <= 8'b0;
      r_fifo_id <= 6'b0;
      rd_ptr <= 1'b0;
      strt_rd_transaction <= 1'b0;
    end

    // FIRST CONDITION TO READ
    else if(ar_fifo_rd_en && !empty_flag && (rd_ptr == 'd0)) begin // first reading OF FIFO
      ar_fifo_addr <= fifo_r[rd_ptr][31:0];
      ar_fifo_prot <= fifo_r[rd_ptr][34:32];
      ar_fifo_burst <= fifo_r[rd_ptr][36:35];
      ar_fifo_size <= fifo_r[rd_ptr][39:37];
      ar_fifo_len <= fifo_r[rd_ptr][47:40];
      r_fifo_id <= fifo_r[rd_ptr][53:48];
      rd_ptr <= rd_ptr +1;
      strt_rd_transaction <= 1'b1;

    end

    //SECOND CONDITION TO READ
    else if (ar_fifo_rd_en && !empty_flag && (rd_ptr == r_rd_ptr)) begin
      ar_fifo_addr <= fifo_r[rd_ptr][31:0];
      ar_fifo_prot <= fifo_r[rd_ptr][34:32];
      ar_fifo_burst <= fifo_r[rd_ptr][36:35];
      ar_fifo_size <= fifo_r[rd_ptr][39:37];
      ar_fifo_len <= fifo_r[rd_ptr][47:40];
      r_fifo_id <= fifo_r[rd_ptr][53:48];
      rd_ptr <= rd_ptr +1;
      strt_rd_transaction <= 1'b1;
    end

    else
      strt_rd_transaction <= 1'b0;
  end



endmodule

