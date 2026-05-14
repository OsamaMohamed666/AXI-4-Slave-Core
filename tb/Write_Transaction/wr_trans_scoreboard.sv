//DECLAWING IMPLEMENTATION ANAYLSIS PORT
`uvm_analysis_imp_decl(W_MON_IN)
`uvm_analysis_imp_decl(W_MON_OUT)

class wr_trans_scoreboard extends uvm_scoreboard;

  // Factory Registration
  `uvm_component_utils(wr_trans_scoreboard)

  // Analysis Ports
  uvm_analysis_impW_MON_IN #(axi_slave_core_seq_item,wr_trans_scoreboard) write_item_export_in;
  uvm_analysis_impW_MON_OUT #(axi_slave_core_seq_item,wr_trans_scoreboard) write_item_export_out;

  // Constructor
  function new (string name = "wr_trans_scoreboard", uvm_component parent);
    super.new(name,parent);

    write_item_export_in = new("write_item_export_in",this);
    write_item_export_out = new("write_item_export_out",this);
  endfunction

  //-------------------------------------------
  // CLASSES HANDELS
  //-------------------------------------------

  // AW Channel
  //-------------------------------------------
  axi_slave_core_seq_item m_aw_in_q [$];

  // W Channel
  //-------------------------------------------
  axi_slave_core_seq_item m_w_in_q [$];

  // AW , W Channel
  //-------------------------------------------
  axi_slave_core_seq_item m_aw_w_out_q [$];

  // B Channel
  //-------------------------------------------
  axi_slave_core_seq_item m_b_out_q[$];

  //-------------------------------------------
  // BUILD PHASE
  //-------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  //-------------------------------------------
  // WRITE FUNCTIONS
  //-------------------------------------------

  // Input
  //-------------------------------------------
  function void writeW_MON_IN(axi_slave_core_seq_item req);
    if(req.axi_channels == req.AW_CHANNEL)
      m_aw_in_q.push_back(req);
    else if(req.axi_channels == req.W_CHANNEL)
      m_w_in_q.push_back(req);
  endfunction


  // Output
  //-------------------------------------------
  function void writeW_MON_OUT(axi_slave_core_seq_item req);
    if(req.axi_channels == req.AW_CHANNEL) // for both (aw, w) together as both are sent together
      m_aw_w_out_q.push_back(req);
    else if(req.axi_channels == req.B_CHANNEL)
      m_b_out_q.push_back(req);
  endfunction


  // Data Members
  axi_slave_core_seq_item aw_in_item,
                          w_in_item;
  axi_slave_core_seq_item aw_w_out_item,
                          b_out_item;
  int aw_address[$];
  int aw_beat_count;
  int w_beat_count;

  bit [1:0] resp;

  //Error and correct counters
  int aw_err_cnt, aw_crr_cnt;
  int w_err_cnt, w_crr_cnt;
  int b_err_cnt, b_crr_cnt;

  //-------------------------------------------
  // RUN PHASE
  //-------------------------------------------

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      // Wait until there is at least one AW transaction in the input queue
      //-------------------------------------------
      wait(m_aw_in_q.size() != 0);
      aw_in_item = m_aw_in_q.pop_front();

      // Calculate expected AW addresses based on burst parameters
      burst_addr(aw_in_item.aw_addr, aw_in_item.aw_burst, aw_in_item.aw_size,
                              aw_in_item.aw_len, aw_address);

      // Check AW - W Channel for each beat in the burst
      repeat (aw_in_item.aw_len +1) begin
        aw_beat_count++;
        w_beat_count++;

        //-------------------------------------------------------------------------------------------------
        //BOTH AW AND W SHOULD BE SENT TOGETHER, SO WE CHECK THEM TOGETHER BASED ON THE SAME BEAT COUNT
        //-------------------------------------------------------------------------------------------------

        // Wait for the corresponding W transfer in the output queue
        wait(m_w_in_q.size() > 0);
        w_in_item = m_w_in_q.pop_front();

        // Wait for the corresponding AW/W transfer in the output queue
        wait(m_aw_w_out_q.size() > 0);
        aw_w_out_item = m_aw_w_out_q.pop_front();

        // FIRST: CHECKING AW CHANNEL
        //-------------------------------------------
        if(aw_w_out_item.write_aw_trans_valid && aw_w_out_item.slave_aw_write_ready) begin

          // Checking AW Address
          if(aw_w_out_item.slave_aw_addr != aw_address[0]) begin
            `uvm_info("AW-Channel", $sformatf("\n\FAILED AW TRANSFER NUMBER: %0d OF LENGTH = %0d\n%s"
                                              ,aw_beat_count, aw_in_item.aw_len + 1, `DASH_LINE),
                                              UVM_NONE)
            `uvm_fatal("AW-Channel", $sformatf("AW Address Mismatch! Expected: %h, Got: %h , burst type: %0d, size: %0d, len: %0d",
                                            aw_address[0], aw_w_out_item.slave_aw_addr,
                                            aw_in_item.aw_burst, aw_in_item.aw_size,
                                            aw_in_item.aw_len))
            `uvm_info("AW-Channel", $sformatf("\n%s\n", `DASH_LINE),UVM_NONE)
            aw_err_cnt++;
          end

          // Checking AW Prot
          else if (aw_w_out_item.slave_aw_prot != aw_in_item.aw_prot) begin
            `uvm_info("AW-Channel", $sformatf("\n\FAILED AW TRANSFER NUMBER: %0d OF LENGTH = %0d\n%s"
                                              ,aw_beat_count, aw_in_item.aw_len + 1, `DASH_LINE),
                                              UVM_NONE)
            `uvm_error("AW-Channel", $sformatf("AW Prot Mismatch! Expected: %h, Got: %h",
                                              aw_in_item.aw_prot, aw_w_out_item.slave_aw_prot))
            aw_err_cnt++;
            `uvm_info("AW-Channel", $sformatf("\n%s\n", `DASH_LINE),UVM_NONE)

          end

          else begin
            `uvm_info("AW-Channel", $sformatf("\n\nSUCCESSFUL AW TRANSFER NUMBER: %0d OF LENGTH = %0d\n%s",
                                              aw_beat_count, aw_in_item.aw_len + 1, `DASH_LINE),
                                              UVM_MEDIUM)
            `uvm_info("AW Address Matched!", $sformatf(" Expected: %h, Got: %h , burst type: %0d, size: %0d, len: %0d",
                                                      aw_address[0], aw_w_out_item.slave_aw_addr,
                                                      aw_in_item.aw_burst, aw_in_item.aw_size,
                                                      aw_in_item.aw_len), UVM_MEDIUM)
            `uvm_info("AW Prot Matched!", $sformatf(" Expected: %h, Got: %h",
                                                      aw_in_item.aw_prot,aw_w_out_item.slave_aw_prot)
                                                      ,UVM_MEDIUM)
            `uvm_info("AW-Channel", $sformatf("\n%s\n", `DASH_LINE),UVM_MEDIUM)

            aw_crr_cnt++;
          end
        end

        else begin
          `uvm_fatal("AW-Channel", "AW Handshake Failed! Valid or Ready signal not asserted.")
          aw_err_cnt++;
        end

        aw_address.pop_front(); // Move to the next expected address



        // SECOND: CHECKING W CHANNEL
        //-------------------------------------------
        if(aw_w_out_item.write_aw_trans_valid && aw_w_out_item.slave_aw_write_ready) begin

          // Checking W DATA
          if(aw_w_out_item.slave_w_data != w_in_item.w_data) begin
            `uvm_info("W-Channel", $sformatf("\n\nFAILED W TRANSFER NUMBER: %0d OF LENGTH = %0d\n%s",
                                            w_beat_count, aw_in_item.aw_len + 1, `DASH_LINE),
                                            UVM_NONE)

            `uvm_fatal("W-Channel", $sformatf("W Data Mismatch! Expected: %h, Got: %h",
                                            w_in_item.w_data, aw_w_out_item.slave_w_data))
            `uvm_info("W-Channel", $sformatf("\n%s\n", `DASH_LINE),UVM_NONE)

            w_err_cnt++;
          end

          // Checking W STROBE
          else if(aw_w_out_item.w_strb != w_in_item.slave_w_strb) begin
            `uvm_info("W-Channel", $sformatf("\n\nFAILED W TRANSFER NUMBER: %0d OF LENGTH = %0d\n%s",
                                            w_beat_count, aw_in_item.aw_len + 1, `DASH_LINE),
                                            UVM_NONE)

            `uvm_fatal("W-Channel", $sformatf("W Strb Mismatch! Expected: %h, Got: %h",
                                            w_in_item.w_strb, aw_w_out_item.slave_w_strb))
            `uvm_info("W-Channel", $sformatf("\n%s\n", `DASH_LINE),UVM_NONE)

            w_err_cnt++;
          end

          else begin
            `uvm_info("W-Channel", $sformatf("\n\nSUCCESSFUL W TRANSFER NUMBER: %0d OF LENGTH = %0d\n%s"
                                            , w_beat_count, aw_in_item.aw_len + 1, `DASH_LINE),
                                            UVM_MEDIUM)
            `uvm_info("W Data Matched!", $sformatf("Expected: %h, Got: %h",
                                            w_in_item.w_data, aw_w_out_item.slave_w_data),
                                            UVM_MEDIUM)
            `uvm_info("W STRB Matched", $sformatf("Expected: %h, Got: %h",
                                            w_in_item.w_strb, aw_w_out_item.slave_w_strb),
                                            UVM_MEDIUM)
            `uvm_info("W-Channel", $sformatf("\n%s\n", `DASH_LINE),UVM_MEDIUM)

            w_crr_cnt++;
          end
        end

      end
      aw_beat_count = 0; // Reset beat count for the next burst
      w_beat_count = 0; // Reset beat count for the next burst

      // THIRD: CHECKING B CHANNEL
      //-------------------------------------------
      wait(m_b_out_q.size() > 0);
      b_out_item = m_b_out_q.pop_front();
      resp = calc_resp(aw_in_item.aw_size, w_in_item.w_last);

      if (b_out_item.b_valid && b_out_item.b_ready) begin
        // Checking BID
        if(b_out_item.b_id != aw_in_item.aw_id) begin
          `uvm_info("B_CHANNEL", $sformatf("\n\n FAILED B TRANSFER \n%s", `DASH_LINE),UVM_NONE)
          `uvm_fatal("B_CHANNEL", $sformatf("BID MISMATCH! Expected: %h, Got: %h",
                                            aw_in_item.aw_id, b_out_item.b_id))
          `uvm_info("B_CHANNEL", $sformatf("\n%s\n", `DASH_LINE),UVM_NONE)
          b_err_cnt++;
        end

        // Checking BRESP
        else if (b_out_item.b_resp != resp) begin
          `uvm_info("B_CHANNEL", $sformatf("\n\n FAILED B TRANSFER \n%s", `DASH_LINE),UVM_NONE)
          `uvm_fatal("B_CHANNEL", $sformatf("BRESP MISMATCH! Expected: %h, Got: %h",
                                            resp, b_out_item.b_resp))
          `uvm_info("B_CHANNEL", $sformatf("\n%s\n", `DASH_LINE),UVM_NONE)
          b_err_cnt++;
        end

        else begin
          `uvm_info("B_CHANNEL", $sformatf("\n\nSUCCESSFUL B TRANSFER\n%s", `DASH_LINE),UVM_LOW)
          `uvm_info("B_CHANNEL", $sformatf("BID Matched! Expected: %h, Got: %h",
                                            aw_in_item.aw_id, b_out_item.b_id), UVM_LOW)
          `uvm_info("B_CHANNEL", $sformatf("BRESP Matched! Expected: %h, Got: %h",
                                            resp, b_out_item.b_resp), UVM_LOW)
          `uvm_info("B_CHANNEL", $sformatf("\n%s\n", `DASH_LINE),UVM_LOW)
          b_crr_cnt++;
        end
      end

      else begin
        `uvm_error("B_CHANNEL", "B Handshake Failed! Valid or Ready signal not asserted.")
        b_err_cnt++;
      end
    end
  endtask


  // Function: Burst Addresses
  function automatic void burst_addr(
    input  int        strt_addr,
    input  bit [1:0]  burst_type,
    input  bit [2:0]  size,
    input  bit [7:0]  length,
    output int        addr_a[$]
  );

    int addr_q[$];
    int beat_bytes;
    int beats;
    int aligned_sa;
    int wrap_size;
    int wrap_boundry;
    int wrap_end;
    int next_addr;

    beat_bytes = (1 << size);     // bytes per beat
    beats      = length + 1;

    // wrap calculations (once)
    wrap_size  = beats * beat_bytes;
    aligned_sa = strt_addr & (~(wrap_size-1));
    wrap_boundry  = (aligned_sa / wrap_size) * wrap_size;
    wrap_end   = wrap_boundry + wrap_size;

    for (int i = 0; i < beats; i++) begin
      if (i == 0) begin
        addr_q.push_back(strt_addr);
      end

      else begin
        case (burst_type)

          // FIXED
          2'b00: begin
            addr_q.push_back(strt_addr);
          end

          // INCR
          2'b01: begin
            addr_q.push_back(addr_q[i-1] + beat_bytes);
          end

          // WRAP
          2'b10: begin
            next_addr = addr_q[i-1] + beat_bytes;

            if (next_addr > wrap_end)
              addr_q.push_back(wrap_boundry + (next_addr - wrap_end));
            else
              addr_q.push_back(next_addr);
          end

          default: addr_q.push_back(strt_addr);

        endcase
      end

    end

    addr_a = addr_q;

  endfunction

  // Function: Response Calculation
  typedef enum bit [1:0] {OKAY = 2'b00, EXOKAY = 2'b01, SLVERR = 2'b10, DECERR = 2'b11} resp_e;
  function automatic bit [1:0] calc_resp(bit [2:0] aw_size, bit w_last);
    return (aw_size > 2) ? SLVERR : (w_last ? OKAY : EXOKAY);
  endfunction



  //FUNCTION: REPORT PHASE
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("WRITE TRANSACTION", $sformatf("\n\nWRITE TRANSACTION SUMMARY:\n%s", `DASH_LINE), UVM_NONE)
    `uvm_info("WRITE TRANSACTION",$sformatf("Successful Cases of AW CHANNEL:%0d",aw_crr_cnt), UVM_NONE)
    `uvm_info("WRITE TRANSACTION",$sformatf("Unsuccessful Cases AW CHANNEL:%0d",aw_err_cnt),UVM_NONE)
    `uvm_info("WRITE TRANSACTION",$sformatf("Successful Cases of W CHANNEL:%0d",w_crr_cnt), UVM_NONE)
    `uvm_info("WRITE TRANSACTION",$sformatf("Unsuccessful Cases W CHANNEL:%0d",w_err_cnt),UVM_NONE)
    `uvm_info("WRITE TRANSACTION",$sformatf("Successful Cases of B CHANNEL:%0d",b_crr_cnt), UVM_NONE)
    `uvm_info("WRITE TRANSACTION",$sformatf("Unsuccessful Cases of B CHANNEL:%0d",b_err_cnt), UVM_NONE)
    `uvm_info("WRITE TRANSACTION", $sformatf("DONE \n%s", `DASH_LINE), UVM_NONE)
  endfunction


endclass
