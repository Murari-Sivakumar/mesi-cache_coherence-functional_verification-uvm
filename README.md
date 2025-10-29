<p align="center">
  <img src="docs/mesi_uvm_env_diagram.png" width="750" alt="MESI Cache Coherence UVM Environment Diagram">
</p>

# MESI Cache Coherence Verification (UVM)

This project implements and verifies a **4-core MESI (Modified, Exclusive, Shared, Invalid)** cache coherence protocol using **SystemVerilog and UVM**.

The goal is to verify cache coherence protocol, eviction & writeback behavior, ensuring data consistency and cache replacement across cores.

---

## 🧠 Overview

This repository contains:
- A complete **UVM environment** (agents, drivers, monitors, scoreboard, sequences, and tests)
- Functional coverage and regression results for MESI protocol validation
- Reports summarizing Detected Bug, Coverage Closure, and Regression

---

## 📂 Repository Structure

| Folder | Description |
|:-------|:-------------|
| `uvm/` | UVM testbench components (driver, monitor, scoreboard, virtual sequencer, tests) |
| `test/` | Individual testcases triggering MESI state transitions and evictions |
| `sim/` | Simulation scripts and configuration files |
| `Report/` | Documentation — bug reports, coverage summary, regression logs |
| `rtl/` | *RTL files omitted due to course IP ownership. Interfaces preserved for reference.* |

---

## 🧩 Verification Features

- **Protocol Checking**: Ensures correctness of MESI state transitions across all cores  
- **Scoreboard Analysis**: Data consistency and writeback verification  
- **Functional Coverage**: >95% state transition and transaction coverage  
- **Regression Testing**: 50+ directed and random testcases executed to closure  
- **Assertion Checks**: Protocol violations caught at transaction level  

---

## 🧪 Example Testcases

| Testcase | Description |
|-----------|--------------|
| `icache_read_miss_test` | Verifies correct instruction fetch and allocation on miss |
| `icache_no_free_block_test` | Triggers eviction path when all cache ways are occupied |
| `l2_write_hit_test` | Checks correct update behavior for L2 write hits from evicted modified lines |
| `shared_eviction_test` | Tests eviction under shared ownership among multiple cores |

---

## 📊 Reports

All verification documents are available under [`Report/`](./Report):

- **Coverage Report (PDF)** 
- **Bug Report (PDF)**  
- **Regression Report (PDF)**  

---

## 🧰 Tools & Methodology

**Languages:** SystemVerilog, UVM, Object-Oriented Programming  
**Simulator:** Cadence Xcelium, IMC, vManager

---

**Murari Sivakumar**  
M.S. Computer Engineering — Texas A&M University  
Focus: *Design Verification and Computer Architecture*  
📧 [ms8716@tamu.edu](mailto:ms8716@tamu.edu)  
[🔗 LinkedIn](https://www.linkedin.com/in/murarisivakumar/)

