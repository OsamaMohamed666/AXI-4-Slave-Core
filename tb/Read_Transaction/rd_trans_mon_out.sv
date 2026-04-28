class rd_trans_mon_out extends uvm_monitor;

  // Factory Registration
  `uvm_component_utils(rd_trans_mon_out)


  //-------------------------------------------
  // CLASSES HANDELS
  //-------------------------------------------
  virtual axi_slave_core_if vif;
  axi_slave_core_seq_item m_ar_seq_item;
  axi_slave_core_seq_item m_r_seq_item;

  //-------------------------------------------
  // ANALYSIS PORTS (R , AR)
  //-------------------------------------------
  uvm_analysis_port #(axi_slave_core_seq_item) Read_collect_port_out;

  // Constructor
  function new (string name = "rd_trans_mon_out", uvm_component parent);
    super.new(name,parent);

    Read_collect_port_out = new("Read_collect_port_out",this);
  endfunction

  //-------------------------------------------
  // BUILD PHASE
  //-------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual axi_slave_core_if)::get(this,"","vif",vif))
      `uvm_fatal(get_name(), "Failed to get configuration for axi_slave_core_if");
  endfunction

  //-------------------------------------------
  // RUN PHASE
  //-------------------------------------------
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
      fork
        begin
          ar_channel();
        end

        begin
          r_channel();
        end
      join_any

  endtask


  //-------------------------------------------
  // TASK: AR CHANNEL (SLAVE CORE INTERFACE)
  //-------------------------------------------
  protected task ar_channel;
    forever begin
      m_ar_seq_item = axi_slave_core_seq_item::type_id::create("m_ar_seq_item");
      // Handshake: Sending addr to slave
      @(negedge vif.clk iff (vif.rst_n && vif.slave_ar_addr_ready && vif.slave_ar_addr_valid))
      m_ar_seq_item.slave_ar_addr = vif.slave_ar_addr;
      m_ar_seq_item.slave_ar_prot = vif.slave_ar_prot;

      m_ar_seq_item.slave_ar_addr_valid = vif.slave_ar_addr_valid;
      m_ar_seq_item.slave_ar_addr_ready = vif.slave_ar_addr_ready;
      m_ar_seq_item.axi_channels = m_ar_seq_item.AR_CHANNEL;
      Read_collect_port_out.write(m_ar_seq_item);
    end
  endtask

  //-------------------------------------------
  // TASK: R CHANNEL (MASTER CORE INTERFACE)
  //-------------------------------------------
  protected task r_channel;
    forever begin
      m_r_seq_item = axi_slave_core_seq_item::type_id::create("m_r_seq_item");
      @(negedge vif.clk iff (vif.rst_n && vif.r_valid && vif.r_ready))
      m_r_seq_item.r_data = vif.r_data;
      m_r_seq_item.r_last = vif.r_last;
      m_r_seq_item.r_id   = vif.r_id;
      m_r_seq_item.r_resp = vif.r_resp;

      m_r_seq_item.r_valid = vif.r_valid;
      m_r_seq_item.r_ready = vif.r_ready;
      m_r_seq_item.axi_channels = m_r_seq_item.R_CHANNEL;
      Read_collect_port_out.write(m_r_seq_item);
    end
  endtask

endclass
