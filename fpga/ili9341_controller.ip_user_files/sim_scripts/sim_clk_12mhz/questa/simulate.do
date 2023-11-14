onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib sim_clk_12mhz_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {sim_clk_12mhz.udo}

run 1000ns

quit -force
