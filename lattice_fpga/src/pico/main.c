#include <stdlib.h>
#include <stdint.h>

#include "pico/stdlib.h"
#include "pico/platform.h"
#include "../../build/fpga_config.h"

int main() {
	for (int i = 0; i < fpga_config_size; i++) {
		printf("%02X ", fpga_config[i]);
	}

	gpio_init(25);
	gpio_set_dir(25, GPIO_OUT);
	gpio_put(25, 1);

	return 0;
}
