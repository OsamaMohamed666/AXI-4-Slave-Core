  //=================================================================================================
  //======================WRITE ADDRESS AND DATA CHANNELS (AW,W)
  //=================================================================================================

  module AXI_Write_channel(

    //GLOBAL SIGNALS
    input              clk,
    input              rst_n,


    //DATA CHANNEL
    input  [31:0]      fifo_w_data,
    input              fifo_w_last, // flag to indicate that the last data from master
    input  [3:0]       fifo_w_strb,
    output reg         w_ready,

    input              data_full_flag, // flag to indicate that the data fifo is full
    input              data_empty_flag, // flag to indicate that the data fifo is empty

    // output data to slave
    output reg [31:0]  slave_w_data,
    output reg         slave_w_last,
    output reg [3:0]   slave_w_strb,


    output reg       [`ADDR_WIDTH-1:0] w_data_count,

    //ADDRESS CHANNEL
    input      [31:0]  fifo_aw_addr,
    input      [1:0]   fifo_aw_burst,
    input      [2:0]   fifo_aw_size,
    input      [2:0]   fifo_aw_prot,
    input      [7:0]   fifo_aw_len,
    input              addr_full_flag, // flag to indicate that the address fifo is full
    output reg         aw_ready,

    output reg  [31:0] slave_aw_addr, // output address to slave
    output reg  [2:0]  slave_aw_prot, // output protection to slave

    //CONTROL FLAGS
    input              slave_write_ready, // slave ready to accept data and address
    input              strt_addr_transfer, // to indicate the start of address transfer from FIFO
    input              strt_data_transfer, // to indicate the start of data transfer from FIFO
    output             write_transfer_done,
    output reg         addr_burst_busy,
    output reg         data_burst_busy, // to indicate that the write transaction is done
    output reg         write_trans_valid // to indicate that the write transaction is valid
  );

  // CALCULATING BEATS NUMBER AND SIZE
    reg  [7:0] beats_size;
    wire [8:0] beats_no;
    assign beats_no = fifo_aw_len + 9'd1;
    always @ (fifo_aw_size) begin
      case (fifo_aw_size)
      3'b000 :  beats_size = 8'd1;
      3'b001 :  beats_size = 8'd2;
      3'b010 :  beats_size = 8'd4;
      3'b011 :  beats_size = 8'd8;
      3'b100 :  beats_size = 8'd16;
      3'b101 :  beats_size = 8'd32;
      3'b110 :  beats_size = 8'd64;
      3'b111 :  beats_size = 8'd128;
      default : beats_size = 8'd0;
      endcase
    end


    //READY FLAGS
    always @ (addr_full_flag , data_full_flag) begin
      aw_ready = ~addr_full_flag;
      w_ready = ~data_full_flag;
    end

    //________________________________________TRANSFER SCENARIOS________________________________________//

    // Internal signals
    wire                        write_trans_valid_temp;

    wire  [31:0]                addr_fixed; // Address temp for Fixed burst

    reg   [`ADDR_WIDTH -1 : 0]  aw_address_count;
    wire                        both_same_beat; // Address and data on the same beat

    assign both_same_beat = (aw_address_count == w_data_count)? 1'b1 : 1'b0;
    //------------------------------------------
    // FSM
    //------------------------------------------
    reg [2:0] cs, ns;
    localparam reg [2:0]  IDLE = 3'b000,
                          ADDRstrt_DATAhold =3'b001,
                          DATAstrt_ADDRhold =3'b011,
                          BOTH_IN_PROGRESS = 3'b010,
                          DATA_EMTPY_DURING_BURSTING = 3'b110;


    // State register
    //------------------------------------------
    always @(posedge clk or negedge rst_n) begin
      if(!rst_n) begin
        cs <= IDLE;
      end
      else begin
        cs <= ns;
      end
    end

    // Combinational logic
    //------------------------------------------
    always @ (*) begin
      addr_burst_busy = 1'b0;
      data_burst_busy = 1'b0;
      case (cs)
        IDLE: begin
          // FIRST SCENARIO MASTER SEND BOTH SIMULTANEOUSLY
          if (strt_addr_transfer && strt_data_transfer) begin
            ns = BOTH_IN_PROGRESS;
            addr_burst_busy = 1'b1;
            data_burst_busy = 1'b1;
          end
          // SECOND SCENARIO AW CHANNEL IS THE ONLY VALID
          else if (strt_addr_transfer) begin
            ns = ADDRstrt_DATAhold;
            addr_burst_busy = 1'b1;
          end
          // THIRD SCENARIO W CHANNEL IS THE ONLY VALID
          else if (strt_data_transfer) begin
            ns = DATAstrt_ADDRhold;
            data_burst_busy = 1'b1;
          end
          else begin
            ns = IDLE;
          end
        end

        ADDRstrt_DATAhold: begin
          addr_burst_busy = 1'b1;
          if(strt_data_transfer) begin
            data_burst_busy = 1'b1;
            ns = BOTH_IN_PROGRESS;
          end
          else begin
            data_burst_busy = 1'b0;
            ns = cs;
          end

        end
        DATAstrt_ADDRhold: begin
          data_burst_busy = 1'b1;
          if(strt_addr_transfer) begin
            addr_burst_busy = 1'b1;
            ns = BOTH_IN_PROGRESS;
          end
          else begin
            addr_burst_busy = 1'b0;
            ns = cs;
          end
        end

        BOTH_IN_PROGRESS: begin
          addr_burst_busy = 1'b1;
          data_burst_busy = 1'b1;

          // both counter are equal and equal to beat number then bursting is done
          if(both_same_beat && (w_data_count == beats_no) ) begin
            ns = IDLE;
            addr_burst_busy = 1'b0;
            data_burst_busy = 1'b0;
          end

          else if (data_empty_flag) begin
            ns = DATA_EMTPY_DURING_BURSTING;
          end

          else begin
            ns = cs;
            addr_burst_busy = 1'b1;
            data_burst_busy = 1'b1;
          end
        end

        DATA_EMTPY_DURING_BURSTING : begin
          addr_burst_busy = 1'b1;
          data_burst_busy = 1'b0;

          // both counter are equal and equal to beat number then bursting is done
          if(both_same_beat && (w_data_count == beats_no) ) begin
            ns = IDLE;
            addr_burst_busy = 1'b0;
            data_burst_busy = 1'b0;
          end

          else if(!data_empty_flag) begin
            ns = BOTH_IN_PROGRESS;
          end
          else begin
            ns = cs;
          end
        end


        default:  begin
          ns = IDLE;
          addr_burst_busy = 1'b0;
          data_burst_busy = 1'b0;
        end
      endcase
    end

    //________________________________________ADDRESS & DATA BURST COUNTERS________________________________________//

    //--------------------------------------------
    // AW Address Counter
    //--------------------------------------------
    wire addr_behind_data;
    assign addr_behind_data = (both_same_beat || aw_address_count < w_data_count)? 1'b1 : 1'b0;

    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
          aw_address_count <= 'h00;
      end

      else if (!addr_burst_busy) begin
        aw_address_count <= 'h00; // Reset after burst completion
      end

      else if (aw_address_count < beats_no  && addr_burst_busy && addr_behind_data && (slave_write_ready || (~|aw_address_count))) begin
          aw_address_count <= aw_address_count + 1'b1;  // Increment during burst
      end
    end

    //--------------------------------------------
    // W Data Counter
    //--------------------------------------------
    wire data_behind_addr;
    assign data_behind_addr = (both_same_beat || (w_data_count < aw_address_count)) ? 1'b1 : 1'b0;

    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
          w_data_count <= 'h00;
      end

      else if (!data_burst_busy && (w_data_count == beats_no)) begin
        w_data_count <= 'h00;  // Reset after burst completion
      end

      else if (w_data_count < beats_no  && data_burst_busy && data_behind_addr && (slave_write_ready || (~|w_data_count))) begin
          w_data_count <= w_data_count + 1'b1;  // Increment during burst
      end
    end


    //________________________________________ADDRESS BRUST TYPES LOGIC________________________________________//


    //-------------------------------------------
    // First Fixed
    //-------------------------------------------
    assign addr_fixed = fifo_aw_addr;

    //-------------------------------------------
    // Second INCR
    //-------------------------------------------
    wire is_incr; // flag to indicate INCR burst type

    assign is_incr = (fifo_aw_burst == 2'b01) ? 1'b1 : 1'b0;

    //-------------------------------------------
    // Third WRAP
    //-------------------------------------------
    wire is_wrap; // flag to indicate Wrap burst type

    assign is_wrap = (fifo_aw_burst == 2'b10) ? 1'b1 : 1'b0;

    // Axlen belong to {1,3,7,15} >>>>> no_beats == {2,4,8,16}
    // Starting address must be alligned to lower addr

    // Flag to indicate starting address
    reg is_starting_addr;

    // Calculating boundry and Checking Address alignment for starting address
    //-------------------------------------------
    wire [31:0] aligned_sa; // aligned starting addr
    wire [31:0] sa; //starting addr
    wire [31:0] wrap_boundry_size;
    wire [31:0] wrap_boundry_addr;

    assign sa =(is_starting_addr && is_wrap)? slave_aw_addr : 32'b0;
    assign wrap_boundry_size = (beats_no << fifo_aw_size); // boundry size
    assign aligned_sa = sa & ~(wrap_boundry_size - 31'd1); // alligned address
    assign wrap_boundry_addr = aligned_sa + wrap_boundry_size; // boundry address



  //________________________________________OUTPUTS________________________________________//

    //------------------------------------------------------------
    // Address generation for INCR && WRAP && FIXED burst types
    //------------------------------------------------------------

    always @ (posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        slave_aw_addr <= 32'b0;
        is_starting_addr <=0;
      end
      // Getting start address
      else if (!write_trans_valid && (is_incr || is_wrap) && strt_addr_transfer) begin
        slave_aw_addr <= fifo_aw_addr; //start address
        is_starting_addr <= 1'b1;
      end
      // For Wrap: The boundary was crossed case
      else if (addr_burst_busy && is_wrap && slave_write_ready && addr_behind_data && !(aw_address_count == beats_no) && !(slave_aw_addr + beats_size < wrap_boundry_addr)) begin
        slave_aw_addr <= (slave_aw_addr + beats_size) -  wrap_boundry_addr ;
        is_starting_addr <= 1'b0;
      end
      // For INCR && normal Wrap
      else if (addr_burst_busy && (is_incr || is_wrap) && slave_write_ready && addr_behind_data && !(aw_address_count == beats_no)) begin
        slave_aw_addr <= slave_aw_addr + beats_size;
        is_starting_addr <= 1'b0;
      end
      else if (fifo_aw_burst == 2'b00)begin
        is_starting_addr <= 0;
        slave_aw_addr <= addr_fixed;
      end
      else
        is_starting_addr <=0;
    end

    //------------------------------------------------------------
    // WRITE TRANSACTION VALID OUTPUT
    //------------------------------------------------------------
    assign  write_trans_valid_temp = addr_burst_busy && data_burst_busy;


    always @ (posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        write_trans_valid <= 1'b0;
      end
      else begin
        write_trans_valid <= write_trans_valid_temp;
      end
    end

    //------------------------------------------------------------
    // WRITE DATA OUTPUT && STRB
    //------------------------------------------------------------
    always @ (posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        slave_w_data <= 32'b0;
        slave_w_strb <= 4'b0;
      end
      // First data out on the bus
      else if (write_trans_valid_temp && (~|w_data_count)) begin
        slave_w_data <= fifo_w_data;
        slave_w_strb <= fifo_w_strb;
      end
      // After handshake put new data from fifo on bus
      else if (write_trans_valid_temp && slave_write_ready) begin
        slave_w_data <= fifo_w_data;
        slave_w_strb <= fifo_w_strb;
      end
    end

    //------------------------------------------------------------
    // SAMPLING WRITE LAST
    //------------------------------------------------------------
    always @ (posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        slave_w_last <= 0;
      end
      else if (w_data_count == beats_no)
        slave_w_last <= fifo_w_last;
    end

    //------------------------------------------------------------
    // PROT OUTPUT
    //------------------------------------------------------------
    always @ (posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        slave_aw_prot <= 3'b0;
      end
      else if (write_trans_valid_temp) begin //&& slave_write_ready) begin
        slave_aw_prot <= fifo_aw_prot;
      end
    end

    //------------------------------------------------------------
    // WRITE TRANSFER DONE
    //------------------------------------------------------------
    // Flag to indicate that address and data transfer is done
    // By detecting neg edge of address count busy (any of them both will go low when its done)
    reg addr_burst_busy_reg;
    always @ (posedge clk or negedge rst_n) begin
      if(!rst_n)
        addr_burst_busy_reg <=0;
      else
        addr_burst_busy_reg <= addr_burst_busy;
    end

    assign write_transfer_done = addr_burst_busy_reg & ~addr_burst_busy;


endmodule

