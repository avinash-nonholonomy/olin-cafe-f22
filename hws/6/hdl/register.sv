`timescale 1ns/1ps
`default_nettype none

/*
A synchronous register (batch of flip flops) with rst higher priority 
than ena. Note this is structural, you can use ifs/elses for registers
unless explicitly told not to. 
*/

module register(clk, ena, rst, d, q);

parameter N = 1;
parameter RESET = 0; // Value to reset to.

input wire clk, ena, rst;
input wire [N-1:0] d;
output logic [N-1:0] q;

logic [N-1:0] internal_d;
always_comb internal_d = rst ? RESET : (ena ? d : q);

always_ff @(posedge clk) begin
  q <= internal_d;
end

endmodule
