class rd_trans_sequencer extends uvm_sequencer #(axi_slave_core_seq_item);

  // Factory Registration
  `uvm_component_utils(rd_trans_sequencer)

  // Constructor
  function new (string name = "rd_trans_sequencer" , uvm_component parent);
    super.new(name,parent);
  endfunction

  //-------------------------------------------
  // BUILD PHASE
  //-------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

endclass
