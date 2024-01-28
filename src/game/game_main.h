#pragma once
#include "../graphics_lib/sprites.h"
#include "../graphics_lib/spi_transfer.h"
#include "../graphics_lib/general_functions.h"
#include <array>

void game_main() {
    tft_sprite sprite;

    uint8_t smile_bitmap[8] = {
        0b00111100,
        0b01111110,
        0b11011011,
        0b11111111,
        0b10111101,
        0b11000011,
        0b01111110,
        0b00111100
    };

    sprite = bitmap_to_sprite(smile_bitmap, 0x0000, 0xFFE0);


    std::array<spi_transfer, 12> transfers = sprite_to_spi_transfer(sprite, 1);

    for (int i = 0; i < 12; i++) {
        spi_transfer_u32_blocking(transfers[i].transfer_data);
    }

    spi_transfer_u32_blocking(0x80000001);

    while (true) {
        sleep_ms(10);
    }
}