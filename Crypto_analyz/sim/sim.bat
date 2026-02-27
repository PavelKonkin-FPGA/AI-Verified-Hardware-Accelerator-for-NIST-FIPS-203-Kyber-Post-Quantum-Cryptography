@echo off
setlocal

:: ========================================================================
:: CONFIGURATION SECTION
:: Please update the paths below to match your local environment:
:: ========================================================================

:: 1. Path to your Quartus Prime installation (EDA simulation libraries)
set QUARTUS_SIM_LIB=C:\altera_lite\25.1std\quartus\eda\sim_lib

:: 2. Path to your GTKWave executable
set GTK_EXE="C:\iverilog\gtkwave\bin\gtkwave.exe"

:: 3. Working Directory (the folder where your .py and .v files are located)
set WORK_DIR=%~dp0

:: ========================================================================

echo ===================================================
echo    V-Guard PQC: AI-Driven Design Flow (Kyber)
echo ===================================================

:: STEP 0: Data Generation
echo [STEP 0] Python: Generating Twiddle Factors...
python "%WORK_DIR%hex_gen.py"
if %errorlevel% neq 0 (
    echo [ERROR] Python script failed. Please check your Python installation.
    pause
    exit /b
)

:: STEP 1: Compilation
echo [STEP 1] Icarus Verilog: Compiling RTL and Altera Libs...
iverilog -g2012 -o dsgn_sim.vvp ^
    -I "%QUARTUS_SIM_LIB%" ^
    "%QUARTUS_SIM_LIB%\altera_primitives.v" ^
    "%QUARTUS_SIM_LIB%\220model.v" ^
    "%QUARTUS_SIM_LIB%\altera_mf.v" ^
    tb_crypto_sign.v ^
    crypto_sign.v ^
    ntt_butterfly.v ^
    ntt_ctrl.v ^
    twiddle_rom.v ^
    mem_array_256.v ^
    twiddle_rom_ip.v 2> error.log

if %errorlevel% neq 0 (
    echo [ERROR] Compilation failed. See error.log for details.
    notepad error.log
    exit /b
)

:: STEP 2: Simulation & Logging
echo [STEP 2] VVP: Running simulation and capturing logs...
vvp dsgn_sim.vvp > simulation_output.log
type simulation_output.log

:: STEP 3: TinyML Audit
echo [STEP 3] TinyML: Analyzing Hardware Health...
python "%WORK_DIR%AI.py"

:: STEP 4: Performance Visualization
echo [STEP 4] Python: Generating Performance Benchmark...
python "%WORK_DIR%benchmark.py"

:: STEP 5: Waveform Visualization
if exist simulation.vcd (
    echo [STEP 5] GTKWave: Opening Waveforms...
    %GTK_EXE% simulation.vcd
) else (
    echo [ERROR] simulation.vcd not found!
)

echo Simulation Flow Completed.
pause