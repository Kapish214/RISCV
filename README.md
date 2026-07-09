# RISC-V Processor with Memory Subsystem and Systolic Array Accelerator

A Verilog implementation of a **32-bit pipelined RISC-V (RV32I) processor** integrated with a complete memory subsystem and a **4×4 systolic array hardware accelerator** for efficient matrix multiplication.

---

# Project Overview

This project combines a custom pipelined RISC-V processor with a cache-based memory hierarchy and a systolic array accelerator. The processor communicates with the accelerator through a memory-mapped interface, enabling hardware acceleration of matrix multiplication workloads.

The project demonstrates the complete hardware flow from instruction execution to cache access, AXI-style memory transactions, and systolic array computation.

---

# Architecture

```
                     +-----------------------+
                     |   RISC-V Processor    |
                     |   (5 Stage Pipeline)  |
                     +----------+------------+
                                |
                                |
                        MemRead / MemWrite
                                |
                                v
                   +--------------------------+
                   |    Memory Subsystem      |
                   +------------+-------------+
                                |
            +-------------------+------------------+
            |                                      |
            |                                      |
            v                                      v
     +---------------+                  +----------------------+
     |  Data Memory  |                  | 4×4 Systolic Array   |
     |               |                  | Hardware Accelerator |
     +---------------+                  +----------------------+
```

---

# Features

## Processor

- RV32I ISA
- 5-stage pipeline
- Branch Predictor
- Hazard Detection Unit
- Forwarding Unit
- Pipeline Registers
- ALU
- Register File

---

## Memory Subsystem

- 2-Way Set Associative Cache
- LRU Replacement Policy
- Cache Controller
- Memory Controller
- AXI-style Interconnect
- Interconnect Controller
- Stall Handling
- Cache Hit/Miss Logic

---

## Systolic Array Accelerator

- 4×4 Processing Element (PE) Array
- Matrix Multiplication Accelerator
- Parallel Multiply-Accumulate (MAC)
- Memory-Mapped Interface
- Controller FSM
- Accelerator Status Signals (Busy / Done)

---

# Directory Structure

```
Branch_predictor/
Cache/
Controllers/
Decode/
Execute/
Fetch/
Interconnects/
Memory/
Pipeline/
Systolic/
Top/
testbench/
```

---

# Processor Pipeline

```
IF → ID → EX → MEM → WB
```

---

# Memory Flow

```
Processor
    │
    ▼
Cache Controller
    │
    ▼
Interconnect Controller
    │
    ▼
AXI Interconnect
    │
    ▼
Memory Controller
    │
    ▼
Data Memory
```

---

# Systolic Array Flow

```
Processor

↓

Store Matrix A

↓

Store Matrix B

↓

Write START Register

↓

Systolic Controller

↓

4×4 Systolic Array

↓

Matrix Multiplication

↓

DONE Signal

↓

Processor Reads Result Matrix
```

---

# Simulation

### Compile

```bash
iverilog -g2012 -Wall -o processor_sim \
testbench/top_tb.v \
Top/top.v \
Top/processor_pipeline.v \
Top/memory_subsystem.v \
Fetch/PC.v \
Fetch/instruction_memory.v \
Branch_predictor/branch_predictor.v \
Decode/decode.v \
Decode/control_unit.v \
Decode/register_file.v \
Decode/immediate_generator.v \
Decode/alu_control.v \
Execute/alu.v \
Pipeline/if_id.v \
Pipeline/id_ex.v \
Pipeline/ex_mem.v \
Pipeline/mem_wb.v \
Pipeline/forwarding_unit.v \
Pipeline/hazard_detection_unit.v \
Controllers/interconnect_controller.v \
Controllers/memory_controller.v \
Interconnects/axi_interconnects.v \
Cache/cache_controller.v \
Cache/data_cache.v \
Cache/lru_memory.v \
Memory/data_memory.v \
Systolic/*.v
```

### Run

```bash
vvp processor_sim
```

### View Waveforms

```bash
gtkwave processor_system.vcd
```

---

# Testbenches

- Processor Pipeline
- Cache Controller
- Interconnect Controller
- Memory Controller
- Memory Subsystem
- Systolic Array
- Top-Level Integration

---

# Results

- Functional 5-stage RV32I Processor
- Fully Integrated Memory Subsystem
- AXI-style Memory Transactions
- Cache Hit/Miss Handling
- Hardware Matrix Multiplication using 4×4 Systolic Array
- Successful End-to-End Simulation

---

# Future Improvements

- Larger Systolic Arrays (8×8 / 16×16)
- SIMD Extensions
- DMA Support
- L2 Cache
- Performance Counters
- Hardware Prefetcher

---

# Tools

- Verilog HDL
- Icarus Verilog
- GTKWave
- Visual Studio Code

---

# Author

**Kapish Eluri**

Integrated M.Tech, Electronics and Communication Engineering
