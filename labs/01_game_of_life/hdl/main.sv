`default_nettype none // Overrides default behaviour (in a good way)

`include "initial_conditions.sv"

/*
An example to get us started with FPGA programming, mapping io,
and using the Digilent CMod-A7-15T board, and combinational logic.

YOU DO NOT NEED TO EDIT ANYTHING IN THIS FILE, but you should read through it
completely to understand how it works.

Based on this [programming guide](https://digilent.com/reference/learn/programmable-logic/tutorials/cmod-a7-programming-guide/start).

NOTE - this example includes advanced SystemVerilog to show you a more 
professional flavor (and to make the demo scale well). If you don't understand 
it all, that's okay - the goal is to learn by exposure! The only HDL you will 
have to write should mostly test your combinational logic skills and show you
how to instantiate, enable, and reset simple flip flops.

Based on the [Luckylight](https://cdn-shop.adafruit.com/datasheets/454datasheet.pdf) 
display modules, available from [adafruit](https://www.adafruit.com/product/454)

*/

// `define DISABLE_GAME // Uncomment this to degug your LED driver without the game running.

module main(clk, buttons, leds, rgb, cols, rows);
//Module I/O and parameters
parameter game_divider = 23; // A clock divider parameter - 12 MHz / 2^23 is about 1 Hz (human visible speed).
parameter display_divider = 12; // 12 to 17 are good values. Need to PWM the LEDs faster than the game clock.
parameter N = 8; // Size of the grid. Change this to 5 if you only built a 5x5 array!
parameter M = N + 2; // Size of the grid, plus a border all around (makes wiring way easier).
// Parameter checks.
initial if (N < 3) $error("N has to be >= 3 to make for interesting patterns.");
initial if (M !== (N+2)) $error("M must N+2=%d, not %d", N+2,M);  

input wire clk;
input wire [1:0] buttons;
logic rst; always_comb rst = buttons[0]; // Use button 0 as a reset signal.
output logic [1:0] leds;
output logic [2:0] rgb;
output wire [N-1:0] cols;
output wire [N-1:0] rows;

logic [game_divider:0] game_counter;
logic [display_divider:0] display_counter;
logic rst_game; always_comb rst_game = buttons[0] | buttons[1];
logic step_game;
logic [$clog2(N):0] x;

wire [M*M-1:0] bordered_cells_q; // Eventually we will drop the "q" and "d", but for now this will help us separate the input and output side of each flip flop.
wire [M*M-1:0] bordered_cells_d; 
logic [M*M-1:0] bordered_cells_0; // Initial cell state.

logic [N*N-1:0] cells_q; // A remapped version of cells_q without the border 
logic [N*N-1:0] cells_0; // to make wiring the led driver easier.

// Some example logic to make sure that you've flashed the FPGA. One of the
// worst problems to debug is when you aren't sure that the FPGA is updating
// its HDL. If you are worried about that, make a simple change to this block
// to make sure that the FPGA is updating!
always_comb begin : io_logic 
    leds[0] = buttons[0] ^ buttons[1];
    leds[1] = buttons[0] & buttons[1];
    
    rgb[0] = ~( buttons[0] & ~buttons[1]);
    rgb[1] = ~(~buttons[0] &  buttons[1]);
    rgb[2] = ~( buttons[0] &  buttons[1]);
end

