# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -g2012 -Wall -y ./ -I ./
VVP=vvp
VVP_POST=-fst
# VIVADO=vivado -mode batch -source
ADDER_SRCS = adder*.sv
MUX_SRCS = mux*.sv
# Look up .PHONY rules for Makefiles
.PHONY: clean submission

test_practice : practice.sv test_practice.sv
	${IVERILOG} $^ -o test_practice.bin && ${VVP} test_practice.bin ${VVP_POST}
waves_practice : test_practice
	gtkwave practice.fst -a practice.gtkw
test_adder_1: test_adder_1.sv ${ADDER_SRCS}
	${IVERILOG} $^ -o test_adder_1.bin && ${VVP} test_adder_1.bin ${VVP_POST}
test_adder_32: test_adder_32.sv ${ADDER_SRCS}
	${IVERILOG} $^ -o test_adder_32.bin && ${VVP} test_adder_32.bin ${VVP_POST}
test_mux: test_mux.sv ${MUX_SRCS}
	${IVERILOG} $^ -o test_mux.bin && ${VVP} test_mux.bin ${VVP_POST}


# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd *.fst vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml
	rm -rf .Xil

# Call this to generate your submission zip file.
submission:
	zip submission.zip Makefile *.sv README.md *.pdf
