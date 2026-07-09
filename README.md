# RISC-V Processor with Memory Subsystem and Systolic Array Integration

## Overview

This project implements a 32-bit pipelined RISC-V processor in Verilog with a complete memory subsystem consisting of a cache controller, AXI-style interconnect, interconnect controller, and memory controller. The project is being extended to integrate a systolic array accelerator for matrix multiplication.

---

## Features

- RV32I 5-stage pipelined processor
- Hazard Detection Unit
- Forwarding Unit
- Branch Predictor
- Data Cache (2-Way Set Associative)
- LRU Replacement Policy
- Cache Controller
- Memory Controller
- AXI-style Interconnect
- Interconnect Controller
- Complete Memory Subsystem
- Modular Verilog Design
- Testbenches for individual modules and integrated system
- GTKWave waveform support

---

## Processor Pipeline

```
Instruction Fetch (IF)
        │
        ▼
Instruction Decode (ID)
        │
        ▼
Execute (EX)
        │
        ▼
Memory Access (MEM)
        │
        ▼
Write Back (WB)
```

---

## Memory Subsystem

```
Processor Pipeline
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

The memory subsystem supports:

- Cache Hits
- Cache Miss Handling
- AXI-style Read Transactions
- AXI-style Write Transactions
- Stall Generation
- Memory Read/Write Handshaking

---

## Directory Structure

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
Systolic/          (Work in Progress)
Top/
testbench/
```

---

## Current Status

### Completed

- RV32I Processor
- Pipeline Registers
- Hazard Detection
- Forwarding
- Branch Prediction
- Cache Controller
- Memory Controller
- AXI Interconnect
- Interconnect Controller
- Integrated Memory Subsystem
- Top-Level Integration
- Individual Module Testbenches

### Work in Progress

- Systolic Array Accelerator
- Memory-Mapped Accelerator Interface
- Matrix Multiplication Support

---

## Simulation

Compile using Icarus Verilog:

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
Memory/data_memory.v
```

Run:

```bash
vvp processor_sim
```

View Waveforms:

```bash
gtkwave processor_system.vcd
```

---

## Testbenches

Available testbenches include:

- Cache Controller
- Interconnect Controller
- Interconnect + Memory Controller
- Memory Subsystem
- Processor Pipeline
- Complete Top-Level System

---

## Future Improvements

- Systolic Array Accelerator
- Matrix Multiplication Instructions
- Memory-Mapped Accelerator Interface
- Performance Counters
- Multi-Level Cache
- Prefetching Support

---

## Tools Used

- Verilog HDL
- Icarus Verilog
- GTKWave
- Visual Studio Code

---

## Author

**Kapish Eluri**

IMTech ECE
