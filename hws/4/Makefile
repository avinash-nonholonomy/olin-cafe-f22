# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -g2012 -Wall -y ./ -I ./
VVP=vvp
VVP_POST=-fst
# VIVADO=vivado -mode batch -source

# Look up .PHONY rules for Makefiles
.PHONY: clean submission

test_practice : practice.sv test_practice.sv
	${IVERILOG} $^ -o test_practice.bin && ${VVP} test_practice.bin ${VVP_POST}
waves_practice : test_practice
	gtkwave practice.fst -a practice.gtkw

# add targets for your tests of your adders and muxes here!



# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd *.fst vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml
	rm -rf .Xil

# Call this to generate your submission zip file.
submission:
	zip submission.zip Makefile *.sv README.md *.pdf
