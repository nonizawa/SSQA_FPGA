# SSQA FPGA Design

This repository contains the SystemVerilog sources used in our IEEE Access resubmission, “Energy-Efficient p-Bit-Based Fully-Connected Quantum-Inspired Simulated Annealer with Dual BRAM Architecture.” The code implements the dual-BRAM SSQA datapath evaluated on the Xilinx ZC706 platform.

## Directory Layout

| File | Description |
| --- | --- |
| `array_ssqa.sv` | Top-level spin-array module instantiating the replica-parallel/spin-serial SSQA datapath. |
| `submain.sv` | Core SSQA controller tying the scheduler, BRAM interface, and spin gates together. |
| `test_submain.sv` | Testbench wrapper for `submain.sv`. |
| `ssqa.sv` | Spin-gate implementation of the stochastic simulated quantum annealer update equations. |
| `scheduler_state.sv`, `scheduler_count.sv` | Scheduler FSM and counter logic (temperature/Q schedule, enable pulses, etc.). |
| `bram.sv` | Dual-BRAM delay-line module for storing spin states and internal signals. |
| `ctr.sv` | Auxiliary counter module for spin/replica iteration. |
| `xorshift.sv` | 64-bit XOR-shift random-number generator (R-parallel outputs). |
| `G11_BRAM.coe` | Example BRAM initialization file (G11 instance) for Vivado/Block RAM preload.

## Requirements

- Vivado 2023.2 (or compatible) for synthesis/implementation on Xilinx ZC706.
- Questa/ModelSim (or similar) for functional simulation.
- Python 3.6.8 with PyCUDA 2022.1 (optional, for reproducing software baselines referenced in the paper).

## How to Build

1. Create a new Vivado project targeting XC7Z045 (ZC706 board).
2. Add all `.sv` sources in this repository to the project.
3. Use `G11_BRAM.coe` to initialize the BRAM contents for the delay lines/weights (Vivado: *Tools > IP Catalog > Block Memory Generator* or via TCL script).
4. Synthesize, implement, and generate the bitstream. Our reference design meets timing at 166 MHz.
5. For simulation, compile `test_submain.sv` along with the DUT files in your simulator of choice. Provide the same BRAM initialization and scheduler configuration as in the hardware run.

## Configuration Notes

- Scheduler parameters (annealing steps, Q/temperature schedule, seed values) are set via AXI registers inside `submain.sv`. See comments in that file for register maps.
- Random seeds can be overridden by editing `xorshift.sv` or by adding seed ports for your testbench.
- To reproduce the paper’s G11/G12/G13 runs, preload the weight matrix and spin state BRAMs with the `G11_BRAM.coe` file and configure `array_ssqa` for `N=800`, `R=20`.

## Citation

If you use this code, please cite:

