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

GEN_DIR = $(PRJ_DIR)/Verilator

# Build flags
VERILATOR_FLAGS = \
  --binary \
  --trace \
  --top-module $(TOP_MODULE) \
  --threads $(shell nproc) \
  --sv \
  -I$(SRC_DIR) \
  -I$(TB_DIR) \
  --Mdir $(GEN_DIR) \
  --Wno-WIDTHTRUNC \
  --Wno-WIDTHEXPAND \
  --Wno-LATCH

# Default target
default: run

# Verilate and build
build:
	@echo "-- Verilator simulation for SHA256 Core"
	@echo "-- VERILATE & BUILD --------"
	@mkdir -p $(GEN_DIR)
	$(VERILATOR) $(VERILATOR_FLAGS) \
	  $(DESIGN_FILES) \
	  $(TESTBENCH) \
	  -o $(BINARY_NAME)
	@echo "-- COMPILE -----------------"
	make -C $(GEN_DIR) -f V$(TOP_MODULE).mk

run: build
	@echo "-- RUN ---------------------"
	$(GEN_DIR)/./$(BINARY_NAME)
	@echo "-- DONE --------------------"

clean:
	-rm -rf $(GEN_DIR) *.log *.dmp *.vpd core $(TOP_MODULE)_sim *.vcd
