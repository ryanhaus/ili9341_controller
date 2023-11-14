//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.1 (win64) Build 3865809 Sun May  7 15:05:29 MDT 2023
//Date        : Sun Nov 12 18:46:22 2023
//Host        : LAPTOP-78477V77 running 64-bit major release  (build 9200)
//Command     : generate_target sim_clk_12mhz.bd
//Design      : sim_clk_12mhz
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "sim_clk_12mhz,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=sim_clk_12mhz,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "sim_clk_12mhz.hwdef" *) 
module sim_clk_12mhz
   (clk_0,
    sync_rst_0);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK_0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK_0, CLK_DOMAIN sim_clk_12mhz_sim_clk_gen_0_0_clk, FREQ_HZ 12000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) output clk_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.SYNC_RST_0 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.SYNC_RST_0, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) output sync_rst_0;

  wire sim_clk_gen_0_clk;
  wire sim_clk_gen_0_sync_rst;

  assign clk_0 = sim_clk_gen_0_clk;
  assign sync_rst_0 = sim_clk_gen_0_sync_rst;
  sim_clk_12mhz_sim_clk_gen_0_0 sim_clk_gen_0
       (.clk(sim_clk_gen_0_clk),
        .sync_rst(sim_clk_gen_0_sync_rst));
endmodule
