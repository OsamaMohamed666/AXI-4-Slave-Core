`include "uvm_macros.svh"

module axi_slave_core_top_tb();
  import uvm_pkg::*;
  import axi_slave_core_package::*;

  //-------------------------------------------
  // Clock
  //-------------------------------------------
  bit   clk;
  // Clock Generation
  always #5 clk = ~clk; // 100MHz clock
  initial begin
    clk = 0;
  end

  //-------------------------------------------
  // Interface signals
  //-------------------------------------------
  axi_slave_core_if intf(clk);
  //-------------------------------------------
  // DUT Interface Signals
  //--------------------------------------------
  AXI_SLAVE_CORE_TOP dut (
  .clk(clk),
  .rst_n(intf.rst_n),

  // Write transaction signals would go here
  .AWVALID(intf.aw_valid),
  .AWADDR(intf.aw_addr),
  .AWID(intf.aw_id),
  .AWLEN(intf.aw_len),
  .AWSIZE(intf.aw_size),
  .AWBURST(intf.aw_burst),
  .AWPROT(intf.aw_prot),
  .AWREADY(intf.aw_ready),

  .WVALID(intf.w_valid),
  .WDATA(intf.w_data),
  .WLAST(intf.w_last),
  .WSTRB(intf.w_strb),
  .WREADY(intf.w_ready),

  .BVALID(intf.b_valid),
  .BID(intf.b_id),
  .BRESP(intf.b_resp),
  .BREADY(intf.b_ready),

  .slave_aw_addr(intf.slave_aw_addr),
  .slave_aw_prot(intf.slave_aw_prot),
  .slave_w_data(intf.slave_w_data),
  .slave_w_strb(intf.slave_w_strb),
  .write_aw_trans_valid(intf.write_aw_trans_valid),
  .slave_aw_write_ready(intf.slave_aw_write_ready),

  // Read transaction signals would go here
  .ARVALID(intf.ar_valid),
  .ARADDR(intf.ar_addr),
  .ARID(intf.ar_id),
  .ARLEN(intf.ar_len),
  .ARSIZE(intf.ar_size),
  .ARBURST(intf.ar_burst),
  .ARPROT(intf.ar_prot),
  .ARREADY(intf.ar_ready),

  .RVALID(intf.r_valid),
  .RDATA(intf.r_data),
  .RID(intf.r_id),
  .RRESP(intf.r_resp),
  .RLAST(intf.r_last),
  .RREADY(intf.r_ready),

  .slave_ar_addr_ready(intf.slave_ar_addr_ready),
  .slave_ar_prot(intf.slave_ar_prot),
  .slave_ar_addr_valid(intf.slave_ar_addr_valid),
  .slave_ar_addr(intf.slave_ar_addr),

  .slave_r_data_valid(intf.slave_r_data_valid),
  .slave_r_data(intf.slave_r_data)
  );


  // Configurations && Running Test
  initial begin
    // Interface
    uvm_config_db#(virtual axi_slave_core_if)::set(null, "*", "vif", intf);

    // Dump waves
    $dumpfile("axi_slave_core_top_tb.vcd");
    $dumpvars;

    // run test
    run_test("axi_slave_core_test");
  end


endmodule

