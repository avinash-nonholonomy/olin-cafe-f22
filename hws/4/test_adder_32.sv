`timescale 1ns/1ps
`default_nettype none

`define SIMULATION

module test_adder_32;
    logic [31:0] a;
    logic [31:0] b;
    logic Cin;
    wire Cout;
    logic [31:0] S;
    logic [31:0] y;

    adder_n UUT32(a, b, Cin, y, Cout);

    initial begin

        $dumpfile("adder_32.vcd");
        $dumpvars(0, UUT32);
        $display("32-Bit Adder Test");

        for (int i = 0; i < 32; i = i + 1) begin
            for (int j = 0; j < 32; j = j + 1) begin
                a = 1 << i;
                b = 1 << j;
                Cin = 0;
                S = a + b;
                #1
                if (y !== S) begin
                    $error("0x%8x + 0x%8x (expected 0x%8x)", a, b, y, S);
                end
            end
        end

        for (int i = 0; i < 128; i = i + 1) begin
            a = $urandom%4294967295; // largest 32-bit unsigned integer
            b = $urandom%4294967295;
            Cin = 0;
            S = a + b;
            #1
            if (y !== S) begin
                $error("0x%8x + 0x%8x (expected 0x%8x", a, b, y, S);
            end
            $display("%1b %2b %3b | %4b %5b", a, b, Cin, S, Cout);  // displays table for randomly generated values
        end

        a = 1<<31;
        b = 1<<31;
        #1
        if (Cout != 1) begin
            $error("Carry out doesn't work");
        end
        $finish;
    end
endmodule