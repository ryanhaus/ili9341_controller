default: all
all: pico verilator

# for building pico binaries
pico: pico/build/ili9341_controller.uf2

pico/build/ili9341_controller.uf2: dependencies/pico-sdk pico/build/Makefile pico/*.c pico/*.h
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
verilator: verilator_sim/obj_dir/Vili9341_verilator

verilator_run: verilator
	./verilator_sim/obj_dir/Vili9341_verilator

verilator_run_trace: verilator
	./verilator_sim/obj_dir/Vili9341_verilator --trace

verilator_sim/obj_dir/Vili9341_verilator: verilator_sim/obj_dir/Vili9341_verilator.mk fpga/ili9341_controller.srcs/sources_1/new/*.v fpga/ili9341_controller.srcs/sim_1/new/*.sv verilator_sim/*.c
	cd verilator_sim && make -C obj_dir -f Vili9341_verilator.mk Vili9341_verilator

verilator_sim/obj_dir/Vili9341_verilator.mk: fpga/ili9341_controller.srcs/sources_1/new/*.v fpga/ili9341_controller.srcs/sim_1/new/*.sv verilator_sim/*.c
	cd fpga/ili9341_controller.srcs/sim_1/new && \
	verilator ili9341_verilator.sv -I$(shell pwd)/fpga/ili9341_controller.srcs/sources_1/new --cc -Mdir $(shell pwd)/verilator_sim/obj_dir -Wno-WIDTH --exe main_sim.c -sv --trace \
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