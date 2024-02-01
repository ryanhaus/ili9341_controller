#pragma once
#include "../graphics_lib/sprites.h"
#include "../graphics_lib/spi_transfer.h"
#include "../graphics_lib/general_functions.h"
#include "sprites_generated.h"
#include <array>

void game_main() {
    std::array<spi_transfer, 12> transfers_s0 = sprite_to_spi_transfer(SPRITES[0], 0);
    std::array<spi_transfer, 12> transfers_s1 = sprite_to_spi_transfer(SPRITES[1], 1);

    for (int i = 0; i < 12; i++) {
        spi_transfer_u32_blocking(transfers_s0[i].transfer_data);
    }

    for (int i = 0; i < 12; i++) {
        spi_transfer_u32_blocking(transfers_s1[i].transfer_data);
    }

    spi_transfer_u32_blocking(0x80000001);

    while (true) {
        sleep_ms(10);
    }
}