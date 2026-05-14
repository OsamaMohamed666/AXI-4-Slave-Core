class rd_trans_agent extends uvm_agent;

  // Factory Registration
  `uvm_component_utils(rd_trans_agent)

  // Constructor
  function new (string name = "rd_trans_agent", uvm_component parent);
    super.new(name,parent);
  endfunction

  //-------------------------------------------
  // CLASSES HANDELS
  //-------------------------------------------
  rd_trans_config m_rd_config;
  rd_trans_sequencer m_rd_trans_seqr;
  rd_trans_driver m_rd_trans_drv;
  rd_trans_mon_in m_rd_trans_mon_in;
  rd_trans_mon_out m_rd_trans_mon_out;

  //-------------------------------------------
  // BUILD PHASE
  //-------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(rd_trans_config)::get(this,"","rd_trans_config",m_rd_config))
      `uvm_fatal(get_name(), "Failed to get configuration for rd_trans_config");

    m_rd_trans_mon_in = rd_trans_mon_in::type_id::create("m_rd_trans_mon_in",this);
    m_rd_trans_mon_out = rd_trans_mon_out::type_id::create("m_rd_trans_mon_out",this);

    if(m_rd_config.is_active == UVM_ACTIVE) begin
      m_rd_trans_drv = rd_trans_driver::type_id::create("m_rd_trans_drv",this);
      m_rd_trans_seqr = rd_trans_sequencer::type_id::create("m_rd_trans_seqr",this);
    end
  endfunction

  //-------------------------------------------
  // CONNECT PHASE
  //-------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(m_rd_config.is_active == UVM_ACTIVE) begin
      m_rd_trans_drv.seq_item_port.connect(m_rd_trans_seqr.seq_item_export);
    end
  endfunction

endclass
