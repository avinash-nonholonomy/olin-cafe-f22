`timescale 1ns/1ps
`default_nettype none

module adder_1(a, b, Cin, S, Cout);
    input wire a, b, Cin;
    output logic S, Cout;

    always_comb begin
        S = a ^ b ^ Cin;
        Cout = (a & b) | (a & Cin) | (b & Cin);
    end

endmodule
