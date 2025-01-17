# Verilator binary
VERILATOR = /usr/bin/verilator

# Project structure
PRJ_DIR = $(shell pwd)
SRC_DIR = $(PRJ_DIR)/src
TB_DIR = $(PRJ_DIR)/testbench

# Design files
DESIGN_FILES = sha256_pkg.sv \
               sha256_core.sv

# Testbench
TESTBENCH = TB_sha256_core.sv

# Top module
TOP_MODULE = TB_sha256_core
BINARY_NAME = $(TOP_MODULE)_sim

# Build flags
VERILATOR_FLAGS = \
  --binary \
  --trace \
  --top-module $(TOP_MODULE) \
  --threads $(shell nproc) \
  --sv \
  -I$(SRC_DIR) \
  -I$(TB_DIR) \
  --Wno-WIDTHTRUNC \
  --Wno-WIDTHEXPAND \
  --Wno-LATCH

# Default target
default: run

# Verilate and build
build:
	@echo "-- Verilator simulation for SHA256 Core"
	@echo "-- VERILATE & BUILD --------"
	$(VERILATOR) $(VERILATOR_FLAGS) \
	  $(DESIGN_FILES) \
	  $(TESTBENCH) \
	  -o $(BINARY_NAME)
	@echo "-- COMPILE -----------------"
	make -C obj_dir -f V$(TOP_MODULE).mk

# Run simulation
run: build
	@echo "-- RUN ---------------------"
	./obj_dir/$(BINARY_NAME)
	@echo "-- DONE --------------------"

# Clean target
clean:
	-rm -rf obj_dir *.log *.dmp *.vpd core $(TOP_MODULE)_sim *.vcd