// Instantiate the LED Driver Module
led_array_driver #(.ROWS(N), .COLS(N), .N(N)) LED_DRIVER (
  .ena(1'b1),
`ifdef DISABLE_GAME
  .cells(cells_0),
`else
  .cells(cells_q),
`endif
  .x(x),
  .rows(rows[N-1:0]),
  .cols(cols[N-1:0])
);

// Initialize the grid. 
`define MANUAL_INITIAL_CONDITION // Uncomment to use the second clause for different initial conditions!
always_comb begin 
`ifndef MANUAL_INITIAL_CONDITION
  // This sets up the "blinker" oscillator in the center of a grid.
  bordered_cells_0[M*M-1:M*M/2+2] = 0;
  bordered_cells_0[M*M/2+1:M*M/2-1] = 3'b111;
  bordered_cells_0[M*M/2-2:0] = 0;
`else // MANUAL_INITIAL_CONDITION
  // You will need to update the constants and size based on the size M.
  if (N == 5) begin
    bordered_cells_0 = `INIT_5x5_PERIOD2_BLINKER;
  end else if (N == 8) begin
    // Last implementation is what counts.
    // bordered_cells_0 = `INIT_8x8_GLIDER;
    // bordered_cells_0 = `INIT_8x8_ALTERNATING;     
  end else if (N==15) begin
    bordered_cells_0 = `INIT_13x13_PULSAR;
  end else begin
    bordered_cells_0 = {M*M {1'b1}};
  end
`endif // MANUAL_INITIAL_CONDITION
end

/*
Instantiating N*N conway_cells: 

We want to create an NxN array of modules that will store the alive (1) or
dead (0) state for each cell. 

Unfortunately, Verilog doesn't have support for 2D arrays: 2D arrays require
a lot more hardware! (They are technically memories, not registers, we'll 
learn more about that later).

The common way to get around this limitation is to "squash" a 2x2 structure
into a linear wire/ that has N*N elements. Then we can "index" it 
differently based on the size of the grid. e.g. for a 5x5 grid you can create
a logic [24:0] register and then index x,y coordinates with a single number
like so:

--------------------------
| 20 | 21 | 22 | 23 | 24 | 
| 15 | 16 | 17 | 18 | 19 | 
| 10 | 11 | 12 | 13 | 14 | 
|  5 |  6 |  7 |  8 |  9 | 
|  0 |  1 |  2 |  3 |  4 |
--------------------------

Generally, to access an index (i,j) in a square grid, the index is N*j + i.

Last but not least, instead of creating an NxN set of wires it makes things 
much easier to do a (N+2)x(N+2) set to have easily connectable wires for the
border elements of the grid. That's why the parameter M is set to N+2;
*/



/*
  Generate blocks are how you can describe many instances of hardware blocks
  with simple scripting style primitives. It's not too easy to use, so 
  in some cases it's faster and easier to just write a script in another
  language (e.g. python) and then copy + paste that to your verilog file.

  This block creates one instance of your conway_cell module per point in the 
  grid.

  Note that the logic has to really consider all the conditions since unlike
  software all of this exists simultaneously! We have to be very careful
  to create only what we need and to make sure that all the cells on the
  border have the appropriate boundary conditions set.
*/

function int cell_index(int i, int j);
  // Helper function to compute the number of the cell module based on 
  // its x and y coordinate, accounting for a border of zero'd out cells.
  cell_index = M*j + i;
endfunction


generate
  genvar i;
  genvar j;
  for (i = 0; i < M; i = i + 1) begin : cells_x
    for (j = 0; j < M; j = j + 1) begin : cells_y
      // Only instantiate cells on the inside of the border
      if ( (i > 0) && (i < (M-1)) && (j > 0) && (j < (M-1)) ) begin
        conway_cell CELL(
          .clk(clk), .rst(rst_game), .ena(step_game),
          .neighbors({
            bordered_cells_q[cell_index(i-1, j-1)],
            bordered_cells_q[cell_index(i-1, j  )],
            bordered_cells_q[cell_index(i-1, j+1)],
            bordered_cells_q[cell_index(i  , j+1)],
            bordered_cells_q[cell_index(i+1, j+1)],
            bordered_cells_q[cell_index(i+1, j  )],
            bordered_cells_q[cell_index(i+1, j-1)],
            bordered_cells_q[cell_index(i  , j-1)]
          }),
          .state_0(bordered_cells_0[cell_index(i, j)]),
          .state_d(bordered_cells_d[cell_index(i, j)]),
          .state_q(bordered_cells_q[cell_index(i, j)])
        );
      end else begin // on a border
        assign bordered_cells_q[cell_index(i,j)] = bordered_cells_0[cell_index(i,j)];
        assign bordered_cells_d[cell_index(i,j)] = 0;
      end
    end
  end
  // A bit of verilog magic to "unborder" cells_q to make wiring the 
  // LED driver easier.
  for (i = 0; i < N; i = i + 1) begin
    always_comb begin
        cells_q[N*(i+1)-1:N*i] = bordered_cells_q[M*(i+2)-2:M*(i+1)+1];
        cells_0[N*(i+1)-1:N*i] = bordered_cells_0[M*(i+2)-2:M*(i+1)+1];
    end
  end
endgenerate

// Here's some clock divider logic to make this run slow enough for humans
// to see. The default parameters dived by 2^20 (powers of two are easier)
// which for our input 12MHz clock results in about a 11 Hz update rate.
// If you want it to run slower or faster you can increase or decrease the 
// divider parameter (larger is slower).
parameter faster_divider = 15;

always_ff @(posedge clk) begin : clocks_and_dividers // You can label any begin/end block, can help with debugging.
  if (rst) begin
      game_counter <= 0;
      display_counter <= 0;
      x <= 0;
  end
  else begin
      if (game_counter[game_divider]) begin
        game_counter <= 0;
      end
      else begin 
        game_counter <= game_counter + 1;
      end

      if(display_counter[display_divider]) begin
        display_counter <= 0;
        if(x >= (N-1)) begin
          x <= 0;
        end
        else begin
          x <= x + 1;
        end
      end
      else begin
        display_counter <= display_counter + 1;
      end
      
  end
end  
`ifdef SIMULATION
always_comb step_game = 1; // Run at full speed if simulating.
`else
always_comb step_game = game_counter[game_divider]; // Run at slow human eye speeds in real life.
`endif // SIMULATION


endmodule

`default_nettype wire // reengages default behaviour, needed when using 
                      // other designs that expect it.