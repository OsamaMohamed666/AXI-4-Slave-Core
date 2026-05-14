class rd_trans_mon_in extends uvm_monitor;

  // Factory Registration
  `uvm_component_utils(rd_trans_mon_in)


  //-------------------------------------------
  // CLASSES HANDELS
  //-------------------------------------------
  virtual axi_slave_core_if vif;
  axi_slave_core_seq_item m_ar_seq_item;
  axi_slave_core_seq_item m_r_seq_item;

  //-------------------------------------------
  // ANALYSIS PORTS
  //-------------------------------------------
  uvm_analysis_port #(axi_slave_core_seq_item) Read_collect_port_in;

  // Constructor
  function new (string name = "rd_trans_mon_in", uvm_component parent);
    super.new(name,parent);

    Read_collect_port_in = new("Read_collect_port_in",this);
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
  // TASK: AR CHANNEL (MASTER CORE INTERFACE)
  //-------------------------------------------
  protected task ar_channel;
    forever begin
      m_ar_seq_item = axi_slave_core_seq_item::type_id::create("m_ar_seq_item");
      // Handshake writing in read fifo
      @(posedge vif.clk iff (vif.rst_n && vif.ar_valid && vif.ar_ready))
      m_ar_seq_item.ar_addr = vif.ar_addr;
      m_ar_seq_item.ar_id = vif.ar_id;
      m_ar_seq_item.ar_burst = vif.ar_burst;
      m_ar_seq_item.ar_len = vif.ar_len;
      m_ar_seq_item.ar_size = vif.ar_size;
      m_ar_seq_item.ar_prot = vif.ar_prot;
      m_ar_seq_item.ar_valid = vif.ar_valid;
      m_ar_seq_item.ar_ready = vif.ar_ready;
      m_ar_seq_item.axi_channels = m_ar_seq_item.AR_CHANNEL;
      Read_collect_port_in.write(m_ar_seq_item);
    end
  endtask

  //-------------------------------------------
  // TASK: R CHANNEL (SLAVE CORE INTERFACE)
  //-------------------------------------------
  protected task r_channel;
    forever begin
      m_r_seq_item = axi_slave_core_seq_item::type_id::create("m_r_seq_item");
      // Slave indicates that the read data is valid for been sampled
      @(negedge vif.clk iff (vif.rst_n && vif.r_valid && vif.r_ready))
      m_r_seq_item.slave_r_data = vif.slave_r_data;
      m_r_seq_item.slave_r_data_valid = vif.slave_r_data_valid;
      m_r_seq_item.axi_channels = m_r_seq_item.R_CHANNEL;
      Read_collect_port_in.write(m_r_seq_item);
    end
  endtask

endclass
