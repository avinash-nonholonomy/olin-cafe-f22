# Xilinx Vivado Gui-less build script
# Based on this tutorial https://www.xilinx.com/video/hardware/using-the-non-project-batch-flow.html
# read_edif and read_ip commands are useful for using other IP.
# Note - you can add `start_gui` between any of these commands to interject into the Vivado environment. This lets you use any tools (and you can open any checkpoint too!).

read_verilog [ glob ./hdl/*.sv ]
read_xdc ./main.xdc

# Sythesis & Optimization
# Parts are either xc7a35tcpg236-1 or xc7a15tcpg236-1
# Select the right one based on the sticker on your board!
# synth_design -top main -part xc7a35tcpg236-1
synth_design -top main -part xc7a15tcpg236-1
write_checkpoint -force synthesis.checkpoint
opt_design
# power_opt_design # optional till later.
place_design
# phys_opt_design # optional till later.
write_checkpoint -force place.checkpoint
route_design
write_checkpoint -force route.checkpoint

# report generation
report_timing_summary -file timing_summary.log
report_timing -sort_by group -max_paths 100 -path_type summary -file timing.log
report_utilization -file usage.log
report_drc -file drc.log

# write bitstream
write_bitstream -force ./main.bit