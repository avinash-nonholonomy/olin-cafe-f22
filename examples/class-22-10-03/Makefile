# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -g2012 -Wall -y./hdl -y./tests -Y.sv -I./hdl
VVP=vvp
VVP_POST=-fst
# VIVADO=vivado -mode batch -source # Not used in this demo.

test_mux: test_mux.sv glitch_mux.sv
	${IVERILOG} $^ -o test_mux.bin && ${VVP} test_mux.bin ${VVP_POST}

waves_mux:
	gtkwave glitch.fst -a glitch.gtkw

# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd *.fst vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml
	rm -rf .Xil
	rm -rf __pycache__

# Call this to generate your submission zip file.
submission:
	zip submission.zip Makefile *.sv README.md docs/* *.tcl *.xdc *.pdf
