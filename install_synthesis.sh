# Note: only tested on Ubuntu
mkdir dep
cd dep



mkdir pico-sdk

git clone https://github.com/raspberrypi/pico-sdk.git pico-sdk



mkdir icestorm

git clone https://github.com/YosysHQ/icestorm.git icestorm
cd icestorm 
make -j$(nproc)
sudo make install
cd ..



mkdir nextpnr

git clone https://github.com/YosysHQ/nextpnr nextpnr
cd nextpnr
cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local .
make -j$(nproc)
sudo make install
cd ..



mkdir yosys

git clone https://github.com/YosysHQ/yosys.git yosys
cd yosys
make -j$(nproc)
sudo make install
cd ..