# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -Wall -g2012 -I ./ -y ./
VVP=vvp
VVP_POST=-fst

# Look up .PHONY rules for Makefiles
.PHONY: clean

# Call this to clean up all your generated files
clean:
	rm -f *.bin *.fst vivado*.log vivado*.jou vivado*.str

test_multiplier : multiplier.sv test_multiplier.sv
	${IVERILOG} $^ -o test_multiplier.bin && ${VVP} test_multiplier.bin ${VVP_POST}

waves_multiplier : test_multiplier
	gtkwave multiplier.fst -a wave_cfgs/multiplier.gtkw
