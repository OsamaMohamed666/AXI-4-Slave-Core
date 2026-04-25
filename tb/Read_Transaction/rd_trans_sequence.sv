class rd_trans_sequence extends uvm_sequence #(axi_slave_core_seq_item);

  // Factory Registration
  `uvm_object_utils(rd_trans_sequence);

  // Constructor
  function new (string name = "rd_trans_sequence");
    super.new(name);
  endfunction

  //-------------------------------------------
  // BODY
  //-------------------------------------------
  task body;
    repeat (axi_slave_core_package::SEQUENCES) begin
      req = axi_slave_core_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize())
        else `uvm_fatal(get_type_name(),"Failed to Randomize");
      finish_item(req);
  end
  endtask
endclass
