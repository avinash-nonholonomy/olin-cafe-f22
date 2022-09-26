`timescale 1ns/1ps
`default_nettype none

module mux(in0, in1, select, out);

input in0, in1, select;
output logic out; // the last or logic

// Below is "STRUCTURAL" verilog - explicit hardware

// inverters: ~
logic select_bar, in0_bar, in1_bar;
always_comb select_bar = ~select;
always_comb in0_bar = ~in0;
always_comb in1_bar = ~in1;


// ands 
logic product0, product1, product2, product3;
always_comb product0 = select_bar & in0 & in1_bar;
always_comb product1 = select_bar & in0 & in1;
always_comb product2 = select & in0_bar & in1;
always_comb product3 = select & in0 & in1;


// logic was declared up top.
always_comb out = product0 | product1 | product2 | product3;




endmodule