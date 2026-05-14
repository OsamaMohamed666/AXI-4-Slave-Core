all: compile sim coverage

compile:
	vlib work
	vlog -sv -f files.f +cover

sim:
	vsim +UVM_VERBOSITY=UVM_LOW -wlf axi_slave_core_top_tb.wlf -logfile sim.log -c -coverage -assertdebug -voptargs="+acc" work.axi_slave_core_top_tb -do  "coverage save -onexit -directive -codeAll axi_slave_core_top_tb.ucdb; run -all"
	vcd2wlf axi_slave_core_top_tb.vcd axi_slave_core_top_tb.wlf

	coverage:
	vcover report -html -htmldir coverage_report axi_slave_core_top_tb.ucdb