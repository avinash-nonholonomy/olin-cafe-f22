`timescale 1ns/1ps
`default_nettype none

`define SIMULATION

module test_adder_1;
    logic a;
    logic b;
    logic Cin;
    wire S, Cout;

    adder_1 UUT(a, b, Cin, S, Cout);

    initial begin

        $dumpfile("adder_1.fst");
        $dumpvars(0, UUT);
        $display("a b Cin  |    S Cout");
        for (int i = 0; i < 8; i = i + 1) begin
            a = i[2];
            b = i[1];
            Cin = i[0];
            #1 $display("%1b %2b %3b | %4b %5b", a, b, Cin, S, Cout);
        end

        $finish;
    end
endmodule