#include <iostream>
#include <verilated.h>
#include <SDL.h>
#include "Vili9341_controller.h"

#define WINDOW_SCALE 2

using namespace std;

#pragma pack(push, 1)
struct Pixel {
    uint8_t a, b, g, r;
};

Pixel framebuffer[320 * 240];
uint8_t* framebuffer_ptr = (uint8_t*)framebuffer;

int main() {
    // initialize SDL for video
    if(SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cout << "Could not initialize SDL: " << SDL_GetError() << std::endl;
        return 1;
    }



    // create SDL window
    SDL_Window* window = SDL_CreateWindow("ILI9341 Controller", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 240 * WINDOW_SCALE, 320 * WINDOW_SCALE, SDL_WINDOW_SHOWN);

    if (!window) {
        std::cout << "Could not create window: " << SDL_GetError() << std::endl;
        return 1;
    }



    // create SDL renderer
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    if (!renderer) {
        std::cout << "Could not create renderer: " << SDL_GetError() << std::endl;
        return 1;
    }



    // create SDL texture for video output
    SDL_Texture* texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 240, 320);

    if (!texture) {
        std::cout << "Could not create texture: " << SDL_GetError() << std::endl;
        return 1;
    }



    // create verilator instance of the ILI9341 controller
    Vili9341_controller *top = new Vili9341_controller;

    top->reset = 0;
    top->enable = 1;



    // main loop
    while (true) {
        // close window if X is pressed
        SDL_Event e;
        if (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                break;
            }
        }



        // loop until vsync is high
        while (!top->tft_vsync) {
            for (int i = 0; i < 3; i++) {
                top->tft_dotclk = 1;
                top->eval();

                top->tft_dotclk = 0;
                top->eval();
            }
        }


        // loop until vsync is low (frame is done)
        int framebuffer_i = 0; // counter for framebuffer
        while (top->tft_vsync) {
            bool data_changed = false;

            for (int i = 0; i < 3; i++) {
                top->tft_dotclk = 1;
                top->eval();

                if (top->tft_data_enable || data_changed) {
                    data_changed = true;
                    framebuffer_ptr[framebuffer_i * 4 + (3 - i)] = (uint8_t)top->tft_data << 2;
                }

                top->tft_dotclk = 0;
                top->eval();
            }

            if (data_changed)
                framebuffer_i++;
        }

        // at this point, the frame is complete and the texture and screen can be updated
        SDL_UpdateTexture(texture, NULL, framebuffer, 240 * sizeof(Pixel));
        SDL_RenderClear(renderer);
        SDL_RenderCopyEx(renderer, texture, NULL, NULL, 0, NULL, SDL_FLIP_HORIZONTAL);
        SDL_RenderPresent(renderer);
    }

    // free resources
    top->final();
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
