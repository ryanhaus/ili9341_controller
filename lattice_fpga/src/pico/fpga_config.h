#include "hardware/spi.h"
#include "../../build/fpga_config.h" // this header is generated and contains an array called 'fpga_config' consisting of the fpga configuration data, as well as a variable 'fpga_config_size' denoting the size of it

typedef struct {
    spi_inst_t* spi;

    int PORT_CDONE,
        PORT_CRESET_B,
        PORT_SPI_SDA,
        PORT_SPI_SCK;

    unsigned int SPI_SPEED;
} fpga_config_info;



// initializes everything needed for the SPI FPGA configuration process
void init_fpga_config(fpga_config_info config_info) {
    // initialize all GPIO pins
    gpio_init(config_info.PORT_CDONE);
    gpio_init(config_info.PORT_CRESET_B);
    gpio_init(config_info.PORT_SPI_SDA);
    gpio_init(config_info.PORT_SPI_SCK);

    // set inputs/outputs
    gpio_set_dir(config_info.PORT_CDONE, GPIO_IN);
    gpio_set_dir(config_info.PORT_CRESET_B, GPIO_OUT);

    // initialize SPI
    spi_init(config_info.spi, config_info.SPI_SPEED);

    // set SPI format
    spi_set_format(
        config_info.spi,
        8, // data bits
        SPI_CPOL_0, // clock polarity
        SPI_CPHA_0, // clock phase
        SPI_MSB_FIRST // data order
    );

    // set SPI pins
    gpio_set_function(config_info.PORT_SPI_SDA, GPIO_FUNC_SPI);
    gpio_set_function(config_info.PORT_SPI_SCK, GPIO_FUNC_SPI);

}



// programs the FPGA with the configuration data in the array 'fpga_config', according to FPGA-TN-02001
void config_fpga(fpga_config_info config_info) {
    // reset the FPGA
    gpio_put(config_info.PORT_CRESET_B, 0);
    sleep_ms(1);
    gpio_put(config_info.PORT_CRESET_B, 1);
    sleep_ms(5);

    // send a dummy byte to the FPGA
    spi_write_blocking(config_info.spi, 0x00, 1); // note: may have to make a variable with the contents of all zero bits instead of just reading whatever's at 0x00

    // send configuration image
    spi_write_blocking(config_info.spi, fpga_config, fpga_config_size);

    // wait for CDONE to go high
    while (gpio_get(config_info.PORT_CDONE) == 0) {}

    // send >49 dummy bits to FPGA, closest multiple of 8 that is at least 49 is 56 bits, or 7 bytes
    spi_write_blocking(config_info.spi, 0x00, 7);

    // done with configuration, just wait an extra millisecond just to be sure everything's good
    sleep_ms(1);
}