onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /axi_slave_core_top_tb/dut/clk
add wave -noupdate /axi_slave_core_top_tb/dut/AWVALID
add wave -noupdate /axi_slave_core_top_tb/dut/AWADDR
add wave -noupdate /axi_slave_core_top_tb/dut/AWID
add wave -noupdate /axi_slave_core_top_tb/dut/AWBURST
add wave -noupdate /axi_slave_core_top_tb/dut/AWREADY
add wave -noupdate /axi_slave_core_top_tb/dut/WVALID
add wave -noupdate -color Maroon /axi_slave_core_top_tb/dut/WDATA
add wave -noupdate /axi_slave_core_top_tb/dut/WLAST
add wave -noupdate /axi_slave_core_top_tb/dut/WSTRB
add wave -noupdate /axi_slave_core_top_tb/dut/WREADY
add wave -noupdate /axi_slave_core_top_tb/dut/BVALID
add wave -noupdate /axi_slave_core_top_tb/dut/BID
add wave -noupdate /axi_slave_core_top_tb/dut/BRESP
add wave -noupdate /axi_slave_core_top_tb/dut/BREADY
add wave -noupdate /axi_slave_core_top_tb/dut/u_write_trans/u_write_fifo/aw_fifo_burst
add wave -noupdate /axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/fifo_aw_addr
add wave -noupdate -color Maroon /axi_slave_core_top_tb/dut/u_write_trans/u_write_fifo/w_fifo_data
add wave -noupdate -color Maroon /axi_slave_core_top_tb/dut/slave_w_data
add wave -noupdate /axi_slave_core_top_tb/dut/slave_aw_addr
add wave -noupdate /axi_slave_core_top_tb/dut/slave_w_strb
add wave -noupdate /axi_slave_core_top_tb/dut/write_aw_trans_valid
add wave -noupdate /axi_slave_core_top_tb/dut/slave_aw_write_ready
add wave -noupdate -radix unsigned /axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/aw_address_count
add wave -noupdate -radix unsigned /axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/w_data_count
add wave -noupdate -radix hexadecimal -childformat {{{/axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/cs[2]} -radix hexadecimal} {{/axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/cs[1]} -radix hexadecimal} {{/axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/cs[0]} -radix hexadecimal}} -expand -subitemconfig {{/axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/cs[2]} {-height 15 -radix hexadecimal} {/axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/cs[1]} {-height 15 -radix hexadecimal} {/axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/cs[0]} {-height 15 -radix hexadecimal}} /axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/cs
add wave -noupdate -radix hexadecimal /axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/ns
add wave -noupdate -color Salmon /axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/addr_burst_busy
add wave -noupdate -color Salmon /axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/data_burst_busy
add wave -noupdate -color Magenta /axi_slave_core_top_tb/dut/u_write_trans/u_axi_write_channel/data_empty_flag
add wave -noupdate -radix unsigned /axi_slave_core_top_tb/dut/u_write_trans/u_write_fifo/fifo_data_count
add wave -noupdate /axi_slave_core_top_tb/dut/AWLEN
add wave -noupdate /axi_slave_core_top_tb/dut/AWSIZE
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {935 ns} 0} {{Cursor 2} {648585 ns} 0} {{Cursor 3} {1 ns} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {648546 ns} {648624 ns}
