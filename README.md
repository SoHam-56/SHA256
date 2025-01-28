# SHA256 Hardware Implementation

A SystemVerilog implementation of the SHA256 cryptographic hash function optimized for hardware synthesis, featuring parallel computation capabilities. This implementation targets the Nexys A7-100T FPGA platform.

## Overview

This project implements the SHA256 hash algorithm in hardware using SystemVerilog. The core processes single-block messages (512 bits) using a parallel computation approach and outputs a 256-bit hash digest. The design is optimized for FPGA implementation with configurable parallelization factors.

## Features

- Fully verified SHA256 hash function implementation
- Single-block message processing (512 bits)
- Parameterized parallel round computation
- Four-state FSM control logic
- Valid output signal indicating hash completion
- Comprehensive testbench with multiple test vectors

## Architecture

### Finite State Machine (FSM)
The core operation is controlled by a 4-state FSM:

1. **IDLE State**
   - Default state waiting for start signal
   - Transitions to PREPARE when start_i is asserted
   - All registers maintain their reset values

2. **PREPARE State**
   - Initializes working variables (a-h) with initial hash values
   - Single cycle state
   - Automatically transitions to COMPUTE state

3. **COMPUTE State**
   - Performs the main SHA256 compression function
   - Processes N rounds in parallel per cycle
   - Maintains round counter for tracking progress
   - Transitions to FINALIZE after completing all 64 rounds

4. **FINALIZE State**
   - Computes final hash values
   - Asserts valid_o signal
   - Returns to IDLE state for next operation

### Package Components (`sha256_pkg`)
- Word size: 32 bits
- Block size: 256 bits
- Number of rounds: 64
- Parallel computation: N rounds
- Pre-computed K constants (64 x 32-bit values)
- Initial hash values (H0 to H7)

### Core Functions
```systemverilog
// Message schedule functions
sigma0(x) = ROTR(7,x) ^ ROTR(18,x) ^ SHR(3,x)
sigma1(x) = ROTR(17,x) ^ ROTR(19,x) ^ SHR(10,x)

// Compression functions
sum0(x) = ROTR(2,x) ^ ROTR(13,x) ^ ROTR(22,x)
sum1(x) = ROTR(6,x) ^ ROTR(11,x) ^ ROTR(25,x)
Ch(x,y,z) = (x & y) ^ (~x & z)
Maj(x,y,z) = (x & y) ^ (x & z) ^ (y & z)
```

## Interface

```systemverilog
module sha256_core (
    input  logic                 clk_i,    // Clock input
    input  logic                 rstn_i,   // Active-low reset
    input  logic                 start_i,  // Start signal
    input  logic [511:0]         msg_i,    // Message input (512-bit block)
    output logic [255:0]         md_o,     // Message digest output
    output logic                 valid_o   // Output valid signal
);
```

## Synthesis Results

The design was synthesized for the Nexys A7-100T FPGA with different parallelization factors. Below are the results showing the trade-offs between performance and resource utilization:

| Parallel Factor | Clock Cycles | LUT Usage | Flip-Flops | Max Frequency (MHz) |
|----------------|--------------|-----------|------------|-------------------|
| 1              | 65          | 5,395     | 535        | 94               |
| 2              | 33          | 5,649     | 534        | 50               |
| 6              | 12          | 8,374     | 553        | 25               |
| 12             | 7           | 10,096    | 546        | 15               |

### Trade-offs
- **Sequential (1 round)**:
  - Highest frequency (94 MHz)
  - Minimal resource usage (5,395 LUTs)
  - Requires 65 clock cycles per hash
- **Highly Parallel (12 rounds)**:
  - Fastest computation (7 cycles)
  - Highest resource usage (10,096 LUTs)
  - Lowest maximum frequency (15 MHz)

## Usage

### Message Format
Messages must be properly padded according to the SHA256 specification:
- Append '1' after the message
- Add zeros until the message length is 448 bits (mod 512)
- Append the 64-bit message length

### Operation Sequence
1. Assert `rstn_i` to initialize the core
2. Load the padded message into `msg_i`
3. Assert `start_i` for one clock cycle
4. Wait for `valid_o` to be asserted
5. Read the hash result from `md_o`

## Test Cases

The implementation has been verified with the following test vectors:

1. Empty string
2. "abc"
3. "hello I am Soham"
4. "hello I am Soham, this verifies my assignment"
5. "Hi hello I am Soham, this verifies my assignment. bye"

## To-Do

1. Add supports for multi-block messages (Messages requiring multiple blocks cannot be processed)
2. Add pipeline stages

## Getting Started

### Prerequisites
- Verilator (tested with version 5.032) or Vivado (tested with version 2024.1)
- SystemVerilog compatible synthesis tool
- GNU Make

### Files Structure
```
├── src/
│   ├── sha256_pkg.sv
│   ├── sha256_core.sv
├── testbench/
│   └── TB_sha256_core.sv
├── Makefile
└── README.md
```

### Simulation
The project includes a Makefile supporting multiple simulation tools:

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. Run simulation with your preferred tool:
   ```bash
   make verilator    # For Verilator simulation
   make iverilog     # For Icarus Verilog simulation
   make vcs          # For Synopsys VCS simulation
   ```

3. Clean build artifacts:
   ```bash
   make clean
   ```

## Author

Soham Pramanik<br>
[LinkedIn](https://www.linkedin.com/in/soham-pramanik-224004271/)
