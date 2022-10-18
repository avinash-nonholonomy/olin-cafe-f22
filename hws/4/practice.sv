`timescale 1ns/1ps
`default_nettype none

// module for d flip flop with reset
module flipflop(d, q, clk, rst);
    output logic q;
    input wire d, clk, rst;
    always @(posedge clk) begin
        if (rst == 1'b1) // if not at restart
            q = 1'b0;
        else
            q = d;
    end
endmodule

module practice(rst, clk, ena, seed, out);

input wire rst, clk, ena, seed;
output logic out;
logic ff_input[1:0]; // ff_input[0] = XOR_out
wire ff_output[1:0];

flipflop flipflop_0(
    .clk (clk),
    .rst (rst),
    .d (ff_input[1]),
    .q (ff_output[0])
);

flipflop flipflop_1(
    .clk (clk),
    .rst (rst),
    .d (ff_output[0]),
    .q (ff_output[1])
);

flipflop flipflop_2(
    .clk (clk),
    .rst (rst),
    .d (ff_output[1]),
    .q (out)
);

always_comb ff_input[0] = ff_output[0] ^ ff_output[1];
always_comb ff_input[1] = ena ? seed : ff_input[0];

endmodule
