`timescale 1ns/1ps
`default_nettype none
module multiplier(clk, rst, ready_i, valid_i, ready_o, valid_o, a, b, product);
// NOTE - this is an unsigned multiplier!!! Signed Multipliers require a little more logic to get the output signs correct.

parameter N = 8;
input wire clk, rst;
input wire valid_i;
output logic ready_i;
output logic valid_o;
input wire ready_o;

input wire [N-1:0] a, b;
output logic [2*N-1:0] product;
logic [N-1:0] valid_a, valid_b; // Stores a and b in case the main module changes them while this module is computing.

typedef enum logic [1:0] {IDLE, COMPUTING, DONE, ERROR} state_t;
state_t state, next_state;

logic [N-1:0] counter;
logic compute_done, shortcut, a_is_zero, b_is_zero, a_is_one, b_is_one;

// Handle special cases where we can know the answer instantly.
always_comb begin: shortcut_logic
  a_is_zero = (a == 0);
  b_is_zero = (b == 0);
  a_is_one = (a == 1);
  b_is_one = (b == 1);
  // This comb output is used by the FSM to skip straight to DONE.
  shortcut = valid_i & |{a_is_zero, b_is_zero, a_is_one, b_is_one};
end

logic [N*N-1:0] shortcut_mux;
always_comb begin : shortcut_mux_logic
  if(a_is_zero | b_is_zero) begin
    shortcut_mux = 0;
  end else if(a_is_one) begin
    shortcut_mux = {{N {1'b0}}, b };
  end else if (b_is_one | (state==IDLE)) begin
    // If b is one, or if 
    shortcut_mux = {{N {1'b0}}, a };
  end else begin
    shortcut_mux ={ {N-1 {1'b0}},  product + valid_a};
  end
end

always_comb begin: hand_shake_comb_logic
  valid_o = (state == DONE);
  ready_i = (state == IDLE);
end

always_ff @(posedge clk) begin : main_fsm
  if(rst) begin
    state <= IDLE;
    counter <= 0;
    valid_a <= 0;
    valid_b <= 0;
    product <= 0;
  end
  else begin
    case (state)
      IDLE: begin
        if(valid_i) begin
          // Save a and b in case the main unit changes them after this cycle.
          valid_a <= a;
          valid_b <= b;
          product <= shortcut_mux;
          counter <= b;
          state <= shortcut ? DONE : COMPUTING;
        end
      end
      COMPUTING: begin
        counter <= counter - 1;
        if(counter == 1) begin
          state <= DONE;
        end
        else begin
          product <= shortcut_mux;
        end
      end
      DONE : begin
        if(ready_o) state <= IDLE;
      end
      default state <= ERROR;
    endcase
  end
end

endmodule
