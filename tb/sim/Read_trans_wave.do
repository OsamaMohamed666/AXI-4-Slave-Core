onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /axi_slave_core_top_tb/dut/clk
add wave -noupdate /axi_slave_core_top_tb/dut/rst_n
add wave -noupdate /axi_slave_core_top_tb/dut/ARVALID
add wave -noupdate /axi_slave_core_top_tb/dut/ARADDR
add wave -noupdate /axi_slave_core_top_tb/dut/ARID
add wave -noupdate /axi_slave_core_top_tb/dut/ARLEN
add wave -noupdate /axi_slave_core_top_tb/dut/ARSIZE
add wave -noupdate /axi_slave_core_top_tb/dut/ARBURST
add wave -noupdate /axi_slave_core_top_tb/dut/ARPROT
add wave -noupdate /axi_slave_core_top_tb/dut/ARREADY
add wave -noupdate /axi_slave_core_top_tb/dut/RVALID
add wave -noupdate /axi_slave_core_top_tb/dut/RREADY
add wave -noupdate /axi_slave_core_top_tb/dut/slave_r_data_valid
add wave -noupdate /axi_slave_core_top_tb/dut/slave_r_data
add wave -noupdate /axi_slave_core_top_tb/dut/RDATA
add wave -noupdate /axi_slave_core_top_tb/dut/RLAST
add wave -noupdate /axi_slave_core_top_tb/dut/RID
add wave -noupdate /axi_slave_core_top_tb/dut/RRESP
add wave -noupdate /axi_slave_core_top_tb/dut/slave_ar_addr_ready
add wave -noupdate /axi_slave_core_top_tb/dut/slave_ar_prot
add wave -noupdate /axi_slave_core_top_tb/dut/slave_ar_addr_valid
add wave -noupdate /axi_slave_core_top_tb/dut/slave_ar_addr
add wave -noupdate /axi_slave_core_top_tb/dut/u_read_trans/fifo_empty
add wave -noupdate /axi_slave_core_top_tb/dut/u_read_trans/fifo_full
add wave -noupdate -radix unsigned /axi_slave_core_top_tb/dut/u_read_trans/u_read_fifo/wr_ptr
add wave -noupdate /axi_slave_core_top_tb/dut/u_read_trans/u_read_fifo/rd_ptr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {338685 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {338649 ns} {338741 ns}
