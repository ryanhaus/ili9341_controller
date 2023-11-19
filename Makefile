dependencies:
	mkdir dependencies

# for building pico binaries
pico: pico/build/ili9341_controller.uf2

pico/build/ili9341_controller.uf2: pico/build pico/main.c
	cd pico/build && make

pico/build:
	mkdir pico/build

pico/main.c: export PICO_SDK_PATH=$(shell pwd)/dependencies/pico-sdk
pico/main.c: pico/build pico/CMakeLists.txt dependencies/pico-sdk
	cd pico/build && cmake ..

dependencies/pico-sdk: dependencies
	-cd dependencies && git clone https://github.com/raspberrypi/pico-sdk.git --branch master



# for building verilog files w/ verilator for simulation
# note that bitstream files have to be generated through xilinx vivado software
dependencies/verilator: dependencies
	-cd dependencies && git clone https://github.com/verilator/verilator

verilator: verilator_sim/obj_dir/Vili9341_controller

verilator_run: verilator
	./verilator_sim/obj_dir/Vili9341_controller

verilator_sim/obj_dir/Vili9341_controller: verilator_sim/*.cpp
	
verilator_sim/*.cpp: verilator_sim/obj_dir/*.cpp
	cd verilator_sim && make -C obj_dir -f Vili9341_controller.mk Vili9341_controller
	
verilator_sim/obj_dir: fpga/ili9341_controller.srcs/sources_1/new/*.v

verilator_sim/obj_dir/*.cpp: verilator_sim/obj_dir

fpga/ili9341_controller.srcs/sources_1/new/*.v: dependencies/SDL dependencies/verilator
	cd fpga/ili9341_controller.srcs/sources_1/new && \
	verilator -I$(shell pwd)/dependencies/SDL/include/ ili9341_controller.v --cc -Mdir $(shell pwd)/verilator_sim/obj_dir -Wno-WIDTH --exe main_sim.cpp \
		-CFLAGS "$(shell sdl2-config --cflags)" -LDFLAGS "$(shell sdl2-config --libs)"

# SDL, also used for verilator simulation
dependencies/SDL: dependencies
	-cd dependencies && git clone https://github.com/libsdl-org/SDL.git -b SDL2

# cleaning
clean: clean_pico clean_verilator
clean_all: clean_pico_all clean_verilator_all

clean_verilator:
	rm -rf verilator_sim/obj_dir

clean_verilator_all: clean_verilator
	rm -rf dependencies/verilator
	rm -rf dependencies/SDL

clean_pico:
	rm -rf pico/build

clean_pico_all: clean_pico
	rm -rf dependencies/pico-sdk

clean_dep:
	rm -rf dependencies