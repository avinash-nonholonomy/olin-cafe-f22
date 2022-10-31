# -Wall turns on all warnings
# -g2012 selects the 2012 version of iVerilog
IVERILOG=iverilog -DSIMULATION -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array -g2012 -Y.sv -I ./hdl -I ./tests 
VVP=vvp
VVP_POST=-fst
VIVADO=vivado -mode batch -source

ILI9341_SRCS=hdl/spi_controller.sv hdl/ili9341_display_controller.sv hdl/spi_types.sv hdl/ili9341_defines.sv hdl/block_rom.sv
FT6206_SRCS=hdl/i2c_controller.sv hdl/ft6206_controller.sv hdl/i2c_types.sv hdl/ft6206_defines.sv 
# Add any new source files needed for the final bitstream here
MAIN_SRCS=hdl/main.sv hdl/pulse_generator.sv hdl/pwm.sv hdl/triangle_generator.sv hdl/block_ram.sv ${ILI9341_SRCS} ${FT6206_SRCS}
MAIN_MEMORIES=memories/ili9341_init.memh

# Look up .PHONY rules for Makefiles
.PHONY: clean submission remove_solutions

test_pulse_generator: tests/test_pulse_generator.sv hdl/pulse_generator.sv
	${IVERILOG} $^ -o test_pulse_generator.bin && ${VVP} test_pulse_generator.bin ${VVP_POST}

test_pwm: tests/test_pwm.sv hdl/pulse_generator.sv hdl/pwm.sv
	@echo "This might take a while, we're testing a lot of clock cycles!"
	${IVERILOG} $^ -o test_pwm.bin && ${VVP} test_pwm.bin ${VVP_POST}

test_triangle_generator: tests/test_triangle_generator.sv hdl/triangle_generator.sv
	${IVERILOG} $^ -o test_triangle_generator.bin && ${VVP} test_triangle_generator.bin ${VVP_POST}
waves_triangle_generator: test_triangle_generator
	gtkwave triangle_generator.fst -a tests/triangle_generator.gtkw

test_spi_controller : tests/test_spi_controller.sv hdl/spi_controller.sv hdl/spi_types.sv
	${IVERILOG} $^ -o test_spi_controller.bin && ${VVP} test_spi_controller.bin ${VVP_POST}
waves_spi_controller: test_spi_controller
	gtkwave spi_controller.fst -a tests/spi_controller.gtkw

test_i2c_controller : tests/test_i2c_controller.sv hdl/i2c_controller.sv hdl/i2c_types.sv
	${IVERILOG} $^ -o test_i2c_controller.bin && ${VVP} test_i2c_controller.bin ${VVP_POST}
waves_i2c_controller: test_i2c_controller
	gtkwave i2c_controller.fst -a tests/i2c_controller.gtkw

memories/ili9341_init.memh: generate_memories.py
	./generate_memories.py --memory ili9341 --out memories/ili9341_init.memh

memories/fibonacci.memh: generate_memories.py
	./generate_memories.py --memory fibonacci --out memories/fibonacci.memh

