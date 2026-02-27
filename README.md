# AI-Verified Hardware Accelerator for Kyber (FIPS 203)

![Performance](Crypto_analyz\docs\performance.png)

## 1. Overview
This repository contains a high-performance hardware accelerator for the **Number Theoretic Transform (NTT)**, a critical computational bottleneck in the **Kyber (NIST FIPS 203)** Post-Quantum Cryptography (PQC) standard. The design is optimized for Intel (Altera) Cyclone 10 LP FPGAs and features a novel **AI-Driven Design Flow** for automated verification and anomaly detection.

### Key Features
* **12-bit Datapath**: Optimized to handle Kyber's prime field $Q=3329$ without overflow or precision loss.
* **Hardware Efficiency**: Utilizes embedded **M9K memory blocks** for dual-port coefficient and data storage.
* **TinyML Audit**: An integrated Python-based TinyML agent that monitors simulation logs for hardware glitches, bit-flips, or side-channel anomalies.
* **15.5x Speedup**: Achieves a latency of **5.5 µs** for a 256-point NTT, outperforming standard software implementations by over an order of magnitude.

---

## 2. Architecture
The accelerator implements a Radix-2 Butterfly architecture with a specialized control unit to manage memory addressing for 256-point polynomial operations.



### Specifications
| Parameter | Value |
| :--- | :--- |
| Algorithm | Kyber (FIPS 203) |
| Points | 256 |
| Modulus (Q) | 3329 |
| Datapath Width | 12-bit |
| Target Device | Intel Cyclone 10 LP (10CL025) |
| Latency | 5.5 µs @ Simulation |

---

## 3. TinyML Verification Layer
Unlike traditional testbenches, this project employs a **closed-loop AI verification system**:
1. **Data Generation**: Python scripts generate cryptographically secure twiddle factors.
2. **RTL Simulation**: Icarus Verilog executes the hardware logic.
3. **AI Audit**: A TinyML classifier analyzes the output distribution. If values deviate from the Kyber field or exhibit "stuck-at" faults, the agent triggers an anomaly alert.

---

## 4. Getting Started

### Prerequisites
* **Icarus Verilog** (v11 or later)
* **GTKWave** (for waveform analysis)
* **Python 3.8+** (`pip install numpy matplotlib`)
* **Intel Quartus Prime** (for `sim_lib` access)

### Configuration
Edit `sim.bat` to configure your local environment:
```batch
set QUARTUS_SIM_LIB=C:\path\to\quartus\eda\sim_lib
set GTK_EXE="C:\path\to\gtkwave.exe"