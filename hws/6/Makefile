SHELL=/bin/bash
IVERILOG=iverilog -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array -g2012 -Y.sv -I ./hdl -I ./tests
VVP=vvp
VVP_POST=-fst

# Look up .PHONY rules for Makefiles
.PHONY: clean submission

# VVV Add any additional files you need for the alu to the targets. VVV
ALU_SRCS:=hdl/mux*.sv hdl/adder*.sv hdl/alu.sv hdl/shift*.sv
ALU_TEST_FILES:=tests/test_alu.sv tests/alu_behavioural.sv
test_alu: ${ALU_TEST_FILES} ${ALU_SRCS} tests/alu_testcases.memh
	${IVERILOG} ${ALU_TEST_FILES} ${ALU_SRCS} -o test_alu.bin && ${VVP} test_alu.bin ${VVP_POST}

waves_alu: test_alu
		gtkwave alu.fst &

RFILE_SRCS:=hdl/register.sv hdl/register_file.sv hdl/mux*.sv

test_register_file: ${RFILE_SRCS} tests/test_register_file.sv
	${IVERILOG} $^ -o test_register_file.bin && ${VVP} test_register_file.bin ${VVP_POST}

waves_register_file: test_register_file
	gtkwave register_file.fst

# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd *.fst vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml

# Call this to generate your submission zip file.
submission:
	zip submission.zip Makefile hdl/*.sv tests/*  *.pdf
