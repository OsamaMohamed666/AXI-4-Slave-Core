module AXI_AR_channel(

  input                     clk,
  input                     rst_n,

  input                     slave_addr_ready, // slave ready to recieve new addr
  input                     ar_valid,
  input       [31:0]        fifo_ar_addr,
  input       [7:0]         fifo_ar_len, // length of brust of rdata, how many transfers
  input       [2:0]         fifo_ar_size, // size of brust of rdata, how many bytes per a single transfer
  input       [2:0]         fifo_ar_prot,
  input       [1:0]         fifo_ar_burst, // its type
  input                     full_flag,
  input                     strt_rd_transaction,



  output      [8:0]         beats_no,
  output  reg               ar_ready,

  output  reg               address_count_busy,


  // OUTPUTS FOR SLAVE
  output  reg [2:0]         slave_ar_prot,
  output  reg [31:0]        slave_ar_addr,
  output  reg               slave_addr_valid,

  //CONTROL FLAGS
  output                   ar_transfer_done
);

  // CALCULATING BEATS NUMBER AND SIZE
  reg  [7:0] beats_size;
  assign beats_no = fifo_ar_len + 9'd1;
  always @ (*) begin
    case (fifo_ar_size)
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


  //ARREADY FLAG
  always @ (full_flag) begin
    ar_ready = ~full_flag;
  end

  //________________________________________BRUST TYPES LOGIC________________________________________//


  // Flags to indicate the types incr and wrap
  wire is_incr, is_wrap;

  // Address temp for wrap and INCR
  reg [31:0] current_addr;

  //-------------------------------------------
  // First Fixed
  //-------------------------------------------
  wire [31:0] addr_fixed;
  assign addr_fixed = fifo_ar_addr;

  //-------------------------------------------
  // Second INCR
  //-------------------------------------------
  assign is_incr = (fifo_ar_burst == 2'b01) ? 1'b1 : 1'b0;



  //-------------------------------------------
  // Third WRAP
  //-------------------------------------------
  assign is_wrap = (fifo_ar_burst == 2'b10) ? 1'b1 : 1'b0;

  // Axlen belong to {1,3,7,15} >>>>> no_beats == {2,4,8,16}
  // Starting address must be alligned to lower addr


  // Calculating boundry and Checking Address alignment for starting address
  //-------------------------------------------
  reg [31:0] sa; //starting addr
  wire [31:0] aligned_sa; // aligned starting addr
  wire [31:0] wrap_boundry_size;
  wire [31:0] wrap_boundry_addr;

  assign wrap_boundry_size = (beats_no << fifo_ar_size); // boundry size
  assign aligned_sa = sa & ~(wrap_boundry_size - 31'd1); // alligned address
  assign wrap_boundry_addr = aligned_sa + wrap_boundry_size; // boundry address


  //--------------------------------------------
  // Address Counter
  //--------------------------------------------
  reg [`ADDR_WIDTH - 1:0] address_count;
  // reg address_count_busy;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        address_count <= 8'h00;
    end

    else if (address_count < fifo_ar_len && slave_addr_ready && address_count_busy) begin
        address_count <= address_count + 1'b1;  // Increment during burst
    end

    else if ((~|fifo_ar_len) || !address_count_busy) begin
        address_count <= 8'h00;  // Reset after burst completion (or LEN=0 case)
    end
  end

  //---------------------------------------------------
  // Address generation for INCR && WRAP burst types
  //---------------------------------------------------


  // always @ (*) begin
  //   if (address_count_busy && is_incr)
  //     current_addr = start_addr_inc + (beats_size * address_count);
  //   else
  //     current_addr = start_addr_inc;
  // end

  // Change the above always block to be sequential to avoid the combinational loop
  // and to avoid using multplication
  always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_addr <= 32'b0;
      sa <= 32'b0;
    end
    else if (!address_count_busy && (is_incr || is_wrap) && strt_rd_transaction) begin
      current_addr <= fifo_ar_addr; //start address
      sa <= fifo_ar_addr;
    end
    // For wrap burst, when the address reaches the boundry, it should wrap to the start address
    else if (address_count_busy && is_wrap && (current_addr + beats_size > wrap_boundry_addr) && slave_addr_ready) begin
      current_addr <= (current_addr + beats_size) -  wrap_boundry_size ;
    end
    else if (address_count_busy && (is_incr || is_wrap) && slave_addr_ready) begin
      current_addr <= current_addr + beats_size;
    end
  end

  //-------------------------------------------
  // Burst TYPE FSM
  //-------------------------------------------

  localparam reg  IDLE = 1'b0,
                  BURSTING = 1'b1;

  reg [31:0] slave_ar_addr_tmp;
  reg slave_addr_valid_tmp;

  reg  cs,ns;
  always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cs <= 1'b0;
    end
    else
      cs <= ns;
  end

  always @ (*) begin
    slave_addr_valid_tmp = 1'b0;
    slave_ar_addr_tmp = 32'b0;
    address_count_busy = 1'b0;
    case (cs)

    IDLE: begin
      if(strt_rd_transaction) begin // fifo start sending transaction data
        ns = BURSTING;
      end
      else begin
        ns = IDLE;
      end
    end


    BURSTING: begin
      address_count_busy = 1'b1;
      slave_addr_valid_tmp = 1'b1;
      slave_ar_addr_tmp = (fifo_ar_burst == 2'b00) ||(fifo_ar_burst == 2'b11) ? addr_fixed: current_addr;

      if ((address_count == fifo_ar_len) && slave_addr_ready) // last address transfer
        ns = IDLE;
      else
        ns = BURSTING;
    end

    default: ns = IDLE;

    endcase
  end

  //________________________________________OUTPUTS LOGIC________________________________________//

  //-------------------------------------------
  //OUTPUTS TO SLAVE
  //-------------------------------------------
  always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      slave_addr_valid <= 1'b0;
    end
    else begin
      slave_addr_valid <= slave_addr_valid_tmp;
    end
  end

  always @ (posedge clk or negedge rst_n)begin
    if(!rst_n) begin
      slave_ar_addr <= 32'b0;
      slave_ar_prot <= 3'b0;
    end
    else if (slave_addr_valid_tmp && slave_addr_ready) begin // HANDSHAKE DONE
      slave_ar_addr <= slave_ar_addr_tmp;
      slave_ar_prot <= fifo_ar_prot;
    end
  end

  //-------------------------------------------
  //OUTPUTS TO R CHANNEL
  //-------------------------------------------

  // Flag to indicate that address transaction is done
  // By detecting neg edge of address count busy
  reg address_count_busy_reg;
  always @ (posedge clk or negedge rst_n) begin
    if(!rst_n)
      address_count_busy_reg <=0;
    else
      address_count_busy_reg <= address_count_busy;
  end
  assign ar_transfer_done = address_count_busy_reg & ~address_count_busy;


endmodule


