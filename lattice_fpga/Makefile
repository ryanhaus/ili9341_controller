build_dir = build
pico_src_dir = src/pico
pico_main_file = $(pico_src_dir)/main.c
verilog_src_dir = src/verilog
top_module_name = top
config_pcf = top.pcf
output_header = fpga_config.h
fpga_config_var_name = fpga_config
place_route_args = --hx1k --package vq100 --ignore-loops

# to create the build directory
$(build_dir):
	mkdir $(build_dir)

# to synthesize the design
$(build_dir)/$(top_module_name).json: $(build_dir) $(verilog_src_dir)/*.v
	yosys -p 'synth_ice40 -top $(top_module_name) -json $(build_dir)/$(top_module_name).json' $(verilog_src_dir)/*.v

# to place and route the design
$(build_dir)/$(top_module_name).asc: $(build_dir) $(build_dir)/$(top_module_name).json $(config_pcf)
	nextpnr-ice40 $(place_route_args) --json $(build_dir)/$(top_module_name).json --pcf $(config_pcf) --asc $(build_dir)/$(top_module_name).asc

# to convert the design to binary
$(build_dir)/$(top_module_name).bin: $(build_dir) $(build_dir)/$(top_module_name).asc
	icepack $(build_dir)/$(top_module_name).asc $(build_dir)/$(top_module_name).bin

# to pack the binary into a c-style array to be used in the pico firmware
$(build_dir)/$(output_header): $(build_dir) $(build_dir)/$(top_module_name).bin
	xxd -i $(build_dir)/$(top_module_name).bin $(build_dir)/$(output_header)
	sed -i "1 s/.*/const uint8_t __in_flash() $(fpga_config_var_name)[] = {/" $(build_dir)/$(output_header)
	sed -i "$$ s/.*/const size_t $(fpga_config_var_name)_size = $(shell stat -c %s $(build_dir)/$(top_module_name).bin);/" $(build_dir)/$(output_header)

clean:
	rm -rf $(build_dir)

fpga_synthesis: $(build_dir)/$(top_module_name).json
fpga_place_and_route: $(build_dir)/$(top_module_name).asc
fpga_output_binary: $(build_dir)/$(top_module_name).bin
fpga_output_c_arr: $(build_dir)/$(output_header)

# pico outputs
$(build_dir)/Makefile: export PICO_SDK_PATH=$(shell pwd)/dep/pico-sdk
$(build_dir)/Makefile: $(build_dir) CMakeLists.txt
	cd build && cmake ..

dep/pico-sdk:
	-mkdir dep
	-cd dep && git clone https://github.com/raspberrypi/pico-sdk.git --branch master

$(build_dir)/pico_out.uf2: dep/pico-sdk $(build_dir)/Makefile $(pico_src_dir)/* $(build_dir)/$(output_header)
	cd build && make

pico: $(build_dir)/pico_out.uf2

.DEFAULT_GOAL := pico
