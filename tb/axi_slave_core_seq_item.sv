`include "uvm_macros.svh"
import uvm_pkg::*;
class axi_slave_core_seq_item extends uvm_sequence_item;

  `uvm_object_utils(axi_slave_core_seq_item);

  function new (string name = "axi_slave_core_seq_item");
    super.new(name);
  endfunction

  //-------------------------------------------
  // DATA MEMBERS
  //-------------------------------------------

  // Gobal Signal
  //-------------------------------------------
  rand bit   rst_n;

  // First Write Transaction
  //-------------------------------------------

  // AXI write Address Channel (Master → Slave Core)
  rand bit           aw_valid;
  rand bit   [31:0]  aw_addr;
  rand bit   [5:0]   aw_id;
  rand bit   [7:0]   aw_len;
  rand bit   [2:0]   aw_size;
  rand bit   [1:0]   aw_burst;
  rand bit   [2:0]   aw_prot;
  logic              aw_ready;

  // AXI write Data Channel (Master → Slave Core)
  rand bit           w_valid;
  rand bit   [31:0]  w_data;
  rand bit           w_last;
  rand bit   [3:0]   w_strb;
  logic              w_ready;

  // AXI write Response Channel (Slave Core → Master)
  logic              b_valid;
  logic [5:0]        b_id;
  logic [1:0]        b_resp;
  rand bit           b_ready;

  // Slave Interface
  logic [31:0]       slave_aw_addr;
  logic [2:0]        slave_aw_prot;
  logic [31:0]       slave_w_data;
  logic [3:0]        slave_w_strb;
  logic              write_aw_trans_valid;
  rand bit           slave_aw_write_ready;


  // Second Read Transaction
  //-------------------------------------------

  // AXI Read Address Channel (Master → Slave Core)
  rand bit           ar_valid;
  rand bit   [31:0]  ar_addr;
  rand bit   [5:0]   ar_id;
  rand bit   [7:0]   ar_len;
  rand bit   [2:0]   ar_size;
  rand bit   [1:0]   ar_burst;
  rand bit   [2:0]   ar_prot;
  logic              ar_ready;

  // AXI Read Data Channel (Slave Core → Master)
  logic              r_valid;
  logic  [31:0]      r_data;
  logic  [5:0]       r_id;
  logic  /*[1:0]*/   r_resp;
  logic              r_last;
  rand bit           r_ready;

  // Slave and Core Interface
  rand bit           slave_ar_addr_ready;
  logic  [2:0]       slave_ar_prot;
  logic              slave_ar_addr_valid;
  logic  [31:0]      slave_ar_addr;

  rand bit           slave_r_data_valid;
  rand bit [31:0]    slave_r_data;


  // Enum to distinguish between different channels
  typedef enum bit [2:0] {  AR_CHANNEL = 3'b000,
                            R_CHANNEL = 3'b001,
                            W_CHANNEL = 3'b010,
                            AW_CHANNEL = 3'b011,
                            B_CHANNEL = 3'b100

  } axi_channels_e;

  axi_channels_e axi_channels;

  //-------------------------------------------
  // CONSTRAINTS
  //-------------------------------------------

  constraint reset_c{
    soft rst_n == 1;
  }

  // First Write Transaction
  //-------------------------------------------
  constraint master_write_address_valid_c {
    aw_valid dist {1 :/85, 0 :/15};
  }

  constraint slave_ready_write_trans_c {
    slave_aw_write_ready dist {1 :/95, 0 :/5};
  }

  constraint write_brust_c {
    aw_burst inside {0 , 1 , 2};
  }

  constraint write_len_c {
    solve aw_burst before aw_len;

    aw_len dist {[0:15] :=90, [15:255] :=10};

    (aw_burst == 'd2) -> aw_len inside {1 , 3 , 7 , 15}; // for wrap
  }

  constraint write_size_c{
    aw_size inside {0,1,2};
  }

  constraint master_write_data_valid_c {
    w_valid dist {1 :=90, 0 :=10};
  }

  constraint master_write_response_ready_c {
    b_ready dist {1 :=90, 0 :=10};
  }




  // Second Read Transaction
  //-------------------------------------------
  constraint master_read_address_valid_c {
    ar_valid dist {1 :/85, 0 :/15};
  }

  constraint slave_ready_address_trans_c {
    slave_ar_addr_ready dist {1 :/95, 0 :/5}; // Slave ready to accept addr from core
  }

  constraint read_brust_c {
    ar_burst inside {0 , 1 , 2};
  }

  constraint read_len_c {
    solve ar_burst before ar_len;

    ar_len dist {[0:15] :=90, [15:255] :=10};

    (ar_burst == 'd2) -> ar_len inside {1 , 3 , 7 , 15}; // For wrap
  }

  constraint read_size_c{
    ar_size inside {0,1,2};
  }

  constraint slave_read_data_valid_c {
    slave_r_data_valid dist {1 :=90, 0 :=10}; // Data which is read from slave is ready
  }

  constraint master_read_data_ready_c {
    r_ready dist {1 :=90, 0 :=10};
  }

endclass
