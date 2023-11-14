vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/sim_clk_gen_v1_0_3
vlib questa_lib/msim/xil_defaultlib

vmap sim_clk_gen_v1_0_3 questa_lib/msim/sim_clk_gen_v1_0_3
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work sim_clk_gen_v1_0_3  -incr -mfcu  \
"../../../../ili9341_controller.gen/sources_1/bd/sim_clk_12mhz/ipshared/fda6/hdl/sim_clk_gen_v1_0_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -mfcu  \
"../../../bd/sim_clk_12mhz/ip/sim_clk_12mhz_sim_clk_gen_0_0/sim/sim_clk_12mhz_sim_clk_gen_0_0.v" \
"../../../bd/sim_clk_12mhz/sim/sim_clk_12mhz.v" \

vlog -work xil_defaultlib \
"glbl.v"

