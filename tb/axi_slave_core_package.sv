  `define ADDR_WIDTH 8
  `define FIFO_DEPTH (1 << `ADDR_WIDTH)  // 256 entries
package axi_slave_core_package;

  `define DASH_LINE "---------------------------------------------------------------------------------"

  parameter int SEQUENCES = 10000;
  parameter int CLK_PERIOD = 10;
  parameter int RESET_PERIOD = 20;


  //-------------------------------------------
  // TESTBENCH CLASSES
  //-------------------------------------------
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  // Sequence Item
  //--------------------------------------------
  `include "axi_slave_core_seq_item.sv"

  // Read Transaction
  //--------------------------------------------
  `include "Read_Transaction/rd_trans_config.sv"
  `include "Read_Transaction/rd_trans_sequence.sv"
  `include "Read_Transaction/rd_trans_sequencer.sv"
  `include "Read_Transaction/rd_trans_driver.sv"
  `include "Read_Transaction/rd_trans_mon_in.sv"
  `include "Read_Transaction/rd_trans_mon_out.sv"
  `include "Read_Transaction/rd_trans_agent.sv"
  `include "Read_Transaction/rd_trans_scoreboard.sv"

  // Write Transaction
  //--------------------------------------------
  `include "Write_Transaction/wr_trans_config.sv"
  `include "Write_Transaction/wr_trans_sequence.sv"
  `include "Write_Transaction/wr_trans_sequencer.sv"
  `include "Write_Transaction/wr_trans_driver.sv"
  `include "Write_Transaction/wr_trans_agent.sv"

  // TOP Level
  //-------------------------------------------
  `include "axi_slave_core_v_sequencer.sv"
  `include "axi_slave_core_v_sequence.sv"
  `include "axi_slave_core_env.sv"
  `include "axi_slave_core_test.sv"


endpackage
