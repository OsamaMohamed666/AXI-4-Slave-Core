//*******RESPONE IN ORDER********
module AXI_R_channel (

  input               clk,
  input               rst_n,

  input               ar_transfer_done,

  input               slave_data_valid,
  input   [31:0]      slave_r_data,

  input   [5:0]       r_fifo_id,

  input               r_ready,
  input   [8:0]       beats_no,

  input       [`ADDR_WIDTH-1:0] fifo_rd_ptr, // Read pointer of fifo
  output  reg [`ADDR_WIDTH-1:0] r_rd_ptr, // Read pointer when RLAST is high


  output  reg          r_resp,
  output  reg          r_valid,
  output  reg [5:0]    r_id,
  output  reg [31:0]   r_data,
  output  reg          r_last
  );




  //________________________________________OUTPUT FSM________________________________________//

  //RESPONSE VALUES
  localparam reg  SLVERR = 1'b1,
                  OKAY = 1'b0;

  //------------------------------------------
  // FSM
  //------------------------------------------
  reg [8:0] beats_counter; // count how many beats are sent

  localparam reg [1:0]  STATE_0 = 2'B00,
                        IDLE = 2'b01,
                        HOLD = 2'B11;
  reg [1:0] cs; // current state
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      cs <= STATE_0;
      beats_counter <= 9'b0;
      r_valid <= 1'b0;
      r_last <= 1'b0;
      r_resp <= 0;
      r_rd_ptr <= 0;
      r_data <= 0;
      r_id <= 0;
    end
    else begin
      case(cs)
      STATE_0  : begin
        if (ar_transfer_done) begin
          cs <= IDLE;
        end
        else begin
          cs <= STATE_0;
        end
      end

      IDLE  : begin
        if (slave_data_valid) begin
          r_valid <= 1'b1;
          cs <= HOLD;
          if(r_ready) begin
            beats_counter <= beats_no - 9'd1;
            r_data <= slave_r_data;
            r_id <= r_fifo_id;
            r_last <= (beats_no == 9'd1)? 1'b1 : 1'b0; // only one beat to be transfered
            r_rd_ptr <= (beats_no == 9'd1)? fifo_rd_ptr : r_rd_ptr; // same cycle as rlast high
            r_resp <= OKAY;
          end
          else begin
            beats_counter <= beats_no;
            r_last <= 1'b0;
            r_resp <= OKAY;

          end
        end
      end

      HOLD : begin
        r_valid <= slave_data_valid; // During bursting r_valid assigned to slave valid

        if (beats_counter == 9'd0) begin
          cs <= STATE_0;
          r_valid <= 1'b0;
          r_last <= 1'b0;
          r_resp <= OKAY;
        end

        else if (r_ready && slave_data_valid) begin // HANDSHAKE
          r_data <= slave_r_data;
          r_id <= r_fifo_id;
          cs <= HOLD;
          beats_counter <= beats_counter - 9'd1;
          r_last <= (beats_counter == 9'd1)? 1'b1 : 1'b0;
          r_rd_ptr <= (beats_counter == 9'd1)? fifo_rd_ptr : r_rd_ptr; // same cycle as rlast high
          r_resp <= OKAY;
        end

        end

      default : begin
          r_resp <= OKAY;
          cs <= STATE_0;
          r_valid <= 0;
        end
      endcase
    end
  end


endmodule
