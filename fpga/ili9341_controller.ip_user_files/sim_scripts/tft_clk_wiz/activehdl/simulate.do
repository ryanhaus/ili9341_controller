transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+tft_clk_wiz  -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.tft_clk_wiz xil_defaultlib.glbl

do {tft_clk_wiz.udo}

run 1000ns

endsim

quit -force
