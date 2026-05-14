// `include "wr_trans_driver.sv"
// `include "wr_trans_sequencer.sv"
// `include "wr_trans_config.sv"

class wr_trans_agent extends uvm_agent;

  // Factory Registration
  `uvm_component_utils(wr_trans_agent)

  // Constructor
  function new (string name = "wr_trans_agent", uvm_component parent);
    super.new(name,parent);
  endfunction

  //-------------------------------------------
  // CLASSES HANDELS
  //-------------------------------------------
  wr_trans_driver m_wr_trans_drv;
  wr_trans_sequencer m_wr_trans_seqr;
  wr_trans_config m_wr_config;
  wr_trans_mon_in m_wr_trans_mon_in;
  wr_trans_mon_out m_wr_trans_mon_out;


  //-------------------------------------------
  // BUILD PHASE
  //-------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db #(wr_trans_config)::get(this,"","wr_trans_config",m_wr_config))
      `uvm_fatal(get_name(), "Failed to get configuration for wr_trans_config");

      m_wr_trans_mon_in = wr_trans_mon_in::type_id::create("m_wr_trans_mon_in",this);
      m_wr_trans_mon_out = wr_trans_mon_out::type_id::create("m_wr_trans_mon_out",this);

    if(m_wr_config.is_active == UVM_ACTIVE) begin
      m_wr_trans_drv = wr_trans_driver::type_id::create("m_wr_trans_drv",this);
      m_wr_trans_seqr = wr_trans_sequencer::type_id::create("m_wr_trans_seqr",this);
    end
  endfunction

  //-------------------------------------------
  // CONNECT PHASE
  //-------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(m_wr_config.is_active == UVM_ACTIVE) begin
      m_wr_trans_drv.seq_item_port.connect(m_wr_trans_seqr.seq_item_export);
    end
  endfunction

endclass
