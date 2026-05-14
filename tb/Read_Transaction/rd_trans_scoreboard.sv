//DECLARING IMPLEMENTATION ANAYLSIS PORT
`uvm_analysis_imp_decl(_MON_IN)
`uvm_analysis_imp_decl(_MON_OUT)

class rd_trans_scoreboard extends uvm_scoreboard;

  // Factory Registration
  `uvm_component_utils(rd_trans_scoreboard)

  // Analysis Ports
  uvm_analysis_imp_MON_IN #(axi_slave_core_seq_item,rd_trans_scoreboard) read_item_export_in;
  uvm_analysis_imp_MON_OUT #(axi_slave_core_seq_item,rd_trans_scoreboard) read_item_export_out;

  // Constructor
  function new (string name = "rd_trans_scoreboard", uvm_component parent);
    super.new(name,parent);

    read_item_export_in = new("read_item_export_in",this);
    read_item_export_out = new("read_item_export_out",this);
  endfunction

  //-------------------------------------------
  // CLASSES HANDELS
  //-------------------------------------------

  // AR Channel
  //-------------------------------------------
  axi_slave_core_seq_item m_ar_in_q [$],m_ar_out_q[$];
  // R Channel
  //-------------------------------------------
  axi_slave_core_seq_item m_r_in_q[$],m_r_out_q[$];

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
  function void write_MON_IN(axi_slave_core_seq_item req);
    if(req.axi_channels == req.AR_CHANNEL)
      m_ar_in_q.push_back(req);
    else if(req.axi_channels == req.R_CHANNEL)
      m_r_in_q.push_back(req);
  endfunction


  // Output
  //-------------------------------------------
  function void write_MON_OUT(axi_slave_core_seq_item req);
    if(req.axi_channels == req.AR_CHANNEL)
      m_ar_out_q.push_back(req);
    else if(req.axi_channels == req.R_CHANNEL)
      m_r_out_q.push_back(req);
  endfunction


  // Data Members
  axi_slave_core_seq_item ar_in_item, ar_out_item;
  axi_slave_core_seq_item r_in_item, r_out_item;
  int ar_address[$];
  int r_beat_count;
  int ar_beat_count;

  //Error counter and correct counter
  int r_err_cnt, r_crr_cnt;
  int ar_err_cnt, ar_crr_cnt;

  //-------------------------------------------
  // RUN PHASE
  //-------------------------------------------

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      // Wait until there is at least one AR transaction in the input queue
      //-------------------------------------------
      wait(m_ar_in_q.size() != 0);
      ar_in_item = m_ar_in_q.pop_front();

      // Calculate expected AR addresses based on burst parameters
      burst_addr(ar_in_item.ar_addr, ar_in_item.ar_burst, ar_in_item.ar_size,
                              ar_in_item.ar_len, ar_address);

      // Check AR Channel for each beat in the burst
      repeat (ar_in_item.ar_len +1) begin
        ar_beat_count++;
        wait(m_ar_out_q.size() > 0);
        ar_out_item = m_ar_out_q.pop_front();

        if(ar_out_item.slave_ar_addr_valid && ar_out_item.slave_ar_addr_ready) begin
          if(ar_out_item.slave_ar_addr != ar_address[0]) begin
            `uvm_info("AR-Channel", $sformatf("\n\FAIL AR TRANSFER NUMBER: %0d OF LENGTH = %0d\n%s"
                                              ,ar_beat_count, ar_in_item.ar_len + 1, `DASH_LINE),
                                              UVM_NONE)
            `uvm_error("AR-Channel", $sformatf("AR Address Mismatch! Expected: %h, Got: %h , burst type: %0d, size: %0d, len: %0d",
                                            ar_address[0], ar_out_item.slave_ar_addr,
                                            ar_in_item.ar_burst, ar_in_item.ar_size,
                                            ar_in_item.ar_len))
            `uvm_info("AR-Channel", $sformatf("\n%s\n", `DASH_LINE),UVM_NONE)
            ar_err_cnt++;
          end
          else if (ar_out_item.slave_ar_prot != ar_in_item.ar_prot) begin
            `uvm_info("AR-Channel", $sformatf("\n\FAIL AR TRANSFER NUMBER: %0d OF LENGTH = %0d\n%s"
                                              ,ar_beat_count, ar_in_item.ar_len + 1, `DASH_LINE),
                                              UVM_NONE)
            `uvm_error("AR-Channel", $sformatf("AR Prot Mismatch! Expected: %h, Got: %h",
                                              ar_in_item.ar_prot, ar_out_item.slave_ar_prot))
            ar_err_cnt++;
            `uvm_info("AR-Channel", $sformatf("\n%s\n", `DASH_LINE),UVM_NONE)

          end
          else begin
            `uvm_info("AR-Channel", $sformatf("\n\nSUCCESSFUL AR TRANSFER NUMBER: %0d OF LENGTH = %0d\n%s",
                                              ar_beat_count, ar_in_item.ar_len + 1, `DASH_LINE),
                                              UVM_MEDIUM)
            `uvm_info("AR Address Matched!", $sformatf(" Expected: %h, Got: %h , burst type: %0d, size: %0d, len: %0d",
                                                      ar_address[0], ar_out_item.slave_ar_addr,
                                                      ar_in_item.ar_burst, ar_in_item.ar_size,
                                                      ar_in_item.ar_len), UVM_MEDIUM)
            `uvm_info("AR Prot Matched!", $sformatf(" Expected: %h, Got: %h",
                                                      ar_in_item.ar_prot,ar_out_item.slave_ar_prot)
                                                      ,UVM_MEDIUM)
            `uvm_info("AR-Channel", $sformatf("\n%s\n", `DASH_LINE),UVM_MEDIUM)

            ar_crr_cnt++;
          end
        end
        else begin
          `uvm_fatal("AR-Channel", "AR Handshake Failed! Valid or Ready signal not asserted.")
          ar_err_cnt++;
        end
        ar_address.pop_front(); // Move to the next expected address
      end
      ar_beat_count = 0; // Reset beat count for the next burst

      // R Channel: Check R data and response for each beat in the burst
      //-------------------------------------------
      repeat (ar_in_item.ar_len +1) begin
        r_beat_count++;
        wait(m_r_in_q.size() != 0);
        r_in_item = m_r_in_q.pop_front();
        // Mark the last beat of the burst
        r_in_item.r_last = (r_beat_count == (ar_in_item.ar_len +1)) ? 1 : 0;

        wait(m_r_out_q.size() != 0);
        r_out_item = m_r_out_q.pop_front();

        if(r_out_item.r_valid && r_out_item.r_ready) begin
          // Checking R DATA
          if(r_out_item.r_data != r_in_item.slave_r_data) begin
            `uvm_info("R-Channel", $sformatf("\n\nFAIL R TRANSFER NUMBER: %0d OF LENGTH = %0d\n%s",
                                            r_beat_count, ar_in_item.ar_len + 1, `DASH_LINE),
                                            UVM_NONE)

            `uvm_error("R-Channel", $sformatf("R Data Mismatch! Expected: %h, Got: %h",
                                            r_in_item.slave_r_data, r_out_item.r_data))
            `uvm_info("R-Channel", $sformatf("\n%s\n", `DASH_LINE),UVM_NONE)

            r_err_cnt++;
          end

          // Checking R ID
          else if (r_out_item.r_id != ar_in_item.ar_id) begin
            `uvm_info("R-Channel", $sformatf("\n\nFAIL R TRANSFER NUMBER: %0d OF LENGTH = %0d\n%s",
                                            r_beat_count, ar_in_item.ar_len + 1, `DASH_LINE),
                                            UVM_NONE)
            `uvm_error("R-Channel", $sformatf("R ID Mismatch! Expected: %h, Got: %h",
                                            ar_in_item.ar_id, r_out_item.r_id))
            `uvm_info("R-Channel", $sformatf("\n%s\n", `DASH_LINE),UVM_NONE)

            r_err_cnt++;
          end

          // Checking R LAST
          else if (r_out_item.r_last != r_in_item.r_last) begin
            `uvm_info("R-Channel", $sformatf("\n\nFAIL R TRANSFER NUMBER: %0d OF LENGTH = %0d\n%s",
                                            r_beat_count, ar_in_item.ar_len + 1, `DASH_LINE),
                                            UVM_NONE)

            `uvm_error("R-Channel", $sformatf("R Last Mismatch! Expected: %h, Got: %h",
                                            r_in_item.r_last, r_out_item.r_last))
            `uvm_info("R-Channel", $sformatf("\n%s\n", `DASH_LINE),UVM_NONE)

            r_err_cnt++;
          end

          else begin
            `uvm_info("R-Channel", $sformatf("\n\nSUCCESSFUL R TRANSFER NUMBER: %0d OF LENGTH = %0d\n%s", r_beat_count, ar_in_item.ar_len + 1, `DASH_LINE),UVM_MEDIUM)
            `uvm_info("R Data Matched!", $sformatf("Expected: %h, Got: %h",
                                            r_in_item.slave_r_data, r_out_item.r_data), UVM_MEDIUM)
            `uvm_info("R ID Matched!", $sformatf("Expected: %h, Got: %h",
                                            ar_in_item.ar_id, r_out_item.r_id), UVM_MEDIUM)
            `uvm_info("R Last Matched", $sformatf("Expected: %h, Got: %h",
                                            r_in_item.r_last, r_out_item.r_last), UVM_MEDIUM)
            `uvm_info("R-Channel", $sformatf("\n%s\n", `DASH_LINE),UVM_MEDIUM)

            r_crr_cnt++;
          end
        end
        else begin
          `uvm_error("R-Channel", "R Handshake Failed! Valid or Ready signal not asserted.")
          r_err_cnt++;
        end
      end
      r_beat_count = 0; // Reset beat count for the next burst
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


  //FUNCTION: REPORT PHASE
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("READ TRANSACTION", $sformatf("\n\nREAD TRANSACTION SUMMARY:\n%s", `DASH_LINE), UVM_NONE)
    `uvm_info("READ TRANSACTION",$sformatf("Successful Cases of AR CHANNEL:%0d",ar_crr_cnt), UVM_NONE);
    `uvm_info("READ TRANSACTION",$sformatf("Unsuccessful Cases AR CHANNEL:%0d",ar_err_cnt),UVM_NONE);
    `uvm_info("READ TRANSACTION",$sformatf("Successful Cases of R CHANNEL:%0d",r_crr_cnt), UVM_NONE);
    `uvm_info("READ TRANSACTION",$sformatf("Unsuccessful Cases R CHANNEL:%0d",r_err_cnt),UVM_NONE);
    `uvm_info("READ TRANSACTION", $sformatf("DONE \n%s", `DASH_LINE), UVM_NONE)
  endfunction


endclass
