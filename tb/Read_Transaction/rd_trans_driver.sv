class rd_trans_driver extends uvm_driver #(axi_slave_core_seq_item);

  // Factory Registration
  `uvm_component_utils(rd_trans_driver)

  // Constructor
  function new (string name = "rd_trans_driver", uvm_component parent);
    super.new(name,parent);
  endfunction

  // Virtual Interface handel
  virtual axi_slave_core_if vif;

  //-------------------------------------------
  // BUILD PHASE
  //-------------------------------------------
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
      if(!uvm_config_db #(virtual axi_slave_core_if)::get(this,"","vif",vif))
        `uvm_fatal(get_name(), "Failed to get configuration for axi_slave_core_if");
  endfunction

  //-------------------------------------------
  // RUN PHASE
  //-------------------------------------------
  task run_phase (uvm_phase phase);
    reset();
    forever begin
      seq_item_port.get_next_item(req);
      if (req.rst_n) // note: reset active low
        drive();
      else
        reset();
      seq_item_port.item_done();
    end
  endtask

  task reset;
    // Reset all signals of Read Transaction
    vif.rst_n <= 0;
    vif.cb.ar_valid <= 0;
    vif.cb.r_ready <= 0;
    vif.cb.ar_addr <= 0;
    vif.cb.ar_id <= 0;
    vif.cb.ar_len <= 0;
    vif.cb.ar_size <= 0;
    vif.cb.ar_burst <= 0;
    vif.cb.ar_prot <= 0;

    vif.cb.slave_ar_addr_ready <= 0;
    vif.cb.slave_r_data_valid <= 0;
    vif.cb.slave_r_data <= 0;

    #RESET_PERIOD
    vif.rst_n <= 1; // De-assert reset after some time
  endtask

  task drive;
    @(vif.cb iff req.rst_n); // Wait for the next clock edge when not in reset
    vif.rst_n <= req.rst_n;

    vif.cb.ar_valid <= req.ar_valid;
    vif.cb.ar_addr <= req.ar_addr;
    vif.cb.ar_id <= req.ar_id;
    vif.cb.ar_len <= req.ar_len;
    vif.cb.ar_size <= req.ar_size;
    vif.cb.ar_burst <= req.ar_burst;
    vif.cb.ar_prot <= req.ar_prot;

    vif.cb.r_ready <= req.r_ready;

    // Drive Slave Interface signals for Read Transaction
    vif.cb.slave_ar_addr_ready <= req.slave_ar_addr_ready;
    vif.cb.slave_r_data_valid <= req.slave_r_data_valid;
    vif.cb.slave_r_data <= req.slave_r_data;
  endtask

endclass
