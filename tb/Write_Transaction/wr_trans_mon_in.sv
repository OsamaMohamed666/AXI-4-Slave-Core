class wr_trans_mon_in extends uvm_monitor;

  // Factory Registration
  `uvm_component_utils(wr_trans_mon_in)

  //-------------------------------------------
  // CLASSES HANDELS
  //-------------------------------------------
  virtual axi_slave_core_if vif;
  axi_slave_core_seq_item m_aw_seq_item;
  axi_slave_core_seq_item m_w_seq_item;

  //-------------------------------------------
  // ANALYSIS PORTS
  //-------------------------------------------
  uvm_analysis_port #(axi_slave_core_seq_item) Write_collect_port_in;


  // Constructor
  function new(string name = "wr_trans_mon_in", uvm_component parent);
    super.new(name,parent);

    Write_collect_port_in = new("Write_collect_port_in",this);
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
        aw_channel();
      end

      begin
        w_channel();
      end
    join_any
  endtask

  //-------------------------------------------
  // TASK: AW CHANNEL (MASTER CORE INTERFACE)
  //-------------------------------------------
  protected task aw_channel;
    forever begin
      m_aw_seq_item = axi_slave_core_seq_item::type_id::create("m_aw_seq_item");
      @(posedge vif.clk iff(vif.rst_n && vif.aw_ready && vif.aw_valid ))
      m_aw_seq_item.aw_addr = vif.aw_addr;
      m_aw_seq_item.aw_id = vif.aw_id;
      m_aw_seq_item.aw_burst = vif.aw_burst;
      m_aw_seq_item.aw_len = vif.aw_len;
      m_aw_seq_item.aw_size = vif.aw_size;
      m_aw_seq_item.aw_prot = vif.aw_prot;
      m_aw_seq_item.aw_valid = vif.aw_valid;
      m_aw_seq_item.aw_ready = vif.aw_ready;
      m_aw_seq_item.axi_channels = m_aw_seq_item.AW_CHANNEL;
      Write_collect_port_in.write(m_aw_seq_item);
    end
  endtask


  //-------------------------------------------
  // TASK: W CHANNEL (MASTER CORE INTERFACE)
  //-------------------------------------------
  protected task w_channel;
    forever begin
      m_w_seq_item = axi_slave_core_seq_item::type_id::create("m_w_seq_item");
      // FIFO GET NEW DATA FROM MASTER
      @(posedge vif.clk iff (vif.rst_n && vif.w_valid && vif.w_ready))
      m_w_seq_item.w_data = vif.w_data;
      m_w_seq_item.w_strb = vif.w_strb;
      m_w_seq_item.w_last = vif.w_last;

      m_w_seq_item.w_valid = vif.w_valid;
      m_w_seq_item.w_ready = vif.w_ready;
      m_w_seq_item.axi_channels = m_w_seq_item.W_CHANNEL;
      Write_collect_port_in.write(m_w_seq_item);
    end
  endtask

endclass

