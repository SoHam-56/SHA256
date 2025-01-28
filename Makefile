# Project Structure
PRJ_DIR = $(shell pwd)
SRC_DIR = $(PRJ_DIR)/src
TB_DIR = $(PRJ_DIR)/testbenches

# Toolchain
VERILATOR = verilator
IVERILOG = iverilog
VCS = vcs
VVP = vvp

# Design files
DESIGN_FILES = sha256_pkg.sv \
               sha256_core.sv

# Testbench
TESTBENCH = TB_sha256_core.sv

# Top module
TOP_MODULE = TB_sha256_core
BINARY_NAME = $(TOP_MODULE)_sim

# Directories
VERILATOR_DIR = $(PRJ_DIR)/Verilator
IVERILOG_DIR = $(PRJ_DIR)/Icarus
VCS_DIR = $(PRJ_DIR)/VCS

# Verilator Flags
VERILATOR_FLAGS = \
	--binary \
	--trace \
	--top-module $(TOP_MODULE) \
	--threads $(shell nproc) \
	--sv \
	-I$(SRC_DIR) \
	-I$(TB_DIR) \
	--Mdir $(VERILATOR_DIR) \
	--Wno-WIDTHTRUNC \
	--Wno-WIDTHEXPAND

# Icarus Verilog Flags
IVERILOG_FLAGS = \
	-g2012 \
	-Wall \
	-Wno-timescale \
	-I$(SRC_DIR) \
	-I$(TB_DIR)

# VCS Flags
VCS_FLAGS = \
	-full64 \
	-sverilog \
	-debug_all \
	-timescale=1ns/1ps \
	-Mdir=$(VCS_DIR) \
	+v2k \
	+incdir+$(SRC_DIR) \
	+incdir+$(TB_DIR)

# Default target
default: help

# Help message
help:
	@echo "Simulation Targets:"
	@echo "  make verilator    - Simulate using Verilator"
	@echo "  make iverilog     - Simulate using Icarus Verilog"
	@echo "  make vcs          - Simulate using Synopsys VCS"
	@echo "  make view-gtkwave - View waveform using GTKWave"
	@echo "  make view-surfer  - View waveform using Surfer"
	@echo "  make clean        - Remove all simulation artifacts"

# Verilator Simulation
verilator:
	@echo "-- Verilator simulation for SHA256 Core"
	@mkdir -p $(VERILATOR_DIR)
	$(VERILATOR) $(VERILATOR_FLAGS) \
		$(addprefix $(SRC_DIR)/,$(DESIGN_FILES)) \
		$(TB_DIR)/$(TESTBENCH) \
		-o $(TOP_MODULE)_sim
	@echo "-- Compiling Verilator simulation"
	make -C $(VERILATOR_DIR) -f V$(TOP_MODULE).mk
	@echo "-- Running Verilator simulation"
	$(VERILATOR_DIR)/./$(TOP_MODULE)_sim

# Icarus Verilog Simulation
iverilog:
	@echo "-- Icarus Verilog simulation for SHA256 Core"
	@mkdir -p $(IVERILOG_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) \
		-o $(IVERILOG_DIR)/$(TOP_MODULE)_sim \
		$(addprefix $(SRC_DIR)/,$(DESIGN_FILES)) \
		$(TB_DIR)/$(TESTBENCH)
	@echo "-- Running Icarus Verilog simulation"
	cd $(IVERILOG_DIR) && $(VVP) ./$(TOP_MODULE)_sim -vcd=$(TOP_MODULE).vcd
	@echo "-- Waveform generated at $(IVERILOG_DIR)/$(TOP_MODULE).vcd"

# VCS Simulation
vcs:
	@echo "-- VCS simulation for SHA256 Core"
	@mkdir -p $(VCS_DIR)
	$(VCS) $(VCS_FLAGS) \
		-o $(VCS_DIR)/$(TOP_MODULE)_sim \
		$(addprefix $(SRC_DIR)/,$(DESIGN_FILES)) \
		$(TB_DIR)/$(TESTBENCH)
	@echo "-- Running VCS simulation"
	cd $(VCS_DIR) && ./$(TOP_MODULE)_sim -visualize
	@echo "-- Simulation complete"

# Clean all simulation artifacts
clean:
	@echo "-- Cleaning simulation artifacts"
	-rm -rf $(VERILATOR_DIR) $(IVERILOG_DIR) $(VCS_DIR)
	-rm -f *.vpd *.vcd

# Phony targets
.PHONY: default help verilator iverilog vcs clean
