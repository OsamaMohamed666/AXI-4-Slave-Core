class rd_trans_config extends uvm_object;
  `uvm_object_utils(rd_trans_config)

  uvm_active_passive_enum is_active;

  function new(string name = "rd_trans_config");
    super.new(name);
    is_active = UVM_ACTIVE; // Default to active mode
  endfunction
endclass
