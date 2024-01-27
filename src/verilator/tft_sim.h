#pragma once

#include <verilated.h>
#include <Vili9341_controller.h>
#include <verilated_vcd_c.h>
#include <SDL.h>

#include "../graphics_lib/tft_pixel.h"


// global variables used by the 'tft_sim_tick' function
int current_pixel = 0;
int prev_vsync = 0;

// handles a single dotclk tick, called by the state machine clock function when appropriate
bool tft_sim_tick(Vili9341_controller* top, SDL_Window* window, SDL_Renderer* renderer, SDL_Texture* texture, tft_pixel* framebuffer) {
    // if data is enabled, read the pixel data and store it in the framebuffer
    if (top->tft_data_enable) {
        tft_pixel pixel;
        pixel.r5 = ((top->tft_data & 0b1111100000000000) >> 11);
        pixel.g6 = ((top->tft_data & 0b0000011111100000) >> 5);
        pixel.b5 = ((top->tft_data & 0b0000000000011111) >> 0);

        framebuffer[current_pixel++] = pixel;
    }



    // if vsync goes low, the frame is done and we can update the screen
    if (prev_vsync && !top->tft_vsync) {
        // check if window is attempting to be closed
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                return false;
            }
        }

        // update the screen
        SDL_UpdateTexture(texture, NULL, framebuffer, 240 * sizeof(tft_pixel));
        SDL_RenderClear(renderer);
        SDL_RenderCopyEx(renderer, texture, NULL, NULL, 0, NULL, SDL_FLIP_HORIZONTAL);
        SDL_RenderPresent(renderer);

        // reset the pixel counter
        current_pixel = 0;
    }

    prev_vsync = top->tft_vsync;

    return true;
}