class wr_trans_mon_out extends uvm_monitor;

  // Factory Registration
  `uvm_component_utils(wr_trans_mon_out)


  //-------------------------------------------
  // CLASSES HANDELS
  //-------------------------------------------
  virtual axi_slave_core_if vif;
  axi_slave_core_seq_item m_aw_w_seq_item;
  axi_slave_core_seq_item m_b_seq_item;

  //-------------------------------------------
  // ANALYSIS PORT
  //-------------------------------------------
  uvm_analysis_port #(axi_slave_core_seq_item) Write_collect_port_out;

  // Constructor
  function new (string name = "wr_trans_mon_out", uvm_component parent);
    super.new(name,parent);

    Write_collect_port_out = new("Write_collect_port_out",this);
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
          aw_w_channel();
        end

        begin
          b_channel();
        end
      join_any

  endtask


  //-------------------------------------------
  // TASK: AW, W CHANNEL (SLAVE CORE INTERFACE)
  //-------------------------------------------
  protected task aw_w_channel;
    forever begin
      m_aw_w_seq_item = axi_slave_core_seq_item::type_id::create("m_aw_w_seq_item");
      // Handshake: Sending addr to slave
      @(posedge vif.clk iff (vif.rst_n && vif.write_aw_trans_valid && vif.slave_aw_write_ready))
      m_aw_w_seq_item.slave_aw_addr = vif.slave_aw_addr;
      m_aw_w_seq_item.slave_aw_prot = vif.slave_aw_prot;

      m_aw_w_seq_item.slave_w_data = vif.slave_w_data;
      m_aw_w_seq_item.slave_w_strb = vif.slave_w_strb;

      m_aw_w_seq_item.write_aw_trans_valid = vif.write_aw_trans_valid;
      m_aw_w_seq_item.slave_aw_write_ready = vif.slave_aw_write_ready;
      m_aw_w_seq_item.axi_channels = m_aw_w_seq_item.AW_CHANNEL; // default to both
      Write_collect_port_out.write(m_aw_w_seq_item);
    end
  endtask

  //-------------------------------------------
  // TASK: B CHANNEL (MASTER CORE INTERFACE)
  //-------------------------------------------
  protected task b_channel;
    forever begin
      m_b_seq_item = axi_slave_core_seq_item::type_id::create("m_b_seq_item");
      @(posedge vif.clk iff (vif.rst_n && vif.b_valid && vif.b_ready))
      m_aw_w_seq_item.b_id   = vif.b_id;
      m_aw_w_seq_item.b_resp = vif.b_resp;

      m_aw_w_seq_item.b_valid = vif.b_valid;
      m_aw_w_seq_item.b_ready = vif.b_ready;
      m_aw_w_seq_item.axi_channels = m_aw_w_seq_item.B_CHANNEL;
      Write_collect_port_out.write(m_aw_w_seq_item);
    end
  endtask

endclass
