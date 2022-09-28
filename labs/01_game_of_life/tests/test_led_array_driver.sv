`timescale 1ns / 1ps
`default_nettype none

`define SIMULATION

module test_led_array_driver;

  parameter N = 3;

  logic ena;
  logic [N*N-1:0] cells;

  logic [$clog2(N):0] x;
  
  wire [N-1:0] rows;
  wire [N-1:0] cols;
  task print_cells();
    for(int i = N-1; i >= 0; i = i - 1) begin
      $display("%b", (cells >> N*i) & {N{1'b1}});
    end
  endtask

  led_array_driver #(.ROWS(N), .COLS(N), .N(N))
  UUT(
    .ena(ena), .cells(cells), .x(x), .rows(rows), .cols(cols)
  );

  led_array_model #(.N(N)) LED_ARRAY_MODEL(
    .rows(rows), .cols(cols)
  );
  /*
    Initial blocks are one of the few things in Verilog that actually
    executes sequentially like normal code, and runs at the top of a 
    simulation. This can sometimes work in synthesis... but it's much
    better practice to use proper synchronous reset logic instead!
  */
  initial begin
    // Collect all internal variables for waveforms.
    $dumpfile("led_array_driver.fst");
    $dumpvars(0, UUT);

    // Initialize modules input.
    ena = 0;
    cells = -1; // -1 in two's complement is N'b111...111! So it's a great way to set all the bits of a bus to 1.
    x = 0;

    // One form of testbench (great for combinational logic) is to change inputs, put a brief delay to let the simulator update logic, then check the output values and make sure that they make sense.
    #1;
    if ((rows !== 0) || (cols !== 0)) begin
      $error("When ena is 0 rows and cols should be all zero, are %b and %b.", rows, cols);
    end
    ena = 1;
/* SOLUTION CODE START */
// `define GENERATE_ROW_COL_DECODERS
`ifdef GENERATE_ROW_COL_DECODERS
    // Check that the row/column decoder masks look okay. Technically we could
    // use generate statements to make this test easier, but it's often way 
    // way way easier to generate some simple verilog via a scripting language
    // like python:

    // print("\n".join([f'$display("Column Mask[%02d] = %b", {i}, UUT.column_masks[{i+1}*N*N-1:{i}*N*N]);' for i in range(8)]))
    $display("Column Mask[%02d] = %b", 0, UUT.column_masks[1*N*N-1:0*N*N]);
    $display("Column Mask[%02d] = %b", 1, UUT.column_masks[2*N*N-1:1*N*N]);
    $display("Column Mask[%02d] = %b", 2, UUT.column_masks[3*N*N-1:2*N*N]);
    $display("Column Mask[%02d] = %b", 3, UUT.column_masks[4*N*N-1:3*N*N]);
    $display("Column Mask[%02d] = %b", 4, UUT.column_masks[5*N*N-1:4*N*N]);
    $display("Column Mask[%02d] = %b", 5, UUT.column_masks[6*N*N-1:5*N*N]);
    $display("Column Mask[%02d] = %b", 6, UUT.column_masks[7*N*N-1:6*N*N]);
    $display("Column Mask[%02d] = %b", 7, UUT.column_masks[8*N*N-1:7*N*N]);
`endif
    
    /* Exhuastively testing all possible variations of the input is only viable
       when the input set is small. For a 5x5 grid you'd need to test 2^25
       inputs (33 million!). Your computer can simulate that in a few minutes,
       but it's impossible to scan through that by hand and validate if it's 
       working or not.

       Professionally, you usually spend a lot of time writing a testbench that
       is smart enough to find errors for you... or you can try to be clever
       and test just a reasonable subset of the inputs, cross your fingers,
       and move on!

       In this case, let's just test one LED of the array at a time. If we can
       do that, theoretically we can light any of them.
    */
/* SOLUTION CODE END */
    $display("Testing an %2dx%2d LED array driver.", N, N);
    $display("(i, j), x | cells | rows | cols ");
    for (int i = 0; i < N; i = i + 1) begin
      for (int j = 0; j < N; j = j + 1) begin
        $display();
        $display("only led (%2d, %2d) should be on", i, j);
        for (x = 0; x < N; x = x + 1) begin
          cells = 0;
          cells[N*j + i] = 1'b1;
          #1 $display("  %2d | 0x%h | %b | %b", x, cells, rows, cols);
          LED_ARRAY_MODEL.print_status();
        end
      end
    end
    $finish;
    $display("Exhaustive test.");
    
    for (int i = 0; i < 2**(N*N); i = i + 1) begin
      for (x = 0; x < N; x = x + 1) begin
        cells = i[N*N-1:0];
        #1;
        $display("cells | x | rows | cols ");
        $display("%d/%5d |%2d | %b | %b",cells, 2**(N*N)-1, x, rows, cols);
        LED_ARRAY_MODEL.print_status();
      end
      cells = cells + 1;
    end
    $finish; // End the simulation.
	end

endmodule
