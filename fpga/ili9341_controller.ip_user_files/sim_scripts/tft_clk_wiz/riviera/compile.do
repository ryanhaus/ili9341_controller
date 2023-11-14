transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vmap -link {C:/Users/ryanh/Documents/projects/fpga/ili9341_controller/ili9341_controller.cache/compile_simlib/riviera}
vlib riviera/xpm
vlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../../ili9341_controller.gen/sources_1/ip/tft_clk_wiz" -l xpm -l xil_defaultlib \
"C:/Xilinx/Vivado/2023.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93  -incr \
"C:/Xilinx/Vivado/2023.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../ili9341_controller.gen/sources_1/ip/tft_clk_wiz" -l xpm -l xil_defaultlib \
"../../../../ili9341_controller.gen/sources_1/ip/tft_clk_wiz/tft_clk_wiz_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

