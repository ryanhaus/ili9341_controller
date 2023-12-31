# Note: only tested on Ubuntu
sudo apt-get intsall git make



mkdir dep



mkdir dep/pico-sdk

sudo apt install cmake gcc-arm-none-eabi libnewlib-arm-none-eabi libstdc++-arm-none-eabi-newlib
git clone https://github.com/raspberrypi/pico-sdk.git dep/pico-sdk



mkdir dep/icestorm

sudo apt-get install build-essential clang bison flex libreadline-dev \
                     gawk tcl-dev libffi-dev git mercurial graphviz   \
                     xdot pkg-config python python3 libftdi-dev \
                     qt5-default python3-dev libboost-all-dev cmake libeigen3-dev

git clone https://github.com/YosysHQ/icestorm.git dep/icestorm
cd dep/icestorm && make -j$(nproc) && sudo make install



mkdir dep/nextpnr

git clone https://github.com/YosysHQ/nextpnr dep/nextpnr
cd dep/nextpnr && cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local . && make -j$(nproc) && sudo make install



mkdir dep/yosys

git clone https://github.com/YosysHQ/yosys.git dep/yosys
cd dep/yosys && make -j$(nproc) && sudo make install




sudo apt-get install git help2man perl python3
sudo apt-get install g++
sudo apt-get install verilator



mkdir dep/sdl2
git clone https://github.com/libsdl-org/SDL.git -b dep/sdl2
cd dep/sdl2 && mkdir build && cd build && ../configure && make && sudo make install