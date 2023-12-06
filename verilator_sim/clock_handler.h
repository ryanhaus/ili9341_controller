#include <stdint.h>
#include <stdbool.h>


// a function that gets called to handle a change in a clock, returns true if the clocks should continue ticking, false if they should stop
typedef bool(*clock_tick_function)(uint64_t);
typedef void(*clock_dump_function)(uint64_t);



// information about a clock
typedef struct {
    clock_tick_function tick_function; // the function to be called every time the clock should change
    uint64_t half_period_ps; // the half period of the clock in picoseconds, i.e. a 12MHz clock would have a half period of 41.666ns, or 41666ps (since its overall period is 1/12000000 seconds, which equals 83.333ns, or 83333ps)
} verilator_clock;



inline uint64_t hz_to_half_period_ps(uint64_t hz) {
    return 1000000000000 / (hz * 2);
}



void handle_clocks(verilator_clock* clocks, size_t num_clocks, uint64_t max_time_ps, clock_dump_function dump_function) {
    uint64_t time_ps = 0;
    bool continue_ticking = true;

    while (continue_ticking && time_ps <= max_time_ps) {
        // figure out when the next clock is going to change
        uint64_t delta_next_time_ps = UINT64_MAX;

        // go through each clock
        for (int i = 0; i < num_clocks; i++) {
            verilator_clock* clock = &clocks[i];

            // if the clock is going to change on the current tick, don't check the rest of the clocks and set the delta t to zero
            if (time_ps % clock->half_period_ps == 0) {
                delta_next_time_ps = 0;
                break;
            }

            // if the clock is not changing on the current tick, find out how many ps until it does change. store the lowest delta t
            uint64_t ps_remaining = (clock->half_period_ps - (time_ps % clock->half_period_ps));

            if (ps_remaining < delta_next_time_ps) {
                delta_next_time_ps = ps_remaining;
            }
        }



        // advance time to the next clock change, then figure out which clocks have changed
        time_ps += delta_next_time_ps;

        // go through each clock
        for (int i = 0; i < num_clocks; i++) {
            verilator_clock* clock = &clocks[i];

            // if the clock is changing on the current tick, execute the tick function for that clock
            if (time_ps % clock->half_period_ps == 0) {
                continue_ticking &= clock->tick_function(time_ps);
            }
        }

        

        // after handling all clock events, call the dump function, which will dump the current state of the verilator instance to the vcd file
        dump_function(time_ps);



        // go forward in time by 1ps to avoid getting stuck in an infinite loop
        time_ps++;
    }
}