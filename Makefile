PYTHON = python3

build_dir = build
pico_src_dir = src/pico
pico_main_file = $(pico_src_dir)/main.c

verilog_src_dir = src/verilog
top_module_name = top
config_pcf = top.pcf
output_header = fpga_config.h
fpga_config_var_name = fpga_config
place_route_args = --up5k --package sg48

pll_module_name = dotclk_pll
pll_input_clk_mhz = 12
pll_output_clk_mhz = 22.0416 # 280 px * 328 px * 60 Hz * 4clks/dotclk = 22.0416 MHz

verilator_top_module_name = ili9341_controller
verilator_arguments = --trace --Wno-width --Wno-pinmissing --Wno-litendian
verilator_sim_bin_name = V$(verilator_top_module_name)
verilator_src_dir = src/verilator
verilator_include_dir = /usr/share/verilator/include

graphics_lib_src_dir = src/graphics_lib
game_src_dir = src/game
util_src_dir = src/util



# to create the PLL module
$(verilog_src_dir)/$(pll_module_name).v:
	icepll \
	-i $(pll_input_clk_mhz) \
	-o $(pll_output_clk_mhz) \
	-mf $(verilog_src_dir)/$(pll_module_name).v \
	-n $(pll_module_name)

# to synthesize the design into json
$(build_dir)/$(top_module_name).json: $(verilog_src_dir)/$(pll_module_name).v $(verilog_src_dir)/*.v
	-mkdir build
	yosys \
	-p 'synth_ice40 -top $(top_module_name) -json $(build_dir)/$(top_module_name).json -spram' \
	$(verilog_src_dir)/*.v

# to place and route the design, also outputs timing report
$(build_dir)/$(top_module_name).asc: $(build_dir)/$(top_module_name).json $(config_pcf)
	nextpnr-ice40 \
	$(place_route_args) \
	--json $(build_dir)/$(top_module_name).json \
	--pcf $(config_pcf) \
	--asc $(build_dir)/$(top_module_name).asc

	icetime \
	-d up5k \
	-mtr $(build_dir)/$(top_module_name).rpt \
	$(build_dir)/$(top_module_name).asc

# to convert the design to binary
$(build_dir)/$(top_module_name).bin: $(build_dir)/$(top_module_name).asc
	icepack \
	$(build_dir)/$(top_module_name).asc \
	$(build_dir)/$(top_module_name).bin

# to pack the binary into a c-style array to be used in the pico firmware
$(build_dir)/$(output_header): $(build_dir)/$(top_module_name).bin
	xxd -i $(build_dir)/$(top_module_name).bin $(build_dir)/$(output_header)
	sed -i "1 s/.*/const uint8_t __in_flash() $(fpga_config_var_name)[] = {/" $(build_dir)/$(output_header)
	sed -i "$$ s/.*/const size_t $(fpga_config_var_name)_size = $(shell stat -c %s $(build_dir)/$(top_module_name).bin);/" $(build_dir)/$(output_header)



# fpga outputs
fpga_pll: $(verilog_src_dir)/$(pll_module_name).v
fpga_synthesis: $(build_dir)/$(top_module_name).json
fpga_place_and_route: $(build_dir)/$(top_module_name).asc
fpga_output_binary: $(build_dir)/$(top_module_name).bin
fpga_output_c_arr: $(build_dir)/$(output_header)



# verilator, for simulation
$(game_src_dir)/sprites_generated.h: $(util_src_dir)/sprites.png
	$(PYTHON) $(util_src_dir)/image_to_sprite.py $(util_src_dir)/sprites.png $(game_src_dir)/sprites_generated.h

$(build_dir)/$(verilator_sim_bin_name): $(verilator_src_dir)/* $(verilog_src_dir)/* $(graphics_lib_src_dir)/* $(game_src_dir)/* $(game_src_dir)/sprites_generated.h
	-mkdir build
	verilator $(verilator_top_module_name).v \
	 -I$(verilog_src_dir) \
	 --top-module $(verilator_top_module_name) \
	 --Mdir $(build_dir) \
	 --cc --exe --build $(verilator_src_dir)/main.cpp \
	 $(verilator_arguments) \
	-CFLAGS "-g -Wall -Ublackbox $(shell sdl2-config --cflags)" \
	-LDFLAGS "$(shell sdl2-config --libs)" \
	$(verilator_src_dir)/*.cpp



verilator: $(build_dir)/$(verilator_sim_bin_name)
verilator_run: verilator
	$(build_dir)/$(verilator_sim_bin_name)


# pico outputs
$(build_dir)/Makefile: export PICO_SDK_PATH=$(shell pwd)/dep/pico-sdk
$(build_dir)/Makefile: CMakeLists.txt
	-mkdir build
	cd build && cmake ..

dep/pico-sdk:
	-mkdir dep
	-cd dep && git clone https://github.com/raspberrypi/pico-sdk.git --branch master

$(build_dir)/pico_out.uf2: dep/pico-sdk $(build_dir)/Makefile $(pico_src_dir)/* $(build_dir)/$(output_header)
	cd build && make

pico: $(build_dir)/pico_out.uf2



# to clean the build directory as well as generated verilog files
clean:
	rm -rf $(build_dir)
	rm -f $(verilog_src_dir)/$(pll_module_name).v
	rm -f $(game_src_dir)/sprites_generated.h

.DEFAULT_GOAL := pico
