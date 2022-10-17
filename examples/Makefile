# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -Wall -g2012 -y ./ -I ./
VVP=vvp
VVP_POST=-fst

# Look up .PHONY rules for Makefiles
.PHONY: clean

# Call this to clean up all your generated files
clean:
	rm -f *.bin *.fst vivado*.log vivado*.jou vivado*.str

test_adder_1 : test_adder_1.sv adder_1.sv
	${IVERILOG} $^ -o test_adder_1.bin && ${VVP} test_adder_1.bin ${VVP_POST}

test_adder_n : test_adder_n.sv adder_1.sv adder_n.sv
	${IVERILOG} $^ -o test_adder_n.bin && ${VVP} test_adder_n.bin ${VVP_POST}

test_shift_register : test_shift_register.sv shift_register.sv
	${IVERILOG} $^ -o test_shift_register.bin && ${VVP} test_shift_register.bin ${VVP_POST}

waves_shift_register: test_shift_register
	gtkwave shift_register.fst -a wave_cfgs/shift_register.gtkw

test_multiplier : multiplier.sv test_multiplier.sv
	${IVERILOG} $^ -o test_multiplier.bin && ${VVP} test_multiplier.bin ${VVP_POST}
	${VVP} test_multiplier.bin

waves_multiplier : test_multiplier
	gtkwave muliplier.fst -a wave_cfgs/multiplier.gtkw
