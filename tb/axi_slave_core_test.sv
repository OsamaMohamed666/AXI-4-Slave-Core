class axi_slave_core_test extends uvm_test;

  // Factory Registration
  `uvm_component_utils(axi_slave_core_test)

  //Constructor
  function new(string name = "axi_slave_core_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  //-------------------------------------------
  // CLASSES HANDELS
  //-------------------------------------------
  axi_slave_core_env m_axi_slave_core_env;
  axi_slave_core_v_sequence m_axi_slave_core_v_seq;
  //Configs
  rd_trans_config m_rd_config;
  wr_trans_config m_wr_config;

  //-------------------------------------------
  // BUILD PHASE
  //-------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Creation
    //-------------------------------------------
    // Classes
    m_axi_slave_core_env = axi_slave_core_env::type_id::create("m_axi_slave_core_env",this);
    m_axi_slave_core_v_seq = axi_slave_core_v_sequence::type_id::create("m_axi_slave_core_v_seq");

    // Configs
    m_rd_config = rd_trans_config::type_id::create("m_rd_config",this);
    m_rd_config.is_active = UVM_ACTIVE;
    m_wr_config = wr_trans_config::type_id::create("m_wr_config",this);
    m_wr_config.is_active = UVM_ACTIVE;


    // Set Configurations
    //-------------------------------------------
    // Read Config
    uvm_config_db#(rd_trans_config)::set(this, "m_axi_slave_core_env", "rd_trans_config",
                                                  m_rd_config);

    // Write Config
    uvm_config_db#(wr_trans_config)::set(this, "m_axi_slave_core_env", "wr_trans_config",
                                                  m_wr_config);
  endfunction

  //-------------------------------------------
  // RUN PHASE
  //-------------------------------------------
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
      m_axi_slave_core_v_seq.start(m_axi_slave_core_env.m_axi_slave_core_v_seqr);
    phase.drop_objection(this);
  endtask

endclass
