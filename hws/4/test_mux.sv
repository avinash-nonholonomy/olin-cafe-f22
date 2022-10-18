`timescale 1ns/1ps
`default_nettype none

`define SIMULATION

module test_mux;
    logic [4:0] select;
    logic [31:0] d;
    logic [31:0] y_32, result;

    mux32 UUT_32(.select(select), .in00(d[0]), .in01(d[1]), .in02(d[2]), .in03(d[3]), .in04(d[4]), .in05(d[5]), .in06(d[6]), .in07(d[7]), .in08(d[8]), .in09(d[9]), .in10(d[10]), .in11(d[11]), .in12(d[12]), .in13(d[13]), .in14(d[14]), .in15(d[15]), .in16(d[16]), .in17(d[17]), .in18(d[18]), .in19(d[19]), .in20(d[20]), .in21(d[21]), .in22(d[22]), .in23(d[23]), .in24(d[24]), .in25(d[25]), .in26(d[26]), .in27(d[27]), .in28(d[28]), .in29(d[29]), .in30(d[30]), .in31(d[31]), .out(y_32));

    initial begin
        $dumpfile("mux_test.vcd");
        $dumpvars(0, UUT_32);

        $display("\nTesting 32:1 MUX");
        d = 0;
        for (int j = 0; j < 32; j++) begin
            d = $urandom%4294967295; // largest 32 bit integer
        end

        for (int i = 0; i < 32; i++) begin
            select = i;
            result = d[i];
            #1
            if (y_32 !== result) begin
                $error("%4b obtained 0x%8x, expected 0x%8x", select, y_32, result);
            end
        end
        $finish;
    end
endmodule