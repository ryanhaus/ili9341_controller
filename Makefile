default: all
all: pico verilator

# for building pico binaries
pico: pico/build/ili9341_controller.uf2

pico/build/ili9341_controller.uf2: dependencies/pico-sdk pico/build/Makefile pico/*.c
	cd pico/build && make

pico/build/Makefile: export PICO_SDK_PATH=$(shell pwd)/dependencies/pico-sdk
pico/build/Makefile: pico/CMakeLists.txt
	-mkdir pico/build
	cd pico/build && cmake ..

dependencies/pico-sdk:
	-mkdir dependencies
	-cd dependencies && git clone https://github.com/raspberrypi/pico-sdk.git --branch master



# for building verilog files w/ verilator for simulation
# note that bitstream files have to be generated through xilinx vivado software
verilator: verilator_sim/obj_dir/Vili9341_controller

verilator_run: verilator
	./verilator_sim/obj_dir/Vili9341_controller

verilator_sim/obj_dir/Vili9341_controller: verilator_sim/obj_dir/ili9341_controller.mk
	cd verilator_sim && make -C obj_dir -f Vili9341_controller.mk Vili9341_controller

verilator_sim/obj_dir/ili9341_controller.mk: fpga/ili9341_controller.srcs/sources_1/new/*.v
	cd fpga/ili9341_controller.srcs/sources_1/new && \
	verilator ili9341_controller.v --cc -Mdir $(shell pwd)/verilator_sim/obj_dir -Wno-WIDTH --exe main_sim.c \
		-CFLAGS "$(shell sdl2-config --cflags)" -LDFLAGS "$(shell sdl2-config --libs)"

# cleaning
clean: clean_pico clean_verilator
clean_all: clean_pico_all clean_verilator

clean_verilator:
	rm -rf verilator_sim/obj_dir

clean_pico:
	rm -rf pico/build

clean_pico_all: clean_pico
	rm -rf dependencies/pico-sdk

clean_dep:
	rm -rf dependencies