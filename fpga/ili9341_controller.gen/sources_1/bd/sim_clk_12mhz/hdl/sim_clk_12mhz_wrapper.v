//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.1 (win64) Build 3865809 Sun May  7 15:05:29 MDT 2023
//Date        : Sun Nov 12 18:46:22 2023
//Host        : LAPTOP-78477V77 running 64-bit major release  (build 9200)
//Command     : generate_target sim_clk_12mhz_wrapper.bd
//Design      : sim_clk_12mhz_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module sim_clk_12mhz_wrapper
   (clk_0,
    sync_rst_0);
  output clk_0;
  output sync_rst_0;

  wire clk_0;
  wire sync_rst_0;

  sim_clk_12mhz sim_clk_12mhz_i
       (.clk_0(clk_0),
        .sync_rst_0(sync_rst_0));
endmodule
