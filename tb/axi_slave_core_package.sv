  `define ADDR_WIDTH 8
  `define FIFO_DEPTH (1 << `ADDR_WIDTH)  // 256 entries
package axi_slave_core_package;


  parameter int SEQUENCES = 10;
  parameter int CLK_PERIOD = 10;
  parameter int RESET_PERIOD = 20;

  // //-------------------------------------------
  // // Design Modules
  // //-------------------------------------------
  // // Read Transaction
  // //-------------------------------------------
  // `include "../Design/Read_FIFO.v"
  // `include "../Design/AXI_AR_channel.v"
  // `include "../Design/AXI_R_channel.v"
  // `include "../Design/Top_Read_Transaction.v"

  // // Write Transaction
  // //-------------------------------------------
  // `include "../Design/Write_FIFO.v"
  // `include "../Design/AXI_Write_channel.v"
  // `include "../Design/AXI_B_channel.v"
  // `include "../Design/Top_Write_Transaction.v"

  // // Top Level
  // //-------------------------------------------
  // `include "../Design/AXI_SLAVE_CORE_TOP.v"


  //-------------------------------------------
  // TESTBENCH CLASSES
  //-------------------------------------------
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  // Sequence Items
  //--------------------------------------------
  `include "axi_slave_core_seq_item.sv"

  // Read Transaction
  //--------------------------------------------

  `include "Read_Transaction/rd_trans_config.sv"
  `include "Read_Transaction/rd_trans_sequence.sv"
  `include "Read_Transaction/rd_trans_sequencer.sv"
  `include "Read_Transaction/rd_trans_driver.sv"
  `include "Read_Transaction/rd_trans_agent.sv"

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
