#pragma once
#include "../graphics_lib/sprites.h"
#include "../graphics_lib/spi_transfer.h"
#include "../graphics_lib/general_functions.h"
#include "smiley_sprite.h"
#include <array>

void game_main() {
    std::array<spi_transfer, 12> transfers = sprite_to_spi_transfer(smiley_sprite, 1);

    for (int i = 0; i < 12; i++) {
        spi_transfer_u32_blocking(transfers[i].transfer_data);
    }

    spi_transfer_u32_blocking(0x80000001);

    while (true) {
        sleep_ms(10);
    }
}