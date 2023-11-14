transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vmap -link {C:/Users/ryanh/Documents/projects/fpga/ili9341_controller/ili9341_controller.cache/compile_simlib/riviera}
vlib riviera/sim_clk_gen_v1_0_3
vlib riviera/xil_defaultlib

vlog -work sim_clk_gen_v1_0_3  -incr -v2k5 -l sim_clk_gen_v1_0_3 -l xil_defaultlib \
"../../../../ili9341_controller.gen/sources_1/bd/sim_clk_12mhz/ipshared/fda6/hdl/sim_clk_gen_v1_0_vl_rfs.v" \

vlog -work xil_defaultlib  -incr -v2k5 -l sim_clk_gen_v1_0_3 -l xil_defaultlib \
"../../../bd/sim_clk_12mhz/ip/sim_clk_12mhz_sim_clk_gen_0_0/sim/sim_clk_12mhz_sim_clk_gen_0_0.v" \
"../../../bd/sim_clk_12mhz/sim/sim_clk_12mhz.v" \

vlog -work xil_defaultlib \
"glbl.v"

