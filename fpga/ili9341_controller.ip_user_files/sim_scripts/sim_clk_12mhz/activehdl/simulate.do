transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+sim_clk_12mhz  -L sim_clk_gen_v1_0_3 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.sim_clk_12mhz xil_defaultlib.glbl

do {sim_clk_12mhz.udo}

run 1000ns

endsim

quit -force
