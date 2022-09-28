`timescale 1ns / 1ps
`default_nettype none

`define SIMULATION

module test_conway_cell;

logic clk, rst, ena, state_0;
logic [7:0] neighbors;
wire state_d, state_q;

conway_cell UUT(
  .clk(clk), .rst(rst), .ena(ena),
  .neighbors(neighbors),
  .state_0(1'b0), .state_d(state_d), .state_q(state_q)
);

int errors = 0;

always #5 clk = ~clk; // Toggle a clock every 5 time units.


/*
  Initial blocks are one of the few things in Verilog that actually
  executes sequentially like normal code, and runs at the top of a 
  simulation. This can sometimes work in synthesis... but it's much
  better practice to use proper synchronous reset logic instead!
*/
initial begin
  // Initialize modules input.
  clk = 0;
  rst = 1; // Start reset in active state.
  ena = 1; // Not testing the ena function in this example (though you should try!)
  state_0 = 0;
  
  // Collect all internal variables for waveforms.
  $dumpfile("conway_cell.fst");
  $dumpvars(0, UUT);
  
  // Wait at least one clock cycle before deasserting reset.
  repeat (2) @(posedge clk);
  rst = 0;
  
  $display("neighbors : d : q");
  for (int i = 0; i < 255; i = i + 1) begin
    // Change inputs at a negative edge to avoid setup issues.
    @(negedge clk);
    neighbors = i[7:0];
    @(posedge clk);
    $display("%b : %b: %b", neighbors, state_d, state_q);
  end

  #10;

  if(errors > 0) $display("FAIL: Had %d errros.", errors);
  else $display("Test finished successfully!");
  $finish; // End the simulation.
end


// behavioural checker
logic [3:0] living_neighbors;
logic correct_d;
always @(neighbors) begin
  #1; 
  living_neighbors = 0;
  for(int i = 0; i < 8; i = i + 1) begin
    living_neighbors = living_neighbors + {3'd0, neighbors[i]};
  end
  
  if (state_q) begin // alive
    case(living_neighbors)
      4'd2, 4'd3 : correct_d = 1;
      default: correct_d = 0;
    endcase
  end else begin // dead
    if (living_neighbors == 3) correct_d = 1;
    else correct_d = 0;
  end

  if(state_d !== correct_d) begin
    $display("@%t: ERROR: living_neighbors = %d, state_d should be %b, is %b",
      $time, living_neighbors, correct_d, state_d);
    errors = errors + 1;
  end
end

endmodule
