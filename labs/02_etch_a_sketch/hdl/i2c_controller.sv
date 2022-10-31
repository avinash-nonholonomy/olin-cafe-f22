`timescale 1ns / 100ps
`default_nettype none

`include "i2c_types.sv"

// TI has a good reference on how i2c works: https://training.ti.com/sites/default/files/docs/slides-i2c-protocol.pdf
// In this guide the "main" device is called the "controller" and the "secondary" device is called the "target".
module i2c_controller(
  clk, rst,
  scl, sda, mode,
  i_ready, i_valid, i_addr, i_data,
  o_ready, o_valid, o_data
);

parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ);
parameter I2C_CLK_HZ = 100_000; // Must be <= 400kHz
parameter DIVIDER_COUNT = CLK_HZ/I2C_CLK_HZ/2;  // Divide by two necessary since we toggle the signal
`ifdef SIMULATION
parameter COOLDOWN_CYCLES = 12; // Wait between transactions (can help smooth over issues with ACK or STOP or START conditions).
`else
parameter COOLDOWN_CYCLES = 120; // Wait between transactions (can help smooth over issues with ACK or STOP or START conditions).
`endif // SIMULATION

//Module I/O and parameters
input wire clk, rst; // standard signals
output logic scl; // i2c signals
inout wire sda;

// Create a tristate for the sda input/output pin.
// Tristates let you go into "high impedance" mode which allows the secondary device to use the same wire to send data back!
// It's your job to drive sda_oe (output enable) low (combinationally) when it's the secondary's turn to talk.
logic sda_oe; // output enable for the sda tristate
logic sda_out; // input to the tristate
assign sda = sda_oe ? sda_out : 1'bz; // Needs to be an assign, not always_comb for icarus verilog.

input wire i2c_transaction_t mode; // See i2c_types.sv, 0 is WRITE and 1 is READ
output logic i_ready; // ready/valid handshake signals
input wire i_valid;
input wire [6:0] i_addr; // the address of the secondary device.
input wire [7:0] i_data; // data to be sent on a WRITE opearation
input wire o_ready; // unused (for now)
output logic o_valid; // high when data is valid. Should stay high until a new i_valid starts a new transaction.
output logic [7:0] o_data; // the result of a read transaction (can be x's on a write).

// Main FSM logic
i2c_state_t state; // see i2c_types for the canonical states.

logic [$clog2(DIVIDER_COUNT):0] clk_divider_counter;
logic [$clog2(COOLDOWN_CYCLES):0] cooldown_counter; // optional, but recommended - have the system wait a few clk cycles before i_ready goes high again - this can make debugging STOP/ACK/START issues way easier!!!
logic [3:0] bit_counter;
logic [7:0] addr_buffer;
logic [7:0] data_buffer;

always_ff @(posedge clk) begin : i2c_fsm  
  if(rst) begin
    clk_divider_counter <= DIVIDER_COUNT-1;
    scl <= 1;
    bit_counter <= 0;
    o_data <= 0;
    o_valid <= 0;
    i_ready <= 1;
    state <= S_IDLE;
  end else begin // out of reset
  end
end


endmodule
