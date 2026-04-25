  //=================================================================================================
  //====================== TWO FIFOS: One for ADDRESS another for DATA
  //=================================================================================================

  // `define ADDR_WIDTH 8
  // `define FIFO_DEPTH (1 << `ADDR_WIDTH)

  module Write_FIFO(
    //GLOBAL SIGNALS
    input                         clk,
    input                         rst_n,

    input                         slave_write_ready,
    // AW-CHANNEL
    input                         aw_fifo_wr_en, // write enable for fifo (AWVALID HIGH)
    input       [5:0]             aw_id,
    input       [31:0]            aw_addr,
    input       [7:0]             aw_len,
    input       [2:0]             aw_size,
    input       [1:0]             aw_burst,
    input       [2:0]             aw_prot,
    input                         addr_burst_busy,

    input       [`ADDR_WIDTH-1:0] b_aw_rd_ptr,

    output  reg [5:0]             b_fifo_id, // bchannel
    output  reg [31:0]            aw_fifo_addr,
    output  reg [7:0]             aw_fifo_len,
    output  reg [2:0]             aw_fifo_size,
    output  reg [1:0]             aw_fifo_burst,
    output  reg [2:0]             aw_fifo_prot,

    // W-CHANNEL
    input                         w_fifo_wr_en, // write enable for fifo (WVALID HIGH)
    input       [31:0]            w_data,
    input                         w_last,
    input       [3:0]             w_strb,
    input                         data_burst_busy,

    input       [`ADDR_WIDTH-1:0] b_w_rd_ptr,
    input       [`ADDR_WIDTH-1:0] w_data_count,

    output  reg [31:0]            w_fifo_data,
    output  reg                   w_fifo_last,
    output  reg [3:0]             w_fifo_strb,

    // B-Channel
    input                         b_valid,
    input                         b_ready,

    // FLAGS
    //aw_channel
    output                       addr_full_flag,
    output reg                   strt_addr_transfer,
    output reg [`ADDR_WIDTH-1:0] aw_rd_ptr, // Read pointer for address channel

    //w_channel
    output                       data_full_flag,
    output                       data_empty_flag,
    output reg [`ADDR_WIDTH-1:0] w_rd_ptr, // Read pointer for data channel
    output reg                   strt_data_transfer
  );

    //________________________________________ADDRESS FIFO________________________________________//

    // FIFO storage
    // Each entry is 54 bits: {aw_id,aw_len, aw_size, aw_burst, aw_prot,aw_addr}
    reg [53:0] fifo_aw [0: `FIFO_DEPTH-1];

    wire [53:0] aw_fifo_wr_data;
    assign aw_fifo_wr_data = {aw_id,aw_len,aw_size,aw_burst,aw_prot,aw_addr};

    // Write Pointer
    reg [`ADDR_WIDTH-1:0] aw_wr_ptr;


    //Flags
    wire addr_empty_flag;

    assign addr_empty_flag = (aw_wr_ptr == aw_rd_ptr);
    assign addr_full_flag = (aw_wr_ptr +1 == aw_rd_ptr );


    //------------------------------------------
    // WRITE LOGIC
    //------------------------------------------
    always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        aw_wr_ptr <= 'b0;
      end
      //once fifo not full and awvalid high write in it
      else if (aw_fifo_wr_en && !addr_full_flag ) begin
        fifo_aw[aw_wr_ptr] <= aw_fifo_wr_data;
        aw_wr_ptr <= aw_wr_ptr +'d1;
      end
    end


    //------------------------------------------
    // READ LOGIC
    //------------------------------------------
    wire aw_fifo_rd_en;
    assign aw_fifo_rd_en = !addr_burst_busy;

    always @ (posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        aw_fifo_addr <= 32'b0;
        aw_fifo_prot <= 3'b0;
        aw_fifo_burst <= 2'b0;
        aw_fifo_size <= 3'b0;
        aw_fifo_len <= 8'b0;
        b_fifo_id <= 6'b0;
        aw_rd_ptr <= 'b0;
        strt_addr_transfer <= 1'b0;
      end

      // FIRST CONDITION TO READ: FIRST READING OF FIFO WHEN IT GOT A
      else if(aw_fifo_rd_en && !addr_empty_flag && (aw_rd_ptr == 'd0)) begin
        aw_fifo_addr <= fifo_aw[aw_rd_ptr][31:0];
        aw_fifo_prot <= fifo_aw[aw_rd_ptr][34:32];
        aw_fifo_burst <= fifo_aw[aw_rd_ptr][36:35];
        aw_fifo_size <= fifo_aw[aw_rd_ptr][39:37];
        aw_fifo_len <= fifo_aw[aw_rd_ptr][47:40];
        b_fifo_id <= fifo_aw[aw_rd_ptr][53:48];
        aw_rd_ptr <= aw_rd_ptr +1;
        strt_addr_transfer <= 1'b1;

      end

      // SECOND CONDITION TO READ: if back 2 back transactions
      else if (aw_fifo_rd_en && !addr_empty_flag && (b_ready && b_valid) )begin
        aw_fifo_addr <= fifo_aw[aw_rd_ptr][31:0];
        aw_fifo_prot <= fifo_aw[aw_rd_ptr][34:32];
        aw_fifo_burst <= fifo_aw[aw_rd_ptr][36:35];
        aw_fifo_size <= fifo_aw[aw_rd_ptr][39:37];
        aw_fifo_len <= fifo_aw[aw_rd_ptr][47:40];
        b_fifo_id <= fifo_aw[aw_rd_ptr][53:48];
        aw_rd_ptr <= aw_rd_ptr +1;
        strt_addr_transfer <= 1'b1;
      end

      // THIRD CONDITION TO READ
      else if (aw_fifo_rd_en && !addr_empty_flag && (aw_rd_ptr == b_aw_rd_ptr)) begin
        aw_fifo_addr <= fifo_aw[aw_rd_ptr][31:0];
        aw_fifo_prot <= fifo_aw[aw_rd_ptr][34:32];
        aw_fifo_burst <= fifo_aw[aw_rd_ptr][36:35];
        aw_fifo_size <= fifo_aw[aw_rd_ptr][39:37];
        aw_fifo_len <= fifo_aw[aw_rd_ptr][47:40];
        b_fifo_id <= fifo_aw[aw_rd_ptr][53:48];
        aw_rd_ptr <= aw_rd_ptr +1;
        strt_addr_transfer <= 1'b1;
      end

      else
        strt_addr_transfer <= 1'b0;
    end

    //________________________________________DATA FIFO________________________________________//

    // FIFO storage
    // Each entry is 33 bits: {WLAST,WDATA}
    reg [36:0] fifo_w [0 : `FIFO_DEPTH-1];

    wire [36:0] w_fifo_wr_data;
    assign w_fifo_wr_data = {w_strb,w_last,w_data};

    // Write Pointers
    reg [`ADDR_WIDTH-1:0] w_wr_ptr;

    //Flags
    assign data_empty_flag = (w_wr_ptr == w_rd_ptr);
    assign data_full_flag = (w_wr_ptr +1 == w_rd_ptr );

    //------------------------------------------
    // WRITE LOGIC
    //------------------------------------------
    always @ (posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        w_wr_ptr <= 'b0;
      end
      //Once fifo not full and wvalid high write in it
      else if (w_fifo_wr_en && !data_full_flag ) begin
        fifo_w[w_wr_ptr] <= w_fifo_wr_data;
        w_wr_ptr <= w_wr_ptr +'d1;
      end
    end

    //------------------------------------------
    // READ LOGIC
    //------------------------------------------

    always @ (posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        w_fifo_data <= 32'b0;
        w_fifo_last <= 1'b0;
        w_fifo_strb <= 4'b0;
        strt_data_transfer <= 1'b0;
        w_rd_ptr <= 1'b0;
      end

      // FIRST CONDITION TO READ: THE INITIAL READING FROM FIFO
      else if((!data_burst_busy) && !data_empty_flag && (w_rd_ptr == 'd0)) begin
        w_fifo_data <= fifo_w[w_rd_ptr][31:0];
        w_fifo_last <= fifo_w[w_rd_ptr][32];
        w_fifo_strb <= fifo_w[w_rd_ptr][36:33];
        w_rd_ptr <= w_rd_ptr +1;
        strt_data_transfer <= 1'b1;
      end

      // SECOND CONDITION TO READ: BURST IS ALREADY PROCESSING
      // Using addr_burst_busy as it's always high during brust processing of data and address
      else if ( addr_burst_busy && (~|w_data_count || slave_write_ready) && !data_empty_flag && (w_rd_ptr != (b_w_rd_ptr + (aw_fifo_len + 9'd1)))) begin
        w_fifo_data <= fifo_w[w_rd_ptr][31:0];
        w_fifo_last <= fifo_w[w_rd_ptr][32];
        w_fifo_strb <= fifo_w[w_rd_ptr][36:33];
        w_rd_ptr <= w_rd_ptr +1;
        strt_data_transfer <= 1'b0;
      end

      // THIRD CONDITION TO READ: NOT THE INITIAL READING
      else if ((!data_burst_busy) && !data_empty_flag && (b_valid && b_ready)) begin
        w_fifo_data <= fifo_w[w_rd_ptr][31:0];
        w_fifo_last <= fifo_w[w_rd_ptr][32];
        w_fifo_strb <= fifo_w[w_rd_ptr][36:33];
        w_rd_ptr <= w_rd_ptr +1;
        strt_data_transfer <= 1'b1;
      end

      else
        strt_data_transfer <= 1'b0;
    end



  endmodule

