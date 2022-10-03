`timescale 1ns/1ps
`default_nettype none

/*
One pro of sum of products is (assuming you've already inverted all the inputs)
you can get pretty glitch free logic. Let's see what happens with an optimized
mux.

This file uses the #(delay) method to show what glitches might be like.
You DO NOT need to ever do this!!! I'm using some older verilog to make 
the sim look right.
*/

module glitch_mux(in0, in1, select, out);

input wire in0, in1, select;
output wire out;

parameter NOT_DELAY=10;
parameter NAND_DELAY=20;
parameter AND_DELAY=NOT_DELAY+NAND_DELAY;
parameter NOR_DELAY=NAND_DELAY;
parameter OR_DELAY=AND_DELAY;

// Invert select
wire select_bar;
assign #(NOT_DELAY) select_bar = ~select;

// ANDs
wire and0, and1;
assign #(AND_DELAY) and0 = select_bar & in0;
assign #(AND_DELAY) and1 = select & in1;

// `logic` keyword for out was declared up top.
assign  #(OR_DELAY) out = and0 | and1;

// just for the waveforms
logic correct_out;
always_comb correct_out = select ? in1 : in0;


endmodule