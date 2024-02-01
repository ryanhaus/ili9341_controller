#pragma once
#include "../graphics_lib/sprites.h"
#include "../graphics_lib/spi_transfer.h"
#include "../graphics_lib/general_functions.h"
#include "sprites_generated.h"
#include <array>

void game_main() {
    for (int i = 0; i < 256; i++) {
        std::array<spi_transfer, 12> transfers = sprite_to_spi_transfer(SPRITES[i], i);

        for (int j = 0; j < 12; j++) {
            spi_transfer_u32_blocking(transfers[j].transfer_data);
        }
    }

    for (int i = 'a'; i < 'z'; i += 2) {
        spi_transfer transfer;
        transfer.ram_select = 1;
        transfer.addr = (i - 'a') / 2;
        transfer.data = i | ((i + 1) << 8);

        spi_transfer_u32_blocking(transfer.transfer_data);
    }

    const char* message1 = "hello world";

    for (int i = 0; i < strlen(message1); i+=2) {
        spi_transfer transfer;
        transfer.ram_select = 1;
        transfer.addr = 15 + i / 2;
        transfer.data = message1[i] | (message1[i + 1] << 8);

        spi_transfer_u32_blocking(transfer.transfer_data);
    }

    const char* message2 = "the quick brown fox jumps over the lazy dog";

    for (int i = 0; i < strlen(message2); i+=2) {
        spi_transfer transfer;
        transfer.ram_select = 1;
        transfer.addr = 30 + i / 2;
        transfer.data = message2[i] | (message2[i + 1] << 8);

        spi_transfer_u32_blocking(transfer.transfer_data);
    }

    while (true) {
        sleep_ms(10);
    }
}