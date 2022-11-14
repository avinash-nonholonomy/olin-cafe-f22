SHELL=/bin/bash
IVERILOG=iverilog -g2012 -Wall -y./hdl -y./tests -Y.sv -I./hdl
VVP=vvp
VVP_POST=-fst
VIVADO=vivado -mode batch -source

RFILE_SRCS=hdl/register_file.sv hdl/register.sv hdl/decoder*.sv
# If you are using your own ALU files you should add them here:
ALU_SRCS=hdl/alu_behavioural.sv hdl/alu_types.sv
PERIPHERAL_SRCS=hdl/ili9341_display_controller.sv hdl/ili9341_defines.sv hdl/spi_controller.sv hdl/spi_types.sv hdl/pwm.sv hdl/pulse_generator.sv
MMU_SRCS=hdl/mmu.sv hdl/block_ram.sv hdl/block_rom.sv hdl/memmap.sv hdl/distributed_ram.sv hdl/dual_port_distributed_ram.sv ${PERIPHERAL_SRCS}
# RV32I_SRCS=hdl/rv32i_defines.sv hdl/rv32i_system.sv hdl/rv32i_multicycle_core.sv ${RFILE_SRCS} ${ALU_SRCS} ${MMU_SRCS}
RV32I_SRCS=${RFILE_SRCS} ${ALU_SRCS} ${MMU_SRCS} hdl/rv32i_defines.sv hdl/rv32i_multicycle_core.sv hdl/rv32i_system.sv

# Look up .PHONY rules for Makefiles
.PHONY: clean submission remove_solutions waves_rv32i_system analyze_rv32i_system

%.memh : %.s assembler.py rv32i.py
	./assembler.py $< -o $@

test_register_file: tests/test_register_file.sv ${RFILE_SRCS}
	${IVERILOG} $^ -o test_register_file.bin && ${VVP} test_register_file.bin ${VVP_POST}

# Modify the -DINITIAL_INST_MEM string to change the initial memory.
test_rv32i_itypes: tests/test_rv32i_system.sv asm/itypes.memh ${RV32I_SRCS}
	${IVERILOG} -DINITIAL_INST_MEM=\"asm/itypes.memh\" tests/test_rv32i_system.sv ${RV32I_SRCS} -s test_rv32i_system -o test_rv32i_system.bin && ${VVP} test_rv32i_system.bin ${VVP_POST}

test_rv32i_ri_types: tests/test_rv32i_system.sv asm/ritypes.memh ${RV32I_SRCS}
	${IVERILOG} -DINITIAL_INST_MEM=\"asm/ritypes.memh\" tests/test_rv32i_system.sv ${RV32I_SRCS} -s test_rv32i_system -o test_rv32i_system.bin && ${VVP} test_rv32i_system.bin ${VVP_POST}

test_rv32i_ls_types: tests/test_rv32i_system.sv asm/lstypes.memh ${RV32I_SRCS}
	${IVERILOG} -DINITIAL_INST_MEM=\"asm/lstypes.memh\" tests/test_rv32i_system.sv ${RV32I_SRCS} -s test_rv32i_system -o test_rv32i_system.bin && ${VVP} test_rv32i_system.bin ${VVP_POST}

test_rv32i_peripherals: tests/test_rv32i_system.sv asm/peripherals.memh ${RV32I_SRCS}
	${IVERILOG} -DINITIAL_INST_MEM=\"asm/peripherals.memh\" tests/test_rv32i_system.sv ${RV32I_SRCS} -s test_rv32i_system -o test_rv32i_system.bin && ${VVP} test_rv32i_system.bin ${VVP_POST}

waves_rv32i_system:
	gtkwave rv32i_system.fst -a tests/rv32i_system.gtkw

rv32i_system.bit: ${RV32I_SRCS} build.tcl asm/peripherals.memh
	@echo "########################################"
	@echo "#### Building FPGA bitstream        ####"
	@echo "########################################"
	${VIVADO} build.tcl

analyze_rv32i_system: ${RV32I_SRCS} analysis.tcl asm/peripherals.memh
	${VIVADO} analysis.tcl

program_fpga_vivado: rv32i_system.bit build.tcl program.tcl
	@echo "########################################"
	@echo "#### Programming FPGA (Vivado)      ####"
	@echo "########################################"
	${VIVADO} program.tcl

program_fpga_digilent: rv32i_system.bit build.tcl
	@echo "########################################"
	@echo "#### Programming FPGA (Digilent)    ####"
	@echo "########################################"
	djtgcfg enum
	djtgcfg prog -d CmodA7 -i 0 -f rv32i_system.bit

lint_all: hdl/*.sv
	verilator --lint-only -I./hdl -I./tests $^

# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd *.fst vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml
	rm -rf .Xil
	rm -rf __pycache__
	rm asm/*.memh

# Call this to generate your submission zip file.
submission:
	zip submission.zip Makefile *.sv README.md docs/* *.tcl *.xdc tests/*.sv *.pdf
