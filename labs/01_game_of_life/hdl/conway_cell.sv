`default_nettype none
`timescale 1ns/1ps

module conway_cell(clk, rst, ena, state_0, state_d, state_q, neighbors);
    input wire clk;
    input wire rst;
    input wire ena;

    input wire state_0;
    output logic state_d; // NOTE - this is only an output of the module for debugging purposes. 
    output logic state_q;

    input wire [7:0] neighbors; //the cells that are neighbors for state_0's cell

    wire c0, c1, c2, c3, c4, c5, c6;
    wire [3:0] s0, s1, s2, s3, s4, s5;
    logic c_out;
    logic [3:0] sum;
    
    adder_n #(.N(4)) adder0({3'b0, neighbors[0]}, {3'b0, neighbors[1]}, 1'b0, s0, c0);
    adder_n #(.N(4)) adder1(s0,{3'b0, neighbors[2]}, 1'b0, s1, c1);
    adder_n #(.N(4)) adder2(s1,{3'b0, neighbors[3]}, 1'b0, s2, c2);
    adder_n #(.N(4)) adder3(s2,{3'b0, neighbors[4]}, 1'b0, s3, c3);
    adder_n #(.N(4)) adder4(s3,{3'b0, neighbors[5]}, 1'b0, s4, c4);
    adder_n #(.N(4)) adder5(s4,{3'b0, neighbors[6]}, 1'b0, s5, c5);
    adder_n #(.N(4)) adder6(s5,{3'b0, neighbors[7]}, 1'b0, sum, c6);

    always_comb begin
        //c_out = c0|c1|c2|c3|c4|c5|c6; no c_out needed because sum will never be above 8
        state_d = (state_q&(sum==4'd2|sum==4'd3)) | (~state_q&(sum==4'd3));
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state_q=state_0;
        end
        else begin
            if (ena) begin
                state_q <= state_d;
            end
        end
    end

endmodule
