class axi_slave_core_v_sequencer extends uvm_sequencer #(axi_slave_core_seq_item);

  // Factory Registration
  `uvm_component_utils(axi_slave_core_v_sequencer)

  // Constructor
  function new (string name = "axi_slave_core_v_sequencer" , uvm_component parent);
    super.new(name,parent);
  endfunction

  // Sequncers handels
  rd_trans_sequencer m_rd_trans_seqr;
  wr_trans_sequencer m_wr_trans_seqr;

  //-------------------------------------------
  // BUILD PHASE
  //-------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

endclass
