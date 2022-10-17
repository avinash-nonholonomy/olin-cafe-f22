# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -g2012 -Wall -y./hdl -y./tests -Y.sv -I./hdl
VVP=vvp
VVP_POST=-fst
VIVADO=vivado -mode batch -source
.PHONY: clean

# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd vivado*.log vivado*.jou vivado*.str *.fst

test_debouncer : tests/test_debouncer.sv hdl/debouncer.sv
	${IVERILOG} $^ -o test_debouncer.bin && ${VVP} test_debouncer.bin ${VVP_POST}

test_edge_detectors : tests/test_edge_detectors.sv hdl/edge_detector.sv hdl/edge_detector_moore.sv
	${IVERILOG} $^ -o test_edge_detectors.bin && ${VVP} test_edge_detectors.bin ${VVP_POST}

test_main : tests/test_main.sv hdl/debouncer.sv hdl/edge_detector.sv hdl/edge_detector_moore.sv hdl/main.sv
	${IVERILOG} $^ -o test_main.bin && ${VVP} test_main.bin ${VVP_POST}

main.bit: hdl/debouncer.sv hdl/edge_detector.sv hdl/edge_detector_moore.sv hdl/main.sv main.xdc
	@echo "########################################"
	@echo "#### Building FPGA bitstream        ####"
	@echo "########################################"
	${VIVADO} build.tcl

program_fpga_vivado: main.bit
	@echo "########################################"
	@echo "#### Programming FPGA (Vivado)      ####"
	@echo "########################################"
	${VIVADO} program.tcl

program_fpga_digilent: main.bit
	@echo "########################################"
	@echo "#### Programming FPGA (Digilent)    ####"
	@echo "########################################"
	djtgcfg enum
	djtgcfg prog -d CmodA7 -i 0 -f main.bit