#include <stdlib.h>
#include <stdint.h>

#include "pico/stdlib.h"
#include "pico/platform.h"
#include "fpga_config.h"

#include "../game/game_main.h"



int main() {
	fpga_config_info config_info;
	config_info.spi = spi0;
	config_info.PORT_CDONE = 0;
	config_info.PORT_CRESET_B = 1;
	config_info.PORT_SPI_SDA = 3;
	config_info.PORT_SPI_SCK = 2;
	config_info.SPI_SPEED = 8000000;

	init_fpga_config(config_info);

	config_fpga(config_info);

	gpio_init(25);
	gpio_set_dir(25, GPIO_OUT);
	gpio_put(25, 1);

	game_main();

	return 0;
}
