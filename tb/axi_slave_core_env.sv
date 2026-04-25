class axi_slave_core_env extends uvm_env;

  // Factory Registration
  `uvm_component_utils(axi_slave_core_env)

  // Constructor
  function new (string name = "axi_slave_core_env", uvm_component parent);
    super.new(name,parent);
  endfunction

  //-------------------------------------------
  // CLASSES HANDELS
  //-------------------------------------------
  // Common
  axi_slave_core_v_sequencer m_axi_slave_core_v_seqr;

  // Read Transaction
  rd_trans_agent m_rd_trans_agt;

  // Write Transaction
  wr_trans_agent m_wr_trans_agt;

  // Configurations
  rd_trans_config m_rd_config;
  wr_trans_config m_wr_config;

  //-------------------------------------------
  // BUILD PHASE
  //-------------------------------------------
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    // Creation
    //-------------------------------------------
    // Virtual Seqr
    m_axi_slave_core_v_seqr = axi_slave_core_v_sequencer::type_id::create("m_axi_slave_core_v_seqr"
                                                                            ,this);

    // Agents
    m_rd_trans_agt = rd_trans_agent::type_id::create("m_rd_trans_agt",this);
    m_wr_trans_agt = wr_trans_agent::type_id::create("m_wr_trans_agt",this);


   // Configurations
    //-------------------------------------------
    // Read Config
    if (!uvm_config_db#(rd_trans_config)::get(this, "", "rd_trans_config", m_rd_config))
      `uvm_fatal("BUILD_PHASE", "End to End env - unable to get read configuration object")
    uvm_config_db#(rd_trans_config)::set(this, "m_rd_trans_agt", "rd_trans_config", m_rd_config);

    // Write Config
    if (!uvm_config_db#(wr_trans_config)::get(this, "", "wr_trans_config", m_wr_config))
      `uvm_fatal("BUILD_PHASE", "End to End env - unable to get write configuration object")
    uvm_config_db#(wr_trans_config)::set(this, "m_wr_trans_agt", "wr_trans_config", m_wr_config);

  endfunction

  //-------------------------------------------
  // CONNECT PHASE
  //-------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connecting vsequencer to sequencers
    m_axi_slave_core_v_seqr.m_rd_trans_seqr = m_rd_trans_agt.m_rd_trans_seqr;
    m_axi_slave_core_v_seqr.m_wr_trans_seqr = m_wr_trans_agt.m_wr_trans_seqr;
  endfunction

endclass
