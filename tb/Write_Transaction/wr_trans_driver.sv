
// `include "../axi_slave_core_seq_item.sv"
// `include "../axi_slave_core_if.sv"
class wr_trans_driver extends uvm_driver #(axi_slave_core_seq_item);

  // Factory Registration
  `uvm_component_utils(wr_trans_driver)

  // Constructor
  function new (string name = "wr_trans_driver", uvm_component parent);
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
      drive();
      seq_item_port.item_done();
    end
  endtask


  task reset;
    // Reset all signals of Write Transaction
    vif.cb.aw_valid <= 0;
    vif.cb.w_valid <= 0;
    vif.cb.aw_addr <= 0;
    vif.cb.aw_id <= 0;
    vif.cb.aw_len <= 0;
    vif.cb.aw_size <= 0;
    vif.cb.aw_burst <= 0;
    vif.cb.aw_prot <= 0;
    vif.cb.w_data <= 0;
    vif.cb.w_strb <= 0;
    vif.cb.w_last <= 0;
    vif.cb.b_ready <= 0;
    vif.cb.slave_aw_write_ready <= 0;
    #RESET_PERIOD;
  endtask

  task drive;
    @(vif.cb iff req.rst_n); // Wait for the next clock edge when not in reset
    vif.cb.aw_valid <= req.aw_valid;
    vif.cb.aw_addr <= req.aw_addr;
    vif.cb.aw_id <= req.aw_id;
    vif.cb.aw_len <= req.aw_len;
    vif.cb.aw_size <= req.aw_size;
    vif.cb.aw_burst <= req.aw_burst;
    vif.cb.aw_prot <= req.aw_prot;

    vif.cb.w_valid <= req.w_valid;
    vif.cb.w_data <= req.w_data;
    vif.cb.w_strb <= req.w_strb;
    vif.cb.w_last <= req.w_last;

    vif.cb.b_ready <= req.b_ready;

    // Drive Slave Interface signal for Write Transaction
    vif.cb.slave_aw_write_ready <= req.slave_aw_write_ready;
  endtask

endclass
