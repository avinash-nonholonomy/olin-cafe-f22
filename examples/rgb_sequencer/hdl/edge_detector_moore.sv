/*
An alternate implementation of an edge detector with Moore outputs (only a function of state).
*/

module edge_detector_moore(clk, rst, in, positive_edge, negative_edge);

input wire clk, rst, in;
output logic positive_edge, negative_edge;

enum logic [1:0] {S_LOW, S_POSITIVE_EDGE, S_HIGH, S_NEGATIVE_EDGE} state;


endmodule