onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc"  -L sim_clk_gen_v1_0_3 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.sim_clk_12mhz xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {sim_clk_12mhz.udo}

run 1000ns

quit -force
