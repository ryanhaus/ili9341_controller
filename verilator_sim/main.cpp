#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <verilated.h>
#include <SDL.h>
#include "Vili9341_verilator.h"
#include "verilated_vcd_c.h"

#include "clock_handler.h"



#define WINDOW_SCALE 2



#pragma pack(push, 1)
struct Pixel {
    union {
        struct { uint8_t a, b, g, r; };
        struct { uint8_t brightness, colors[3]; };
    };
};

Pixel framebuffer[320 * 240];
bool VERILATOR_TRACE = false;

Vili9341_verilator* top;
VerilatedVcdC* m_trace;
SDL_Window* window;
SDL_Renderer* renderer;
SDL_Texture* texture;



// called once per frame, handles SDL events and updates the screen, returns if window is still active
bool sdl_tick() {
    SDL_Event e;
    while (SDL_PollEvent(&e)) {
        if (e.type == SDL_QUIT) {
            return false;
        }
    }

    SDL_UpdateTexture(texture, NULL, framebuffer, 240 * sizeof(Pixel));
    SDL_RenderClear(renderer);
    SDL_RenderCopyEx(renderer, texture, NULL, NULL, 0, NULL, SDL_FLIP_HORIZONTAL);
    SDL_RenderPresent(renderer);

    return true;
}



// handle dotclk tick
uint8_t prev_vsync = 0;
unsigned int transfer_count = 0;
unsigned int pixel = 0;

bool clock_dotclk_tick(uint64_t time_ps) {
    // toggle clock
    top->tft_dotclk = !top->tft_dotclk;
    


    // evaluate
    top->eval();



    // if data is valid, put it onto the framebuffer
    if (top->tft_dotclk == 1) {
        if (top->tft_data_enable) {
            int current_color = transfer_count % 3; // 0 = red, 1 = green, 2 = blue

            // write the current pixel to memory
            if (pixel < 320 * 240) {
                framebuffer[pixel].brightness = 0xFF;
                framebuffer[pixel].colors[current_color] = top->tft_data << 2;
            }

            // if all three colors have been sent, advance to next pixel
            if (transfer_count % 3 == 2) {
                pixel++;
            }

            // increase the transfer count
            transfer_count++;
        }



        // if vsync falls, then a new frame is ready (also ensure that all pixels have been sent)
        if (prev_vsync == 1 && top->tft_vsync == 0 && pixel >= 320 * 240) {
            // reset transfer count and pixel
            transfer_count = 0;
            pixel = 0;

            // handle sdl
            if (!sdl_tick()) {
                return false;
            }

            // if we're in trace mode, we only want to draw one frame
            if (VERILATOR_TRACE) {
                printf("Tracing finished\n");
                
                // await window closing
                while (sdl_tick()) {}

                return false;
            }
        }

        prev_vsync = top->tft_vsync;
    }

    return true;
}



// handle sck tick
uint16_t spi_transfer_count = 0;
uint8_t spi_bit_counter = 0;
bool clock_sck_tick(uint64_t time_ps) {
    // if we can't send data, just do nothing
    if (!top->spi_ready) {
        return true;
    }

    // toggle clock
    top->spi_sck = !top->spi_sck;

    // if clock is rising, set data too
    if (top->spi_sck == 1) {
        // figure out x and y position
        uint16_t x = spi_transfer_count % 240,
                 y = spi_transfer_count / 240;

        // set data based on the bit counter, note that data is sent MSB first
        if (spi_bit_counter < 16) { // 16 most significant bits are the address
            top->spi_sda = (spi_transfer_count >> (15 - spi_bit_counter)) & 1;
        } else { // 8 least significant bits are the data
            top->spi_sda = (x >> (23 - spi_bit_counter)) & 1;
        }

        // increase spi bit counter
        spi_bit_counter++;

        // if we have completed the transfer, reset the bit counter and increase the transfer counter
        if (spi_bit_counter == 24) {
            spi_bit_counter = 0;
            spi_transfer_count++;
        }
    }

    // evaluate
    top->eval();

    return true;
}



// handle saving trace information
void dump(uint64_t time_ps) {
    if (VERILATOR_TRACE) {
        m_trace->dump(time_ps);
    }
}



int main(int argc, char** argv) {
    // determine if we are tracing
    if (argc > 1 && strcmp(argv[1], "--trace") == 0) {
        printf("TRACING ENABLED, to view output run gtkwave trace.vcd\n");
        VERILATOR_TRACE = true;
    }

    // set up verilator
    top = new Vili9341_verilator;
    top->tft_dotclk = 0;
    top->spi_sck = 0;
    
    // set up tracing, if indicated
    if (VERILATOR_TRACE) {
        m_trace = new VerilatedVcdC;
        Verilated::traceEverOn(true);
        top->trace(m_trace, 99);
        m_trace->open("trace.vcd");
    }



    // initialize SDL for video
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("Could not initialize SDL: %s\n", SDL_GetError());
        return 1;
    }

    // create SDL window
    window = SDL_CreateWindow("ILI9341 Controller", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 240 * WINDOW_SCALE, 320 * WINDOW_SCALE, SDL_WINDOW_SHOWN);

    if (!window) {
        printf("Could not create window: %s\n", SDL_GetError());
        return 1;
    }

    // create SDL renderer
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    if (!renderer) {
        printf("Could not craete renderer: %s\n", SDL_GetError());
        return 1;
    }

    // create SDL texture for video output
    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET, 240, 320);

    if (!texture) {
        printf("Could not craete texture: %s\n", SDL_GetError());
        return 1;
    }



    // set up clocks
    verilator_clock dotclk_clock = { clock_dotclk_tick, hz_to_half_period_ps(16531200) }; // 16.5312MHz dotclk
    verilator_clock sck_clock = { clock_sck_tick, hz_to_half_period_ps(1000000) }; // 62.5MHz sck
    verilator_clock clocks[] = { dotclk_clock, sck_clock };

    SDL_PollEvent(NULL);

    handle_clocks(clocks, 2, -1, dump);



    // exit
    top->final();

    if (VERILATOR_TRACE) {
        m_trace->close();
    }

    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}