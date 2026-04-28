`include "uvm_macros.svh"
import uvm_pkg::*;
interface axi_slave_core_if( input bit clk);

  bit rst_n;

  //-------------------------------------------
  // FIRST WRITE TRANSACTION
  //-------------------------------------------

  // AXI w_rite Address Channel (Master → Slave Core)
  bit           aw_valid;
  bit   [31:0]  aw_addr;
  bit   [5:0]   aw_id;
  bit   [7:0]   aw_len;
  bit   [2:0]   aw_size;
  bit   [1:0]   aw_burst;
  bit   [2:0]   aw_prot;
  logic         aw_ready;

  // AXI w_rite Data Channel (Master → Slave Core)
  bit           w_valid;
  bit   [31:0]  w_data;
  bit           w_last;
  bit   [3:0]   w_strb;
  logic         w_ready;

  // AXI w_rite Response Channel (Slave Core → Master)
  logic         b_valid;
  logic [5:0]   b_id;
  logic [1:0]   b_resp;
  bit           b_ready;
  // Slave Interface
  logic [31:0]  slave_aw_addr;
  logic [2:0]   slave_aw_prot;
  logic [31:0]  slave_w_data;
  logic [3:0]   slave_w_strb;
  logic         write_aw_trans_valid;
  bit           slave_aw_write_ready;


  //-------------------------------------------
  // SECOND READ TRANSACTION
  //-------------------------------------------

  // AXI Read Address Channel (Master → Slave Core)
  bit                      ar_valid;
  bit   [31:0]             ar_addr;
  bit   [5:0]              ar_id;
  bit   [7:0]              ar_len;
  bit   [2:0]              ar_size;
  bit   [1:0]              ar_burst;
  bit   [2:0]              ar_prot;
  logic                    ar_ready;

  // AXI Read Data Channel (Slave Core → Master)
  logic                     r_valid;
  logic  [31:0]             r_data;
  logic  [5:0]              r_id;
  logic  /*[1:0]*/          r_resp;
  logic                     r_last;
  bit                       r_ready;

  // Slave and Core Interface
  bit                       slave_ar_addr_ready;
  logic  [2:0]              slave_ar_prot;
  logic                     slave_ar_addr_valid;
  logic  [31:0]             slave_ar_addr;

  bit                      slave_r_data_valid;
  bit   [31:0]             slave_r_data;


  // Clocking Block
  clocking cb @(posedge clk);
    default input #1step output #((axi_slave_core_package::CLK_PERIOD)/2);
    // FOR WRITE TRANSACTION
    input  aw_ready;
    input  w_ready;
    input  b_valid;
    input  b_id;
    input  b_resp;
    input  slave_aw_addr;
    input  slave_aw_prot;
    input  slave_w_data;
    input  slave_w_strb;
    input  write_aw_trans_valid;

    output aw_valid;
    output aw_addr;
    output aw_id;
    output aw_len;
    output aw_size;
    output aw_burst;
    output aw_prot;
    output w_valid;
    output w_data;
    output w_last;
    output w_strb;
    output b_ready;
    output slave_aw_write_ready;


    // FOR READ TRANSACTION
    input  ar_ready;
    input  r_valid;
    input  r_last;
    input  r_data;
    input  r_id;
    input  r_resp;
    input  slave_ar_prot;
    input  slave_ar_addr_valid;
    input  slave_ar_addr;

    output ar_valid;
    output ar_addr;
    output ar_id;
    output ar_len;
    output ar_size;
    output ar_burst;
    output ar_prot;
    output r_ready;
    output slave_ar_addr_ready;
    output slave_r_data_valid;
    output slave_r_data;
  endclocking


endinterface
