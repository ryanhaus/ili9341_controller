#include <iostream>
#include <verilated.h>
#include <Vili9341_controller.h>
#include <verilated_vcd_c.h>
#include <SDL.h>
#include <thread>
#include <mutex>
#include <queue>

#include "clock_handler.h"
#include "tft_sim.h"
#include "spi_sim.h"
#include "../graphics_lib/sprites.h"
#include "../game/game_main.h"



// global variables
uint64_t max_time_ns = -1;
bool VERILATOR_TRACE = false;
bool RUN_GTKWAVE = false;
bool RUN_SCREEN_SIM = false;

uint8_t WINDOW_SCALE = 1;

Vili9341_controller* top;
VerilatedVcdC* m_trace;

SDL_Window* window;
SDL_Renderer* renderer;
SDL_Texture* texture;

tft_pixel framebuffer[320 * 240];

extern std::queue<uint32_t> spi_queue;
extern std::mutex spi_queue_mutex;
std::mutex verilator_mutex;


// handle state machine clock ticks, also handle determining positive edges of the dotclk for SDL simulation functions if applicable
int previous_tft_dotclk = 0;

bool state_machine_clock_tick(uint64_t time_ps) {
    bool continue_sim = true;

    verilator_mutex.lock();

    top->sm_clock = !top->sm_clock;
    top->eval();
    
    if (RUN_SCREEN_SIM) {
        if (top->tft_dotclk && !previous_tft_dotclk) {
            // positive edge of dotclk, call appropriate function
            continue_sim = tft_sim_tick(top, window, renderer, texture, &framebuffer[0]);
        }

        previous_tft_dotclk = top->tft_dotclk;
    }

    verilator_mutex.unlock();

    return continue_sim;
}



// handle sck clock ticks
bool transfer_active = false;

bool sck_clock_tick(uint64_t time_ps) {
    verilator_mutex.lock();

    if (top->spi_ready) {
        if (transfer_active || (!spi_queue.empty())) {
            top->spi_sck = !top->spi_sck;
            transfer_active = (!spi_queue.empty());

            if (!top->spi_sck) {
                top->spi_sda = spi_next_bit();
            }


            top->eval();
        }
    }

    verilator_mutex.unlock();

    return true;
}



// dump the current state of the verilator instance to the vcd file
void dump(uint64_t time_ps) {
    verilator_mutex.lock();

    if (VERILATOR_TRACE) {
        m_trace->dump(time_ps);
    }

    verilator_mutex.unlock();
}



// print the help menu
void print_help(char** argv) {
    std::cout << "Usage: " << argv[0] << " [options]" << std::endl;
    std::cout << "Options:" << std::endl;
    std::cout << "  --max-time [time_ns]    Maximum simulation time in nanoseconds (default: infinity)" << std::endl;
    std::cout << "  --trace                 Enable tracing (generates a VCD file)" << std::endl;
    std::cout << "  --gtkwave               Automatically open the VCD file with GTKWave (requires it to be installed, sudo apt install gtkwave)" << std::endl;
    std::cout << "  --screen-sim            Simulate a physical screen connected to the FPGA with SDL" << std::endl;
    std::cout << "  --screen-scale [scale]  Changes the scale of the simulated 240x320 screen (default: 1x scale)" << std::endl;
}



int main(int argc, char** argv) {
    // handle command line arguments
    if (argc == 1) {
        std::cout << "Error: No arguments provided." << std::endl;
        print_help(argv);
        return 0;
    }

    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];

        if (arg == "--help") {
            print_help(argv);
            return 0;
        } else if (arg == "--max-time") {
            if (i + 1 >= argc) {
                std::cout << "Error: Expected argument to --max-time." << std::endl;
                return 1;
            }

            max_time_ns = std::stoull(argv[++i]);
        } else if (arg == "--trace") {
            VERILATOR_TRACE = true;
        } else if (arg == "--gtkwave") {
            RUN_GTKWAVE = true;
        } else if (arg == "--screen-sim") {
            RUN_SCREEN_SIM = true;
        } else if (arg == "--screen-scale") {
            WINDOW_SCALE = std::stoi(argv[++i]);
        } else {
            std::cout << "Error: Unknown argument '" << arg << "'." << std::endl;
            return 1;
        }
    }

    if (RUN_GTKWAVE && !VERILATOR_TRACE) {
        std::cout << "Error: Tracing must be enabled with --trace to use --gtkwave." << std::endl;
        return 1;
    }



    // set up verilator
    top = new Vili9341_controller;
    top->reset = 1;
    top->enable = 1;
    top->spi_sck = 1;
    top->spi_sda = 0;
    top->sm_clock = 1;
    top->tft_dotclk = 0;



    // set up tracing if necessary
    Verilated::traceEverOn(VERILATOR_TRACE);
    if (VERILATOR_TRACE) {
        m_trace = new VerilatedVcdC;
        top->trace(m_trace, 99);
        m_trace->open("trace.vcd");
    }



    // set up SDL if necessary
    if (RUN_SCREEN_SIM) {
        if (SDL_Init(SDL_INIT_VIDEO) != 0) {
            std::cout << "Error: Failed to initialize SDL: " << SDL_GetError() << std::endl;
            return 1;
        }

        window = SDL_CreateWindow("TFT Simulator", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 240 * WINDOW_SCALE, 320 * WINDOW_SCALE, SDL_WINDOW_SHOWN);

        if (window == NULL) {
            std::cout << "Error: Failed to create SDL window: " << SDL_GetError() << std::endl;
            return 1;
        }

        renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

        if (renderer == NULL) {
            std::cout << "Error: Failed to create SDL renderer: " << SDL_GetError() << std::endl;
            return 1;
        }

        texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGB565, SDL_TEXTUREACCESS_STREAMING, 240, 320);

        if (texture == NULL) {
            std::cout << "Error: Failed to create SDL texture: " << SDL_GetError() << std::endl;
            return 1;
        }
    }



    // start the game code
    std::thread game_thread(game_main);



    // cycle reset
    top->eval();
    top->reset = 0;
    top->eval();



    // set up clocks
    verilator_clock state_machine_clock = { state_machine_clock_tick, hz_to_half_period_ps(5510400 * 4), false };
    verilator_clock sck_clock = { sck_clock_tick, hz_to_half_period_ps(10000000), false };

    verilator_clock clocks[] = { state_machine_clock, sck_clock };

    handle_clocks(clocks, 2, max_time_ns, dump);



    // clean up
    top->final();

    if (VERILATOR_TRACE) {
        m_trace->close();

        if (RUN_GTKWAVE) {
            std::cout << "Tracing complete, saved to 'trace.vcd'. Running gtkwave..." << std::endl;
            int gtkwave_success = system("gtkwave trace.vcd");

            if (gtkwave_success != 0) {
                std::cout << "Failed to run gtkwave. You may need to install it with 'sudo apt install gtkwave'." << std::endl;
                return 1;
            }
        } else {
            std::cout << "Tracing complete, run 'gtkwave trace.vcd' to view the trace (or run this program with --gtkwave to automatically do it)." << std::endl;
        }
    }

    if (RUN_SCREEN_SIM) {
        SDL_DestroyTexture(texture);
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
    }



    std::terminate(); // to also kill child thread handling game code

    return 0;
}